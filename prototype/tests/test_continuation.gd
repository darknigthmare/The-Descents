extends SceneTree
## Pure progression and durable-schema tests. Physical escort/collision checks
## belong to the integration suites; a positive duo_arrived flag is not geometry.

const Director = preload("res://scripts/continuation_director.gd")
const Store = preload("res://scripts/save_store.gd")
const SAVE_PATH: String = "user://qa_v010_continuation.json"
var failures: Array[String] = []
var checks: int = 0


func _initialize() -> void:
	_cleanup()
	_test_progression()
	_test_migration()
	_test_checkpoint_integrity()
	_cleanup()
	if failures.is_empty():
		print("PASS continuation: %d checks; explicit refuge start, escort handoff, two-proof completion, stable restart, strict v3 migration and schema-4 integrity." % checks)
		quit(0)
	else:
		for failure: String in failures:
			push_error(failure)
		print("FAIL continuation: %d failures / %d checks." % [failures.size(), checks])
		quit(1)


func _test_progression() -> void:
	var director = Director.new()
	var dormant: Dictionary = director.snapshot()
	_check(director.phase == "dormant" and director.escort_state == "waiting" and not director.duo_briefed, "A new director fabricated an ongoing reconnaissance.")
	for change: Dictionary in [{"floor": 24}, {"floor": 25.0}, {"at_landing": false}, {"at_landing": 1}, {"completed": false}, {"incident_state": "intact"}, {"rescued": ["survivor_30", "survivor_28"]}]:
		var context: Dictionary = _context(25)
		context.merge(change, true)
		_check(not director.begin(context), "An invalid refuge-start context was accepted: %s." % change)
		_check(director.snapshot() == dormant, "Rejected start mutated progression: %s." % change)
	_check(not director.start_escort(_context(24)) and not director.pause_escort(), "The escort began before reconnaissance.")
	_check(director.begin(_context(25)), "A completed supported refuge could not begin reconnaissance.")
	_check(director.phase == "active" and director.snapshot()["started_at_refuge"], "Beginning did not record its refuge origin.")
	var begun: Dictionary = director.snapshot()
	_check(not director.begin(_context(25)) and director.snapshot() == begun, "Repeated start reset progress.")
	_check(not director.start_escort(_context(25)), "A first conversation happened without finding the duo at 24.")
	var suspended: Dictionary = _context(24)
	suspended["at_landing"] = false
	_check(not director.start_escort(suspended), "A suspended player could start escorting.")
	_check(director.start_escort(_context(24)), "The actual 24 rendezvous could not begin its escort.")
	_check(director.duo_briefed and director.escort_state == "following", "The rendezvous did not record both briefing and following.")
	var snapshot: Dictionary = director.snapshot()
	snapshot["phase"] = "complete"
	_check(director.phase == "active", "A returned snapshot aliases live progression.")
	var stable: Dictionary = director.checkpoint_snapshot()
	_check(stable["escort_state"] == "waiting" and stable["duo_briefed"], "The checkpoint stored a moving convoy or forgot its conversation.")
	_check(director.escort_state == "following", "Preparing a stable checkpoint stopped the live convoy.")
	var resumed = Director.new()
	_check(resumed.restore(director.snapshot()) and resumed.escort_state == "waiting" and resumed.duo_briefed, "Restoring an interrupted escort retained a transient moving state.")
	_check(not resumed.restore({"phase": "complete"}) and resumed.escort_state == "waiting", "An invalid restore corrupted the last valid director.")
	_check(director.pause_escort() and director.escort_state == "waiting", "The duo could not wait voluntarily.")
	_check(not director.pause_escort(), "Repeated waiting was treated as another escort transition.")
	_check(director.start_escort(_context(25)), "An already briefed duo could not resume after waiting on refuge's landing.")
	var premature: Dictionary = _context(24)
	premature["duo_arrived"] = true
	_check(not director.receive_escort(premature), "A reception was confirmed while still at 24.")
	_check(not director.receive_escort(_context(25)), "The player's refuge arrival alone counted both survivors as received.")
	var reception: Dictionary = _context(25)
	reception["duo_arrived"] = true
	_check(director.receive_escort(reception), "The supported refuge handoff could not receive an arrived duo.")
	_check(director.escort_state == "received" and not director.pause_escort(), "Received survivors could be made transient again.")
	_check(not director.receive_escort(reception), "Repeated handoff counted a second reception.")
	var final_context: Dictionary = _context(23)
	final_context["completed"] = false
	for clues: Array in [[], ["continuation_model_23"], ["continuation_photo_23"]]:
		final_context["clues"] = clues
		_check(not director.can_complete(final_context) and not director.complete(final_context), "Completion did not require both independent proofs: %s." % [clues])
	final_context["clues"] = ["continuation_model_23", "continuation_photo_23"]
	for change: Dictionary in [{"floor": 24}, {"at_landing": false}, {"incident_state": "intact"}, {"rescued": []}]:
		var invalid: Dictionary = final_context.duplicate(true)
		invalid.merge(change, true)
		_check(not director.complete(invalid), "Invalid reconnaissance conclusion was accepted: %s." % change)
	_check(director.can_complete(final_context) and director.complete(final_context), "A received duo and both proofs could not conclude at 23.")
	_check(director.phase == "complete" and director.checkpoint_snapshot()["escort_state"] == "received", "Conclusion discarded the durable reception.")
	_check(not director.complete(final_context), "Repeated conclusion transitioned twice.")
	_check(resumed.restore(director.checkpoint_snapshot()) and resumed.phase == "complete" and resumed.escort_state == "received", "Final-state restoration reopened a completed escort.")
	director.reset()
	_check(director.snapshot() == dormant, "New-game reset retained reconnaissance state.")


