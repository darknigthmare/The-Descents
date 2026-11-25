extends SceneTree
## Integration test of mission state, input and checkpoint restoration.
## Teleportation is deliberate: this does NOT verify geometric traversability.
## Run: godot --headless --path prototype --script tests/test_mission.gd

const MainScene = preload("res://scenes/main.tscn")
const Store = preload("res://scripts/save_store.gd")
const TEST_PATH: String = "user://qa_test_mission.json"
const TEST_SEED: int = 271104
const PREFS_PATH: String = TEST_PATH + ".preferences.cfg"
var mission: Node3D
var failures: Array[String] = []
var checks: int = 0


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	_cleanup_save()
	var timeout_timer: SceneTreeTimer = create_timer(30.0)
	timeout_timer.timeout.connect(func():
		push_error("Mission integration test timed out.")
		_cleanup_save()
		quit(1)
	)
	mission = MainScene.instantiate()
	mission.save_path = TEST_PATH
	mission.preferences_path = PREFS_PATH
	mission.sound_enabled = false
	root.add_child(mission)
	mission.set_process(false)
	await process_frame
	_check(not mission.started, "The mission must start at its menu.")
	_check(is_instance_valid(mission.hud) and is_instance_valid(mission.player), "HUD/player initialization failed.")
	_check(mission.floor_specs.size() == 6, "The playable slice does not contain six floor specifications.")
	mission._start_new(TEST_SEED)
	mission._finish_arrival()
	_disable_automatic_ticks()
	await physics_frame
	_check(mission.started and not mission.paused and not mission.completed, "Starting did not enter active play.")
	_check(mission.current_seed == TEST_SEED, "New-game seed was not preserved.")
	_check(mission.player.nearest_floor() == 31, "New mission did not start at the rooftop.")
	_check(Store.load_data(TEST_PATH).get("floor", 0) == 31, "The initial rooftop checkpoint was not written.")

	await _test_rope()
	_test_pause()
	var refuge: Node3D = _find("refuge", 25)
	_move_to(refuge)
	mission._interact_node(refuge)
	_check(not mission.completed, "The refuge completed a mission with no rescued survivors.")
	_check(Store.load_data(TEST_PATH).get("floor", 0) == 25, "The uncompleted refuge did not create a checkpoint.")

	for number in [29, 27, 26]:
		var evidence: Node3D = _find("evidence", number)
		_move_to(evidence)
		mission._find_nearest()
		_check(mission.nearest == evidence, "Evidence %d was not selected from its interaction socket." % number)
		mission._interact()
		var count: int = mission.clues.size()
		mission._interact_node(evidence)
		_check(mission.clues.size() == count, "Evidence %d was counted twice." % number)
	_check(mission.clues.size() == 3, "The three evidence records could not be collected.")
	_check(mission._journal_content().contains("Relevé SILLAGE 06"), "Collected evidence is missing from the journal.")
	_test_supply()

	# First extraction creates the checkpoint used by the interrupted-carry test.
	_extract(30)
	_check(not mission.completed, "One rescue completed the mission prematurely.")
	var saved: Dictionary = Store.load_data(TEST_PATH)
	_check(saved.get("rescued", []) == ["survivor_30"], "The first extraction did not persist exactly one rescued ID.")
	_check(saved.get("clues", []).size() == 3 and saved.get("supplies_used", []) == ["supply_29"], "The extraction checkpoint lost collected evidence or supply state.")
	var person_28: Node3D = _find("survivor", 28)
	_move_to(person_28)
	mission._interact_node(person_28)
	_check(mission.carried == person_28 and mission.player.carrying, "The second survivor could not enter the harness.")
	mission._continue_game()
	_disable_automatic_ticks()
	await physics_frame
	_check(mission.current_seed == TEST_SEED, "Checkpoint continuation changed the procedural seed.")
	_check(mission.carried == null and not mission.player.carrying and mission.hoisting == null, "An unfinished carried/hoisting state leaked through restoration.")
	_check(mission.rescued == saved["rescued"] and mission.clues == saved["clues"] and mission.supplies_used == saved["supplies_used"], "Restoration changed completed objective IDs.")
	_check(mission.player.nearest_floor() == 30 and not mission.player.on_rope, "Restoration did not place the player at a stable saved floor.")
	_check(_find("survivor", 28).visible and not _find("survivor", 28).get_meta("used", false), "The interrupted survivor did not return to their original rescue point.")
	_check(not _find("survivor", 30).visible and _find("survivor", 30).get_meta("used", false), "The rescued survivor was duplicated after restoration.")
	_check(not _find("evidence", 29).visible and not _find("supply", 29).visible, "Consumed objects reappeared after checkpoint restoration.")

	# Exercise the new irreversible incident before continuing the rescue loop.
	mission.elapsed = 40.0
	mission.player.teleport_to_floor(29)
	mission.player.position = mission.world_data["observation_position"]
	_check(mission._start_incident(), "The incident did not start at the observation bay after Ana's extraction.")
	_check(mission.player.active, "The structural incident took player control away.")
	mission._process_incident(25.1)
	_check(mission.incident.phase == "aftermath" and Store.load_data(TEST_PATH).get("incident_state", "") == "aftermath", "The collapsed state was not made persistent.")
	_check(mission.rescued == ["survivor_30"], "The incident changed an already confirmed rescue.")

	_extract(28)
	_move_to(_find("refuge", 25))
	mission._interact_node(_find("refuge", 25))
	_check(not mission.completed and mission.rescued.size() == 2, "The refuge accepted an incomplete two-person rescue.")
	_extract(26)
	_check(mission.rescued.size() == 3 and not mission.completed, "Three rescued people must still require activation of refuge 25.")
	_check(mission.player.nearest_floor() == 26, "The third extraction moved the player to the roof instead of only hoisting the survivor.")
	_move_to(_find("refuge", 25))
	mission._interact_node(_find("refuge", 25))
	_check(mission.completed and not mission.player.active, "Refuge 25 did not finish a completed rescue.")
	_check(mission.epilogue_playing and mission.hud.cinematic.visible, "Completion did not start the closing in-game sequence.")
	mission._finish_epilogue()
	_check(mission.hud.end_panel.visible, "Completion did not display the end-of-slice screen.")
	var final_save: Dictionary = Store.load_data(TEST_PATH)
	_check(final_save.get("completed", false) and final_save.get("floor", 0) == 25, "Final completion was not persisted at refuge 25.")
	_check(final_save.get("rescued", []).size() == 3 and final_save.get("clues", []).size() == 3, "Final save lost rescue or evidence records.")
	var final_elapsed: float = mission.elapsed
	mission._process(60.0)
	_check(is_equal_approx(mission.elapsed, final_elapsed), "The mission timer continued after completion.")
	mission._continue_game()
	_disable_automatic_ticks()
	await process_frame
	_check(mission.completed and mission.hud.end_panel.visible and not mission.player.active, "Continuing a completed checkpoint did not restore its ending.")
	_check(mission.carried == null and mission.hoisting == null, "Completed restoration left an active transported survivor.")

	for action in ["move_forward", "move_back", "move_left", "move_right"]:
		Input.action_release(action)
	mission.free()
	_cleanup_save()
	if failures.is_empty():
		print("PASS mission integration: %d checks; rope controls, 3 clues, 3 hoisted rescues, one-shot supplies, pause, checkpoints and refuge completion passed. Uses teleports; does not prove physical route traversal." % checks)
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		print("FAIL mission integration: %d failures / %d checks." % [failures.size(), checks])
		quit(1)


