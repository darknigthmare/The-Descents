extends Node3D
class_name DescentContinuationPresentation
## Authored A24/A23 dressing and collision-driven escort. This node never
## advances itself: the mission owns its clock, pause and receipt decisions.

const Routes = preload("res://scripts/route_catalog.gd")
const NAMES: Array[String] = ["Léa Mercier", "Idris Kaci"]
const STARTS: Array[Vector3] = [Vector3(7.7, 0.06, -8.1), Vector3(9.2, 0.06, -8.1)]
const RECEIVING: Array[Vector3] = [Vector3(6.6, 6.06, -3.9), Vector3(8.0, 6.06, -3.9)]
const ESCORT_SPEED: float = 1.5
const MAX_LEAD_DISTANCE: float = 5.0
const REMANENCE_DURATION: float = 14.0

var chapter_active: bool = false
var escort_state: String = "waiting"
var people: Array[CharacterBody3D] = []
var figures: Array[Node3D] = []
var paths: Array = []
var path_indices: Array[int] = [0, 0]
var arrived: Array[bool] = [false, false]
var walk_clocks: Array[float] = [0.0, 0.0]
var duo_interaction: Node3D
var visual_instruction: Label3D
var remanence: Node3D
var remanence_elapsed: float = 0.0
var remanence_count: int = 0
var remanence_gap: float = 0.0
var remanence_started: bool = false
var _world: Node3D

func build(world: Node3D) -> void:
	_world = world
	name = "CongressAndNacreExhibition"
	set_process(false)
	set_physics_process(false)
	_build_congress(world.get_node("Floor24"))
	_build_exhibition(world.get_node("Floor23"))
	_build_escort()
	_build_receiving()
	_update_sign()

func set_escort_state(state: String) -> void:
	if state not in ["waiting", "following", "received"]:
		return
	var changed: bool = state != escort_state
	escort_state = state
	if state == "received" and changed:
		# Only restoration or a verified receipt requests this stable placement.
		# During following/waiting, no position or path cursor is ever reset.
		for index in range(people.size()):
			people[index].global_position = RECEIVING[index]
			people[index].velocity = Vector3.ZERO
			arrived[index] = true
			path_indices[index] = paths[index].size()
			figures[index].rotation.y = PI
	if is_instance_valid(duo_interaction):
		duo_interaction.set_meta("used", state == "received")
	_update_sign()

func advance(delta: float, player_position: Vector3, running: bool, allow_remanence: bool = true) -> void:
	if not running or not chapter_active or not is_finite(delta) or delta <= 0.0 or not player_position.is_finite():
		return
	var step: float = minf(delta, 0.05)
	for index in range(people.size()):
		_advance_person(index, step, player_position)
	if is_instance_valid(duo_interaction):
		duo_interaction.set_meta("floor", 25 if people[0].global_position.y >= 5.65 else 24)
	_update_sign(player_position)
	if allow_remanence:
		_advance_remanence(step, player_position)
	elif is_instance_valid(remanence):
		remanence.hide()

func both_arrived() -> bool:
	if people.size() != 2 or not arrived[0] or not arrived[1]:
		return false
	for index in range(people.size()):
		var body: CharacterBody3D = people[index]
		if body.global_position.distance_to(RECEIVING[index]) > 0.25 or absf(body.velocity.y) > 0.15 or not _has_support(body):
			return false
	return true

func snapshot() -> Dictionary:
	var positions: Array[Vector3] = []
	for body: CharacterBody3D in people:
		positions.append(body.global_position)
	return {"escort_state": escort_state, "positions": positions, "path_indices": path_indices.duplicate(), "arrived": arrived.duplicate(), "both_arrived": both_arrived(), "remanence_count": remanence_count, "remanence_elapsed": remanence_elapsed, "remanence_visible": is_instance_valid(remanence) and remanence.visible}

