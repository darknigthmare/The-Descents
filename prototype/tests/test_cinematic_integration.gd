extends SceneTree
## Drives real UI signals and mission clocks. It checks flow/state, not rendered pixels.

const MainScene = preload("res://scenes/main.tscn")
const Store = preload("res://scripts/save_store.gd")
const Preferences = preload("res://scripts/preferences_store.gd")
const Director = preload("res://scripts/cinematic_director.gd")
const TEST_PATH: String = "user://qa_v04_cinematic_integration.json"
const PREFS_PATH: String = "user://qa_v04_cinematic_integration.cfg"
var mission: Node3D
var failures: Array[String] = []
var checks: int = 0


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	_cleanup()
	var timer: SceneTreeTimer = create_timer(40.0)
	timer.timeout.connect(func():
		push_error("Cinematic integration timed out.")
		_cleanup()
		quit(1)
	)
	var comfortable: Dictionary = Preferences.normalize({"audio": false, "reduced_motion": true, "flashes": false, "startup_intro": false})
	_check(Preferences.save_settings(comfortable, PREFS_PATH) == OK, "Could not prepare isolated comfort settings.")
	mission = MainScene.instantiate()
	mission.save_path = TEST_PATH
	mission.preferences_path = PREFS_PATH
	root.add_child(mission)
	_disable_ticks()
	await process_frame
	_check(mission.preferences == comfortable and not mission.sound_enabled and mission.reduced_motion and not mission.flashes_enabled, "Stored comfort preferences were not applied before any sequence.")
	_check(mission.player.reduced_motion and mission.hud.menu.toggles["reduced_motion"].button_pressed and AudioServer.is_bus_mute(0), "The player, menu and audio bus disagree with loaded comfort settings.")
	_check(is_instance_valid(mission.audio_score) and mission.audio_score.stream != null and mission.audio_score.stream.get_length() > 0.0, "The menu score has no imported playable stream.")
	_check(is_instance_valid(mission.audio_rotors) and mission.audio_rotors.stream != null and mission.audio_rotors.stream.get_length() > 0.0, "The approach rotors have no imported playable stream.")
	_check(not mission.boot_playing and not mission.started and mission.hud.menu.visible, "Headless initialization failed to expose the menu without automatic boot.")
	_check(mission.menu_context.get("id") == "approach" and mission.incident.phase == "intact" and mission.world.twin_tower.rotation.is_zero_approx(), "An empty installation reveals future structural damage.")
	_check(not mission.hud.continue_button.visible and mission.hud.continue_button.disabled, "The no-save menu offers an invalid continuation.")
	_check((mission.menu_camera.cull_mask & 1) != 0 and (mission.menu_camera.cull_mask & 2) == 0, "Menu/cinematic camera exposes gameplay markers or hides the world geometry.")
	var billboard_count: int = 0
	var markers_separate: bool = true
	for label: Label3D in mission.world.find_children("*", "Label3D", true, false):
		if label.billboard != BaseMaterial3D.BILLBOARD_DISABLED:
			billboard_count += 1
			markers_separate = markers_separate and (label.layers & 2) != 0 and (label.layers & 1) == 0
	_check(billboard_count > 0 and markers_separate, "Billboard gameplay labels are not isolated from scenic cameras.")
	mission._process(40.0)
	_check(mission.elapsed == 0.0 and not FileAccess.file_exists(TEST_PATH), "Waiting at the menu advanced mission time or wrote a checkpoint.")
	_press(mission.hud.menu, "DOSSIER DE MISSION")
	_check(mission.hud.menu.dossier.visible and mission.hud.menu.mission_text.text.contains("sont debout") and not mission.hud.menu.mission_text.text.contains("fait basculer"), "The first dossier reveals an unreached incident or fails to open.")
	_press(mission.hud.menu.dossier, "COMMANDES ET MATÉRIEL")
	_check(mission.hud.help_panel.visible, "Dossier commands did not open the help overlay.")
	_press(mission.hud.help_panel, "Compris")
	_check(not mission.hud.help_panel.visible and mission.hud.menu.dossier.visible, "Closing help did not return to the dossier.")
	_press(mission.hud.menu.dossier, "RETOUR")
	_check(not mission.hud.menu.has_modal() and root.gui_get_focus_owner() == mission.hud.start_button, "Closing the dossier failed to return keyboard focus to the main action.")
	_press(mission.hud.menu, "OPTIONS")
	_check(mission.hud.menu.options.visible and not mission.hud.menu.dossier.visible, "Options failed to replace the previous modal.")
	for key: String in ["audio", "reduced_motion", "flashes", "startup_intro"]:
		var toggle: CheckButton = mission.hud.menu.toggles[key]
		toggle.button_pressed = not toggle.button_pressed
		_check(Preferences.load_settings(PREFS_PATH).get(key) == toggle.button_pressed and mission.preferences[key] == toggle.button_pressed, "Changing %s did not persist through its real menu signal." % key)
	mission.hud.menu.toggles["audio"].button_pressed = false
	_check(not mission.reduced_motion and mission.flashes_enabled and not mission.sound_enabled, "Changed comfort settings were not applied to the live session.")
	_press(mission.hud.menu.options, "COMMANDES")
	_check(mission.hud.help_panel.visible, "Options commands failed to open help.")
	_press(mission.hud.help_panel, "Compris")
	_send_menu_cancel()
	_check(not mission.hud.menu.has_modal() and not mission.started, "Escape failed to close the options modal without starting a game.")
	var preference_bytes: String = FileAccess.get_file_as_string(PREFS_PATH)

	for sample: Array in [[31, "intact"], [30, "intact"], [29, "intact"], [29, "aftermath"], [28, "aftermath"]]:
		var saved: Dictionary = _fixture(int(sample[0]), str(sample[1]))
		_check(Store.save_data(saved, TEST_PATH) == OK, "Could not write a validated menu-preview fixture.")
		var original: String = FileAccess.get_file_as_string(TEST_PATH)
		mission._prepare_menu()
		_disable_ticks()
		var expected: Dictionary = saved.duplicate(true)
		expected["version"] = Store.SAVE_VERSION
		expected["continuation"] = {"phase": "dormant", "started_at_refuge": false, "duo_briefed": false, "escort_state": "waiting"}
		expected["commerce"] = preload("res://scripts/commerce_director.gd").dormant_state()
		_check(mission.menu_context["floor"] == sample[0] and mission.menu_context["incident"] == sample[1] and mission.menu_snapshot == expected, "Menu preview did not preserve the validated legacy checkpoint through its explicit schema migration.")
		_check(mission.current_seed == saved["seed"] and mission.world.roof_rescued_people["survivor_30"].visible and not _find("survivor", 30).visible, "Menu reconstructed the wrong seed or duplicated a confirmed rescue.")
		_check((not mission.world.twin_tower.rotation.is_zero_approx()) == (sample[1] == "aftermath"), "Menu revealed future tower damage or concealed already witnessed damage.")
		var previous_elapsed: float = mission.elapsed
		mission._process(90.0)
		_check(mission.elapsed == previous_elapsed and FileAccess.get_file_as_string(TEST_PATH) == original, "Live menu preview advanced mission time or modified its checkpoint.")
	_check(mission.hud.continue_button.visible and not mission.hud.continue_button.disabled, "A valid checkpoint failed to enable the continuation action.")
	var preview_bytes: String = FileAccess.get_file_as_string(TEST_PATH)
	var preview_context: Dictionary = mission.menu_context.duplicate(true)
	_press(mission.hud.menu, "REVOIR L’INTRODUCTION")
	_disable_ticks()
	_check(mission.boot_playing and mission.hud.cinematic.visible and not mission.hud.menu.visible and not mission.started, "Replay did not start the studio sequence independently of the mission.")
	_check(mission.incident.phase == "intact" and mission.rescued.is_empty(), "The signature sequence leaked a later damaged-world state.")
	var boot_elapsed: float = mission.elapsed
	mission._process(7.0)
	_check(mission.elapsed == boot_elapsed and FileAccess.get_file_as_string(TEST_PATH) == preview_bytes, "Studio replay advanced mission time or overwrote the saved intervention.")
	mission.hud.cinematic.skip_button.pressed.emit()
	_disable_ticks()
	_check(not mission.boot_playing and mission.hud.menu.visible and not mission.hud.cinematic.visible, "The studio skip button did not return to the menu.")
	_check(mission.menu_context == preview_context and mission.incident.phase == "aftermath" and FileAccess.get_file_as_string(TEST_PATH) == preview_bytes, "Skipping replay lost the previously validated checkpoint context.")
	mission._start_studio_intro()
	_disable_ticks()
	mission._process(14.99)
	_check(mission.boot_playing, "Studio sequence ended before its fifteen seconds.")
	mission._process(0.02)
	_disable_ticks()
	_check(not mission.boot_playing and mission.hud.menu.visible and mission.menu_context == preview_context, "Natural studio completion did not restore the contextual menu.")
	_check(FileAccess.get_file_as_string(TEST_PATH) == preview_bytes and FileAccess.get_file_as_string(PREFS_PATH) == preference_bytes, "Replay completion modified progress or comfort preferences.")

	var corrupt: String = "{\"version\":3}"
	_write_save(corrupt)
	mission.hud.continue_button.pressed.emit()
	_check(not mission.started and mission.hud.continue_button.disabled, "Continue entered play after the checkpoint became invalid.")
	mission._prepare_menu()
	_disable_ticks()
	_check(mission.menu_snapshot.is_empty() and mission.menu_context["id"] == "approach" and mission.incident.phase == "intact", "Invalid checkpoint leaked stale progress into the menu.")
	_check(not mission.hud.continue_button.visible and FileAccess.get_file_as_string(TEST_PATH) == corrupt, "Preparing a corrupt-save menu rewrote its bytes or offered continuation.")
	var finished: Dictionary = _fixture(25, "aftermath")
	finished["completed"] = true
	finished["rescued"] = ["survivor_30", "survivor_28", "survivor_26"]
	_check(Store.save_data(finished, TEST_PATH) == OK, "Could not prepare a completed checkpoint.")
	mission._prepare_menu()
	_disable_ticks()
	_check(mission.menu_context["id"] == "refuge" and mission.hud.continue_button.text.contains("TERMINÉE"), "Completed checkpoint did not expose its achieved final-report action.")
	mission.hud.continue_button.pressed.emit()
	_disable_ticks()
	_check(mission.completed and mission.hud.end_panel.visible and not mission.arrival_playing and not mission.boot_playing, "Continuing completion replayed an introduction or failed to expose its report.")
	mission._return_to_menu()
	_disable_ticks()
	var completed_bytes: String = FileAccess.get_file_as_string(TEST_PATH)
	mission.hud.start_button.pressed.emit()
	_check(mission.hud.menu.new_panel.visible and mission.hud.menu.replacement_note.visible and not mission.started, "New intervention bypassed its replacement confirmation.")
	_check(FileAccess.get_file_as_string(TEST_PATH) == completed_bytes, "Merely opening new intervention replaced the existing checkpoint.")
	_press(mission.hud.menu.new_panel, "RETOUR")
	_check(not mission.hud.menu.new_panel.visible and FileAccess.get_file_as_string(TEST_PATH) == completed_bytes, "Cancelling deployment changed saved progress.")
	mission.hud.start_button.pressed.emit()
	mission.hud.seed_input.value = 50231
	_press(mission.hud.menu.new_panel, "DÉPLOYER ALPHA")
	_disable_ticks()
	_check(mission.started and mission.arrival_playing and not mission.player.active and mission.menu_camera.current and mission.hud.cinematic.visible, "Confirmed deployment did not begin the controlled helicopter approach.")
	var initial: Dictionary = Store.load_data(TEST_PATH)
	_check(initial.get("seed") == 50231 and initial.get("floor") == 31 and initial.get("rescued", ["old"]).is_empty(), "Confirmed deployment failed to create a valid new rooftop checkpoint.")
	_check(FileAccess.get_file_as_string(PREFS_PATH) == preference_bytes and not mission.reduced_motion and mission.flashes_enabled, "A new intervention discarded previously chosen comfort preferences.")
	var initial_bytes: String = FileAccess.get_file_as_string(TEST_PATH)
	mission._process(0.59)
	_check(mission.radio.history.is_empty() and mission.elapsed == 0.0, "Approach emitted its first cue too early or started the mission clock.")
	for index in range(4):
		var target_time: float = float(Director.ARRIVAL_CUES[index]["at"])
		mission._process(target_time - mission.arrival_time)
		_check(mission.radio.history.size() == index + 1 and mission.radio.current.get("message") == Director.ARRIVAL_CUES[index]["message"], "Arrival radio cue %d was lost, duplicated or presented out of order." % index)
		_check(mission.elapsed == 0.0 and mission.health == 100.0 and mission.oxygen == 100.0, "Arrival advanced mission time or survival resources.")
	_send_mission_action("pause_game")
	var paused_time: float = mission.arrival_time
	var paused_radio: float = mission.radio.remaining
	_check(mission.paused and mission.hud.pause_panel.visible and not mission.hud.cinematic.visible, "Pausing arrival left its overlay covering the pause controls.")
	mission._process(100.0)
	mission.hud.cinematic.skip_button.pressed.emit()
	_check(mission.arrival_playing and mission.arrival_time == paused_time and mission.radio.remaining == paused_radio and mission.elapsed == 0.0, "Paused arrival advanced, consumed radio or accepted a hidden skip.")
	_press(mission.hud.pause_panel, "Reprendre")
	_disable_ticks()
	_check(not mission.paused and mission.arrival_playing and mission.hud.cinematic.visible and not mission.player.active, "Resuming arrival prematurely granted movement or hid its sequence.")
	mission._process(Director.ARRIVAL_DURATION - mission.arrival_time - 0.01)
	_check(mission.arrival_playing and mission.elapsed == 0.0, "The approach ended before twenty-eight seconds.")
	mission._process(0.02)
	_check(not mission.arrival_playing and mission.player.active and mission.player.camera.current and mission.hud.game.visible and not mission.hud.cinematic.visible, "Natural arrival completion failed to transfer first-person control.")
	_check((mission.player.camera.cull_mask & 3) == 3, "Player camera did not retain both world geometry and gameplay markers after the cinematic handoff.")
	_check(mission.menu_camera.global_position.is_equal_approx(mission.player.camera.global_position) and mission.menu_camera.global_basis.z.is_equal_approx(mission.player.camera.global_basis.z), "The final unrestricted arrival camera does not meet the player pose.")
	_check(mission.elapsed == 0.0 and mission.radio.history.size() == 4 and FileAccess.get_file_as_string(TEST_PATH) == initial_bytes, "Arrival finish leaked elapsed time, duplicated cues or changed the initial safe checkpoint.")
	mission._process(0.25)
	_check(is_equal_approx(mission.elapsed, 0.25), "The mission clock failed to begin when player control was returned.")
	mission._return_to_menu()
	_disable_ticks()
	_check(FileAccess.get_file_as_string(TEST_PATH) == initial_bytes and mission.menu_context["floor"] == 31, "Returning from active play modified the previous safe checkpoint.")
	mission._start_new(50232)
	_disable_ticks()
	mission._process(1.0)
	mission.hud.cinematic.skip_button.pressed.emit()
	_check(not mission.arrival_playing and mission.player.active and mission.elapsed == 0.0 and mission.radio.history.size() == 1, "Skipping arrival advanced the mission clock or emitted unplayed future cues.")
	mission._skip_cinematic()
	_check(mission.player.active and mission.radio.history.size() == 1 and mission.incident.phase == "intact", "A repeated skip replayed cues or triggered the structural incident.")
	mission.free()
	# Let deferred scene/audio retirement finish before constructing a new scene.
	await process_frame
	await process_frame
	mission = MainScene.instantiate()
	mission.save_path = TEST_PATH
	mission.preferences_path = PREFS_PATH
	root.add_child(mission)
	_disable_ticks()
	_check(mission.preferences == Preferences.load_settings(PREFS_PATH) and not mission.reduced_motion and mission.flashes_enabled and not mission.sound_enabled, "Restart did not apply persisted comfort settings before its sequence.")
	mission._start_studio_intro()
	_disable_ticks()
	var camera_before: Vector3 = mission.menu_camera.position
	mission._process(3.0)
	_check(mission.menu_camera.position != camera_before and not mission.hud.menu.toggles["reduced_motion"].button_pressed, "Replayed intro ignored the persisted movement preference.")
	mission.free()
	await process_frame
	await process_frame
	_cleanup()
	_finish()