func _test_migration() -> void:
	var legacy: Dictionary = _save_fixture()
	legacy["version"] = 3
	legacy.erase("continuation")
	legacy.erase("commerce")
	legacy["completed"] = true
	# Old v3 permits this short visited ledger; loading must not invent visits.
	legacy["seen_floors"] = [31, 30, 29]
	legacy["transmissions"] = [{"speaker": "VARGA", "message": "Trois réceptions confirmées.", "elapsed": 80.0}]
	var serialized: String = JSON.stringify(legacy)
	_write(serialized)
	var migrated: Dictionary = Store.load_data(SAVE_PATH)
	_check(migrated.get("version") == Store.SAVE_VERSION and migrated.get("completed") == true, "The v3 completion did not migrate to a completed v4 debrief.")
	_check(migrated.get("continuation") == Director.dormant_state(), "Reading an old debrief silently activated reconnaissance.")
	_check(migrated.get("seen_floors") == legacy["seen_floors"] and migrated.get("transmissions") == legacy["transmissions"], "Migration invented visited floors or dialogue.")
	_check(FileAccess.get_file_as_string(SAVE_PATH) == serialized, "Read-only v3 migration rewrote saved bytes.")
	var original: Dictionary = legacy.duplicate(true)
	_check(Store.save_data(legacy, SAVE_PATH) == OK and legacy == original, "The compatible v3 writer failed or mutated its input.")
	_check(Store.load_data(SAVE_PATH) == migrated, "The compatible writer disagrees with read-only migration.")
	var good_bytes: String = FileAccess.get_file_as_string(SAVE_PATH)
	for change: Dictionary in [{"floor": 24}, {"seen_floors": [31, 25, 24]}, {"continuation": Director.dormant_state(), "commerce": preload("res://scripts/commerce_director.gd").dormant_state()}, {"rescued": ["survivor_30"]}]:
		var invalid: Dictionary = legacy.duplicate(true)
		invalid.merge(change, true)
		_check(Store.save_data(invalid, SAVE_PATH) == ERR_INVALID_DATA, "v3 migration bypassed its original schema: %s." % change)
		_check(FileAccess.get_file_as_string(SAVE_PATH) == good_bytes, "A rejected legacy write damaged the previous checkpoint.")
		var invalid_bytes: String = JSON.stringify(invalid)
		_write(invalid_bytes)
		_check(Store.load_data(SAVE_PATH).is_empty(), "The reader accepted invalid legacy state: %s." % change)
		_check(FileAccess.get_file_as_string(SAVE_PATH) == invalid_bytes, "Rejecting legacy state changed its source.")
		_write(good_bytes)


