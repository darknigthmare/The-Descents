extends SceneTree
## Real controls, migration, persistence and live camera/audio application.
## Rendered layout and physical mouse feel require the separate visual/manual review.

const Preferences = preload("res://scripts/preferences_store.gd")
const MainScene = preload("res://scenes/main.tscn")
const Player = preload("res://scripts/player_controller.gd")
const PREFS_PATH: String = "user://qa_v06_comfort.cfg"
const SAVE_PATH: String = "user://qa_v06_comfort.json"
var mission: Node3D
var failures: Array[String] = []
var checks: int = 0

func _initialize() -> void:
	_run.call_deferred()

func _run() -> void:
	_cleanup()
	var timer: SceneTreeTimer = create_timer(45.0)
	timer.timeout.connect(func():
		push_error("Comfort integration timed out.")
		_cleanup()
		quit(1)
	)
	_test_storage()
	await _test_player()
	await _test_live_controls()
	_cleanup()
	if failures.is_empty():
		print("PASS comfort: %d checks; legacy migration, finite ranges, safe writes, live volume/look/FOV, keyboard focus, paused options and reset without checkpoint changes." % checks)
		quit(0)
	else:
		for failure: String in failures:
			push_error(failure)
		print("FAIL comfort: %d failures / %d checks." % [failures.size(), checks])
		quit(1)

func _test_storage() -> void:
	var defaults: Dictionary = Preferences.DEFAULTS.duplicate()
	_check(Preferences.load_settings(PREFS_PATH) == defaults, "Missing settings did not retain the original audio/camera defaults.")
	var legacy: Dictionary = {"audio": false, "reduced_motion": false, "flashes": true, "startup_intro": false}
	_check(Preferences.save_settings(legacy, PREFS_PATH) == OK, "Complete legacy callers no longer save successfully.")
	_check(Preferences.load_settings(PREFS_PATH) == Preferences.normalize(legacy), "Legacy callers did not acquire independent new defaults.")
	var config: ConfigFile = ConfigFile.new()
	for key: String in legacy:
		config.set_value("comfort", key, legacy[key])
	config.save(PREFS_PATH)
	var original: String = FileAccess.get_file_as_string(PREFS_PATH)
	_check(Preferences.load_settings(PREFS_PATH) == Preferences.normalize(legacy), "A real v0.5 file failed to migrate in memory.")
	_check(FileAccess.get_file_as_string(PREFS_PATH) == original, "Reading a legacy config rewrote it before user intent.")
	var unsafe: Dictionary = {"master_volume": -8.0, "mouse_sensitivity": 999.0, "field_of_view": 1.0, "invert_y": "true", "unknown": 42}
	var preserved: Dictionary = unsafe.duplicate(true)
	var clean: Dictionary = Preferences.normalize(unsafe)
	_check(clean["master_volume"] == 0.0 and clean["mouse_sensitivity"] == 2.5 and clean["field_of_view"] == 65.0, "Numeric values outside supported ranges were not bounded.")
	_check(not clean["invert_y"] and not clean.has("unknown") and unsafe == preserved, "Normalization coerced a boolean, exposed an unknown key or mutated its input.")
	for key: String in Preferences.LIMITS:
		var limits: Vector2 = Preferences.LIMITS[key]
		_check(Preferences.valid_value(key, limits.x) and Preferences.valid_value(key, limits.y), "A supported range boundary was rejected: " + key)
		_check(not Preferences.valid_value(key, limits.x - 1.0) and not Preferences.valid_value(key, limits.y + 1.0), "A range escape was accepted for writing: " + key)
		for invalid: Variant in [true, "1.0", null, [], {}, NAN, INF, -INF]:
			var bad: Dictionary = defaults.duplicate()
			bad[key] = invalid
			_check(not Preferences.valid_value(key, invalid), "Invalid numeric type or nonfinite number accepted: " + key)
			_check(Preferences.normalize(bad)[key] == defaults[key], "Invalid numeric input did not fall back independently: " + key)
			_check(Preferences.save_settings(bad, PREFS_PATH) == ERR_INVALID_DATA, "Invalid numeric preferences reached the writer: " + key)
			_check(FileAccess.get_file_as_string(PREFS_PATH) == original, "Rejected numeric write damaged the legacy config.")
	_check(not Preferences.valid_value("invert_y", 1) and not Preferences.valid_value("unknown", true), "Boolean/unknown key validation is permissive.")
	var values: Dictionary = defaults.duplicate()
	values.merge({"audio": false, "master_volume": 0.45, "mouse_sensitivity": 1.75, "field_of_view": 91, "invert_y": true, "startup_intro": false}, true)
	var copy: Dictionary = values.duplicate()
	_check(Preferences.save_settings(values, PREFS_PATH) == OK, "A complete numeric settings set failed to save.")
	_check(Preferences.load_settings(PREFS_PATH) == Preferences.normalize(values) and values == copy, "Numeric preferences were lost or their source dictionary was mutated.")
	var bounded: ConfigFile = ConfigFile.new()
	bounded.set_value("comfort", "field_of_view", 170.0)
	bounded.set_value("comfort", "master_volume", -3.0)
	bounded.set_value("comfort", "invert_y", true)
	bounded.save(PREFS_PATH)
	clean = Preferences.load_settings(PREFS_PATH)
	_check(clean["field_of_view"] == 100.0 and clean["master_volume"] == 0.0 and clean["invert_y"], "Hand-edited config did not clamp numeric fields and retain valid booleans.")
	Preferences.save_settings(values, PREFS_PATH)