func _test_rope() -> void:
	_move_to(_find("beacon", 31))
	mission._interact_node(_find("beacon", 31))
	_check(not mission.player.on_rope, "The orange rescue beacon still starts a personal rappel.")
	_move_to(_find("rappel", 31))
	await physics_frame
	var approach: Vector3 = mission.player.position
	mission._interact_node(_find("rappel", 31))
	_check(mission.player.on_rope and mission.player.rope_transfer == "attach", "The blue rooftop station did not begin a local belayed transfer.")
	_check(mission.player.position.is_equal_approx(approach), "Attaching teleported the capsule into the shaft.")
	mission.player._process_rope(0.85)
	_check(mission.player.rope_transfer.is_empty(), "The 0.85-second entry transfer did not finish.")
	var before_y: float = mission.player.position.y
	Input.action_press("move_back")
	mission.player._process_rope(1.0)
	Input.action_release("move_back")
	_check(before_y - mission.player.position.y > 1.5 and before_y - mission.player.position.y < 2.8, "S / move_back did not accelerate into a controlled descent.")
	_check(not mission.player.can_exit_rope(), "The rope allowed dismounting halfway between its two floors.")
	mission._interact()
	_check(mission.player.on_rope and mission.player.rope_transfer.is_empty(), "Interact bypassed the between-floor dismount restriction.")
	var old_anchors: int = mission.anchors
	_send_action("anchor")
	_check(mission.anchors == old_anchors - 1 and mission.player.secured_time > 0.0, "An anchor did not consume one item and stabilize the rope.")
	_send_action("anchor")
	_check(mission.anchors == old_anchors - 1, "Repeated anchoring consumed another item while stabilization was active.")
	Input.action_press("move_back")
	mission.player._process_rope(100.0)
	Input.action_release("move_back")
	_check(is_equal_approx(mission.player.position.y, 36.04), "The rooftop rope escaped its local floor-30 arrival clamp.")
	Input.action_press("move_forward")
	mission.player._process_rope(100.0)
	Input.action_release("move_forward")
	_check(is_equal_approx(mission.player.position.y, 42.04), "Rope ascent escaped the rooftop clamp.")
	Input.action_press("move_back")
	mission.player._process_rope(100.0)
	Input.action_release("move_back")
	_check(mission.player.can_exit_rope(), "A level-aligned player could not leave the rope.")
	mission._interact()
	_check(mission.player.on_rope and mission.player.rope_transfer == "exit", "Dismount skipped its belayed return transfer.")
	mission.player._process_rope(0.85)
	_check(not mission.player.on_rope and mission.player.nearest_floor() == 30, "Aligned dismount failed to land on floor 30.")
	_check(mission.player.position.x < -2.7, "Dismount left the player inside the west shaft opening.")
	old_anchors = mission.anchors
	_send_action("anchor")
	_check(mission.anchors == old_anchors, "Trying to anchor on foot consumed an item.")


