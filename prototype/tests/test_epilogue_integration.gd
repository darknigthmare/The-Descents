extends SceneTree
## Real mission/HUD signals, explicit placements and clocks. This suite checks
## completion integrity and modal ownership; it is not a human playthrough.

const MainScene = preload("res://scenes/main.tscn")
const Store = preload("res://scripts/save_store.gd")
const Preferences = preload("res://scripts/preferences_store.gd")
const SAVE_PATH: String = "user://qa_v07_epilogue_integration.json"
const PREFS_PATH: String = "user://qa_v07_epilogue_integration.cfg"
var mission: Node3D
var failures: Array[String] = []
var checks: int = 0

func _initialize() -> void:
	_run.call_deferred()

func _run() -> void:
	_cleanup()
	var timeout: SceneTreeTimer = create_timer(45.0)
	timeout.timeout.connect(func():
		push_error("Epilogue integration timed out.")
		_cleanup()
		quit(1)
	)
	Preferences.save_settings(Preferences.normalize({"audio": false, "startup_intro": false}), PREFS_PATH)
	mission = MainScene.instantiate()
	mission.save_path = SAVE_PATH
	mission.preferences_path = PREFS_PATH
	root.add_child(mission)
	_disable_ticks()
	await process_frame
	mission.hud.epilogue_replay_requested.emit()
	_check(not mission.epilogue_playing and not FileAccess.file_exists(SAVE_PATH), "A hidden replay action started a film or saved before any mission.")
	mission._start_new(271104)
	_disable_ticks()
	mission.hud.epilogue_replay_requested.emit()
	_check(mission.arrival_playing and not mission.epilogue_playing, "A hidden final replay interrupted the arrival.")
	mission._finish_arrival()
	mission.elapsed = 90.0
	mission._complete_game()
	_check(not mission.completed and not mission.epilogue_playing, "An incomplete intervention entered its ending.")
	mission._interact_node(_find("evidence", 29))
	var projection: Dictionary = mission._dossier_snapshot()
	_check(projection["clue_records"].size() == 1 and projection["clue_records"][0]["id"] == "evidence_29", "Main leaked uncollected clue records into the dossier projection.")
	projection["clues"].clear()
	projection["clue_records"][0]["title"] = "changed outside mission"
	_check(mission.clues == ["evidence_29"] and mission._dossier_snapshot()["clue_records"][0]["title"] != "changed outside mission", "The dossier projection aliases mutable mission content.")
	mission._open_journal()
	_check(mission.paused and mission.hud.journal_panel.visible and not mission.player.active, "Reading the active journal failed to suspend gameplay.")
	mission.hud.journal_panel.tab_buttons["clues"].pressed.emit()
	_check(mission.hud.journal_panel.selected_tab == "clues" and mission.hud.journal_text.text.contains(mission._dossier_snapshot()["clue_records"][0]["title"]), "A real clue-tab action did not display the collected record.")
	mission.hud.journal_panel.close_button.pressed.emit()
	_disable_ticks()
	_check(not mission.paused and mission.player.active and not mission.hud.journal_panel.visible, "Closing an active journal did not return control to the player.")
	_extract(30)
	mission.incident.restore("aftermath")
	mission.world.apply_incident("aftermath", 0.0)
	_extract(28)
	_extract(26)
	mission.health = 78.0
	mission.oxygen = 83.0
	mission.stress = 41.0
	mission.player.teleport_to_floor(25)
	mission.world.set_process(true)
	var before_failed_completion: String = FileAccess.get_file_as_string(SAVE_PATH)
	mission.save_path = "user://qa_v07_absent_%d/completion.json" % Time.get_ticks_usec()
	mission._interact_node(_find("refuge", 25))
	_check(not mission.completed and not mission.epilogue_playing and mission.player.active and mission.hud.game.visible, "A failed final save locked the player into an undurable ending.")
	_check(mission.hud.notify_label.visible and mission.hud.notify_label.text.contains("Sauvegarde impossible"), "A failed final save hid its actionable error behind the film.")
	_check(FileAccess.get_file_as_string(SAVE_PATH) == before_failed_completion, "A failed completion damaged the previous valid checkpoint.")
	mission.save_path = SAVE_PATH
	mission._interact_node(_find("refuge", 25))
	_check(mission.completed and mission.epilogue_playing and mission.hud.cinematic.visible and not mission.hud.end_panel.visible, "The first valid refuge completion did not enter its closing sequence.")
	_check(not mission.player.active and not mission.world.is_processing() and mission.menu_camera.current, "The closing sequence left gameplay or world simulation active.")
	_disable_ticks()
	var final_save: Dictionary = Store.load_data(SAVE_PATH)
	var saved_bytes: String = FileAccess.get_file_as_string(SAVE_PATH)
	_check(final_save.get("completed", false) and final_save.get("floor") == 25 and final_save.get("rescued", []).size() == 3, "Completion was not durable before the first epilogue frame.")
	var frozen: Dictionary = _state()
	mission._process(2.0)
	_check(is_equal_approx(mission.epilogue.elapsed, 2.0) and mission.epilogue.presentation()["shot"] == 0, "The closing film did not use its independent timeline.")
	_check(_state() == frozen and FileAccess.get_file_as_string(SAVE_PATH) == saved_bytes, "A closing frame advanced mission state, radio or checkpoint bytes.")
	mission._open_journal()
	_check(not mission.hud.journal_panel.visible and not mission.paused, "Journal input covered an active closing film.")
	# Exercise an actual stream while the bus remains muted. Stopped channels
	# legitimately report stream_paused=false because they own no playback.
	mission.audio_wind.play()
	_action("pause_game")
	var camera_before: Transform3D = mission.menu_camera.transform
	_check(mission.paused and mission.hud.pause_panel.visible and not mission.hud.cinematic.visible, "Pause failed to expose its controls above the closing film.")
	for channel: AudioStreamPlayer in [mission.audio_wind, mission.audio_radio, mission.audio_effect, mission.audio_score, mission.audio_rotors]:
		_check(not channel.playing or channel.stream_paused, "Pause left an audio channel advancing during the ending.")
	mission._process(60.0)
	mission._process_epilogue(60.0)
	mission.hud.cinematic.skip_button.pressed.emit()
	_check(mission.epilogue_playing and mission.epilogue.elapsed == 2.0 and mission.menu_camera.transform == camera_before, "Paused closing film advanced or accepted a hidden skip.")
	mission.hud.show_comfort_settings()
	mission.hud.show_help()
	_action("pause_game")
	_check(mission.paused and not mission.hud.help_panel.visible and mission.hud.menu.options.visible and not mission.hud.cinematic.visible, "Escape skipped the help/options layer during the epilogue pause.")
	mission.hud.menu.sliders["field_of_view"].value = 92.0
	_check(mission.player.camera.fov == 92.0 and mission.menu_camera.transform == camera_before, "A gameplay FOV option moved the suspended cinematic camera.")
	_action("pause_game")
	_check(mission.paused and mission.hud.pause_panel.visible and not mission.hud.menu.standalone_settings, "Closing epilogue options did not restore the pause screen.")
	_action("pause_game")
	_check(not mission.paused and mission.epilogue_playing and mission.hud.cinematic.visible and not mission.hud.end_panel.visible, "Resuming the closing film exposed the report or lost the film.")
	_check(not mission.player.active and not mission.world.is_processing() and _state() == frozen, "Resuming the ending restarted gameplay or mutated mission state.")
	_disable_ticks()
	mission._process(12.99)
	_check(mission.epilogue_playing and mission.epilogue.elapsed < 15.0, "The closing sequence ended before its final frame.")
	mission._process(0.02)
	await process_frame
	_check(not mission.epilogue_playing and mission.hud.end_panel.visible and not mission.hud.cinematic.visible, "Natural completion failed to replace the film with its debrief.")
	_check(root.gui_get_focus_owner() == mission.hud.end_journal_button, "The debrief did not expose its primary action to keyboard navigation.")
	var final_model: Dictionary = mission.hud.end_panel.model.duplicate(true)
	_check(final_model["rescued_count"] == 3 and final_model["clue_count"] == 1, "Debrief counters do not reflect the actual rescue and clue ledger.")
	_check(_state() == frozen and FileAccess.get_file_as_string(SAVE_PATH) == saved_bytes, "Natural completion altered mission outcomes or persisted a new save.")
	mission.hud.end_panel.replay_button.pressed.emit()
	_check(mission.epilogue_playing and mission.epilogue.elapsed == 0.0 and not mission.hud.end_panel.visible, "The report's replay action did not start a fresh read-only film.")
	mission._process(7.0)
	_action("interact")
	_check(not mission.epilogue_playing and mission.hud.end_panel.visible and mission.hud.end_panel.model == final_model, "Skipping a replay produced a different report.")
	_check(_state() == frozen and FileAccess.get_file_as_string(SAVE_PATH) == saved_bytes, "Skipping replay changed the checkpoint, radio ledger or mission statistics.")
	mission.hud.end_journal_button.pressed.emit()
	await process_frame
	_check(mission.paused and mission.hud.journal_panel.visible and not mission.hud.end_panel.visible, "The final report's journal remained behind the report.")
	mission.hud.epilogue_replay_requested.emit()
	_check(not mission.epilogue_playing, "A hidden replay signal interrupted the final journal.")
	mission.hud.journal_panel.tab_buttons["transmissions"].pressed.emit()
	_check(mission.hud.journal_text.text.contains("réception confirmée") and not mission.hud.journal_text.text.contains("Il y a de la lumière dessous"), "The received transcript lost rescue confirmations or invented film excerpts as received radio.")
	_action("pause_game")
	_check(mission.hud.end_panel.visible and not mission.hud.journal_panel.visible and not mission.player.active, "Closing the final journal failed to restore its frozen report.")
	mission.hud.end_panel.replay_button.pressed.emit()
	mission._process(4.0)
	_action("pause_game")
	mission._return_to_menu()
	_disable_ticks()
	_check(not mission.epilogue_playing and not mission.completed and mission.hud.menu.visible and mission.menu_context["id"] == "refuge", "Leaving a suspended ending failed to restore the achieved refuge menu.")
	_check(FileAccess.get_file_as_string(SAVE_PATH) == saved_bytes, "Returning to the contextual menu rewrote completion.")
	mission.hud.continue_button.pressed.emit()
	_disable_ticks()
	_check(mission.completed and not mission.epilogue_playing and mission.hud.end_panel.visible and not mission.radio.is_busy(), "Continuing completion replayed the film/radio or hid the report.")
	_check(FileAccess.get_file_as_string(SAVE_PATH) == saved_bytes and mission.radio.history_snapshot() == final_save["transmissions"], "Reading a completed save changed its bytes or received transcript.")
	_check(mission.hud.end_panel.model == final_model, "Reloading completion changed the report's factual model.")
	mission.hud.end_panel.replay_button.pressed.emit()
	mission._process(2.0)
	mission._start_new(50231)
	_disable_ticks()
	_check(not mission.epilogue_playing and mission.arrival_playing and not mission.completed and mission.rescued.is_empty(), "A new intervention retained the ending or its confirmed rescues.")
	_check(mission.hud.cinematic.skip_button.text.contains("PASSER") and not mission.hud.cinematic.skip_button.text.contains("BILAN"), "The arrival inherited the ending's skip action.")
	mission._return_to_menu()
	_disable_ticks()
	var corrupt: Dictionary = final_save.duplicate(true)
	corrupt["rescued"] = ["survivor_30"]
	var corrupt_bytes: String = JSON.stringify(corrupt)
	var file: FileAccess = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	file.store_string(corrupt_bytes)
	file.close()
	mission._continue_game()
	_check(not mission.started and not mission.epilogue_playing and mission.hud.continue_button.disabled, "An inconsistent completion started a film naming unreceived people.")
	_check(FileAccess.get_file_as_string(SAVE_PATH) == corrupt_bytes, "Rejecting inconsistent completion modified the existing file.")
	mission.free()
	await process_frame
	_cleanup()
	if failures.is_empty():
		print("PASS epilogue integration: %d checks; real completion and dossier signals, independent clock, nested pause/options, durable final report, read-only replay, restore and new-game isolation." % checks)
		quit(0)
	else:
		for failure: String in failures:
			push_error(failure)
		print("FAIL epilogue integration: %d failures / %d checks." % [failures.size(), checks])
		quit(1)

