extends SceneTree
## Pure sampled timelines and menu projections; no scene rendering required.

const Director = preload("res://scripts/cinematic_director.gd")
const Store = preload("res://scripts/save_store.gd")
const TEST_PATH: String = "user://qa_v04_cinematic_context.json"
var failures: Array[String] = []
var checks: int = 0


func _initialize() -> void:
	_cleanup()
	_test_boot()
	_test_arrival()
	_test_camera()
	_test_menu_context()
	_cleanup()
	if failures.is_empty():
		print("PASS cinematic director: %d checks; four boot cards, four arrival shots/cues, skip, frozen sampling, long frames and spoiler-safe saved menu contexts." % checks)
		quit(0)
	else:
		for failure: String in failures:
			push_error(failure)
		print("FAIL cinematic director: %d failures / %d checks." % [failures.size(), checks])
		quit(1)


func _test_boot() -> void:
	var director = Director.new()
	director.start("boot")
	_check(director.active and director.duration() == 15.0, "Boot is not the expected fifteen-second sequence.")
	var last_progress: float = -1.0
	for sample: Array in [[0.9, "studio"], [4.3, "presents"], [6.5, "author"], [10.0, "title"]]:
		_check(director.advance(float(sample[0]) - director.elapsed).is_empty(), "A boot card emitted arrival radio cues.")
		var card: Dictionary = director.presentation()
		_check(card.get("card") == sample[1] and float(card.get("alpha", 0.0)) > 0.0, "Boot card %s did not appear during its readable interval." % sample[1])
		_check(float(card["progress"]) > last_progress and float(card["alpha"]) <= 1.0, "Boot progress or opacity is invalid.")
		last_progress = float(card["progress"])
	var before: Dictionary = director.presentation()
	_check(director.advance(0.0).is_empty() and director.presentation() == before, "A paused boot advanced or changed its card.")
	director.advance(5.0)
	_check(not director.active and director.elapsed == 15.0 and director.presentation()["progress"] == 1.0, "Boot failed to finish exactly at fifteen seconds.")
	director.start("boot")
	director.advance(1.0)
	director.finish()
	_check(not director.active and director.elapsed == 15.0 and director.advance(1000.0).is_empty(), "Skipping boot did not finish without further events.")
	director.start("unknown")
	_check(not director.active and director.mode.is_empty() and director.duration() == 0.0 and director.advance(100.0).is_empty(), "An invalid sequence started a live timeline.")


func _test_arrival() -> void:
	var director = Director.new()
	director.start("arrival")
	_check(director.active and director.duration() == 28.0, "Arrival is not the expected twenty-eight-second sequence.")
	_check(director.presentation()["shot"] == 0 and director.advance(0.0).is_empty(), "Arrival did not begin on shot zero before its first radio cue.")
	_check(director.advance(-3.0).is_empty() and director.elapsed == 0.0, "A negative frame rewound or advanced arrival.")
	_check(director.advance(0.59).is_empty(), "First arrival cue fired before its scheduled time.")
	var received: Array[Dictionary] = director.advance(0.01)
	_check(received.size() == 1 and received[0]["speaker"] == Director.ARRIVAL_CUES[0]["speaker"], "The opening arrival cue did not fire at its threshold.")
	var snapshot: Dictionary = director.presentation()
	_check(director.advance(0.0).is_empty() and director.presentation() == snapshot, "A paused arrival replayed a cue or advanced its card.")
	for shot: int in [1, 2, 3]:
		var boundary: float = float(shot) * 7.0
		received.append_array(director.advance(boundary - director.elapsed))
		_check(director.presentation()["shot"] == shot, "Arrival did not cut to shot %d at its boundary." % shot)
		received.append_array(director.advance(0.3))
	_check(received.size() == 4, "The complete arrival did not emit exactly four radio cues.")
	for index in range(received.size()):
		_check(received[index] == Director.ARRIVAL_CUES[index], "Arrival cues changed order, wording or duration.")
	director.advance(1000.0)
	_check(not director.active and director.elapsed == 28.0 and director.presentation()["shot"] == 3, "A long final frame escaped the timeline end.")
	_check(director.advance(1000.0).is_empty(), "A finished arrival repeated a cue.")
	director.start("arrival")
	var all_at_once: Array[Dictionary] = director.advance(10000.0)
	_check(all_at_once.size() == 4 and director.cue_cursor == 4 and not director.active, "A single long frame lost or duplicated arrival cues.")
	all_at_once[0]["message"] = "Mutated returned copy"
	director.start("arrival")
	var restarted: Array[Dictionary] = director.advance(1.0)
	_check(restarted.size() == 1 and restarted[0]["message"] != "Mutated returned copy", "Returned cue dictionaries expose mutable timeline constants.")
	director.finish()
	_check(director.advance(1000.0).is_empty() and director.cue_cursor == 4 and director.elapsed == 28.0, "Skipping arrival emitted its unplayed future cues.")