func _advance_person(index: int, delta: float, player_position: Vector3) -> void:
	var body: CharacterBody3D = people[index]
	var move_allowed: bool = escort_state == "following" and not arrived[index] and body.global_position.distance_to(player_position) <= MAX_LEAD_DISTANCE
	# Single-file separation on the two narrow flights; bodies still collide
	# with the real world, but do not trap the player or push one another.
	if index == 1 and not arrived[0] and path_indices[1] >= 2 and body.global_position.distance_to(people[0].global_position) < 1.15:
		move_allowed = false
	var planar: Vector3 = Vector3.ZERO
	if move_allowed:
		var target: Vector3 = paths[index][path_indices[index]]
		var offset: Vector3 = Vector3(target.x - body.global_position.x, 0.0, target.z - body.global_position.z)
		if offset.length() < 0.12 and absf(body.global_position.y - target.y) < 0.24 and _has_support(body):
			path_indices[index] += 1
			if path_indices[index] >= paths[index].size():
				arrived[index] = true
			else:
				target = paths[index][path_indices[index]]
				offset = Vector3(target.x - body.global_position.x, 0.0, target.z - body.global_position.z)
		if not arrived[index]:
			planar = offset.normalized() * minf(ESCORT_SPEED, offset.length() / maxf(delta, 0.001))
	body.velocity.x = planar.x
	body.velocity.z = planar.z
	body.velocity.y = 0.0 if body.is_on_floor() else body.velocity.y - 16.0 * delta
	body.move_and_slide()
	if planar.length() > 0.01:
		figures[index].rotation.y = lerp_angle(figures[index].rotation.y, atan2(-planar.x, -planar.z), minf(1.0, delta * 8.0))
		walk_clocks[index] += delta * 7.0
	_world._pose_human_walk(figures[index], walk_clocks[index], clampf(planar.length() / ESCORT_SPEED, 0.0, 1.0))
	if planar.length() <= 0.01 and escort_state != "received":
		# An open hand is also readable with audio disabled.
		figures[index].get_node("RightArm").rotation.x = -0.9 if index == 0 else -0.2

func _has_support(body: CharacterBody3D) -> bool:
	var origin: Vector3 = body.global_position + Vector3(0, 0.12, 0)
	var query: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(origin, origin + Vector3(0, -0.40, 0), 1, [body.get_rid()])
	var hit: Dictionary = get_world_3d().direct_space_state.intersect_ray(query)
	return not hit.is_empty() and Vector3(hit.get("normal", Vector3.ZERO)).y > 0.65

func _update_sign(player_position: Vector3 = Vector3.INF) -> void:
	if not is_instance_valid(visual_instruction):
		return
	if escort_state == "received":
		visual_instruction.text = "LÉA + IDRIS\nREÇUS AU REFUGE 25"
	elif escort_state == "following":
		var close: bool = player_position.is_finite() and people[0].global_position.distance_to(player_position) <= MAX_LEAD_DISTANCE and people[1].global_position.distance_to(player_position) <= MAX_LEAD_DISTANCE
		visual_instruction.text = "SUIVEZ LES REPÈRES VERTS\nGardez le groupe à moins de 5 m" if close else "LE GROUPE ATTEND\nRapprochez-vous — signes visuels"
	else:
		visual_instruction.text = "LÉA + IDRIS — EN ATTENTE\nE  Donner / reprendre le signal visuel"

func _build_escort() -> void:
	for index in range(2):
		var body: CharacterBody3D = CharacterBody3D.new()
		body.name = "LeaMercier" if index == 0 else "IdrisKaci"
		body.collision_layer = 2
		body.collision_mask = 1
		body.floor_snap_length = 0.25
		var capsule: CapsuleShape3D = CapsuleShape3D.new()
		capsule.radius = 0.30
		capsule.height = 1.72
		var collider: CollisionShape3D = CollisionShape3D.new()
		collider.shape = capsule
		collider.position.y = 0.87
		body.add_child(collider)
		add_child(body)
		body.global_position = STARTS[index]
		var figure: Node3D = _world._human(body, Vector3.ZERO, _world.materials["green"] if index == 0 else _world.materials["cream"], false)
		people.append(body)
		figures.append(figure)
		var label: Label3D = _world._label(body, Vector3(0, 2.18, 0), NAMES[index], 26, Color("c5eee3"), 0.0055)
		label.name = "CivilianName"
		# A conference badge and an earpiece identify the roles without turning
		# hearing accessibility into an invented injury or loss of agency.
		_world._box(figure, Vector3(0.13, 1.15, -0.18), Vector3(0.12, 0.19, 0.02), _world.materials["white"])
		if index == 0:
			_world._sphere(figure, Vector3(0.17, 1.68, 0), Vector3(0.045, 0.06, 0.04), _world.materials["black_metal"])
		paths.append(_escort_path(index))
	duo_interaction = _world._interaction(people[0], Vector3.ZERO, "continuation_escort", "continuation_duo_24", 24, "Léa Mercier et Idris Kaci", "Établissez le contact visuel. Le groupe rejoint à pied le refuge 25 par l’escalier nord. E alterne suivre et attendre ; restez à proximité.")
	visual_instruction = _world._label(people[0], Vector3(0, 2.65, 0), "", 24, Color("b3e5d5"), 0.005, true)
	visual_instruction.name = "AccessibleEscortInstruction"

