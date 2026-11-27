extends SceneTree
## Integration invariants for cosmetic carrying, timed hoisting and roof reception.
## Uses prepared positions; the existing physical-route suites cover traversal.
const MainScene = preload("res://scenes/main.tscn")
const Rescue = preload("res://scripts/rescue_presentation.gd")
const Preferences = preload("res://scripts/preferences_store.gd")
const Save = preload("res://scripts/save_store.gd")
const SAVE_PATH: String = "user://qa_v06_rescue.json"
const PREFS_PATH: String = "user://qa_v06_rescue.cfg"
var mission: Node3D
var checks: int = 0
var failures: Array[String] = []

func _initialize() -> void:
	_run.call_deferred()

func _run() -> void:
	_cleanup()
	var settings: Dictionary = Preferences.DEFAULTS.duplicate()
	settings["audio"] = false
	settings["startup_intro"] = false
	Preferences.save_settings(settings, PREFS_PATH)
	mission = MainScene.instantiate()
	mission.save_path = SAVE_PATH
	mission.preferences_path = PREFS_PATH
	mission.sound_enabled = false
	root.add_child(mission)
	await process_frame
	mission._start_new(271104)
	mission._finish_arrival()
	_freeze()
	await physics_frame
	await process_frame
	_check(not mission.rescue_visuals.carry_rig.visible and not mission.rescue_visuals.hoist_rig.visible, "A new intervention displays an empty transport rig.")
	_check(_collision_count(mission.rescue_visuals) == 0, "Presentation added a collider to the rescue route.")
	var original_interactions: int = mission.world_data["interactables"].size()
	_test_sampling()
	for floor_number: int in [30, 28, 26]:
		await _rescue(floor_number)
		_check(mission.world_data["interactables"].size() == original_interactions, "Rescue presentation changed interaction count.")
	_check(mission.rescued == ["survivor_30", "survivor_28", "survivor_26"], "Final registry differs from actual completed hoists.")
	var stable: Dictionary = Save.load_data(SAVE_PATH)
	mission._restore(stable)
	_freeze()
	await process_frame
	_check(mission.rescue_visuals.carry_id.is_empty() and mission.rescue_visuals.hoist_id.is_empty() and mission.rescue_visuals.reception_id.is_empty(), "Checkpoint restored a transient animation.")
	_check(mission.player.camera.get_cull_mask_value(2), "Checkpoint rebuild retained a temporary hidden annotation layer.")
	for id_value: String in mission.world.roof_rescued_people:
		var person: Node3D = mission.world.roof_rescued_people[id_value]
		_check(person.visible and person.position.x >= 6 and person.position.z < -8, "Reload failed to place a received person under the medical canopy.")
	mission._start_new(51)
	mission._finish_arrival()
	_freeze()
	await process_frame
	_check(mission.rescued.is_empty() and not mission.rescue_visuals.carry_rig.visible and not mission.rescue_visuals.cable.visible, "New game retained rescue visuals from the old mission.")
	for person: Node3D in mission.world.roof_rescued_people.values():
		_check(not person.visible, "New game retained a received casualty.")
	mission.free()
	await process_frame
	_cleanup()
	if failures.is_empty():
		print("PASS rescue presentation: %d checks; first-person harness, continuous hoist, pause, reception, restoration and collision-free staging." % checks)
		quit(0)
	else:
		for failure: String in failures:
			push_error(failure)
		print("FAIL rescue presentation: %d failures / %d checks." % [failures.size(), checks])
		quit(1)

