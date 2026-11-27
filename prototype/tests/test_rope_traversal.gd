extends SceneTree
## Pure traversal contracts; actual capsule and route geometry have separate tests.
const Rope = preload("res://scripts/rope_traversal.gd")
var checks: int = 0
var failures: Array[String] = []

func _initialize() -> void:
	_run.call_deferred()

func _run() -> void:
	_test_attach_and_isolation()
	_test_controls_and_brakes()
	_test_local_limits_and_landings()
	_test_stamina()
	_test_pause_and_stabilization()
	_test_collision_reconciliation()
	_test_determinism_and_invalid_inputs()
	if failures.is_empty():
		print("PASS rope_traversal: %d checks; adjacent local belays, two-way travel, precision, fast descent, persistent lock, exhaustion recovery, safe landings, collision reconciliation and frozen pause." % checks)
		quit(0)
	else:
		for failure: String in failures:
			push_error(failure)
		print("FAIL rope_traversal: %d failures / %d checks." % [failures.size(), checks])
		quit(1)

func _route(upper: int = 31) -> Dictionary:
	var y: float = float(upper - 24) * 6.0
	return {
		"id": "R%d_%d" % [upper, upper - 1], "kind": "rope", "title": "Rappel local",
		"upper": upper, "lower": upper - 1,
		"top_entry": Vector3(-3.8, y + 0.06, 0), "bottom_entry": Vector3(-3.8, y - 6 + 0.06, 0),
		"rope_top": Vector3(-1.3, y + 0.04, 0), "rope_bottom": Vector3(-1.3, y - 6 + 0.04, 0),
		"anchor": Vector3(-1.3, y + 2.6, 0), "max_sway": 0.65
	}

func _controls(vertical: float = 0.0, extra: Dictionary = {}) -> Dictionary:
	var result: Dictionary = {"running": true, "vertical": vertical, "lateral": 0.0, "precision": false, "fast": false, "wind_strength": 0.0}
	result.merge(extra, true)
	return result

func _test_attach_and_isolation() -> void:
	var rope = Rope.new()
	var route: Dictionary = _route()
	_check(not rope.active and not rope.can_exit() and rope.exit_floor() == 0, "A detached rig has a usable landing.")
	_check(not rope.toggle_lock() and not rope.secure(), "Detached controls accepted an anchor or lock.")
	_check(rope.attach(route, 31, 73.0), "A valid upper landing could not attach.")
	var before: Dictionary = rope.snapshot()
	_check(before["position"] == Vector3(-1.3, 42.04, 0) and before["stamina"] == 73.0 and before["route_id"] == "R31_30", "Attach lost the exact route, position or carried endurance.")
	_check(before["can_exit"] and before["landing"] == route["top_entry"] and before["exit_floor"] == 31, "An initially held rig cannot return safely to its upper landing.")
	route["rope_top"] = Vector3(500, 500, 500)
	route["id"] = "corrupted"
	before["position"] = Vector3(999,999,999)
	before["stamina"] = -200.0
	_check(rope.snapshot()["position"] == Vector3(-1.3,42.04,0) and rope.snapshot()["route_id"] == "R31_30" and rope.snapshot()["stamina"] == 73.0, "Caller data or returned snapshots alias a live belay.")
	var invalid_changes: Array[Dictionary] = [
		{"kind": "stairs"}, {"upper": 31, "lower": 25}, {"upper": 32}, {"lower": 24},
		{"upper": 31.0}, {"id": " "}, {"rope_top": Vector3(NAN,42.04,0)},
		{"rope_bottom": Vector3(-1.2,36.04,0)}, {"rope_top": Vector3(-1.3,42.8,0)},
		{"top_entry": Vector3(-3.8,42.5,0)}, {"max_sway": 1.8}, {"max_sway": -1.0},
		{"max_sway": NAN}, {"anchor": Vector3(-1.3,42.2,0)}
	]
	for change: Dictionary in invalid_changes:
		var invalid: Dictionary = _route()
		invalid.merge(change, true)
		var retained: Dictionary = rope.snapshot()
		_check(not rope.attach(invalid, 31, 100.0) and rope.snapshot() == retained, "Invalid attachment replaced the current safe rig: %s." % str(change))
	_check(not rope.attach({},31) and not rope.attach(_route(),29) and not rope.attach(_route(),31,NAN), "An absent route, foreign landing or invalid endurance attached.")
	_check(rope.attach(_route(29),28,61.0) and rope.snapshot()["position"] == Vector3(-1.3,24.04,0), "Attaching from the bottom endpoint fails.")
	rope.detach()
	_check(not rope.active and rope.snapshot()["route_id"].is_empty() and rope.snapshot()["stamina"] == 61.0, "Detach leaked a route or invented recovered endurance.")
	rope.reset()
	_check(rope.snapshot()["stamina"] == 100.0 and not rope.snapshot()["locked"] and rope.snapshot()["elapsed"] == 0.0, "Reset retained a previous-session condition.")

