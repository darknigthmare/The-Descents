extends SceneTree
## Run: godot --headless --path prototype --script tests/test_save.gd

const Store = preload("res://scripts/save_store.gd")
const TEST_PATH: String = "user://qa_v04_save_store_test.json"
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
		["version", 1], ["version", 2], ["version", 4], ["version", "3"], ["seed", 0], ["seed", 1000000],
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
	for missing_id: String in ["survivor_30", "survivor_28", "survivor_26"]:
		var incomplete: Dictionary = second.duplicate(true)
		incomplete["rescued"].erase(missing_id)
		invalid_cases.append(incomplete)
	var misplaced: Dictionary = second.duplicate(true)
	misplaced["floor"] = 30
	invalid_cases.append(misplaced)
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
	json_invalid["version"] = 4
	_write_text(JSON.stringify(json_invalid))
	_check(Store.load_data(TEST_PATH).is_empty(), "An unsupported saved schema version was silently accepted.")
	_test_migration()
	for schema: int in [1, 2, 3]:
		var inconsistent: Dictionary = second.duplicate(true)
		inconsistent["version"] = schema
		inconsistent["rescued"] = ["survivor_30"]
		if schema < 3:
			inconsistent.erase("transmissions")
			inconsistent.erase("radio_events")
		if schema == 1:
			inconsistent.erase("incident_state")
		var original: String = JSON.stringify(inconsistent)
		_write_text(original)
		_check(Store.load_data(TEST_PATH).is_empty(), "Schema %d invented completion from an incomplete reception ledger." % schema)
		_check(FileAccess.get_file_as_string(TEST_PATH) == original, "Rejecting an inconsistent completion rewrote its bytes.")
		inconsistent["rescued"] = second["rescued"].duplicate()
		inconsistent["floor"] = 30
		_write_text(JSON.stringify(inconsistent))
		_check(Store.load_data(TEST_PATH).is_empty(), "Schema %d accepted a final checkpoint outside refuge 25." % schema)
	_test_radio_schema()
	_check(Store.save_data(source, TEST_PATH) == OK, "A corrupt save could not be replaced by a valid checkpoint.")
	var orphan: FileAccess = FileAccess.open(TEST_PATH + ".tmp", FileAccess.WRITE)
	orphan.store_string("{interrupted write")
	orphan.close()
	_check(Store.load_data(TEST_PATH) == source, "An interrupted temporary file superseded the valid checkpoint.")
	_cleanup()
	if failures.is_empty():
		print("PASS checkpoint storage: %d checks; v3 radio persistence, strict v1/v2 migration, atomic replacement, immutable data and corruption handling passed." % checks)
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		print("FAIL checkpoint storage: %d failures / %d checks." % [failures.size(), checks])
		quit(1)


func _fixture() -> Dictionary:
	return {
		"version": 3, "seed": 24011, "floor": 29,
		"health": 92.25, "oxygen": 81.75, "stress": 23.0,
		"anchors": 4, "flares": 2,
		"rescued": ["survivor_30"], "clues": ["evidence_29"],
		"supplies_used": ["supply_29"], "elapsed": 123.456,
		"seen_floors": [31, 30, 29], "completed": false, "incident_state": "intact",
		"transmissions": [], "radio_events": []
	}