func _test_sampling() -> void:
	for floor_number: int in [30, 28, 26]:
		_check(Rescue.hoist_position(-10, floor_number).is_equal_approx(Rescue.hoist_position(0, floor_number)), "Negative hoist clock escaped the initial pose.")
		_check(Rescue.hoist_position(50, floor_number).is_equal_approx(Rescue.DOCK), "Oversized hoist clock escaped the roof dock.")
		var last: Vector3 = Rescue.hoist_position(0, floor_number)
		for step in range(1, 101):
			var next: Vector3 = Rescue.hoist_position(step * 0.05, floor_number)
			_check(next.y >= last.y - 0.0001 and next.y <= Rescue.DOCK.y + 0.0001, "Hoist reverses or overshoots vertically.")
			_check(next.x >= 1.8 - 0.0001 and next.x <= Rescue.DOCK.x + 0.0001, "Hoist escaped its shaft/dock corridor.")
			if step * 0.05 < 4.2:
				_check(next.x < 2.7, "Casualty crosses a slab before clearing the roof.")
			last = next

	# Keep the physical silhouette clear of the actual roof anchor and beacon
	# volumes, including the diagonal docking segment (not only the final point).
	var obstructions: Array[AABB] = [
		AABB(Vector3(3.31, 42.0, -0.09), Vector3(0.18, 3.0, 0.18)),
		AABB(Vector3(3.26, 42.0, -0.34), Vector3(0.68, 1.8, 0.68))
	]
	for moment: float in [4.2, 4.4, 4.6, 4.8, 5.0]:
		var point: Vector3 = Rescue.hoist_position(moment, 30)
		var harness_bounds: AABB = AABB(point + Vector3(-0.43, 0.45, -0.43), Vector3(0.86, 1.75, 0.86))
		for obstruction: AABB in obstructions:
			_check(not harness_bounds.intersects(obstruction), "Docking harness intersects the roof anchor or beacon.")
	var stretcher_bounds: AABB = AABB(Rescue.DOCK + Vector3(-0.58, 0.12, -1.3), Vector3(1.16, 1.12, 2.6))
	for obstruction: AABB in obstructions:
		_check(not stretcher_bounds.intersects(obstruction), "Received stretcher intersects the roof anchor or beacon.")

	var medical_obstacles: Array[AABB] = [
		AABB(Vector3(5.455, 42.0, -8.245), Vector3(0.09, 2.65, 0.09)),
		AABB(Vector3(11.055, 42.0, -8.245), Vector3(0.09, 2.65, 0.09)),
		AABB(Vector3(5.74, 42.0, -10.81), Vector3(0.32, 1.25, 0.32)),
		AABB(Vector3(6.14, 42.0, -10.81), Vector3(0.32, 1.25, 0.32))
	]
	var ana_destination: Transform3D = mission.rescue_visuals.reception_origins["survivor_30"]
	for moment: float in [0.0, 0.5, 1.0, 1.5, 2.0, 2.5, 3.0, 3.5, 4.2]:
		var location: Vector3 = Rescue.reception_position(moment, ana_destination.origin)
		var bed: AABB = AABB(location + Vector3(-0.58, 0.12, -1.3), Vector3(1.16, 1.12, 2.6))
		for obstacle: AABB in medical_obstacles:
			_check(not bed.intersects(obstacle), "Medical transfer intersects a canopy post or oxygen bottle.")