func _test_pause() -> void:
	mission.health = 74.0
	mission.oxygen = 62.0
	mission.stress = 40.0
	mission.elapsed = 18.0
	var before: Array = [mission.health, mission.oxygen, mission.stress, mission.elapsed, mission.flares]
	mission._pause()
	mission._process(30.0)
	_send_action("flare")
	_check(mission.paused and not mission.player.active, "Pause did not stop player control.")
	_check([mission.health, mission.oxygen, mission.stress, mission.elapsed, mission.flares] == before, "Pause changed resources, time or accepted a flare action.")
	mission._resume()
	_check(not mission.paused and mission.player.active, "Resume did not restore player control.")


func _test_supply() -> void:
	var supply: Node3D = _find("supply", 29)
	_move_to(supply)
	mission.health = 50.0
	mission.oxygen = 35.0
	mission.anchors = 2
	mission.flares = 1
	mission._interact_node(supply)
	_check(mission.health == 80.0 and mission.oxygen == 100.0 and mission.anchors == 4 and mission.flares == 3, "The supply crate did not apply the expected resupply.")
	mission.health = 70.0
	mission.oxygen = 75.0
	mission._interact_node(supply)
	_check(mission.health == 70.0 and mission.oxygen == 75.0 and mission.supplies_used == ["supply_29"], "The supply crate could be used or counted twice.")


func _extract(number: int) -> void:
	var survivor: Node3D = _find("survivor", number)
	var before: int = mission.rescued.size()
	_move_to(survivor)
	mission._interact_node(survivor)
	_check(mission.carried == survivor and mission.player.carrying, "Survivor %d was not secured to the harness." % number)
	_check(mission.rescued.size() == before, "A merely carried survivor was counted as evacuated.")
	if number == 30:
		mission._interact_node(_find("survivor", 28))
		_check(mission.carried == survivor, "Picking another survivor replaced the carried person.")
	var beacon: Node3D = _find("beacon", number)
	_move_to(beacon)
	mission._interact_node(beacon)
	_check(mission.carried == null and not mission.player.carrying and mission.hoisting == survivor, "Survivor %d did not transition from carrying to hoisting." % number)
	_check(mission.rescued.size() == before, "Starting the hoist counted an unfinished rescue.")
	mission._pause()
	mission._process(10.0)
	_check(is_zero_approx(mission.hoist_progress), "The hoist continued while the mission was paused.")
	mission._resume()
	mission._process_hoist(5.1)
	_check(mission.hoisting == null and mission.rescued.size() == before + 1, "Survivor %d did not complete a five-second evacuation." % number)
	_check("survivor_%d" % number in mission.rescued, "The completed rescue has an incorrect stable ID.")
	mission._process_hoist(5.1)
	mission._interact_node(survivor)
	_check(mission.rescued.size() == before + 1 and mission.carried == null, "Survivor %d could be evacuated twice." % number)


func _move_to(target: Node3D) -> void:
	if target == null:
		return
	var number: int = int(target.get_meta("floor", 31))
	mission.player.teleport_to_floor(number)
	mission.player.position = target.global_position + Vector3(0.0 if target.get_meta("kind", "") == "rappel" else 1.1, 0.06, 0.0)
	mission._enter_floor(number)
	mission.last_floor = number


func _find(kind: String, number: int) -> Node3D:
	for target: Node3D in mission.world_data.get("interactables", []):
		if target.get_meta("kind", "") == kind and int(target.get_meta("floor", 0)) == number:
			return target
	_check(false, "Missing interaction target %s on floor %d." % [kind, number])
	return null


func _send_action(action: String) -> void:
	var event: InputEventAction = InputEventAction.new()
	event.action = action
	event.pressed = true
	mission._unhandled_input(event)


func _disable_automatic_ticks() -> void:
	mission.set_process(false)
	mission.player.set_physics_process(false)
	mission.world.set_process(false)


func _check(condition: bool, message: String) -> void:
	checks += 1
	if not condition:
		failures.append(message)


func _cleanup_save() -> void:
	for path: String in [TEST_PATH, PREFS_PATH, PREFS_PATH + ".tmp"]:
		if FileAccess.file_exists(path):
			DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