func _state() -> Dictionary:
	return {"snapshot": mission._dossier_snapshot(), "radio_current": mission.radio.current.duplicate(true),
		"radio_pending": mission.radio.pending.duplicate(true), "radio_remaining": mission.radio.remaining,
		"radio_events": mission.radio_events.duplicate(), "incident_time": mission.incident.phase_elapsed,
		"player_position": mission.player.position, "carried": mission.carried, "hoisting": mission.hoisting}

func _extract(floor_number: int) -> void:
	mission.player.teleport_to_floor(floor_number)
	mission._interact_node(_find("survivor", floor_number))
	mission._interact_node(_find("beacon", floor_number))
	mission._process_hoist(5.01)

func _find(kind: String, floor_number: int) -> Node3D:
	for object: Node3D in mission.world_data.get("interactables", []):
		if object.get_meta("kind", "") == kind and int(object.get_meta("floor", 0)) == floor_number:
			return object
	return null

func _action(action: String) -> void:
	var event: InputEventAction = InputEventAction.new()
	event.action = action
	event.pressed = true
	mission._unhandled_input(event)

func _disable_ticks() -> void:
	mission.set_process(false)
	mission.player.set_process(false)
	mission.player.set_physics_process(false)
	mission.world.set_process(false)

func _cleanup() -> void:
	for path: String in [SAVE_PATH, PREFS_PATH]:
		if FileAccess.file_exists(path):
			DirAccess.remove_absolute(ProjectSettings.globalize_path(path))

func _check(condition: bool, message: String) -> void:
	checks += 1
	if not condition:
		failures.append(message)