func _test_controls_and_brakes() -> void:
	var rope = Rope.new()
	rope.attach(_route(),31)
	var initial: Vector3 = rope.snapshot()["position"]
	var early: Dictionary = rope.advance(0.1,_controls(1.0))
	_check(float(early["speed"]) > 0.0 and float(early["speed"]) < Rope.DESCENT_SPEED, "Rope speed jumps immediately instead of accelerating.")
	var normal: Dictionary = rope.advance(0.9,_controls(1.0))
	_check(is_equal_approx(float(normal["speed"]),Rope.DESCENT_SPEED) and normal["vertical_speed"] < 0.0 and normal["mode"] == "descend", "S does not produce the configured downward velocity.")
	_check(initial.y - normal["position"].y > 2.1 and initial.y - normal["position"].y < 2.5, "The first second of descent ignores acceleration distance.")
	var released_y: float = normal["position"].y
	var held: Dictionary = rope.advance(0.4,_controls())
	_check(held["speed"] == 0.0 and held["mode"] == "hold" and released_y - held["position"].y < 0.3, "Releasing movement fails to engage a short automatic brake.")
	var still: Dictionary = rope.advance(2.0,_controls())
	_check(still["position"] == held["position"], "An unattended descender continues slipping vertically.")
	rope.advance(0.4,_controls(1.0))
	var lock_position: Vector3 = rope.snapshot()["position"]
	_check(rope.toggle_lock() and rope.snapshot()["locked"] and rope.snapshot()["speed"] == 0.0, "Persistent lock did not stop motion immediately.")
	var locked: Dictionary = rope.advance(3.0,_controls(-1.0,{"fast":true,"precision":true,"lateral":1.0}))
	_check(locked["position"] == lock_position and locked["locked"] and locked["mode"] == "locked", "Held controls override a locked descender.")
	_check(rope.toggle_lock() and not rope.snapshot()["locked"], "The same lock command cannot release the descender.")
	var ascending: Dictionary = rope.advance(0.6,_controls(-1.0))
	_check(is_equal_approx(float(ascending["speed"]),Rope.ASCENT_SPEED) and ascending["vertical_speed"] > 0.0 and ascending["mode"] == "ascend", "Z/W does not climb at the configured speed.")
	rope.attach(_route(),31)
	var precise: Dictionary = rope.advance(1.0,_controls(1.0,{"precision":true,"fast":true}))
	_check(is_equal_approx(float(precise["speed"]),Rope.PRECISION_SPEED) and precise["mode"] == "precision", "Precision fails to override fast descent.")
	rope.attach(_route(),31)
	var rapid: Dictionary = rope.advance(1.0,_controls(1.0,{"fast":true}))
	_check(is_equal_approx(float(rapid["speed"]),Rope.FAST_DESCENT_SPEED) and rapid["mode"] == "rapid" and rapid["stamina"] < 100.0, "Fast descent has no distinct speed or endurance cost.")
	rope.attach(_route(),30)
	var fast_up: Dictionary = rope.advance(0.5,_controls(-1.0,{"fast":true}))
	_check(is_equal_approx(float(fast_up["speed"]),Rope.ASCENT_SPEED), "Fast descent improperly accelerates climbing.")
	var old_y: float = fast_up["position"].y
	var reversed: Dictionary = rope.advance(0.05,_controls(1.0))
	_check(reversed["position"].y > old_y and reversed["vertical_speed"] >= 0.0, "Direction reversal bypasses braking and instantly reverses inertia.")

