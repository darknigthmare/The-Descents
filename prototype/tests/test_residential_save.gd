extends SceneTree
## Genuine v5 migration and schema-6 persistence; no scene-state shortcuts.
const Store = preload("res://scripts/save_store.gd")
const Residential = preload("res://scripts/residential_director.gd")
const Commerce = preload("res://scripts/commerce_director.gd")
const Continuation = preload("res://scripts/continuation_director.gd")
const SAVE := "user://qa_residential_v013_schema.json"
var checks: int = 0
var failures: Array[String] = []

func _initialize() -> void:
	_run.call_deferred()

func _run() -> void:
	_clean()
	var legacy := _v5_fixture()
	_write(JSON.stringify(legacy))
	var original := FileAccess.get_file_as_bytes(SAVE)
	var migrated := Store.load_data(SAVE)
	_check(migrated.get("version") == 6 and migrated.get("residential") == Residential.dormant_state(), "v5 migration did not add a dormant residential chapter.")
	for key: String in legacy:
		if key != "version": _check(migrated.get(key) == legacy[key], "v5 migration changed previous durable field: " + key)
	_check(FileAccess.get_file_as_bytes(SAVE) == original, "Read-only migration rewrote the v5 checkpoint.")
	_check(Store.save_data(legacy, SAVE) == OK and Store.load_data(SAVE) == migrated, "Compatible v5 write disagreed with read-only migration.")
	var d := Residential.new()
	_check(d.begin({"completed": true, "floor": 20, "at_landing": true, "commerce": legacy["commerce"]}), "Completed v5 refuge did not permit the next chapter.")
	var active := migrated.duplicate(true)
	active["completed"] = false
	active["residential"] = d.checkpoint_snapshot()
	_check(Store.save_data(active, SAVE) == OK, "Residential start could not persist with previous commerce still complete.")
	for floor_number: int in [20, 19, 18, 17, 25]:
		active["floor"] = floor_number
		if floor_number not in active["seen_floors"]: active["seen_floors"].append(floor_number)
		_check(Store.save_data(active, SAVE) == OK and Store.load_data(SAVE) == active, "Active chapter could not persist a safe landing at %d." % floor_number)
	_do(d, "care", "")
	_do(d, "service_access", "halligan")
	_do(d, "power", "")
	_do(d, "reference", "")
	for id: String in Residential.PERSON_IDS: _check(d.toggle_person(id), "Could not start safe escort: " + id)
	active["floor"] = 17
	active["residential"] = d.checkpoint_snapshot()
	active["clues"].append_array(Residential.CLUES.keys())
	# The radio ring buffer may already have dropped the reference subtitle.
	# Durable reference/action receipts must remain sufficient to retry.
	active["transmissions"] = []
	_check(Store.save_data(active, SAVE) == OK, "Active escorts could not be normalized to stable waiting checkpoints.")
	var restored := Residential.new()
	_check(restored.restore(Store.load_data(SAVE)["residential"]) and restored.validate_relay("AUBE-20", "NACRE-204"), "Trimmed radio history removed the durable relay reference.")
	for id: String in Residential.PERSON_IDS: _check(restored.person_state(id) == "waiting", "Checkpoint restored movement midway through an escort: " + id)
	var good := FileAccess.get_file_as_bytes(SAVE)
	for change: String in ["old_commerce_lost", "old_rescue_lost", "old_clue_lost", "old_duo_lost", "transient", "unknown_key", "missing_residential", "bad_floor", "future_schema", "dormant_lower_floor", "active_but_completed"]:
		var corrupt := active.duplicate(true)
		match change:
			"old_commerce_lost": corrupt["commerce"] = Commerce.dormant_state()
			"old_rescue_lost": corrupt["rescued"].erase("survivor_28")
			"old_clue_lost": corrupt["clues"].erase("commerce_maintenance_21")
			"old_duo_lost": corrupt["continuation"]["escort_state"] = "waiting"
			"transient": corrupt["residential"]["people"]["marc"] = "following"
			"unknown_key": corrupt["residential"]["pending_code"] = "NACRE-204"
			"missing_residential": corrupt.erase("residential")
			"bad_floor": corrupt["floor"] = 16
			"future_schema": corrupt["version"] = 7
			"dormant_lower_floor": corrupt["residential"] = Residential.dormant_state()
			"active_but_completed": corrupt["completed"] = true
		_check(Store.save_data(corrupt, SAVE) == ERR_INVALID_DATA, "Schema accepted corrupt checkpoint: " + change)
		_check(FileAccess.get_file_as_bytes(SAVE) == good, "Rejected write damaged prior checkpoint: " + change)
		_write(JSON.stringify(corrupt))
		_check(Store.load_data(SAVE).is_empty(), "JSON reader accepted corrupt checkpoint: " + change)
		_write(good.get_string_from_utf8())
	var live := d.snapshot()
	_check(d.begin_relay("AUBE-20", "NACRE-204"), "Valid relay could not start after wrong-entry tests.")
	for index in range(45): d.advance_action(0.05, true, true, "")
	var pending := active.duplicate(true)
	pending["residential"] = d.checkpoint_snapshot()
	_check(Store.save_data(pending, "user://qa_residential_absent_%d/save.json" % Time.get_ticks_usec()) != OK, "Absent target directory did not report persistence failure.")
	_check(d.restore_runtime(live) and d.person_state("marc") == "following" and not d.has_action("relay"), "I/O rollback reset an escort or retained an uncommitted relay receipt.")
	_check(FileAccess.get_file_as_bytes(SAVE) == good, "Unrelated I/O failure overwrote the real checkpoint.")
	_check(d.begin_relay("AUBE-20", "NACRE-204"), "Relay could not be retried after I/O failure.")
	for index in range(45): d.advance_action(0.05, true, true, "")
	for id: String in Residential.PERSON_IDS: _check(d.receive(id, 20, true), "Physical rescue receipt missing: " + id)
	_check(d.complete({"floor": 17, "at_landing": true, "clues": active["clues"]}), "Full rescue+relay dossier could not complete at17.")
	var complete := active.duplicate(true)
	complete["completed"] = true
	complete["residential"] = d.checkpoint_snapshot()
	_check(Store.save_data(complete, SAVE) == OK and Store.load_data(SAVE) == complete, "Final17 report could not round-trip with eight previous and three new receipts.")
	good = FileAccess.get_file_as_bytes(SAVE)
	for missing: String in Residential.CLUES:
		var corrupt := complete.duplicate(true)
		corrupt["clues"].erase(missing)
		_check(Store.save_data(corrupt, SAVE) == ERR_INVALID_DATA and FileAccess.get_file_as_bytes(SAVE) == good, "Final report accepted a missing residential clue: " + missing)
	var legacy_impossible := legacy.duplicate(true)
	legacy_impossible["floor"] = 17
	_write(JSON.stringify(legacy_impossible))
	_check(Store.load_data(SAVE).is_empty(), "v5 migration bypassed its original floor bounds.")
	_clean()
	if failures.is_empty():
		print("PASS residential schema: %d checks; untouched v5 migration, earlier receipts, safe landings, trimmed radio, strict corruption, I/O rollback and final17 report." % checks)
		quit(0)
	else:
		for failure: String in failures: push_error(failure)
		print("FAIL residential schema: %d failures / %d checks." % [failures.size(), checks])
		quit(1)

