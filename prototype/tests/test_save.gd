extends SceneTree
## Run: godot --headless --path prototype --script tests/test_save.gd

const Store = preload("res://scripts/save_store.gd")
const TEST_PATH: String = "user://save_store_test.json"
var failures: Array[String] = []
var checks: int = 0


func _initialize() -> void:
	_cleanup()
	_check(Store.load_data(TEST_PATH).is_empty(), "Missing save must return an empty dictionary.")
	var source: Dictionary = _fixture()
	var untouched: Dictionary = source.duplicate(true)
	_check(Store.save_data(source, TEST_PATH) == OK, "Valid checkpoint could not be written.")
	_check(source == untouched, "Saving mutated its input dictionary.")
	var loaded: Dictionary = Store.load_data(TEST_PATH)
	_check(loaded == source, "Round trip did not preserve checkpoint contents.")
	_check(typeof(loaded.get("seed")) == TYPE_INT, "JSON seed was not restored as an integer.")
	_check(typeof(loaded.get("health")) == TYPE_FLOAT, "Health was not normalized as a float.")
	loaded["rescued"].append("changed_after_load")
	_check(Store.load_data(TEST_PATH) == source, "Mutating loaded data changed stored state.")
	var second: Dictionary = _fixture()
	second["floor"] = 25
	second["completed"] = true
	second["incident_state"] = "aftermath"
	second["rescued"] = ["survivor_30", "survivor_28", "survivor_26"]
	_check(Store.save_data(second, TEST_PATH) == OK, "Atomic replacement failed for an existing save.")
	_check(Store.load_data(TEST_PATH) == second, "Replacement did not preserve the new checkpoint.")

	var invalid_cases: Array[Dictionary] = []
	for pair in [
		["version", 1], ["version", 3], ["version", "2"], ["seed", 0], ["seed", 1000000],
		["seed", 42.5], ["seed", true], ["floor", 24], ["floor", 32],
		["health", -0.1], ["health", 100.1], ["health", NAN], ["oxygen", INF],
		["stress", "50"], ["anchors", 9], ["flares", -1], ["elapsed", -1.0],
		["completed", 1], ["rescued", "survivor_30"], ["clues", [123]],
		["supplies_used", [""]], ["rescued", ["x".repeat(81)]],
		["clues", ["same", "same"]], ["seen_floors", [31, 24]],
		["seen_floors", [31, 31]], ["seen_floors", [29.5]],
		["incident_state", "collapse"], ["incident_state", "unknown"],
		["incident_state", 1], ["completed", true]
	]:
		var invalid: Dictionary = _fixture()
		invalid[pair[0]] = pair[1]
		invalid_cases.append(invalid)
	var missing: Dictionary = _fixture()
	missing.erase("version")
	invalid_cases.append(missing)
	var extra: Dictionary = _fixture()
	extra["future_schema_field"] = "no implicit migration"
	invalid_cases.append(extra)
	var too_many: Dictionary = _fixture()
	too_many["rescued"] = []
	for index in range(65):
		too_many["rescued"].append("id_%d" % index)
	invalid_cases.append(too_many)
	for index in range(invalid_cases.size()):
		_check(Store.save_data(invalid_cases[index], TEST_PATH) == ERR_INVALID_DATA, "Invalid case %d was accepted." % index)
		_check(Store.load_data(TEST_PATH) == second, "Invalid case %d damaged the prior checkpoint." % index)

	_check(Store.save_data(source, "") == ERR_INVALID_PARAMETER, "An empty output path was accepted.")
	_check(Store.save_data(source, "relative_save.json") == ERR_INVALID_PARAMETER, "A relative output path was accepted.")
	_check(Store.save_data(source, "user://missing_save_test_directory/save.json") != OK, "Writing to an absent directory should report a filesystem error.")
	_check(Store.load_data(TEST_PATH) == second, "An unrelated filesystem error changed the checkpoint.")

	for corrupt in ["{truncated", "[]", "null", "\"text\"", "{\"version\": 1}", " ", " ".repeat(65537)]:
		_write_text(corrupt)
		_check(Store.load_data(TEST_PATH).is_empty(), "Corrupt, wrong-root or oversized JSON was accepted.")
	var json_invalid: Dictionary = _fixture()
	json_invalid["seed"] = 123.25
	_write_text(JSON.stringify(json_invalid))
	_check(Store.load_data(TEST_PATH).is_empty(), "A fractional JSON seed was truncated instead of rejected.")
	json_invalid = _fixture()
	json_invalid["version"] = 3
	_write_text(JSON.stringify(json_invalid))
	_check(Store.load_data(TEST_PATH).is_empty(), "An unsupported saved schema version was silently accepted.")
	_test_migration()
	_check(Store.save_data(source, TEST_PATH) == OK, "A corrupt save could not be replaced by a valid checkpoint.")
	var orphan: FileAccess = FileAccess.open(TEST_PATH + ".tmp", FileAccess.WRITE)
	orphan.store_string("{interrupted write")
	orphan.close()
	_check(Store.load_data(TEST_PATH) == source, "An interrupted temporary file superseded the valid checkpoint.")
	_cleanup()
	if failures.is_empty():
		print("PASS checkpoint storage: %d checks; v2 incident persistence, strict v1 migration, atomic replacement, immutable data and corruption handling passed." % checks)
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		print("FAIL checkpoint storage: %d failures / %d checks." % [failures.size(), checks])
		quit(1)


