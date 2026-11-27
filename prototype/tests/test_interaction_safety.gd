extends SceneTree
## Real-world reach, stale prompts and checkpoint survival on a lethal frame.

const MainScene = preload("res://scenes/main.tscn")
const Store = preload("res://scripts/save_store.gd")
const Preferences = preload("res://scripts/preferences_store.gd")
const SAVE: String = "user://qa_interaction_safety.json"
const PREFS: String = SAVE + ".cfg"
var mission: Node3D
var checks: int = 0
var failures: Array[String] = []

func _initialize() -> void:
	_run.call_deferred()

func _run() -> void:
	_clean()
	Preferences.save_settings(Preferences.normalize({"audio": false, "startup_intro": false}), PREFS)
	mission = MainScene.instantiate()
	mission.save_path = SAVE
	mission.preferences_path = PREFS
	root.add_child(mission)
	mission._start_new(271104)
	mission._finish_arrival()
	_freeze()
	await physics_frame
	await _test_reach()
	await _test_living_checkpoint()
	Input.action_release("interact")
	mission.free()
	_clean()
	if failures.is_empty():
		print("PASS interaction safety: %d checks; occlusion, gaze, range, stale prompts, one-shot actions and living checkpoint recovery." % checks)
		quit(0)
	else:
		for message: String in failures:
			push_error(message)
		print("FAIL interaction safety: %d failures / %d checks" % [failures.size(), checks])
		quit(1)

func _test_reach() -> void:
	for request: Array in [["survivor", 30], ["supply", 29], ["evidence", 27], ["refuge", 25], ["beacon", 31], ["rappel", 31], ["observation", 29]]:
		var target: Node3D = _object(str(request[0]), int(request[1]))
		await _face(target)
		var before: Dictionary = _facts()
		var origin: Vector3 = mission.player.camera.global_position
		var focus: Vector3 = mission._legacy_interaction_focus(target)
		var wall: StaticBody3D = _wall(origin.lerp(focus, 0.5), origin)
		await physics_frame
		mission._find_nearest()
		_check(mission.nearest != target, "%s remained an offered action through a physical wall." % request[0])
		mission._interact_node(target)
		_check(_facts() == before, "%s could be directly activated through a wall." % request[0])
		# A prompt drawn before the wall appeared is not an authorization to act.
		mission.nearest = target
		mission._interact()
		_check(_facts() == before, "%s used a stale prompt after the sightline became blocked." % request[0])
		wall.free()
		await physics_frame
		mission.player.global_position.x += 8.0
		mission._interact_node(target)
		_check(_facts() == before, "%s could be activated from beyond physical reach." % request[0])
		if str(request[0]) not in ["beacon", "rappel"]:
			await _face(target)
			mission.player.camera.rotate_y(PI)
			mission.nearest = target
			mission._interact()
			_check(_facts() == before, "%s used a stale prompt after looking away." % request[0])
			mission._find_nearest()
			_check(mission.nearest != target, "%s offered an action behind the rescuer." % request[0])
	var evidence: Node3D = _object("evidence", 27)
	await _face(evidence)
	mission._find_nearest()
	_check(mission.nearest == evidence, "A reachable, aimed archive did not receive its prompt.")
	mission._interact()
	_check(mission.clues == ["evidence_27"], "A visible archive could not be collected exactly once.")
	mission._interact_node(evidence)
	_check(mission.clues == ["evidence_27"], "Reusing an archive duplicated its receipt.")
	var casualty: Node3D = _object("survivor", 30)
	await _face(casualty)
	var impostor: Node3D = Node3D.new()
	mission.add_child(impostor)
	impostor.global_position = casualty.global_position
	impostor.set_meta("kind", "survivor")
	impostor.set_meta("floor", 30)
	mission._interact_node(impostor)
	_check(not is_instance_valid(mission.carried), "A node outside the world's interaction registry was accepted.")
	impostor.free()
	mission._find_nearest()
	_check(mission.nearest == casualty, "A nearby visible casualty did not receive the rescue prompt.")
	mission._interact()
	_check(mission.carried == casualty and mission.player.carrying, "A visible casualty could not be secured.")
	var beacon: Node3D = _object("beacon", 30)
	await _face(beacon)
	mission._interact_node(beacon)
	_check(mission.hoisting == casualty and not mission.player.carrying, "Physical reach validation prevented a legitimate rescue handoff.")
	mission._process_hoist(5.1)
	_check("survivor_30" in mission.rescued, "The reachable handoff did not finish the actual rescue.")

