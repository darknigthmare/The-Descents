extends SceneTree
## Optional field reading must preserve mission truth, physical access and HUD exit.
## Run: godot --headless --fixed-fps 60 --path prototype --script tests/test_field_props.gd

const Props = preload("res://scripts/field_props.gd")
const HUD = preload("res://scripts/hud.gd")
const World = preload("res://scripts/world_builder.gd")
const Generator = preload("res://scripts/floor_generator.gd")
var failures: Array[String] = []
var checks: int = 0

func _initialize() -> void:
	_run.call_deferred()

func _run() -> void:
	_test_catalogue()
	await _test_world()
	await _test_panel()
	if failures.is_empty():
		print("PASS field inspections: %d checks; twelve optional props, coherent rescue/incident reads, collision-free detail, visible reachable targets and modal closure." % checks)
		quit(0)
	else:
		for failure: String in failures:
			push_error(failure)
		print("FAIL field inspections: %d failures / %d checks." % [failures.size(), checks])
		quit(1)

func _test_catalogue() -> void:
	var catalogue: Array = Props.catalogue()
	_check(catalogue.size() == 12, "The field catalogue must have twelve inspection points.")
	var ids: Array[String] = []
	var floors: Array[int] = []
	for entry: Dictionary in catalogue:
		_check(not ids.has(entry.id), "Duplicated stable inspection ID: %s" % entry.id)
		ids.append(entry.id)
		if not floors.has(entry.floor):
			floors.append(entry.floor)
		for phase: String in ["intact", "aftermath"]:
			var context: Dictionary = {"incident_state": phase, "rescued": [], "supplies_used": ["supply_29"]}
			var original: Dictionary = context.duplicate(true)
			var read: Dictionary = Props.read(entry.id, context)
			_check(context == original, "Reading %s mutated mission context." % entry.id)
			for field: String in ["id", "title", "floor_label", "category", "status_label", "usage", "observation", "action", "team_note"]:
				_check(not str(read.get(field, "")).is_empty(), "Incomplete %s/%s read: %s" % [entry.id, phase, field])
			_check(not read.observation.contains(entry.id), "Internal inspection ID leaked into the observation.")
			_check(read.floor == entry.floor, "Reading was assigned to the wrong floor.")
		_check(Props.read(entry.id, {"incident_state": "intact"}).observation != Props.read(entry.id, {"incident_state": "aftermath"}).observation, "Before/after observation did not change for %s." % entry.id)
	floors.sort()
	_check(floors == [25, 26, 27, 28, 29, 30, 31], "Field reading does not cover the roof and all six floors.")
	var first_id: String = catalogue[0].id
	catalogue[0].title = "MUTATED COPY"
	catalogue[0].position.x = 500.0
	_check(Props.read(first_id).title != "MUTATED COPY" and Props.catalogue()[0].position.x < 12.0, "Catalogue copy changed shared content.")
	_check(Props.read("missing_inspection", {}).is_empty(), "Unknown inspection IDs must not invent a record.")
	var register: Dictionary = Props.read("inspect_roof_register", {"incident_state": "aftermath", "rescued": ["survivor_30", "survivor_30", "unknown"]})
	_check(register.status_label.contains("1 / 3"), "Reception count accepted duplicate or unknown IDs.")
	_check(register.observation.contains("À l’abri au toit : Ana Rios.") and register.observation.contains("Réception encore attendue : Samuel Breton, Nora Haddad."), "Register disagrees with confirmed rescue identities.")
	var complete: Dictionary = Props.read("inspect_roof_register", {"incident_state": "aftermath", "rescued": ["survivor_26", "survivor_30", "survivor_28"]})
	_check(complete.status_label.contains("3 / 3") and not complete.observation.contains("Réception encore attendue"), "Completed reception still lists pending people.")
	for pair: Array in [["inspect_30_table", "survivor_30", "Ana Rios"], ["inspect_28_archive", "survivor_28", "Samuel Breton"], ["inspect_26_filtration", "survivor_26", "Nora Haddad"]]:
		var before: Dictionary = Props.read(pair[0], {"incident_state": "aftermath", "rescued": []})
		var after: Dictionary = Props.read(pair[0], {"incident_state": "aftermath", "rescued": [pair[1]]})
		_check(not before.team_note.contains("a été reçu") and after.team_note.contains(pair[2]), "Rescue note is premature or fails to name the received person.")
		_check(after.action != before.action, "Post-rescue guidance still orders the same person's evacuation.")
		_check(not after.observation.contains("attend de l’aide"), "Observation leaves a confirmed patient in the field.")
	_check(Props.read("inspect_29_glazing", {"incident_state": "aftermath"}).team_note.contains("pas une confirmation de perte"), "Loss of Bravo contact was converted to a death confirmation.")

