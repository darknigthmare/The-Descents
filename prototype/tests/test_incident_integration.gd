extends SceneTree
## Integration coverage for the live collapse, arrival and persistent world state.
## Uses teleports to isolate rules; physical detour traversal is tested separately.
## Run: godot --headless --path prototype --script tests/test_incident_integration.gd

const MainScene = preload("res://scenes/main.tscn")
const Store = preload("res://scripts/save_store.gd")
const TEST_PATH: String = "user://qa_test_incident_integration.json"
var mission: Node3D
var failures: Array[String] = []
var checks: int = 0


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	_cleanup_save()
	var timeout_timer: SceneTreeTimer = create_timer(30.0)
	timeout_timer.timeout.connect(func():
		push_error("Live-collapse integration test timed out.")
		_cleanup_save()
		quit(1)
	)
	mission = MainScene.instantiate()
	mission.save_path = TEST_PATH
	mission.sound_enabled = false
	root.add_child(mission)
	mission.set_process(false)
	await process_frame
	mission._start_new(271104)
	_disable_automatic_ticks()
	await physics_frame
	_check(mission.arrival_playing and not mission.player.active, "A new intervention did not open with the helicopter arrival.")
	_check(mission.world_data.get("helicopters", []).size() == 2, "Both towers must have distinct rescue helicopters.")
	_check(mission.world_data.get("rotors", []).size() == 2, "One rescue helicopter is missing its rotor.")
	_check(mission.world_data.get("helicopter_origins", []).size() == 2, "The two helicopter departure origins are not retained.")
	var helicopters: Array = mission.world_data.get("helicopters", [])
	if helicopters.size() == 2:
		_check(helicopters[0] != helicopters[1] and helicopters[0].visible and helicopters[1].visible, "Arrival reuses or hides one helicopter.")
		_check(helicopters[0].global_position.distance_to(helicopters[1].global_position) > 20.0, "The rescue aircraft are not deployed on separate towers.")
	_check(mission.world.twin_tower.rotation.is_zero_approx(), "Hespérie is already leaning before the aftershock.")
	_check(mission.world.breakable_glass.size() > 0 and _all_glass_visible(), "The future impact façade lacks its intact starting panes.")
	_check(_all_damage_hidden(), "Collapse rubble or smoke is visible before the incident.")
	_check(is_instance_valid(mission.world.twin_tower.get_node_or_null("BravoRoofTeam")), "Bravo has no visible deployment on Hespérie.")
	mission._finish_arrival()
	_check(not mission.arrival_playing and mission.player.active and mission.player.camera.current, "Skipping arrival did not restore first-person control.")
	_check(mission.incident.phase == "intact", "Skipping arrival triggered the collapse.")
	mission.elapsed = 40.0
	mission._process_departure()
	_check(not mission._can_observe_incident() and not mission._start_incident(), "The collapse can start from the rooftop.")
	_to_observation(true)
	_check(not mission._can_observe_incident() and not mission._start_incident(), "The observation point can trigger before Ana is rescued.")
	mission._process_incident(100.0)
	_check(mission.incident.phase == "intact", "A long idle interval bypassed the first rescue requirement.")
	_extract(30)
	_check(mission.rescued == ["survivor_30"], "Ana was not confirmed at the roof before the incident tests.")
	_to_observation(true)
	mission.elapsed = 35.9
	_check(not mission._can_observe_incident() and not mission._start_incident(), "The incident can start before the aircraft leave.")
	mission.elapsed = 40.0
	mission.player.engage_rope(29)
	_check(not mission._can_observe_incident() and not mission._start_incident(), "A player suspended in the shaft can trigger the window incident.")
	_to_observation(false)
	_check(not mission._can_observe_incident(), "Looking away satisfies the observation gate.")
	mission._process_incident(1.0)
	_check(mission.incident.phase == "intact", "The event starts while the player is looking away.")

	# A genuine unfinished carry and hoist must postpone the scene, not lose a life.
	var person_28: Node3D = _find("survivor", 28)
	_move_to(person_28)
	mission._interact_node(person_28)
	_to_observation(true)
	_check(mission.carried == person_28 and not mission._can_observe_incident() and not mission._start_incident(), "An active carried survivor failed to defer the incident.")
	_move_to(_find("beacon", 28))
	mission._interact_node(_find("beacon", 28))
	_to_observation(true)
	_check(mission.hoisting == person_28 and not mission._can_observe_incident() and not mission._start_incident(), "An active hoist failed to defer the incident.")
	mission._process_incident(100.0)
	_check(mission.incident.phase == "intact" and mission.hoisting == person_28, "The deferred incident changed a rescue transfer.")
	mission._process_hoist(5.1)
	_check(mission.rescued.size() == 2, "A postponed incident prevented the second rescue from completing.")
	_extract(26)
	_move_to(_find("refuge", 25))
	mission._interact_node(_find("refuge", 25))
	_check(mission.rescued.size() == 3 and not mission.completed, "Three rescues bypassed the required collapse before mission completion.")
	_check(Store.load_data(TEST_PATH).get("incident_state") == "intact", "A deferred event was incorrectly saved as completed.")

	# Continuous gaze is required; a glance in the wrong direction clears it.
	_to_observation(true)
	mission._process_incident(0.4)
	_check(mission.incident.phase == "intact", "A brief glimpse skipped the observation hold.")
	_look_at_tower(false)
	mission._process_incident(0.1)
	_look_at_tower(true)
	mission._process_incident(0.4)
	_check(mission.incident.phase == "intact", "Separated glimpses accumulated into an automatic trigger.")
	mission._process_incident(0.41)
	_check(mission.incident.phase == "warning", "Continuous observation did not start the warning.")
	_check(mission.player.active and mission.player.camera.current, "The live incident took control away from the player.")
	var before_scene: Dictionary = Store.load_data(TEST_PATH)
	_check(before_scene.get("incident_state") == "intact" and before_scene.get("floor") == 29, "The incident did not create a safe pre-scene checkpoint on floor 29.")
	_check(before_scene.get("rescued", []).size() == 3, "The pre-scene checkpoint lost confirmed survivors.")
	mission._process_incident(2.0)
	mission._pause()
	var paused_phase: String = mission.incident.phase
	var paused_time: float = mission.incident.phase_elapsed
	var paused_pose: Transform3D = mission.world.twin_tower.transform
	var paused_elapsed: float = mission.elapsed
	mission._process(100.0)
	_check(mission.incident.phase == paused_phase and is_equal_approx(mission.incident.phase_elapsed, paused_time), "The incident timer advanced through pause.")
	_check(mission.world.twin_tower.transform.is_equal_approx(paused_pose), "The tower animation advanced through pause.")
	_check(is_equal_approx(mission.elapsed, paused_elapsed), "The intervention timer advanced through pause.")
	mission._resume()
	_check(mission.player.active and not mission.paused, "Resuming the incident did not restore movement.")
	mission._process_incident(9.0)
	_check(mission.incident.is_active(), "The partial incident unexpectedly settled before interruption.")
	mission._continue_game()
	_disable_automatic_ticks()
	await physics_frame
	_check(mission.incident.phase == "intact" and mission.world.twin_tower.rotation.is_zero_approx(), "An interrupted sequence restored half-collapsed geometry.")
	_check(mission.rescued.size() == 3 and mission.player.nearest_floor() == 29, "Interrupted-scene restoration lost rescues or its safe floor.")
	_check(_all_glass_visible() and _all_damage_hidden(), "Replaying the pre-scene checkpoint retained impact damage.")
	_check(not mission.arrival_playing and mission.player.active, "Restoring the pre-scene checkpoint replayed the arrival.")
	for number in [30, 28, 26]:
		var saved_survivor: Node3D = _find("survivor", number)
		_check(saved_survivor.get_meta("used", false) and not saved_survivor.visible, "A saved survivor reappeared after incident restoration.")

	# Explicit interaction acknowledges the window without forcibly turning the camera.
	_to_observation(false)
	var before_explicit_view: Basis = mission.player.camera.global_basis
	_check(mission._start_incident(), "Explicit observation could not replay the incident from its safe checkpoint.")
	_check(mission.player.camera.global_basis.is_equal_approx(before_explicit_view), "Explicit observation forcibly turned the camera.")
	mission._process_incident(8.0)
	_check(mission.incident.phase == "quake", "The warning did not progress into the aftershock.")
	mission._process_incident(6.0)
	_check(mission.incident.phase == "collapse", "The aftershock did not progress into tower movement.")
	mission._process_incident(3.5)
	_check(not mission.world.twin_tower.rotation.is_zero_approx(), "Hespérie does not move during the collapse.")
	_check(mission.player.active, "The falling tower disabled player movement.")
	mission._process_incident(3.5)
	_check(mission.incident.phase == "impact", "The falling phase did not reach the impact.")
	mission._process_incident(4.0)
	await process_frame
	await physics_frame
	_check(mission.incident.phase == "aftermath" and mission.world.incident_stage == "aftermath", "The director and scene disagree about the settled incident.")
	_check(_all_glass_hidden() and _all_damage_visible(), "Impact did not leave persistent broken panes and debris.")
	_check(mission.world.route_obstacle.visible and mission.world.route_obstacle_body.collision_layer != 0, "The aftermath did not activate its physical route change.")
	_check(mission.player.active and mission.rescued.size() == 3, "The impact removed player control or a confirmed rescue.")
	var final_pose: Transform3D = mission.world.twin_tower.transform
	var after_scene: Dictionary = Store.load_data(TEST_PATH)
	_check(after_scene.get("incident_state") == "aftermath" and after_scene.get("rescued", []).size() == 3, "The post-scene checkpoint did not persist the incident and rescued people.")
	_check(not mission._start_incident(), "A completed incident can be triggered again.")
	mission._process_incident(100.0)
	_check(mission.world.twin_tower.transform.is_equal_approx(final_pose), "Settled geometry keeps drifting after the incident.")
	mission._continue_game()
	_disable_automatic_ticks()
	await process_frame
	await physics_frame
	_check(mission.incident.phase == "aftermath" and mission.world.twin_tower.transform.is_equal_approx(final_pose), "Loading a post-impact checkpoint reset or changed the tower pose.")
	_check(_all_glass_hidden() and _all_damage_visible(), "Loading a post-impact checkpoint repaired destroyed scenery.")
	_check(mission.world.route_obstacle_body.collision_layer != 0, "Loading a post-impact checkpoint reopened the obstructed route.")
	_move_to(_find("refuge", 25))
	mission._interact_node(_find("refuge", 25))
	_check(mission.completed and Store.load_data(TEST_PATH).get("completed", false), "The settled incident prevented a valid three-person mission from ending.")
	_check(Store.load_data(TEST_PATH).get("incident_state") == "aftermath", "Mission completion discarded the persistent collapse.")
	mission.free()
	_cleanup_save()
	if failures.is_empty():
		print("PASS live-collapse integration: %d checks; twin arrival, progression and gaze gates, carry/hoist protection, pause, replay checkpoints, persistent geometry and mission completion passed. Uses teleports; physical routes are tested separately." % checks)
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		print("FAIL live-collapse integration: %d failures / %d checks." % [failures.size(), checks])
		quit(1)