func _test_checkpoint_integrity() -> void:
	var active: Dictionary = _save_fixture()
	active["continuation"] = {"phase": "active", "started_at_refuge": true, "duo_briefed": false, "escort_state": "waiting"}
	for floor_number: int in [25, 24, 23]:
		active["floor"] = floor_number
		_check(Store.save_data(active, SAVE_PATH) == OK, "Active reconnaissance cannot checkpoint at supported floor %d." % floor_number)
		_check(Store.load_data(SAVE_PATH) == active, "Active floor %d did not survive its round trip." % floor_number)
	active["floor"] = 25
	var complete: Dictionary = active.duplicate(true)
	complete["floor"] = 23
	complete["seen_floors"] = [31, 30, 29, 28, 27, 26, 25, 24, 23]
	complete["completed"] = true
	complete["clues"] = ["evidence_29", "continuation_model_23", "continuation_photo_23"]
	complete["continuation"] = {"phase": "complete", "started_at_refuge": true, "duo_briefed": true, "escort_state": "received"}
	_check(Store.save_data(complete, SAVE_PATH) == OK and Store.load_data(SAVE_PATH) == complete, "A valid 23 conclusion failed to preserve all nine visited floors and both proofs.")
	var good_bytes: String = FileAccess.get_file_as_string(SAVE_PATH)
	var invalid_cases: Array[Dictionary] = []
	for change: Dictionary in [{"completed": true}, {"rescued": ["survivor_30"]}, {"incident_state": "intact"}, {"seen_floors": [31, 30]}, {"floor": 22}]:
		var invalid: Dictionary = active.duplicate(true)
		invalid.merge(change, true)
		invalid_cases.append(invalid)
	for change: Dictionary in [{"started_at_refuge": false}, {"started_at_refuge": 1}, {"duo_briefed": "yes"}, {"phase": "unknown"}, {"escort_state": "received"}, {"duo_briefed": true, "escort_state": "following"}, {"escort_position": [0, 0, 0]}]:
		var invalid: Dictionary = active.duplicate(true)
		invalid["continuation"].merge(change, true)
		invalid_cases.append(invalid)
	for missing_key: String in Director.STATE_KEYS:
		var invalid: Dictionary = active.duplicate(true)
		invalid["continuation"].erase(missing_key)
		invalid_cases.append(invalid)
	for wrong_type: Variant in [[], "active", true, 1, null]:
		var invalid: Dictionary = active.duplicate(true)
		invalid["continuation"] = wrong_type
		invalid_cases.append(invalid)
	for change: Dictionary in [{"completed": false}, {"floor": 25}, {"clues": ["continuation_model_23"]}, {"clues": ["continuation_photo_23"]}, {"clues": []}]:
		var invalid: Dictionary = complete.duplicate(true)
		invalid.merge(change, true)
		invalid_cases.append(invalid)
	var missing_reception: Dictionary = complete.duplicate(true)
	missing_reception["continuation"]["escort_state"] = "waiting"
	invalid_cases.append(missing_reception)
	for change: Dictionary in [{"floor": 24}, {"seen_floors": [31, 25, 23]}, {"clues": ["continuation_model_23"]}]:
		var invalid: Dictionary = _save_fixture()
		invalid.merge(change, true)
		invalid_cases.append(invalid)
	var premature: Dictionary = _save_fixture()
	premature["continuation"]["duo_briefed"] = true
	invalid_cases.append(premature)
	for index: int in range(invalid_cases.size()):
		_check(Store.save_data(invalid_cases[index], SAVE_PATH) == ERR_INVALID_DATA, "Writer accepted inconsistent continuation case %d." % index)
		_check(FileAccess.get_file_as_string(SAVE_PATH) == good_bytes, "Rejected continuation case %d overwrote the final checkpoint." % index)
		var serialized: String = JSON.stringify(invalid_cases[index])
		_write(serialized)
		_check(Store.load_data(SAVE_PATH).is_empty(), "Reader accepted inconsistent continuation case %d." % index)
		_check(FileAccess.get_file_as_string(SAVE_PATH) == serialized, "Rejected continuation read %d rewrote its data." % index)
		_write(good_bytes)
	var loaded: Dictionary = Store.load_data(SAVE_PATH)
	loaded["continuation"]["phase"] = "dormant"
	loaded["clues"].clear()
	_check(Store.load_data(SAVE_PATH) == complete, "Mutating loaded continuation aliases persisted state.")


func _context(floor_number: int) -> Dictionary:
	return {"floor": floor_number, "at_landing": true, "completed": true, "incident_state": "aftermath", "rescued": ["survivor_30", "survivor_28", "survivor_26"], "clues": []}


func _save_fixture() -> Dictionary:
	return {"version": Store.SAVE_VERSION, "seed": 271104, "floor": 25, "health": 92.0, "oxygen": 83.0, "stress": 20.0, "anchors": 4, "flares": 2,
		"rescued": ["survivor_30", "survivor_28", "survivor_26"], "clues": [], "supplies_used": [], "elapsed": 100.0,
		"seen_floors": [31, 30, 29, 28, 27, 26, 25], "completed": false, "incident_state": "aftermath", "transmissions": [], "radio_events": [], "continuation": Director.dormant_state(), "commerce": preload("res://scripts/commerce_director.gd").dormant_state()}


func _write(value: String) -> void:
	var file: FileAccess = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	file.store_string(value)
	file.close()


func _cleanup() -> void:
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE_PATH))


func _check(condition: bool, message: String) -> void:
	checks += 1
	if not condition:
		failures.append(message)
