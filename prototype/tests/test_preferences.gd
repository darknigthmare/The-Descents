extends SceneTree
## Boolean comfort settings have independent defaults and atomic replacement.

const Preferences = preload("res://scripts/preferences_store.gd")
const TEST_PATH: String = "user://qa_v04_preferences.cfg"
const MISSING_PATH: String = "user://qa_v04_absent_preferences_directory/preferences.cfg"
var failures: Array[String] = []
var checks: int = 0


func _initialize() -> void:
	_cleanup()
	var defaults: Dictionary = {"audio": true, "reduced_motion": true, "flashes": false, "startup_intro": true}
	var loaded: Dictionary = Preferences.load_settings(TEST_PATH)
	_check(loaded == defaults, "A missing preferences file did not return the intended defaults.")
	loaded["audio"] = false
	_check(Preferences.load_settings(TEST_PATH) == defaults and Preferences.DEFAULTS == defaults, "Mutating loaded defaults changed shared state.")
	var settings: Dictionary = {"audio": false, "reduced_motion": false, "flashes": true, "startup_intro": false}
	var source_copy: Dictionary = settings.duplicate(true)
	_check(Preferences.save_settings(settings, TEST_PATH) == OK, "Valid comfort settings could not be saved.")
	_check(settings == source_copy and Preferences.load_settings(TEST_PATH) == settings, "Saving mutated settings or changed their boolean values.")
	loaded = Preferences.load_settings(TEST_PATH)
	loaded["startup_intro"] = true
	_check(Preferences.load_settings(TEST_PATH) == settings, "Mutating a loaded result changed persisted settings.")
	_check(Preferences.save_settings(defaults, TEST_PATH) == OK and Preferences.load_settings(TEST_PATH) == defaults, "Replacing an existing preferences file failed.")
	var original: String = FileAccess.get_file_as_string(TEST_PATH)
	for key: String in defaults:
		for invalid_value in [0, 1, "true", "false", null, [], {}]:
			var invalid: Dictionary = defaults.duplicate()
			invalid[key] = invalid_value
			_check(Preferences.save_settings(invalid, TEST_PATH) == ERR_INVALID_DATA, "Writer coerced non-boolean %s into a comfort setting." % key)
			_check(FileAccess.get_file_as_string(TEST_PATH) == original, "Rejected %s damaged the previous preferences file." % key)
		var missing: Dictionary = defaults.duplicate()
		missing.erase(key)
		_check(Preferences.save_settings(missing, TEST_PATH) == ERR_INVALID_DATA, "Writer accepted missing required setting %s." % key)
		_check(FileAccess.get_file_as_string(TEST_PATH) == original, "Rejected missing setting changed existing bytes.")
	var config: ConfigFile = ConfigFile.new()
	config.set_value("comfort", "audio", false)
	config.set_value("comfort", "reduced_motion", "false")
	config.set_value("comfort", "flashes", 1)
	config.set_value("comfort", "startup_intro", 0)
	config.set_value("comfort", "unknown", true)
	_check(config.save(TEST_PATH) == OK, "Could not prepare valid config syntax with invalid setting types.")
	var raw: String = FileAccess.get_file_as_string(TEST_PATH)
	loaded = Preferences.load_settings(TEST_PATH)
	_check(loaded == {"audio": false, "reduced_motion": true, "flashes": false, "startup_intro": true}, "Reader coerced invalid types instead of retaining each field's default.")
	_check(not loaded.has("unknown") and FileAccess.get_file_as_string(TEST_PATH) == raw, "Reading unknown or invalid settings rewrote the user's config.")
	config = ConfigFile.new()
	config.set_value("comfort", "startup_intro", false)
	config.save(TEST_PATH)
	_check(Preferences.load_settings(TEST_PATH) == {"audio": true, "reduced_motion": true, "flashes": false, "startup_intro": false}, "Missing individual config entries failed to use independent defaults.")
	_check(Preferences.save_settings(settings, TEST_PATH) == OK, "A partially specified config could not be replaced with a valid set.")
	original = FileAccess.get_file_as_string(TEST_PATH)
	_check(Preferences.save_settings(defaults, MISSING_PATH) != OK, "Writing to an absent directory failed to report an error.")
	_check(FileAccess.get_file_as_string(TEST_PATH) == original, "An unrelated filesystem error damaged valid preferences.")
	var temp_path: String = ProjectSettings.globalize_path(TEST_PATH + ".tmp")
	_check(DirAccess.make_dir_absolute(temp_path) == OK, "Could not prepare the isolated temporary-path obstruction.")
	_check(Preferences.save_settings(defaults, TEST_PATH) != OK, "A blocked temporary output path was silently accepted.")
	_check(FileAccess.get_file_as_string(TEST_PATH) == original and Preferences.load_settings(TEST_PATH) == settings, "A failed replacement destroyed the last valid preferences.")
	DirAccess.remove_absolute(temp_path)
	_cleanup()
	if failures.is_empty():
		print("PASS preferences storage: %d checks; independent defaults, strict boolean fields, immutable reads and preservation after rejected or failed writes." % checks)
		quit(0)
	else:
		for failure: String in failures:
			push_error(failure)
		print("FAIL preferences storage: %d failures / %d checks." % [failures.size(), checks])
		quit(1)


func _cleanup() -> void:
	for path: String in [TEST_PATH, TEST_PATH + ".tmp"]:
		if FileAccess.file_exists(path) or DirAccess.dir_exists_absolute(ProjectSettings.globalize_path(path)):
			DirAccess.remove_absolute(ProjectSettings.globalize_path(path))


func _check(condition: bool, message: String) -> void:
	checks += 1
	if not condition:
		failures.append(message)