func _to_observation(face_tower: bool) -> void:
	mission.player.teleport_to_floor(29)
	mission.player.position = mission.world_data["observation_position"]
	mission.last_floor = 29
	_look_at_tower(face_tower)


func _look_at_tower(face_tower: bool) -> void:
	var target: Vector3 = mission.world_data["twin_view_target"]
	if not face_tower:
		target = mission.player.camera.global_position * 2.0 - target
	mission.player.camera.look_at(target, Vector3.UP)


func _extract(number: int) -> void:
	var survivor: Node3D = _find("survivor", number)
	_move_to(survivor)
	mission._interact_node(survivor)
	_move_to(_find("beacon", number))
	mission._interact_node(_find("beacon", number))
	mission._process_hoist(5.1)


func _move_to(target: Node3D) -> void:
	if target == null:
		return
	var number: int = int(target.get_meta("floor", 31))
	mission.player.teleport_to_floor(number)
	mission.player.position = target.global_position + Vector3(1.1, 0.06, 0.0)
	mission.last_floor = number


func _find(kind: String, number: int) -> Node3D:
	for target: Node3D in mission.world_data.get("interactables", []):
		if target.get_meta("kind", "") == kind and int(target.get_meta("floor", 0)) == number:
			return target
	_check(false, "Missing interaction target %s on floor %d." % [kind, number])
	return null


func _all_glass_visible() -> bool:
	for pane: MeshInstance3D in mission.world.breakable_glass:
		if not pane.visible:
			return false
	return true


func _all_glass_hidden() -> bool:
	for pane: MeshInstance3D in mission.world.breakable_glass:
		if pane.visible:
			return false
	return true


func _all_damage_hidden() -> bool:
	for damage: Node3D in mission.world.incident_damage:
		if damage.visible:
			return false
	return true


func _all_damage_visible() -> bool:
	for damage: Node3D in mission.world.incident_damage:
		if not damage.visible:
			return false
	return true


func _disable_automatic_ticks() -> void:
	mission.set_process(false)
	mission.player.set_physics_process(false)
	mission.world.set_process(false)


func _check(condition: bool, message: String) -> void:
	checks += 1
	if not condition:
		failures.append(message)


func _cleanup_save() -> void:
	if FileAccess.file_exists(TEST_PATH):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_PATH))