func _test_player() -> void:
	var player: CharacterBody3D = Player.new()
	var settings: Dictionary = Preferences.normalize({"mouse_sensitivity": 2.0, "field_of_view": 96.0, "invert_y": true})
	player.apply_comfort(settings)
	root.add_child(player)
	player.set_physics_process(false)
	await process_frame
	_check(is_equal_approx(player.camera.fov, 96.0) and is_equal_approx(player.sensitivity, 0.0048) and player.invert_y, "Pre-ready comfort was discarded by camera construction.")
	settings["field_of_view"] = 68.0
	settings["mouse_sensitivity"] = 0.5
	settings["invert_y"] = false
	player.apply_comfort(settings)
	_check(is_equal_approx(player.camera.fov, 68.0) and is_equal_approx(player.sensitivity, 0.0012) and not player.invert_y, "Live player settings do not affect the actual camera/controller.")
	# The headless display does not own an OS mouse capture. Exercise the
	# same look transformation used by the input event, then the inactive guard.
	player.active = true
	var motion: InputEventMouseMotion = InputEventMouseMotion.new()
	motion.relative = Vector2(10.0, 10.0)
	player._apply_mouse_look(motion.relative)
	_check(is_equal_approx(player.rotation.y, -0.012) and is_equal_approx(player.head.rotation.x, -0.012), "Normal mouse look does not preserve horizontal and vertical direction.")
	player.rotation = Vector3.ZERO
	player.head.rotation = Vector3.ZERO
	settings["invert_y"] = true
	player.apply_comfort(settings)
	player._apply_mouse_look(motion.relative)
	_check(is_equal_approx(player.rotation.y, -0.012) and is_equal_approx(player.head.rotation.x, 0.012), "Invert Y failed to reverse only the vertical mouse axis.")
	player.active = false
	var orientation: Vector3 = player.head.rotation
	player._unhandled_input(motion)
	_check(player.head.rotation == orientation, "Inactive player accepted mouse movement while a modal owns input.")
	player.free()
	await process_frame