func _test_camera() -> void:
	var director = Director.new()
	director.start("boot")
	var still_boot: Dictionary = director.camera_sample(true)
	var moving_boot: Dictionary = director.camera_sample(false)
	director.advance(7.0)
	_check(director.camera_sample(true) == still_boot, "Reduced-motion boot still moves its camera.")
	_check(director.camera_sample(false) != moving_boot, "Normal boot does not sample its camera movement.")
	director.start("arrival")
	for shot in range(4):
		director.advance(float(shot) * 7.0 + 0.5 - director.elapsed)
		var fixed: Dictionary = director.camera_sample(true)
		var moving: Dictionary = director.camera_sample(false)
		director.advance(1.0)
		_check(director.camera_sample(true) == fixed, "Reduced-motion arrival drifts inside shot %d." % shot)
		_check(director.camera_sample(false) != moving, "Normal arrival has no motion inside shot %d." % shot)
		_check((fixed["position"] as Vector3).is_finite() and (fixed["target"] as Vector3).is_finite() and (fixed["position"] as Vector3).distance_to(fixed["target"]) > 0.1, "A camera sample has an invalid look-at position.")
	director.finish()
	var landing: Vector3 = Vector3(8.0, 44.0, 6.0)
	var facing: Vector3 = Vector3.FORWARD
	var handoff: Dictionary = director.camera_sample(false, landing, facing)
	_check((handoff["position"] as Vector3).is_equal_approx(landing) and (handoff["target"] as Vector3).is_equal_approx(landing + facing * 10.0), "Arrival endpoint fails to meet the supplied player camera pose.")
	_check(is_equal_approx(float(handoff["fov"]), 76.0), "Arrival endpoint failed to restore first-person field of view.")


func _test_menu_context() -> void:
	var empty: Dictionary = Director.menu_context(Store.load_data(TEST_PATH))
	_check(empty["id"] == "approach" and empty["incident"] == "intact" and empty["rescued"] == 0, "No-save menu reveals future damage or rescue progress.")
	_check(str(empty["detail"]).contains("Deux tours debout"), "The no-save menu does not establish the intact approach.")
	for phase: String in ["intact", "aftermath"]:
		for floor_number: int in [31, 30, 29, 28, 27, 26, 25]:
			var data: Dictionary = _fixture(floor_number, phase)
			var error: Error = Store.save_data(data, TEST_PATH)
			var validated: Dictionary = Store.load_data(TEST_PATH)
			_check(error == OK and not validated.is_empty(), "Menu fixture did not pass the public checkpoint validator.")
			var context: Dictionary = Director.menu_context(validated)
			_check(context["floor"] == floor_number and context["incident"] == phase and context["rescued"] == 1, "Menu changed the actual saved floor, structure or confirmed rescue count.")
			_check(context["id"] == ("roof" if floor_number == 31 else "floor") and not str(context["title"]).contains("TERMINÉE"), "An active save prematurely exposes the completed menu.")
			if phase == "intact":
				_check(str(context["detail"]).contains("Alpha et Bravo sont en liaison") and not str(context["detail"]).contains("dégradé"), "An intact checkpoint reveals the future radio loss.")
	var completed: Dictionary = _fixture(25, "aftermath")
	completed["completed"] = true
	completed["rescued"] = ["survivor_30", "survivor_28", "survivor_26"]
	_check(Store.save_data(completed, TEST_PATH) == OK, "Completed menu fixture was rejected.")
	var end_context: Dictionary = Director.menu_context(Store.load_data(TEST_PATH))
	_check(end_context["id"] == "refuge" and end_context["rescued"] == 3 and end_context["floor"] == 25, "Completed checkpoint did not select its achieved refuge context.")
	var original: Dictionary = end_context.duplicate(true)
	var camera_a: Dictionary = Director.menu_camera(end_context, 0.0, true)
	_check(Director.menu_camera(end_context, 200.0, true) == camera_a, "Reduced-motion menu still animates its camera.")
	_check(Director.menu_camera(end_context, 0.0, false) != Director.menu_camera(end_context, 20.0, false), "Normal menu did not animate its sampled camera.")
	_check(end_context == original, "Sampling the menu camera mutated the persisted-state projection.")
	var before: Dictionary = Director.menu_context(_fixture(29, "intact"))
	var after: Dictionary = Director.menu_context(_fixture(29, "aftermath"))
	_check(Director.menu_camera(before, 0.0, true) != Director.menu_camera(after, 0.0, true), "Observed damage failed to change the menu's floor-29 composition.")


func _fixture(floor_number: int, phase: String) -> Dictionary:
	return {"version": 3, "seed": 271104, "floor": floor_number, "health": 100.0, "oxygen": 100.0, "stress": 8.0, "anchors": 4, "flares": 3, "rescued": ["survivor_30"], "clues": [], "supplies_used": [], "elapsed": 100.0, "seen_floors": [31, 30], "completed": false, "incident_state": phase, "transmissions": [], "radio_events": []}


func _cleanup() -> void:
	if FileAccess.file_exists(TEST_PATH):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_PATH))


func _check(condition: bool, message: String) -> void:
	checks += 1
	if not condition:
		failures.append(message)