func _test_migration() -> void:
	for schema: int in [1, 2]:
		var legacy: Dictionary = _fixture()
		legacy["version"] = schema
		legacy.erase("transmissions")
		legacy.erase("radio_events")
		if schema == 1:
			legacy.erase("incident_state")
		var serialized: String = JSON.stringify(legacy)
		_write_text(serialized)
		_check(Store.load_data(TEST_PATH) == _fixture(), "Valid v%d did not migrate to intact v3 (including JSON numeric version)." % schema)
		_check(FileAccess.get_file_as_string(TEST_PATH) == serialized, "Reading v%d rewrote original bytes." % schema)
		_check(Store.save_data(legacy, TEST_PATH) == ERR_INVALID_DATA, "The v3 writer accepted a legacy v%d checkpoint." % schema)
		_check(FileAccess.get_file_as_string(TEST_PATH) == serialized, "Rejected legacy write damaged previous bytes.")
		if schema == 2:
			legacy["incident_state"] = "aftermath"
			_write_text(JSON.stringify(legacy))
			var in_progress: Dictionary = Store.load_data(TEST_PATH)
			_check(in_progress.get("incident_state") == "aftermath" and not in_progress.get("completed", true), "A v2 active aftermath lost its stable incident state.")
			_check(in_progress.get("transmissions", ["invented"]).is_empty() and in_progress.get("radio_events", ["invented"]).is_empty(), "Migration invented received words or consumed story events.")
		legacy["completed"] = true
		legacy["floor"] = 25
		legacy["rescued"] = ["survivor_30", "survivor_28", "survivor_26"]
		_write_text(JSON.stringify(legacy))
		var migrated: Dictionary = Store.load_data(TEST_PATH)
		_check(migrated.get("incident_state") == "aftermath", "Completed v%d did not restore the collapsed world." % schema)
		_check(migrated.get("completed") == true and migrated.get("rescued") == legacy["rescued"], "Migration lost completed rescue progress.")
		_check(migrated.get("transmissions", ["invented"]).is_empty() and migrated.get("radio_events", ["invented"]).is_empty(), "Completed migration fabricated a radio transcript.")
		_check(Store.save_data(migrated, TEST_PATH) == OK, "Migrated v%d could not be written as v3." % schema)
		_check(Store.load_data(TEST_PATH) == migrated, "Migration was unstable after a v3 write.")
		for pair in [
			["extra", true], ["seed", 42.5], ["version", float(schema) + 0.5],
			["version", true], ["version", str(schema)], ["completed", "false"],
			["rescued", ["same", "same"]], ["transmissions", []], ["radio_events", []]
		]:
			var invalid: Dictionary = legacy.duplicate(true)
			invalid[pair[0]] = pair[1]
			_write_text(JSON.stringify(invalid))
			_check(Store.load_data(TEST_PATH).is_empty(), "Invalid v%d field %s bypassed strict migration." % [schema, pair[0]])
		var missing: Dictionary = legacy.duplicate(true)
		missing.erase("completed")
		_write_text(JSON.stringify(missing))
		_check(Store.load_data(TEST_PATH).is_empty(), "Migration accepted incomplete v%d schema." % schema)
		var invalid_incident: Dictionary = legacy.duplicate(true)
		invalid_incident["incident_state"] = "intact" if schema == 2 else "aftermath"
		_write_text(JSON.stringify(invalid_incident))
		_check(Store.load_data(TEST_PATH).is_empty(), "Migration accepted an extra v1 incident or completed intact v2.")


func _radio_fixture() -> Dictionary:
	var data: Dictionary = _fixture()
	data["incident_state"] = "aftermath"
	data["rescued"] = ["survivor_30", "survivor_28"]
	data["radio_events"] = ["bravo_echo", "bravo_verification"]
	data["transmissions"] = [
		{"speaker": "VARGA", "message": "Samuel : réception confirmée.", "elapsed": 80.0},
		{"speaker": "BRAVO", "message": "On vous voit à la baie Est...", "elapsed": 100.0},
		{"speaker": "VARGA", "message": "Nous vérifions la liaison.", "elapsed": 111.0}
	]
	return data