func _test_live_controls() -> void:
	mission = MainScene.instantiate()
	mission.save_path = SAVE_PATH
	mission.preferences_path = PREFS_PATH
	root.add_child(mission)
	_disable_ticks()
	await process_frame
	var menu: Control = mission.hud.menu
	_check(is_equal_approx(mission.player.camera.fov, 91.0) and is_equal_approx(mission.player.sensitivity, 0.0042) and mission.player.invert_y, "Stored numeric settings were not applied before the first menu.")
	_check(is_equal_approx(db_to_linear(AudioServer.get_bus_volume_db(0)), 0.45) and AudioServer.is_bus_mute(0), "Master volume and independent audio mute disagree with saved settings.")
	_check(menu.sliders.size() == 3 and menu.toggles.size() == 5, "Options expose an incomplete set of controls.")
	menu._open_modal(menu.options)
	_check(root.gui_get_focus_owner() == menu.toggles["audio"] and menu.settings_scroll.follow_focus, "Options do not begin in an accessible focusable control.")
	var source_focus: Control = menu.sliders["master_volume"]
	source_focus.grab_focus()
	mission.hud.show_help()
	_check(mission.hud.help_panel.visible and menu.options.visible and _button_has_focus("Compris"), "Help did not open above menu options with a usable keyboard focus.")
	var cancel: InputEventAction = InputEventAction.new()
	cancel.action = "ui_cancel"
	cancel.pressed = true
	menu._unhandled_key_input(cancel)
	_check(mission.hud.help_panel.visible and menu.options.visible, "The underlying frontend consumed Escape while help owned the top modal.")
	await _send_escape()
	_check(not mission.hud.help_panel.visible and menu.options.visible and root.gui_get_focus_owner() == source_focus, "Real Escape failed to return from help to the original menu option.")
	var cinematic_fov: float = mission.menu_camera.fov
	menu.sliders["field_of_view"].value = 88.0
	_check(is_equal_approx(mission.player.camera.fov, 88.0) and Preferences.load_settings(PREFS_PATH)["field_of_view"] == 88.0, "FOV slider does not reach the live player and persisted config.")
	_check(is_equal_approx(mission.menu_camera.fov, cinematic_fov), "Gameplay FOV changed the cinematic framing.")
	menu.sliders["mouse_sensitivity"].value = 1.25
	_check(is_equal_approx(mission.player.sensitivity, 0.003) and Preferences.load_settings(PREFS_PATH)["mouse_sensitivity"] == 1.25, "Mouse slider failed to apply its multiplier.")
	menu.toggles["invert_y"].button_pressed = false
	_check(not mission.player.invert_y and not Preferences.load_settings(PREFS_PATH)["invert_y"], "Invert Y toggle did not propagate through the real menu signal.")
	menu.sliders["master_volume"].value = 0.0
	var silent_db: float = AudioServer.get_bus_volume_db(0)
	_check(is_finite(silent_db) and silent_db <= -79.9 and AudioServer.is_bus_mute(0), "Zero volume does not use a finite silent gain or unexpectedly unmutes audio.")
	menu.sliders["master_volume"].value = 0.6
	_check(is_equal_approx(db_to_linear(AudioServer.get_bus_volume_db(0)), 0.6) and AudioServer.is_bus_mute(0), "Adjusting volume changed the independent mute preference.")
	var before_invalid: Dictionary = mission.preferences.duplicate()
	var bytes: String = FileAccess.get_file_as_string(PREFS_PATH)
	for invalid: Array in [["field_of_view", "90"], ["master_volume", INF], ["invert_y", 1], ["unknown", true]]:
		mission._setting_changed(str(invalid[0]), invalid[1])
		_check(mission.preferences == before_invalid and FileAccess.get_file_as_string(PREFS_PATH) == bytes, "The live setting callback accepted invalid data.")
	_check(not FileAccess.file_exists(SAVE_PATH) and mission.elapsed == 0.0, "Menu comfort changes created a mission checkpoint or advanced the mission.")
	mission._start_new(271104)
	_disable_ticks()
	mission._setting_changed("reduced_motion", false)
	for sample_time: float in [3.0, 10.0, 17.0]:
		mission.cinematic.elapsed = sample_time
		var authored: Dictionary = mission.cinematic.camera_sample(false, mission.player.camera.global_position, -mission.player.camera.global_basis.z)
		mission._render_cinematic()
		_check(is_equal_approx(mission.menu_camera.fov, float(authored["fov"])), "A gameplay FOV preference altered an authored approach shot.")
	mission.cinematic.elapsed = 28.0
	mission._render_cinematic()
	_check(is_equal_approx(mission.menu_camera.fov, 88.0) and is_equal_approx(mission.player.camera.fov, 88.0), "The final moving handoff does not arrive at the selected gameplay FOV.")
	mission._finish_arrival()
	_check(is_equal_approx(mission.player.camera.fov, 88.0) and is_equal_approx(mission.player.sensitivity, 0.003), "World reconstruction lost gameplay comfort preferences.")
	mission._pause()
	mission.hud.show_comfort_settings()
	_check(mission.paused and menu.standalone_settings and menu.options.visible and not mission.hud.pause_panel.visible, "Paused options failed to open without resuming gameplay.")
	var checkpoint_bytes: String = FileAccess.get_file_as_string(SAVE_PATH)
	var elapsed_before: float = mission.elapsed
	mission.hud.show_help()
	_check(mission.paused and menu.standalone_settings and menu.options.visible and mission.hud.help_panel.visible and _button_has_focus("Compris"), "Help from paused options lost pause, modal context or keyboard focus.")
	await _send_escape()
	_check(mission.paused and menu.standalone_settings and menu.options.visible and not mission.hud.help_panel.visible, "Escape from paused help skipped the options layer or resumed the mission.")
	menu.sliders["field_of_view"].value = 93.0
	_check(mission.paused and not mission.player.active and mission.player.camera.fov == 93.0, "Adjusting a paused option resumed controls or failed to update the camera.")
	await _send_escape()
	_check(mission.paused and not menu.standalone_settings and not menu.visible and mission.hud.pause_panel.visible and _button_has_focus("Reprendre"), "Escape from paused options did not return to pause with its resume focus.")
	mission.hud.show_help()
	await _send_escape()
	_check(mission.paused and mission.hud.pause_panel.visible and not mission.hud.help_panel.visible and not menu.visible, "Escape from the pause help resumed gameplay or reopened the hidden menu.")
	mission.hud.show_comfort_settings()
	menu._reset_settings()
	_check(mission.preferences == Preferences.DEFAULTS and Preferences.load_settings(PREFS_PATH) == Preferences.DEFAULTS, "Reset did not persist the complete safe default set.")
	_check(mission.player.camera.fov == 77.0 and is_equal_approx(mission.player.sensitivity, 0.0024) and not mission.player.invert_y and mission.player.reduced_motion, "Reset failed to apply the original gameplay camera controls.")
	_check(is_equal_approx(AudioServer.get_bus_volume_db(0), 0.0) and not AudioServer.is_bus_mute(0), "Reset failed to restore master gain and audio enable independently.")
	_check(FileAccess.get_file_as_string(SAVE_PATH) == checkpoint_bytes and mission.elapsed == elapsed_before and mission.paused, "Comfort changes/reset modified the safe checkpoint or mission timing.")
	menu.close_modals()
	mission._resume()
	_check(not mission.paused and mission.player.active and not menu.visible and not menu.options.visible, "Resuming after the comfort panel left the menu or player in a stale state.")
	for channel: AudioStreamPlayer in [mission.audio_wind, mission.audio_radio, mission.audio_effect, mission.audio_score, mission.audio_rotors]:
		channel.stop()
	await create_timer(0.15).timeout
	mission.free()
	await process_frame
	await process_frame
	AudioServer.set_bus_mute(0, false)
	AudioServer.set_bus_volume_db(0, 0.0)

func _button_has_focus(title: String) -> bool:
	var focus: Control = root.gui_get_focus_owner()
	return focus is Button and (focus as Button).text == title

func _send_escape() -> void:
	var key: InputEventKey = InputEventKey.new()
	key.keycode = KEY_ESCAPE
	key.pressed = true
	Input.parse_input_event(key)
	await process_frame
	var release: InputEventKey = InputEventKey.new()
	release.keycode = KEY_ESCAPE
	release.pressed = false
	Input.parse_input_event(release)
	await process_frame

func _disable_ticks() -> void:
	mission.set_process(false)
	mission.player.set_process(false)
	mission.player.set_physics_process(false)
	mission.world.set_process(false)

func _cleanup() -> void:
	for path: String in [PREFS_PATH, PREFS_PATH + ".tmp", SAVE_PATH]:
		if FileAccess.file_exists(path):
			DirAccess.remove_absolute(ProjectSettings.globalize_path(path))

func _check(condition: bool, message: String) -> void:
	checks += 1
	if not condition:
		failures.append(message)