func _test_living_checkpoint() -> void:
	mission._start_new(271104)
	mission._finish_arrival()
	_freeze()
	await physics_frame
	var safe_bytes: PackedByteArray = FileAccess.get_file_as_bytes(SAVE)
	mission.health = 0.0
	_check(not mission._save_checkpoint(31), "A dead rescuer overwrote the checkpoint.")
	_check(mission.health == 0.0 and FileAccess.get_file_as_bytes(SAVE) == safe_bytes, "Rejecting the dead checkpoint healed the rescuer or altered the previous bytes.")
	mission._fall_recovery()
	_freeze()
	await physics_frame
	_check(mission.started and mission.health == 100.0 and mission.player.nearest_floor() == 31, "The previous living rooftop checkpoint was not restored.")
	mission.incident.restore("aftermath")
	mission.world.apply_incident("aftermath", 0.0)
	mission._process_equipment(0.0, 0)
	var boards: Node3D = mission.equipment_visuals.targets["equipment_boards_29"]
	mission.player.teleport_to_floor(29)
	mission.player.position = boards.global_position + Vector3(0, 0.06, 1.8)
	mission.player.camera.look_at(boards.global_position + boards.get_meta("focus_offset", Vector3(0, 0.85, 0)))
	mission.last_floor = 29
	mission.seen_floors = [29]
	for spec: Dictionary in mission.floor_specs:
		if int(spec["number"]) == 29:
			spec["hazard"] = "smoke"
	await physics_frame
	mission._select_equipment("fire_axe")
	mission._interact_node(boards)
	_check(mission.equipment.active_id == "equipment_boards_29", "Lethal-frame fixture could not begin its real equipment action.")
	for tick in range(7):
		mission._process_equipment(0.25, 1)
	mission.oxygen = 0.0
	mission.health = 0.1
	Input.action_press("interact")
	mission._process(0.25)
	Input.action_release("interact")
	_freeze()
	await physics_frame
	_check(FileAccess.get_file_as_bytes(SAVE) == safe_bytes, "Equipment completing on a lethal smoke frame replaced the living checkpoint.")
	_check(mission.health > 0.0 and mission.player.nearest_floor() == 31 and mission.supplies_used.is_empty(), "Lethal-frame recovery retained a dead state or duplicated an unsaved equipment reward.")
	# Historical files can contain health=0. Preserve them without a reload loop,
	# automatic new game, or fabricated health in the saved record.
	var historical: Dictionary = Store.load_data(SAVE)
	historical["health"] = 0.0
	_check(Store.save_data(historical, SAVE) == OK, "Could not construct the historical dead-checkpoint regression.")
	var dead_bytes: PackedByteArray = FileAccess.get_file_as_bytes(SAVE)
	mission._fall_recovery()
	_freeze()
	_check(not mission.started and mission.hud.continue_button.disabled, "A historical dead checkpoint entered an automatic death/reload loop.")
	_check(FileAccess.get_file_as_bytes(SAVE) == dead_bytes, "Fallback silently changed or replaced the historical checkpoint.")
	mission._continue_game()
	_freeze()
	_check(not mission.started and FileAccess.get_file_as_bytes(SAVE) == dead_bytes, "Continue bypassed the dead-checkpoint guard.")
	mission._start_new(271105)
	_freeze()
	_check(Store.load_data(SAVE).get("health", 0.0) > 0.0 and Store.load_data(SAVE).get("seed", 0) == 271105, "An explicitly requested new intervention could not replace the historical checkpoint.")

func _face(target: Node3D) -> void:
	var number: int = int(target.get_meta("floor", 31))
	for offset: Vector3 in [Vector3(0, 0.06, 1.8), Vector3(1.8, 0.06, 0), Vector3(-1.8, 0.06, 0), Vector3(0, 0.06, -1.8)]:
		mission.player.teleport_to_floor(number)
		mission.player.global_position = target.global_position + offset
		mission.player.velocity = Vector3.ZERO
		mission.player.camera.look_at(mission._legacy_interaction_focus(target))
		mission.last_floor = number
		await physics_frame
		if mission._legacy_interaction_reachable(target):
			return
	_check(false, "No reachable physical setup for %s." % target.name)

func _wall(position_value: Vector3, face: Vector3) -> StaticBody3D:
	var body: StaticBody3D = StaticBody3D.new()
	var collider: CollisionShape3D = CollisionShape3D.new()
	var shape: BoxShape3D = BoxShape3D.new()
	shape.size = Vector3(1.2, 2.5, 0.15)
	collider.shape = shape
	body.add_child(collider)
	mission.add_child(body)
	body.global_position = position_value
	body.look_at(Vector3(face.x, position_value.y, face.z))
	return body

func _facts() -> Dictionary:
	return {"health": mission.health, "oxygen": mission.oxygen, "anchors": mission.anchors, "flares": mission.flares,
		"rescued": mission.rescued.duplicate(), "clues": mission.clues.duplicate(), "supplies": mission.supplies_used.duplicate(),
		"carried": mission.carried, "hoisting": mission.hoisting, "on_rope": mission.player.on_rope, "completed": mission.completed, "incident": mission.incident.phase}

func _object(kind: String, number: int) -> Node3D:
	for object: Node3D in mission.world_data.get("interactables", []):
		if object.get_meta("kind", "") == kind and int(object.get_meta("floor", 0)) == number:
			return object
	push_error("Missing interaction fixture: %s %d" % [kind, number])
	return null

func _freeze() -> void:
	mission.set_process(false)
	mission.set_physics_process(false)
	mission.player.set_physics_process(false)
	mission.world.set_process(false)

func _check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures.append(message)

func _clean() -> void:
	for path: String in [SAVE, PREFS]:
		if FileAccess.file_exists(path):
			DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