func _test_radio_schema() -> void:
	var source: Dictionary = _radio_fixture()
	_check(Store.save_data(source, TEST_PATH) == OK, "Valid v3 radio checkpoint was rejected.")
	var original: String = FileAccess.get_file_as_string(TEST_PATH)
	var loaded: Dictionary = Store.load_data(TEST_PATH)
	_check(loaded == source, "v3 radio/events round trip changed received words.")
	loaded["transmissions"][0]["message"] = "mutated nested record"
	loaded["radio_events"].clear()
	_check(Store.load_data(TEST_PATH) == source, "Mutating nested loaded radio data changed the stored checkpoint.")
	var invalid_cases: Array[Dictionary] = []
	for pair in [
		["transmissions", {}], ["transmissions", ["not a record"]],
		["radio_events", "bravo_echo"], ["radio_events", [1]],
		["radio_events", ["unknown"]], ["radio_events", ["bravo_echo", "bravo_echo"]],
		["radio_events", ["bravo_verification"]], ["radio_events", ["bravo_verification", "bravo_echo"]],
		["radio_events", ["bravo_echo", "bravo_verification", "other"]],
		["rescued", ["survivor_30"]], ["incident_state", "intact"]
	]:
		var invalid: Dictionary = source.duplicate(true)
		invalid[pair[0]] = pair[1]
		invalid_cases.append(invalid)
	for pair in [
		["speaker", ""], ["speaker", "   "], ["speaker", 14], ["speaker", "S".repeat(121)],
		["message", ""], ["message", "  "], ["message", false], ["message", "M".repeat(1201)],
		["elapsed", -1.0], ["elapsed", 124.0],
		["elapsed", "80"], ["elapsed", true], ["extra", "unsupported"]
	]:
		var invalid: Dictionary = source.duplicate(true)
		invalid["transmissions"][0][pair[0]] = pair[1]
		invalid_cases.append(invalid)
	for key: String in ["speaker", "message", "elapsed"]:
		var invalid: Dictionary = source.duplicate(true)
		invalid["transmissions"][0].erase(key)
		invalid_cases.append(invalid)
	for key: String in ["transmissions", "radio_events"]:
		var invalid: Dictionary = source.duplicate(true)
		invalid.erase(key)
		invalid_cases.append(invalid)
	var reversed_times: Dictionary = source.duplicate(true)
	reversed_times["transmissions"][1]["elapsed"] = 79.0
	invalid_cases.append(reversed_times)
	var overflow: Dictionary = source.duplicate(true)
	overflow["transmissions"] = []
	for index in range(33):
		overflow["transmissions"].append({"speaker": "VARGA", "message": "Reçu %d" % index, "elapsed": float(index)})
	invalid_cases.append(overflow)
	for index in range(invalid_cases.size()):
		_check(Store.save_data(invalid_cases[index], TEST_PATH) == ERR_INVALID_DATA, "Invalid radio record %d was accepted by writer." % index)
		_check(FileAccess.get_file_as_string(TEST_PATH) == original, "Rejected radio record %d damaged previous bytes." % index)
		var serialized: String = JSON.stringify(invalid_cases[index])
		_write_text(serialized)
		_check(Store.load_data(TEST_PATH).is_empty(), "Invalid JSON radio record %d was accepted by reader." % index)
		_check(FileAccess.get_file_as_string(TEST_PATH) == serialized, "Rejected JSON read rewrote its source.")
		_write_text(original)
	for invalid_time: float in [NAN, INF]:
		var invalid: Dictionary = source.duplicate(true)
		invalid["transmissions"][0]["elapsed"] = invalid_time
		_check(Store.save_data(invalid, TEST_PATH) == ERR_INVALID_DATA, "Non-finite transmission timestamp was accepted.")
		_check(FileAccess.get_file_as_string(TEST_PATH) == original, "Non-finite timestamp rejection damaged saved bytes.")
	var maximum: Dictionary = source.duplicate(true)
	maximum["transmissions"] = overflow["transmissions"].slice(0, 32)
	_check(Store.save_data(maximum, TEST_PATH) == OK, "The supported 32-record history could not be saved.")
	_check(Store.load_data(TEST_PATH)["transmissions"].size() == 32, "A full journal did not survive loading.")
	var oversized: Dictionary = maximum.duplicate(true)
	for entry: Dictionary in oversized["transmissions"]:
		entry["message"] = "🜁".repeat(1000)
	var maximum_bytes: String = FileAccess.get_file_as_string(TEST_PATH)
	_check(Store.save_data(oversized, TEST_PATH) == ERR_INVALID_DATA, "The UTF-8 byte cap was bypassed by valid character counts.")
	_check(FileAccess.get_file_as_string(TEST_PATH) == maximum_bytes, "Oversized UTF-8 write damaged a valid journal.")


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