func _escort_path(index: int) -> Array[Vector3]:
	var path: Array[Vector3] = [Vector3(STARTS[index].x, 0.06, -4.5), Vector3(4.2, 0.06, -4.5), Vector3(-1.3, 0.06, -4.5)]
	var stair_points: Array = Routes.for_id("S25_24")["path_points"].duplicate()
	stair_points.reverse()
	for point: Vector3 in stair_points:
		path.append(point)
	path.append(Vector3(1.3, 6.06, -4.5))
	path.append(Vector3(4.2, 6.06, -4.5))
	path.append(RECEIVING[index])
	return path

func _build_receiving() -> void:
	var parent: Node3D = _world.get_node("Floor25")
	for position_value: Vector3 in RECEIVING:
		_world._box(parent, position_value + Vector3(0, -0.042, 0), Vector3(1.0, 0.025, 1.0), _world.materials["green"])
	_world._label(parent, Vector3(7.3, 8.6, -4.0), "ACCUEIL DU CONGRÈS\nREFUGE 25", 28, Color("a8e5cb"), 0.006, true)

func _build_congress(parent: Node3D) -> void:
	var m: Dictionary = _world.materials
	# The eastern auditorium is dense; the northern service foyer is a clear,
	# continuous escort route, visually distinct from Alex's west rappel.
	for row in range(4):
		for column in range(4):
			_world._chair(parent, Vector3(5.2 + column * 1.65, 0, 1.0 + row * 1.55), PI, m["blue"])
	_world._box(parent, Vector3(7.4, 0.18, 9.5), Vector3(8.0, 0.36, 3.2), m["wood"], true)
	var screen: MeshInstance3D = _world._box(parent, Vector3(7.3, 3.25, 8.7), Vector3(7.6, 2.5, 0.16), m["cream"], true)
	screen.rotation.z = -0.12
	screen.name = "StalledSuspendedScreen"
	_world._traversal_beam(parent, Vector3(3.7, 5.25, 8.7), Vector3(3.7, 4.65, 8.7), 0.04, m["metal"], false)
	_world._traversal_beam(parent, Vector3(10.8, 5.25, 8.7), Vector3(10.8, 4.20, 8.7), 0.04, m["metal"], false)
	_world._label(parent, Vector3(7.4, 3.25, 8.53), "PELAGOS\nHABITER LE BIEN-ÊTRE", 40, Color("17343e"), 0.011, false).rotation.y = PI
	_world._box(parent, Vector3(6.2, 1.05, 9.0), Vector3(0.85, 1.5, 0.7), m["dark"], true)
	_world._label(parent, Vector3(9.8, 2.5, 6.8), "ÉCRAN INSTABLE\nCONTOUR PAR LE FOYER", 23, Color("f0c284"), 0.006, true)
	# Translation booth, open towards the wide service foyer.
	_world._box(parent, Vector3(8.0, 1.6, -10.5), Vector3(6.1, 3.2, 0.18), m["wood"], true)
	_world._box(parent, Vector3(5.1, 1.6, -8.3), Vector3(0.18, 3.2, 4.2), m["wood"], true)
	_world._box(parent, Vector3(10.9, 1.6, -8.3), Vector3(0.18, 3.2, 4.2), m["wood"], true)
	_world._box(parent, Vector3(8.0, 0.9, -9.6), Vector3(4.5, 0.15, 0.9), m["metal"], true)
	for x: float in [6.5, 8.0, 9.5]:
		_world._box(parent, Vector3(x, 1.15, -9.6), Vector3(0.65, 0.08, 0.42), m["screen"])
	_world._label(parent, Vector3(8.0, 3.55, -9.9), "CABINE D’INTERPRÉTATION", 34, Color("c6e2e4"), 0.007, false)
	_world._light(parent, Vector3(8.0, 3.8, -7.5), Color("b6dfd5"), 1.1, 6.0)
	_world._label(parent, Vector3(-0.5, 2.9, -4.2), "25  ↑  REFUGE\nESCALIER DE SERVICE NORD", 25, Color("a6e5c7"), 0.0055, true)
	for x: float in [-0.8, 0.5, 2.0, 3.5, 5.0, 6.5]:
		_world._box(parent, Vector3(x, 0.022, -4.5), Vector3(0.55, 0.03, 0.12), m["lit_green"])
	# West reception lounge preserves the cross route to the lower rappel.
	for x: float in [-9.0, -6.3]:
		_world._cylinder(parent, Vector3(x, 0.65, 7.6), 0.65, 1.3, m["dark"], true)
		_world._cylinder(parent, Vector3(x, 1.34, 7.6), 0.95, 0.12, m["wood"])
	_world._label(parent, Vector3(-7.3, 3.6, 10.5), "NACRE\nCENTRE DE CONGRÈS", 52, Color("d4d9cf"), 0.010, false)

