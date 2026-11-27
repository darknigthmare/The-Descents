extends SceneTree
const Director = preload("res://scripts/commerce_director.gd")
const Store = preload("res://scripts/save_store.gd")
const Continuation = preload("res://scripts/continuation_director.gd")
const SAVE := "user://qa_v012_commerce_schema.json"
var checks := 0
var failures: Array[String] = []
func _initialize() -> void: _run.call_deferred()
func _run() -> void:
	var d := Director.new()
	_check(not d.begin({}), "Missing starting conditions opened commerce.")
	var start := {"completed": true, "floor": 23, "at_landing": true, "continuation": {"phase": "complete"}}
	for key: String in ["completed", "at_landing", "continuation"]:
		var broken := start.duplicate(true)
		broken.erase(key)
		_check(not d.begin(broken), "Missing gate opened commerce: " + key)
	_check(d.begin(start) and not d.begin(start), "Chapter start was unavailable or repeatable.")
	_check(not d.toggle_person("mina") and not d.toggle_person("theo"), "A blocked civilian began an escort.")
	_check(not d.begin_action("shutter", "fire_axe"), "Wrong tool opened the reserve.")
	_check(d.begin_action("shutter", "halligan"), "Halligan could not start the reserve.")
	d.advance_action(0.25, true, true, "halligan")
	d.advance_action(0.25, false, true, "halligan")
	_check(d.active_action.is_empty() and not d.has_action("shutter"), "Occlusion completed an interrupted worksite.")
	d.begin_action("shutter", "halligan")
	d.advance_action(INF, true, true, "halligan")
	d.advance_action(100.0, true, true, "halligan")
	_check(not d.has_action("shutter") and d.progress <= 0.25, "A suspended frame completed a worksite.")
	d.cancel()
	_do(d, "shutter", "halligan")
	_check(d.toggle_person("mina") and d.person_state("mina") == "following", "Released Mina did not follow.")
	_check(d.checkpoint_snapshot()["people"]["mina"] == "waiting" and d.person_state("mina") == "following", "Saving aliased live movement.")
	_check(not d.receive("mina", 21, true) and not d.receive("mina", 20, false), "Arrival was confirmed on a wrong floor or at a distance.")
	_check(d.receive("mina", 20, true) and not d.receive("mina", 20, true), "A real reception was missing or duplicated.")
	_check(not d.begin_action("blanket", "halligan"), "Covering was allowed before power isolation.")
	_do(d, "isolation", "halligan")
	_do(d, "blanket", "halligan")
	for id: String in ["theo", "sofia"]:
		_check(d.toggle_person(id), "Civilian could not start: " + id)
		_check(d.receive(id, 20, true), "Civilian could not be received: " + id)
	_check(d.received_count() == 3, "Three physical receptions were not retained.")
	var finish := {"floor": 20, "at_landing": true, "clues": Director.CLUES.keys()}
	_check(not d.complete(finish), "Bilan completed with an unpowered relay.")
	_do(d, "relay", "halligan")
	var missing_clue := finish.duplicate(true)
	missing_clue["clues"] = ["commerce_deliveries_22"]
	_check(not d.complete(missing_clue), "Missing technical record completed the chapter.")
	_check(d.complete(finish) and d.phase == "complete", "Complete physical rescue could not close.")
	var normalized := Director.normalize(d.snapshot(), true)
	_check(not normalized.is_empty(), "A finished state failed strict normalization.")
	for bad: Variant in [null, [], {}, {"phase": "complete"}]:
		_check(Director.normalize(bad).is_empty(), "Malformed state was accepted.")
	var duplicate := d.snapshot()
	duplicate["actions"].append("relay")
	_check(Director.normalize(duplicate).is_empty(), "Duplicated worksite receipt accepted.")
	duplicate = d.snapshot()
	duplicate["actions"].erase("isolation")
	_check(Director.normalize(duplicate).is_empty(), "A blanket receipt without isolation accepted.")
	var checkpoint := _fixture()
	checkpoint["floor"] = 20
	checkpoint["seen_floors"].append_array([22,21,20])
	checkpoint["commerce"] = d.checkpoint_snapshot()
	checkpoint["clues"].append_array(Director.CLUES.keys())
	_check(Store.save_data(checkpoint, SAVE) == OK, "Valid chapter completion could not be persisted.")
	_check(Store.load_data(SAVE) == checkpoint, "Completion changed during JSON round-trip.")
	var original := FileAccess.get_file_as_string(SAVE)
	for change: String in ["continuation", "clues", "people", "floor"]:
		var broken := checkpoint.duplicate(true)
		match change:
			"continuation": broken["continuation"] = Continuation.dormant_state()
			"clues": broken["clues"].erase("commerce_maintenance_21")
			"people": broken["commerce"]["people"]["mina"] = "waiting"
			"floor": broken["floor"] = 21
		_check(Store.save_data(broken, SAVE) == ERR_INVALID_DATA, "Corrupt completion accepted: " + change)
		_check(FileAccess.get_file_as_string(SAVE) == original, "Rejected write overwrote the previous checkpoint.")
	var legacy := _fixture()
	legacy["version"] = 4
	legacy.erase("commerce")
	legacy.erase("residential")
	var file := FileAccess.open(SAVE, FileAccess.WRITE)
	file.store_string(JSON.stringify(legacy))
	file.close()
	original = FileAccess.get_file_as_string(SAVE)
	var migrated := Store.load_data(SAVE)
	_check(migrated.get("version") == Store.SAVE_VERSION and migrated.get("continuation") == legacy["continuation"] and migrated.get("commerce") == Director.dormant_state(), "Migration v4 reset earlier progress or began commerce.")
	_check(FileAccess.get_file_as_string(SAVE) == original, "Merely reading v4 changed its bytes.")
	DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE))
	if failures.is_empty():
		print("PASS commerce director and schema: %d checks; prerequisite actions, physical receipts, interruption, strict JSON and v4 migration." % checks)
		quit(0)
	else:
		for failure in failures: push_error(failure)
		quit(1)
func _do(d: RefCounted, id: String, tool: String) -> void:
	_check(d.begin_action(id, tool), "Cannot begin authored action: " + id)
	for index in range(80): d.advance_action(0.05, true, true, tool)
	_check(d.has_action(id) and not d.begin_action(id, tool), "Action did not finish exactly once: " + id)
func _fixture() -> Dictionary:
	return {"version": Store.SAVE_VERSION, "seed": 271104, "floor": 23, "health": 92.0, "oxygen": 83.0, "stress": 20.0, "anchors": 4, "flares": 2,
		"rescued": ["survivor_30", "survivor_28", "survivor_26"], "clues": Continuation.PROOF_IDS.duplicate(), "supplies_used": [], "elapsed": 320.0,
		"seen_floors": [31,30,29,28,27,26,25,24,23], "completed": true, "incident_state": "aftermath", "transmissions": [], "radio_events": [],
		"continuation": {"phase": "complete", "started_at_refuge": true, "duo_briefed": true, "escort_state": "received"}, "commerce": Director.dormant_state(), "residential": preload("res://scripts/residential_director.gd").dormant_state()}
func _check(condition: bool, message: String) -> void:
	checks += 1
	if not condition: failures.append(message)
