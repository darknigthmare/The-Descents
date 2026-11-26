extends SceneTree
## State-machine checks. Physical capsule travel is covered separately.
const Director = preload("res://scripts/residential_director.gd")
var checks: int = 0
var failures: Array[String] = []

func _initialize() -> void:
	_run.call_deferred()

func _run() -> void:
	var d := Director.new()
	var start := {"completed": true, "floor": 20, "at_landing": true, "commerce": {"phase": "complete"}}
	for change: Dictionary in [{"completed": false}, {"floor": 19}, {"at_landing": false}, {"commerce": {"phase": "active"}}]:
		var invalid: Dictionary = start.duplicate(true)
		invalid.merge(change, true)
		_check(not d.begin(invalid) and d.snapshot() == Director.dormant_state(), "Invalid previous debrief opened residences: %s" % change)
	_check(d.begin(start) and not d.begin(start), "Residences must start once from a completed refuge-20 debrief.")
	for id: String in Director.PERSON_IDS:
		_check(not d.toggle_person(id), "An unsafe escort began before its prerequisites: " + id)
	_check(not d.begin_action("service_access", "fire_axe"), "A wrong tool opened the service route.")
	_check(not d.begin_action("relay", "") and not d.begin_relay("AUBE-20", "NACRE-204"), "Unpowered/unread relay could emit.")
	_check(d.begin_action("care", ""), "Care action could not begin.")
	d.advance_action(0.25, true, true, "")
	d.advance_action(0.25, false, true, "")
	_check(d.active_action.is_empty() and not d.has_action("care"), "Occluded care action kept its progress.")
	d.begin_action("care", "")
	for delta: float in [INF, NAN, -1.0, 0.0]: d.advance_action(delta, true, true, "")
	_check(d.progress == 0.0, "Non-finite, negative or zero elapsed time changed action progress.")
	d.advance_action(200.0, true, true, "")
	_check(d.progress <= 0.25 and not d.has_action("care"), "A suspended frame completed care.")
	d.cancel()
	_do(d, "care", "")
	_check(d.toggle_person("jeanne") and d.person_state("jeanne") == "following", "Prepared Jeanne did not follow.")
	var walking := d.snapshot()
	var saved := d.checkpoint_snapshot()
	_check(saved["people"]["jeanne"] == "waiting" and d.person_state("jeanne") == "following", "Checkpoint normalization mutated live escort motion.")
	_check(Director.normalize(walking, true).is_empty(), "Durable state accepted transient following.")
	_check(d.restore_runtime(walking) and d.person_state("jeanne") == "following", "Runtime rollback reset a walking civilian.")
	var resumed := Director.new()
	_check(resumed.restore(walking) and resumed.person_state("jeanne") == "waiting", "Reload restored a civilian in the middle of physical travel.")
	_check(not d.receive("jeanne", 19, true) and not d.receive("jeanne", 20, false), "A distant or wrong-floor arrival was received.")
	_check(d.receive("jeanne", 20, true) and not d.receive("jeanne", 20, true), "Supported refuge reception was lost or repeatable.")
	_do(d, "service_access", "halligan")
	for id: String in ["marc", "ines"]:
		_check(d.toggle_person(id), "Open service route did not allow escort: " + id)
	_do(d, "power", "")
	_check(not d.begin_relay("AUBE-20", "NACRE-204"), "A remembered code bypassed the unread physical reference.")
	_do(d, "reference", "")
	var before_wrong := d.snapshot()
	for pair: Array in [["HESPERIE", "NACRE-204"], ["AUBE-20", "NACRE-240"], ["", ""], ["AUBE-20\nHESPERIE", "NACRE-204"]]:
		_check(not d.validate_relay(pair[0], pair[1]) and not d.begin_relay(pair[0], pair[1]) and d.snapshot() == before_wrong, "Wrong relay entry changed escorts or progress: %s" % [pair])
	_check(not d.begin_action("relay", ""), "Relay verification was bypassed through generic action start.")
	_check(d.validate_relay("  aube-20  ", " nacre-204 ") and d.snapshot() == before_wrong, "Harmless case/spacing was rejected or validation mutated durable state.")
	_check(d.begin_relay("AUBE-20", "NACRE-204"), "Correct destination/reference could not arm relay.")
	for tick: int in range(12): d.advance_action(1.0 / 60.0, true, false, "")
	_check(d.active_action == "relay" and d.progress == 0.0 and not d.has_action("relay"), "The verified form was discarded before the player could press E, or emitted without a hold.")
	var armed_checkpoint := d.checkpoint_snapshot()
	var armed_reload := Director.new()
	_check(armed_reload.restore(armed_checkpoint) and not armed_reload.begin_action("relay", ""), "Transient radio authorization leaked into a checkpoint.")
	d.advance_action(0.25, true, true, "")
	d.advance_action(0.25, true, false, "")
	_check(not d.has_action("relay") and not d.begin_action("relay", ""), "Interrupted relay retained an armed authorization.")
	_check(d.begin_relay("AUBE-20", "NACRE-204"), "Correct relay retry was not available after interruption.")
	for index in range(45): d.advance_action(0.05, true, true, "")
	_check(d.has_action("relay") and d.person_state("marc") == "following" and d.person_state("ines") == "following", "Relay completion reset ongoing escorts.")
	_check(not d.begin_relay("AUBE-20", "NACRE-204"), "Already confirmed relay could be submitted again.")
	# Simulate a failing checkpoint write: the caller keeps physical cursors and
	# restores the director's previous live snapshot rather than its disk form.
	_check(d.restore_runtime(before_wrong) and not d.has_action("relay") and d.person_state("ines") == "following", "Failed-relay save rollback lost the escort or retained the unpersisted receipt.")
	_check(d.begin_relay("AUBE-20", "NACRE-204"), "Relay could not be retried after failed-save rollback.")
	for index in range(45): d.advance_action(0.05, true, true, "")
	var finish := {"floor": 17, "at_landing": true, "clues": Director.CLUES.keys()}
	_check(not d.complete(finish), "Relay alone completed the chapter before physical receptions.")
	for id: String in ["marc", "ines"]: _check(d.receive(id, 20, true), "Physical arrival failed: " + id)
	_check(d.received_count() == 3, "The three new receptions were not retained.")
	for change: Dictionary in [{"floor": 20}, {"at_landing": false}, {"clues": ["residential_visits_19", "residential_crack_18"]}]:
		var incomplete := finish.duplicate(true)
		incomplete.merge(change, true)
		_check(not d.complete(incomplete), "Incomplete final-report context was accepted: %s" % change)
	_check(d.complete(finish) and not d.complete(finish), "Valid final report was missing or repeatable.")
	_check(not Director.normalize(d.snapshot(), true).is_empty(), "A valid completed residential state failed normalization.")
	for malformed: Variant in [null, [], {}, {"phase": "complete"}]: _check(Director.normalize(malformed).is_empty(), "Malformed residential state accepted.")
	for change: String in ["relay_before_power", "unknown_action", "duplicate_contact", "unknown_person", "missing_care", "missing_access", "extra_key", "missing_reception"]:
		var invalid := d.snapshot()
		match change:
			"relay_before_power": invalid["actions"] = ["relay", "power", "reference", "care", "service_access"]
			"unknown_action": invalid["actions"].append("invented")
			"duplicate_contact": invalid["contacted"].append("ines")
			"unknown_person": invalid["people"]["alex"] = "received"
			"missing_care": invalid["actions"].erase("care")
			"missing_access": invalid["actions"].erase("service_access")
			"extra_key": invalid["radio_code"] = "NACRE-204"
			"missing_reception": invalid["people"]["jeanne"] = "waiting"
		_check(Director.normalize(invalid).is_empty(), "Inconsistent state accepted: " + change)
	d.reset()
	_check(d.snapshot() == Director.dormant_state() and d.active_action.is_empty(), "Reset retained residential progress.")
	_finish()

func _do(d: RefCounted, id: String, tool: String) -> void:
	_check(d.begin_action(id, tool), "Could not begin action " + id)
	for index in range(70): d.advance_action(0.05, true, true, tool)
	_check(d.has_action(id) and not d.begin_action(id, tool), "Action failed or could repeat: " + id)

func _check(condition: bool, message: String) -> void:
	checks += 1
	if not condition: failures.append(message)

func _finish() -> void:
	if failures.is_empty():
		print("PASS residential director: %d checks; rescue prerequisites, cancellable work, verified relay, retry, runtime rollback and physical-reception contracts." % checks)
		quit(0)
	else:
		for failure: String in failures: push_error(failure)
		print("FAIL residential director: %d failures / %d checks." % [failures.size(), checks])
		quit(1)