func _rescue(floor_number: int) -> void:
	var survivor: Node3D = _find("survivor", floor_number)
	var beacon: Node3D = _find("beacon", floor_number)
	var id_value: String = str(survivor.get_meta("id"))
	var registry_size: int = mission.rescued.size()
	# Exercise both incoming annotation states, preserving every other layer.
	mission.player.camera.set_cull_mask_value(2, floor_number != 26)
	var original_camera_mask: int = mission.player.camera.cull_mask
	mission.player.teleport_to_floor(floor_number)
	mission.player.position = survivor.global_position + Vector3(0, 0.1, 1.3)
	mission.player.camera.rotation = Vector3.ZERO
	mission._interact_node(survivor)
	_check(mission.rescue_visuals.carry_id == id_value and mission.rescue_visuals.carry_rig.visible, "Carried casualty has no visible first-person rig.")
	_check(not survivor.visible and mission.rescued.size() == registry_size, "Carry duplicated or prematurely registered a casualty.")
	var visible_figures: int = 0
	for body: Node3D in mission.rescue_visuals.carry_people.values():
		if body.visible:
			visible_figures += 1
	_check(visible_figures == 1, "Carry rig shows multiple casualties.")
	mission.rescue_visuals.advance(0.1, true)
	var before_transform: Transform3D = mission.rescue_visuals.carry_rig.global_transform
	mission.rescue_visuals.advance(2.0, true)
	_check(mission.rescue_visuals.carry_rig.global_transform.is_equal_approx(before_transform), "Reduced motion still adds carry sway.")
	mission.player.position.x += 0.25
	mission.rescue_visuals.advance(0.0, true)
	_check(is_equal_approx(mission.rescue_visuals.carry_rig.global_position.x, mission.player.camera.global_position.x), "View rig does not track the camera.")
	mission.player.position = beacon.global_position + Vector3(0, 0.1, 1.0)
	mission._interact_node(beacon)
	_check(mission.rescue_visuals.carry_id.is_empty() and not mission.rescue_visuals.carry_rig.visible, "First-person casualty remains after harness transfer.")
	_check(mission.rescue_visuals.hoist_rig.visible and mission.rescue_visuals.cable.visible and survivor.visible, "Hoist is missing its casualty, harness or cable.")
	_check(mission.rescued.size() == registry_size, "Attaching the hoist registered an unfinished rescue.")
	_check(mission.player.camera.cull_mask == (original_camera_mask & ~2), "Hoist labels obstruct the cable, or another render layer was changed.")
	_check(not mission.hud.notify_label.text.contains("Retournez"), "Active lift still tells the player to return a carried casualty.")
	var safe_bytes: String = FileAccess.get_file_as_string(SAVE_PATH)
	mission._process_hoist(2.5)
	_check(survivor.global_position.is_equal_approx(Rescue.hoist_position(2.5, floor_number)), "Real hoist does not use the absolute trajectory.")
	_check(mission.rescue_visuals.cable.scale.y > 0 and mission.rescue_visuals.cable.global_position.y < 45, "Hoist cable is inverted or detached.")
	var hoist_position: Vector3 = survivor.global_position
	var clock: float = mission.hoist_progress
	mission._pause()
	mission._process(3.0)
	await process_frame
	_check(survivor.global_position == hoist_position and mission.hoist_progress == clock, "Pause advanced the rescue.")
	_check(not mission.player.camera.get_cull_mask_value(2), "Pausing the hoist restored obstructive annotations.")
	_check(FileAccess.get_file_as_string(SAVE_PATH) == safe_bytes, "A half-hoisted casualty changed the safe checkpoint.")
	mission._resume()
	_freeze()
	mission._process_hoist(2.5)
	_check(mission.hoisting == null and mission.rescued.size() == registry_size + 1 and id_value in mission.rescued, "A full five-second hoist did not register exactly one rescue.")
	_check(mission.player.camera.cull_mask == original_camera_mask, "Completed hoist failed to restore the incoming annotation state.")
	_check(not mission.rescue_visuals.cable.visible and not mission.rescue_visuals.hoist_rig.visible and not survivor.visible, "Completed hoist retained a duplicate figure or cable.")
	_check(mission.rescue_visuals.reception_id == id_value, "Roof reception did not start for the confirmed ID.")
	_check(not mission.hud.notify_label.text.contains("Treuillage en cours"), "Receipt leaves an unfinished-lift instruction visible.")
	var receipt: Node3D = mission.world.roof_rescued_people[id_value]
	_check(receipt.visible and receipt.position.is_equal_approx(Rescue.DOCK), "Roof reception does not begin at the actual hoist dock.")
	mission.rescue_visuals.advance(1.8, true)
	var receiving_position: Vector3 = receipt.position
	_check(receiving_position.distance_to(Rescue.DOCK) > 0.5, "Reception has no visible transfer.")
	mission._pause()
	mission._process(10.0)
	await process_frame
	_check(receipt.position == receiving_position, "Pause advanced the roof transfer.")
	mission._resume()
	_freeze()
	var saved: Dictionary = Save.load_data(SAVE_PATH)
	_check(saved["rescued"].size() == registry_size + 1 and not saved.has("reception_id") and not saved.has("carried"), "Cosmetic transfer leaked into checkpoint schema.")
	mission.rescue_visuals.advance(10.0, true)
	_check(mission.rescue_visuals.reception_id.is_empty() and receipt.position.x >= 6 and receipt.position.z < -8, "Reception failed to settle in its named medical position.")
	for index in range(mission.world.alpha_roof_members.size()):
		_check(mission.world.alpha_roof_members[index].transform.is_equal_approx(mission.rescue_visuals.crew_origins[index]), "Medic or winch operator failed to return to duty.")
	mission._process_hoist(50)
	mission._interact_node(survivor)
	_check(mission.rescued.size() == registry_size + 1, "A finished rescue was counted twice.")

func _find(kind: String, floor_number: int) -> Node3D:
	for object: Node3D in mission.world_data["interactables"]:
		if object.get_meta("kind", "") == kind and int(object.get_meta("floor", 0)) == floor_number:
			return object
	push_error("Missing fixture object: %s %d" % [kind, floor_number])
	return null

func _freeze() -> void:
	mission.set_process(false)
	mission.world.set_process(false)
	mission.player.set_process(false)
	mission.player.set_physics_process(false)

func _collision_count(node: Node) -> int:
	var result: int = 1 if node is CollisionObject3D else 0
	for child: Node in node.get_children():
		result += _collision_count(child)
	return result

func _cleanup() -> void:
	for path: String in [SAVE_PATH, SAVE_PATH + ".tmp", PREFS_PATH, PREFS_PATH + ".tmp"]:
		if FileAccess.file_exists(path):
			DirAccess.remove_absolute(ProjectSettings.globalize_path(path))

func _check(condition: bool, message: String) -> void:
	checks += 1
	if not condition:
		failures.append(message)