func _fixture() -> Dictionary:
	return {
		"version": 2, "seed": 24011, "floor": 29,
		"health": 92.25, "oxygen": 81.75, "stress": 23.0,
		"anchors": 4, "flares": 2,
		"rescued": ["survivor_30"], "clues": ["evidence_29"],
		"supplies_used": ["supply_29"], "elapsed": 123.456,
		"seen_floors": [31, 30, 29], "completed": false, "incident_state": "intact"
	}


func _test_migration() -> void:
	var legacy: Dictionary = _fixture()
	legacy["version"] = 1
	legacy.erase("incident_state")
	var serialized: String = JSON.stringify(legacy)
	_write_text(serialized)
	_check(Store.load_data(TEST_PATH) == _fixture(), "A valid v1 checkpoint did not migrate to intact v2.")
	_check(FileAccess.get_file_as_string(TEST_PATH) == serialized, "Loading a legacy save unexpectedly rewrote its bytes.")
	_check(Store.save_data(legacy, TEST_PATH) == ERR_INVALID_DATA, "The v2 writer accepted a legacy checkpoint.")
	_check(FileAccess.get_file_as_string(TEST_PATH) == serialized, "Rejected legacy write damaged the old checkpoint.")
	legacy["completed"] = true
	legacy["floor"] = 25
	legacy["rescued"] = ["survivor_30", "survivor_28", "survivor_26"]
	_write_text(JSON.stringify(legacy))
	var migrated: Dictionary = Store.load_data(TEST_PATH)
	_check(migrated.get("incident_state") == "aftermath", "A completed v1 mission did not restore the collapsed world.")
	_check(migrated.get("completed") == true and migrated.get("rescued") == legacy["rescued"], "Migration lost completed rescue progress.")
	_check(Store.save_data(migrated, TEST_PATH) == OK, "A migrated v1 checkpoint could not be written as v2.")
	_check(Store.load_data(TEST_PATH) == migrated, "Migration was not stable after the first v2 write.")
	for pair in [
		["incident_state", "aftermath"], ["extra", true], ["seed", 42.5],
		["version", 1.5], ["version", true], ["version", "1"],
		["completed", "false"], ["rescued", ["same", "same"]]
	]:
		var invalid: Dictionary = legacy.duplicate(true)
		invalid[pair[0]] = pair[1]
		_write_text(JSON.stringify(invalid))
		_check(Store.load_data(TEST_PATH).is_empty(), "Invalid legacy field %s bypassed migration validation." % pair[0])
	var missing: Dictionary = legacy.duplicate(true)
	missing.erase("completed")
	_write_text(JSON.stringify(missing))
	_check(Store.load_data(TEST_PATH).is_empty(), "Migration accepted an incomplete legacy schema.")


func _write_text(text: String) -> void:
	var file: FileAccess = FileAccess.open(TEST_PATH, FileAccess.WRITE)
	file.store_string(text)
	file.close()


func _check(condition: bool, message: String) -> void:
	checks += 1
	if not condition:
		failures.append(message)


func _cleanup() -> void:
	for path in [TEST_PATH, TEST_PATH + ".tmp"]:
		if FileAccess.file_exists(path):
			DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
