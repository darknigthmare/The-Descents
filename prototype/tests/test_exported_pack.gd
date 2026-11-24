extends SceneTree
## External smoke test: run from an EMPTY directory, with the EXE/PCK mounted
## by --main-pack and this script supplied by its absolute filesystem path.
## This script is excluded from the exported resources and is counted separately.

const Store = preload("res://scripts/save_store.gd")
const Preferences = preload("res://scripts/preferences_store.gd")
const Director = preload("res://scripts/cinematic_director.gd")
const TEST_PATH: String = "user://qa_v04_external_pack.json"
const PREFS_PATH: String = "user://qa_v04_external_pack.cfg"
var failures: Array[String] = []
var checks: int = 0


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	_cleanup()
	_check(ProjectSettings.get_setting("application/config/version", "") == "0.4.0", "Packed project has the wrong application version.")
	_check(not ResourceLoader.exists("res://tests/test_save.gd") and not ResourceLoader.exists("res://tests/test_cinematic_integration.gd"), "Developer tests unexpectedly shipped inside the pack.")
	var scene: PackedScene = load("res://scenes/main.tscn")
	_check(scene != null, "The mounted pack has no loadable main scene.")
	if scene == null:
		_cleanup()
		_finish()
		return
	_check(Preferences.save_settings({"audio": false, "reduced_motion": true, "flashes": false, "startup_intro": false}, PREFS_PATH) == OK, "Packed preferences code could not write an isolated valid configuration.")
	var mission: Node3D = scene.instantiate()
	mission.save_path = TEST_PATH
	mission.preferences_path = PREFS_PATH
	mission.sound_enabled = false
	root.add_child(mission)
	_disable_ticks(mission)
	await process_frame
	_check(not mission.started and mission.hud.menu.visible and not mission.hud.cinematic.visible and mission.menu_context["id"] == "approach", "Packed scene failed to enter its accessible initial menu.")
	_check(mission.world_data.get("helicopters", []).size() == 2 and mission.world_data.get("rotors", []).size() == 2, "Mounted resources lost one of the two rescue helicopters.")
	var director = Director.new()
	director.start("boot")
	_check(director.duration() == 15.0 and director.presentation()["card"] == "studio", "Packed studio director is missing or outdated.")
	director.start("arrival")
	_check(director.duration() == 28.0 and director.advance(28.0).size() == 4, "Packed arrival director lost its duration or four cues.")
	_check(mission.audio_score.stream != null and mission.audio_rotors.stream != null, "Export is missing the cinematic audio resources.")
	mission._start_new(928401)
	mission._finish_arrival()
	_disable_ticks(mission)
	_check(mission.started and mission.player.active and mission.player.camera.current and mission.elapsed == 0.0, "The exported new-game/skip path did not return control.")
	mission._say("PACK A", "Première transmission exportée", 8.0)
	mission._say("PACK B", "Deuxième transmission exportée", 8.0)
	_check(mission.radio.current.get("speaker") == "PACK A" and mission.radio.pending.size() == 1 and mission.radio.history.size() == 2, "Packed radio did not serialize ordinary subtitles.")
	mission._say("PACK PRIORITAIRE", "Consigne prioritaire exportée", 8.0, true)
	_check(mission.radio.current.get("speaker") == "PACK PRIORITAIRE" and mission.radio.pending.is_empty() and mission.radio.history.size() == 3, "Packed radio priority or journal retention is outdated.")
	mission.incident.restore("aftermath")
	mission.rescued = ["survivor_30", "survivor_28"]
	mission.radio_events = ["bravo_echo", "bravo_verification"]
	mission.world.set_rescued_people(mission.rescued)
	_check(mission._save_checkpoint(27), "The mounted runtime could not create its isolated schema-3 checkpoint.")
	var saved: Dictionary = Store.load_data(TEST_PATH)
	_check(saved.get("version") == 3 and saved.get("radio_events") == mission.radio_events and saved.get("transmissions", []).size() == 3, "Packed storage lost schema-3 received words or event markers.")
	var before: String = FileAccess.get_file_as_string(TEST_PATH)
	var invalid: Dictionary = saved.duplicate(true)
	invalid["radio_events"] = ["unknown_event"]
	_check(Store.save_data(invalid, TEST_PATH) == ERR_INVALID_DATA and FileAccess.get_file_as_string(TEST_PATH) == before, "Packed validation accepted an invalid event or destroyed its previous checkpoint.")
	mission._restore(saved)
	_disable_ticks(mission)
	_check(mission.player.nearest_floor() == 27 and mission.incident.phase == "aftermath" and mission.rescued == ["survivor_30", "survivor_28"], "Packed loading did not reconstruct the saved floor, incident and rescue progress.")
	_check(not mission.radio.is_busy() and mission.radio.history_snapshot() == saved["transmissions"] and mission.radio_events == saved["radio_events"], "Packed loading replayed or altered the received radio exchange.")
	_check(mission.world.roof_rescued_people["survivor_30"].visible and mission.world.roof_rescued_people["survivor_28"].visible and not mission.world.roof_rescued_people["survivor_26"].visible, "The exported world failed to rebuild the named reception figures.")
	mission.free()
	await process_frame
	await process_frame
	_cleanup()
	_finish()


func _disable_ticks(mission: Node3D) -> void:
	mission.set_process(false)
	mission.player.set_process(false)
	mission.player.set_physics_process(false)
	mission.world.set_process(false)


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
		print("PASS exported pack: %d checks; mounted v0.4 resources, menu/cinematic directors, both helicopters, imported audio, schema-3 radio persistence and isolated restoration. Linux headless engine loads the pack; this is not a Windows executable or browser launch." % checks)
		quit(0)
	else:
		for failure: String in failures:
			push_error(failure)
		print("FAIL exported pack: %d failures / %d checks." % [failures.size(), checks])
		quit(1)