func _test_world() -> void:
	var world = World.new()
	root.add_child(world)
	world.build(47, Generator.generate(47))
	world.set_process(false)
	var original_collisions: int = _collision_count(world)
	var original_interactions: int = world.interactables.size()
	var builder = Props.new()
	var points: Array[Node3D] = builder.build(world)
	_check(points.size() == 12 and world.get_node(Props.GROUP_NAME).get_child_count() == 12, "Builder did not create one world point per record.")
	_check(_collision_count(world) == original_collisions, "Reading props introduced collision into playable routes.")
	_check(world.interactables.size() == original_interactions, "Props builder directly modified mission interactables.")
	for point: Node3D in points:
		_check(point.get_meta("kind", "") == "inspect" and not point.get_meta("used", true), "Point was built as a pickup or consumed resource.")
		_check(point.get_meta("range", 0.0) == 2.4 and point.get_meta("focus_offset", Vector3.ZERO).y > 0.0, "Reading point lacks a close, visible focus target.")
		_check(_mesh_count(point) >= 4, "Point has no recognizable physical detail: %s" % point.name)
		_check(not _has_billboard(point), "Inspection detail introduced a floating billboard: %s" % point.name)
		_check(absf(point.position.x) > 3.4 or absf(point.position.z) > 3.4, "An inspection point occupies the rope opening.")
	points = builder.build(world)
	_check(world.get_node(Props.GROUP_NAME).get_child_count() == 12 and _collision_count(world) == original_collisions, "Repeated construction duplicated points or physics bodies.")
	var capsule: CapsuleShape3D = CapsuleShape3D.new()
	capsule.radius = 0.34
	capsule.height = 1.72
	for phase: String in ["intact", "aftermath"]:
		world.apply_incident(phase, 0.0)
		await physics_frame
		await physics_frame
		var space: PhysicsDirectSpaceState3D = world.get_world_3d().direct_space_state
		for point: Node3D in points:
			var approach_offset: Vector3 = Vector3(0, 0, 1.8)
			match str(point.get_meta("id")):
				"inspect_30_table": approach_offset = Vector3(0, 0, 2.15)
				"inspect_30_service": approach_offset = Vector3(0, 0, 1.7)
				"inspect_28_archive": approach_offset = Vector3(1.8, 0, 0.4)
				"inspect_27_locker": approach_offset = Vector3(0, 0, 1.4)
			var foot: Vector3 = point.global_position + approach_offset
			var occupancy: PhysicsShapeQueryParameters3D = PhysicsShapeQueryParameters3D.new()
			occupancy.shape = capsule
			occupancy.transform = Transform3D(Basis.IDENTITY, foot + Vector3(0, 0.93, 0))
			occupancy.collision_mask = 1
			_check(space.intersect_shape(occupancy).is_empty(), "No capsule space at %s reading position (%s)." % [point.name, phase])
			var target: Vector3 = point.global_position + point.get_meta("focus_offset")
			var sight: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(foot + Vector3(0, 1.62, 0), target, 1)
			_check(space.intersect_ray(sight).is_empty(), "A collider obscures %s reading surface (%s)." % [point.name, phase])
			_check(approach_offset.length() <= point.get_meta("range"), "Accessible reading position exceeds interaction distance.")
	world.free()

func _test_panel() -> void:
	root.size = Vector2i(1440, 900)
	var hud = HUD.new()
	root.add_child(hud)
	await process_frame
	await process_frame
	_check(not hud.inspection_panel.visible, "Inspection panel appears before a reading is requested.")
	var entry: Dictionary = Props.read("inspect_roof_register", {"incident_state": "aftermath", "rescued": ["survivor_30"]})
	var before: Dictionary = entry.duplicate(true)
	hud.show_game()
	hud.set_paused(true)
	hud.show_inspection(entry)
	await process_frame
	await process_frame
	var panel = hud.inspection_panel
	_check(panel.visible and not hud.pause_panel.visible, "Inspection overlaps the pause menu.")
	_check(panel.title_label.text == entry.title and panel.observation_label.text == entry.observation, "HUD did not render the requested field record.")
	_check(panel.usage_label.text == entry.usage and panel.action_label.text == entry.action and panel.team_label.text == entry.team_note, "One of the four reading sections is missing.")
	_check(entry == before, "The inspection UI mutated the reading record.")
	_check(panel.close_button.get_global_rect().end.y <= 900.0, "Close button is below the visible screen.")
	_check(panel.scroll.size.y > 240.0, "Reading viewport is too short to consult the record.")
	var emissions: Array[int] = [0]
	hud.inspection_closed.connect(func(): emissions[0] += 1)
	panel.close_button.pressed.emit()
	_check(emissions[0] == 1 and panel.visible, "Close must request one owner-controlled resume, not bypass it.")
	hud.hide_inspection()
	_check(not panel.visible, "Explicit close did not hide the panel.")
	hud.show_inspection(entry)
	hud.show_menu()
	_check(not panel.visible, "Returning to the title screen left the field panel visible.")
	hud.show_inspection(entry)
	hud.show_game()
	_check(not panel.visible, "Starting or restoring play left an inspection panel visible.")
	hud.show_inspection(entry)
	hud.set_paused(false)
	_check(not panel.visible, "Resuming normal play left the inspection visible.")
	await process_frame
	hud.free()

func _collision_count(node: Node) -> int:
	var count: int = 1 if node is CollisionObject3D or node is CollisionShape3D else 0
	for child: Node in node.get_children():
		count += _collision_count(child)
	return count

func _mesh_count(node: Node) -> int:
	var count: int = 1 if node is MeshInstance3D else 0
	for child: Node in node.get_children():
		count += _mesh_count(child)
	return count

func _has_billboard(node: Node) -> bool:
	if node is Label3D and node.billboard != BaseMaterial3D.BILLBOARD_DISABLED:
		return true
	for child: Node in node.get_children():
		if _has_billboard(child):
			return true
	return false

func _check(condition: bool, message: String) -> void:
	checks += 1
	if not condition:
		failures.append(message)