func _test_local_limits_and_landings() -> void:
	var rope = Rope.new()
	for upper: int in [31,29,27,24,22,21,19,18]:
		var route: Dictionary = _route(upper)
		rope.attach(route,upper)
		var bottom: Dictionary = rope.advance(100.0,_controls(1.0))
		_check(bottom["position"] == route["rope_bottom"] and bottom["speed"] == 0.0, "Local rope descended beyond its single lower floor: %d." % upper)
		_check(bottom["can_exit"] and bottom["exit_floor"] == upper-1 and bottom["landing"] == route["bottom_entry"], "Bottom exit does not match its actual prepared landing: %d." % upper)
		var top: Dictionary = rope.advance(100.0,_controls(-1.0))
		_check(top["position"] == route["rope_top"] and top["can_exit"] and top["exit_floor"] == upper, "Return route cannot climb back to its own upper endpoint: %d." % upper)
		_check(is_equal_approx(float(top["segment_length"]),6.0) and is_zero_approx(float(top["travelled"])), "The local route length is not one six-metre floor.")
	_check(not rope.attach(_route(17), 17), "The rig admitted a route below the built chapter's floor-17 boundary.")
	rope.attach(_route(),31)
	rope.sync_position(Vector3(-1.3,39.04,0))
	_check(not rope.can_exit() and rope.exit_floor() == 0 and not rope.landing().is_finite(), "A midpoint offers an invented walkable floor.")
	rope.sync_position(Vector3(-1.3,41.65,0))
	_check(rope.can_exit() and rope.exit_floor() == 31, "A braked player inside vertical landing tolerance cannot exit.")
	rope.sync_position(Vector3(-1.3,41.58,0))
	_check(not rope.can_exit(), "A player outside vertical landing tolerance can exit.")
	rope.sync_position(Vector3(-1.3,42.04,0.26))
	_check(not rope.can_exit(), "Excess lateral offset allows an unsafe dismount.")
	rope.sync_position(Vector3(-1.3,42.04,0.25))
	_check(rope.can_exit(), "The documented lateral dismount boundary rejects a stable player.")
	rope.attach(_route(),31)
	rope.advance(0.12,_controls(1.0))
	_check(not rope.can_exit(), "Alignment alone permits dismounting at speed.")
	rope.toggle_lock()
	_check(rope.can_exit(), "Immediate lock cannot prepare an aligned landing.")
	var measure: Dictionary = rope.snapshot()
	_check(float(measure["deployed"]) > 0.0 and float(measure["rope_length"]) >= float(measure["deployed"]) and is_equal_approx(float(measure["deployed"])+float(measure["remaining"]),float(measure["rope_length"])), "Line deployment measures contradict their available length.")
	_check(is_equal_approx(float(measure["travelled"])+float(measure["distance_remaining"]),6.0), "Travel measures do not cover exactly the local descent.")

func _test_stamina() -> void:
	var normal = Rope.new()
	normal.attach(_route(),31,65.0)
	_check(is_equal_approx(float(normal.advance(1.0,_controls(1.0))["stamina"]),65.0), "Normal controlled descent has an undocumented endurance cost or recovery.")
	var climbing = Rope.new()
	climbing.attach(_route(),30,65.0)
	var climbed: Dictionary = climbing.advance(1.0,_controls(-1.0))
	_check(climbed["stamina"] < 57.0 and climbed["stamina"] > 55.0, "Climbing endurance does not reflect movement with acceleration.")
	var precise = Rope.new()
	precise.attach(_route(),30,65.0)
	_check(precise.advance(1.0,_controls(-1.0,{"precision":true}))["stamina"] > climbed["stamina"], "Precision climbing does not reduce the rate of exertion.")
	climbing.attach(_route(),30,1.0)
	var exhausted: Dictionary = climbing.advance(0.4,_controls(-1.0))
	_check(exhausted["exhausted"] and exhausted["mode"] == "rest" and exhausted["speed"] == 0.0, "Exhaustion does not securely hold the player.")
	var rested_position: Vector3 = exhausted["position"]
	var recovering: Dictionary = climbing.advance(0.5,_controls(-1.0))
	_check(recovering["position"] == rested_position and recovering["stamina"] > exhausted["stamina"], "Exhausted hold falls, climbs prematurely or cannot recover.")
	var resumed: Dictionary = climbing.advance(2.0,_controls(-1.0))
	_check(not resumed["exhausted"] and resumed["position"].y > rested_position.y, "The recovery threshold softlocks ascent.")
	climbing.toggle_lock()
	var before_lock_stamina: float = climbing.snapshot()["stamina"]
	var locked: Dictionary = climbing.advance(0.5,_controls(1.0,{"fast":true}))
	_check(is_equal_approx(float(locked["stamina"]),minf(100.0,before_lock_stamina+6.0)), "Locked rest does not recover twelve endurance points per second.")
	climbing.advance(100.0,_controls())
	_check(climbing.snapshot()["stamina"] == 100.0, "Rest exceeds or fails to reach the endurance ceiling.")
	climbing.attach(_route(),31,0.0)
	_check(climbing.snapshot()["mode"] == "rest" and climbing.snapshot()["speed"] == 0.0, "Zero initial endurance creates an uncontrolled descent.")
	climbing.advance(2.0,_controls(1.0))
	_check(climbing.snapshot()["position"].y < 42.04, "A fully exhausted new belay cannot recover and continue.")