func _fixture(floor_number: int, phase: String) -> Dictionary:
	return {"version": 3, "seed": 77123, "floor": floor_number, "health": 93.0, "oxygen": 82.0, "stress": 17.0, "anchors": 4, "flares": 2, "rescued": ["survivor_30"], "clues": ["evidence_29"], "supplies_used": [], "elapsed": 50.0, "seen_floors": [31, 30, 29], "completed": false, "incident_state": phase, "transmissions": [], "radio_events": []}


func _press(parent: Node, title: String) -> void:
	var target: Button
	for child: Node in parent.find_children("*", "Button", true, false):
		if child is Button and child.text == title:
			target = child
			break
	_check(is_instance_valid(target), "Required UI button is missing: %s." % title)
	if is_instance_valid(target):
		target.pressed.emit()


func _send_menu_cancel() -> void:
	var event: InputEventAction = InputEventAction.new()
	event.action = "ui_cancel"
	event.pressed = true
	mission.hud.menu._unhandled_key_input(event)


func _send_mission_action(action: String) -> void:
	var event: InputEventAction = InputEventAction.new()
	event.action = action
	event.pressed = true
	mission._unhandled_input(event)


func _find(kind: String, floor_number: int) -> Node3D:
	for target: Node3D in mission.world_data.get("interactables", []):
		if target.get_meta("kind", "") == kind and int(target.get_meta("floor", 0)) == floor_number:
			return target
	return null


func _disable_ticks() -> void:
	mission.set_process(false)
	mission.player.set_process(false)
	mission.player.set_physics_process(false)
	mission.world.set_process(false)


func _write_save(value: String) -> void:
	var file: FileAccess = FileAccess.open(TEST_PATH, FileAccess.WRITE)
	file.store_string(value)
	file.close()


func _cleanup() -> void:
	for path: String in [TEST_PATH, PREFS_PATH, PREFS_PATH + ".tmp"]:
		if FileAccess.file_exists(path):
			DirAccess.remove_absolute(ProjectSettings.globalize_path(path))


func _check(condition: bool, message: String) -> void:
	checks += 1
	if not condition:
		failures.append(message)


func _finish() -> void:
	if failures.is_empty():
		print("PASS cinematic integration: %d checks; real menu buttons, preserved checkpoints, validated contexts, persisted comfort, studio replay, timed arrival and pause/skip/control handoff. Logic checks; rendered presentation requires separate visual QA." % checks)
		quit(0)
	else:
		for failure: String in failures:
			push_error(failure)
		print("FAIL cinematic integration: %d failures / %d checks." % [failures.size(), checks])
		quit(1)