func _build_exhibition(parent: Node3D) -> void:
	var m: Dictionary = _world.materials
	var model: Node3D = _world._interaction(parent, Vector3(7.4, -6.0, -6.3), "continuation_evidence", "continuation_model_23", 23, "Maquette des souterrains de Nacre", "Sous les deux tours, la coupe d’origine montre un ancien bassin et des galeries absentes du plan touristique actuel. Le socle de la maquette a été modifié après l’ouverture du complexe.")
	_world._box(model, Vector3(0, 0.75, 0), Vector3(4.4, 1.5, 2.5), m["dark"], true)
	_world._box(model, Vector3(0, 1.52, 0), Vector3(4.7, 0.12, 2.8), m["cream"])
	for x: float in [-0.85, 0.85]:
		_world._box(model, Vector3(x, 2.10, 0), Vector3(0.48, 1.06, 0.48), m["metal"])
		for band in range(5):
			_world._box(model, Vector3(x, 1.68 + band * 0.18, -0.25), Vector3(0.5, 0.04, 0.025), m["lit_blue"])
	_world._box(model, Vector3(0, 1.585, 0.8), Vector3(2.8, 0.055, 0.2), m["lit_amber"])
	_world._box(model, Vector3(-0.9, 1.6, 0.45), Vector3(0.2, 0.06, 0.9), m["lit_amber"])
	_world._box(model, Vector3(0.9, 1.6, 0.45), Vector3(0.2, 0.06, 0.9), m["lit_amber"])
	_world._label(model, Vector3(0, 3.1, 0), "NACRE — COUPE D’ORIGINE", 27, Color("e0e7d8"), 0.006, true)
	var photo: Node3D = _world._interaction(parent, Vector3(-7.4, -6.0, 7.5), "continuation_evidence", "continuation_photo_23", 23, "Photographie des anciens bains", "Photographie antérieure au complexe Pelagos : les anciens bains municipaux encadrent une porte haute à double voussure. Sa silhouette correspond à celle dessinée par Alma avant le typhon. La date et le lieu sont visibles sur la légende.")
	_world._box(photo, Vector3(0, 1.5, 0), Vector3(4.3, 3.0, 0.20), m["wood"], true)
	_world._box(photo, Vector3(0, 1.6, -0.12), Vector3(3.9, 2.45, 0.03), m["cream"])
	# Stylised in-world archival display: code-native, not a claimed final photo.
	_world._box(photo, Vector3(0, 1.55, -0.15), Vector3(1.05, 1.65, 0.04), m["dark"])
	for x: float in [-1.55, -0.75, 0.75, 1.55]:
		_world._box(photo, Vector3(x, 1.45, -0.16), Vector3(0.13, 1.8, 0.04), m["metal"])
	_world._box(photo, Vector3(0, 2.46, -0.17), Vector3(3.5, 0.13, 0.03), m["metal"])
	var photo_caption: Label3D = _world._label(photo, Vector3(0, 0.32, -0.18), "LES ANCIENS BAINS — NACRE, 1964", 25, Color("193039"), 0.0058, false)
	photo_caption.rotation.y = PI
	photo.rotation.y = PI
	_world._label(parent, Vector3(-7.3, -2.4, 10.8), "HISTOIRE DE NACRE", 55, Color("e1d5b9"), 0.012, false)
	# A fallen sculpture is a readable diversion, well away from the rope lip.
	var sculpture: Node3D = Node3D.new()
	sculpture.name = "FallenTidalSculpture"
	parent.add_child(sculpture)
	sculpture.position = Vector3(9.0, -5.45, 5.6)
	sculpture.rotation.y = 0.45
	_world._box(sculpture, Vector3.ZERO, Vector3(1.8, 1.1, 4.1), m["metal"], true)
	_world._cylinder(sculpture, Vector3(0.4, 1.0, -0.5), 0.48, 1.15, m["gold"])
	_world._label(parent, Vector3(7.4, -3.2, 3.6), "PASSAGE PAR L’ALLÉE CENTRALE", 24, Color("dfc48d"), 0.0055, true)
	var terminal: Node3D = _world._interaction(parent, Vector3(7.0, -6.0, 9.0), "continuation_finish", "continuation_terminal_23", 23, "Relais d’exposition", "Transmettre le compte rendu de la reconnaissance après l’accueil du groupe au refuge et l’examen des deux pièces historiques.")
	_world._box(terminal, Vector3(0, 0.9, 0), Vector3(1.5, 1.8, 0.75), m["metal"], true)
	_world._box(terminal, Vector3(0, 1.3, -0.4), Vector3(1.1, 0.5, 0.04), m["lit_green"])
	_world._label(terminal, Vector3(0, 2.6, 0), "TRANSMETTRE AU REFUGE", 26, Color("a4dfc6"), 0.0055, true)
	# A mundane repeated maintenance gesture off the protected circulation.
	remanence = _world._human(parent, Vector3(-8.6, -6.0, -8.0), m["dark"], false)
	remanence.name = "ExhibitionRemanence"
	remanence.rotation.y = -PI * 0.5
	remanence.set_meta("role", "non_hostile_repeated_perception")
	remanence.set_meta("damage", 0)
	remanence.hide()
	_world._box(parent, Vector3(-10.5, -4.8, -8.0), Vector3(0.18, 2.4, 1.3), m["wood"], true)
	_world._light(parent, Vector3(-7.2, -2.3, -6.6), Color("86aab8"), 0.65, 8.0)

func _advance_remanence(delta: float, player_position: Vector3) -> void:
	if not is_instance_valid(remanence):
		return
	var on_exhibition: bool = absf(player_position.y + 6.0) < 0.4
	if not on_exhibition or escort_state == "following":
		remanence.hide()
		return
	if not remanence_started:
		if remanence_count >= 2:
			remanence.hide()
			return
		remanence_gap += delta
		if remanence_gap < (3.0 if remanence_count == 0 else 10.0):
			return
		remanence_started = true
		remanence_elapsed = 0.0
		remanence_count += 1
		remanence_gap = 0.0
	remanence_elapsed = minf(REMANENCE_DURATION, remanence_elapsed + delta)
	remanence.visible = remanence_elapsed < REMANENCE_DURATION
	var gesture: float = smoothstep(3.0, 5.0, remanence_elapsed) * (1.0 - smoothstep(9.0, 12.0, remanence_elapsed))
	remanence.get_node("RightArm").rotation.x = -gesture * 1.1
	remanence.rotation.y = -PI * 0.5 + 0.1 * sin(remanence_elapsed * 0.45)
	if remanence_elapsed >= REMANENCE_DURATION:
		remanence_started = false