func _test_pause_and_stabilization() -> void:
	var rope = Rope.new()
	rope.attach(_route(),31,70.0)
	rope.advance(0.7,_controls(1.0,{"lateral":1.0,"wind_strength":1.0}))
	var swung: Dictionary = rope.snapshot()
	_check(float(swung["sway"]) > 0.25 and is_equal_approx(swung["position"].x, -1.3) and absf(float(swung["sway"])) <= 0.65, "Lateral input leaves its bounded Z corridor or has no effect.")
	_check(rope.secure(), "A fresh secondary anchor cannot be set.")
	var secured: Dictionary = rope.snapshot()
	_check(secured["secured_time"] == 16.0 and secured["sway"] == 0.0 and secured["sway_speed"] == 0.0, "The secondary anchor does not stabilize the local rig.")
	_check(not rope.secure() and rope.snapshot() == secured, "Repeated anchoring refreshes an active consumable effect.")
	var paused: Dictionary = rope.advance(30.0,_controls(1.0,{"running":false,"lateral":1.0,"wind_strength":1.0}))
	_check(paused == secured, "Pause advances movement, fatigue, anchor expiry or the wind clock.")
	rope.advance(8.0,_controls(0.0,{"wind_strength":1.0}))
	_check(absf(float(rope.snapshot()["secured_time"])-8.0) < 0.001, "Anchor duration does not use eligible simulation time.")
	rope.advance(8.1,_controls(0.0,{"wind_strength":1.0}))
	_check(rope.snapshot()["secured_time"] == 0.0 and rope.secure(), "An expired anchor cannot be replaced.")
	var bounded: Dictionary = rope.advance(100.0,_controls(0.0,{"lateral":-1.0,"wind_strength":1.0}))
	_check(absf(float(bounded["sway"])) <= 0.65 and is_equal_approx(bounded["position"].x, -1.3) and bounded["position"].is_finite(), "Long-frame wind or input escapes the reserved rope corridor.")

func _test_collision_reconciliation() -> void:
	var rope = Rope.new()
	rope.attach(_route(),31,80.0)
	var moving: Dictionary = rope.advance(0.5,_controls(1.0))
	rope.sync_position(moving["position"])
	_check(rope.snapshot()["speed"] == moving["speed"], "Reconciliation of an unobstructed capsule discards its velocity.")
	var stopped_position: Vector3 = moving["position"] + Vector3(0,0.1,0)
	rope.sync_position(stopped_position)
	_check(rope.snapshot()["position"] == stopped_position and rope.snapshot()["speed"] == 0.0 and rope.snapshot()["stamina"] == moving["stamina"], "A collision correction keeps hidden inertia or changes resources.")
	rope.sync_position(Vector3(5,100,8))
	_check(rope.snapshot()["position"] == Vector3(-1.3,42.04,0.65) and not rope.can_exit(), "Collision reconciliation can escape route height or lateral limits.")
	rope.sync_position(Vector3(-1.3,-100,-8))
	_check(rope.snapshot()["position"] == Vector3(-1.3,36.04,-0.65), "Lower collision reconciliation escapes the adjacent landing.")
	var before: Dictionary = rope.snapshot()
	rope.sync_position(Vector3(INF,0,0))
	_check(rope.snapshot() == before, "A non-finite physics result corrupts the current belay.")

func _test_determinism_and_invalid_inputs() -> void:
	var one = Rope.new()
	var split = Rope.new()
	one.attach(_route(),31,82.0)
	split.attach(_route(),31,82.0)
	var controls: Dictionary = _controls(1.0,{"precision":true,"lateral":0.6,"wind_strength":0.7})
	one.advance(2.0,controls)
	for _step in range(120):
		split.advance(1.0/60.0,controls)
	var a: Dictionary = one.snapshot()
	var b: Dictionary = split.snapshot()
	_check(a["position"].distance_to(b["position"]) < 0.0002 and absf(float(a["stamina"])-float(b["stamina"])) < 0.0001, "Equivalent simulated time depends on render-frame partition.")
	var before: Dictionary = one.snapshot()
	for delta: float in [-1.0,0.0,NAN,INF,-INF,121.0]:
		_check(one.advance(delta,controls) == before, "Invalid or unbounded timestep changes a live rig.")
	for change: Dictionary in [{"vertical":NAN},{"vertical":2.0},{"vertical":"1"},{"lateral":INF},{"wind_strength":-1.0},{"wind_strength":NAN},{"running":1},{"precision":"yes"},{"fast":null}]:
		_check(one.advance(1.0,_controls(1.0,change)) == before, "Malformed control input changes a live rig: %s." % str(change))
	seed(93451)
	var expected_random: int = randi()
	seed(93451)
	one.advance(1.0,controls)
	_check(randi() == expected_random, "Traversal consumes global random state.")

func _check(condition: bool, message: String) -> void:
	checks += 1
	if not condition:
		failures.append(message)