func _v5_fixture() -> Dictionary:
	var clues: Array = Continuation.PROOF_IDS.duplicate()
	clues.append_array(Commerce.CLUES.keys())
	return {"version": 5, "seed": 271104, "floor": 20, "health": 91.0, "oxygen": 83.0, "stress": 29.0, "anchors": 4, "flares": 2,
		"rescued": ["survivor_30", "survivor_28", "survivor_26"], "clues": clues, "supplies_used": ["equipment_fire_28"], "elapsed": 1600.0,
		"seen_floors": [31,30,29,28,27,26,25,24,23,22,21,20], "completed": true, "incident_state": "aftermath",
		"transmissions": [{"speaker": "VARGA", "message": "Huit personnes reçues entre le toit et les refuges.", "elapsed": 1590.0}], "radio_events": ["bravo_echo", "bravo_verification"],
		"continuation": {"phase": "complete", "started_at_refuge": true, "duo_briefed": true, "escort_state": "received"},
		"commerce": {"phase": "complete", "actions": ["shutter", "isolation", "blanket", "relay"], "people": {"mina": "received", "theo": "received", "sofia": "received"}, "contacted": ["mina", "theo", "sofia"]}}

func _do(d: RefCounted, id: String, tool: String) -> void:
	_check(d.begin_action(id, tool), "Cannot start required action " + id)
	for index in range(70): d.advance_action(0.05, true, true, tool)
	_check(d.has_action(id), "Required action did not complete " + id)

func _write(content: String) -> void:
	var file := FileAccess.open(SAVE, FileAccess.WRITE)
	file.store_string(content)
	file.close()

func _clean() -> void:
	if FileAccess.file_exists(SAVE): DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE))

func _check(condition: bool, message: String) -> void:
	checks += 1
	if not condition: failures.append(message)
