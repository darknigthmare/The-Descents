extends SceneTree
## Early ambiguity remains non-combat, deterministic and subordinate to rescue.
const Horror = preload("res://scripts/horror_director.gd")
const Visuals = preload("res://scripts/horror_presentation.gd")
const World = preload("res://scripts/world_builder.gd")
const Generator = preload("res://scripts/floor_generator.gd")
var checks: int = 0
var failures: Array[String] = []

func _initialize() -> void:
	_run.call_deferred()

func _run() -> void:
	_test_priorities()
	_test_periphery()
	_test_traces()
	_test_spa()
	_test_visibility()
	_test_restore_and_isolation()
	await _test_presentation()
	if failures.is_empty():
		print("PASS horror: %d checks; quiet early perceptions, peripheral glance, lingering traces, bounded recurrence, rescue priority, checkpoint continuity and collision-free scene dressing." % checks)
		quit(0)
	else:
		for failure: String in failures:
			push_error(failure)
		print("FAIL horror: %d failures / %d checks." % [failures.size(), checks])
		quit(1)

func _context(floor_number: int) -> Dictionary:
	var anchor: Vector3 = Horror.SUITES_POSITION if floor_number == 29 else (Horror.SPA_POSITION if floor_number == 26 else Horror.TRACE_POSITION)
	var position_value: Vector3 = anchor + Vector3(6, 0.2, 1.0)
	var camera: Vector3 = position_value + Vector3(0, 1.5, 0)
	var toward: Vector3 = (anchor + Vector3(0, 1.2, 0) - camera).normalized()
	return {"floor": floor_number, "running": true, "on_rope": false, "carrying": false, "hoisting": false, "incident_active": false, "incident_state": "aftermath", "radio_busy": false, "player_position": position_value, "camera_position": camera, "camera_forward": toward.rotated(Vector3.UP, 0.55), "lamp_enabled": true, "flare_active": false, "reduced_motion": true}

func _test_priorities() -> void:
	var director = Horror.new()
	var context: Dictionary = _context(29)
	context["running"] = false
	_check(_quiet(director.advance(100, context)) and director.elapsed == 0.0 and director.cue_serial == 0, "An inactive mission ran a manifestation or cue.")
	context["running"] = true
	for priority: String in ["on_rope", "carrying", "hoisting", "incident_active", "radio_busy"]:
		director.reset()
		context[priority] = true
		_check(_quiet(director.advance(100, context)) and director.elapsed == 0.0 and director.cue_serial == 0, "Priority %s allowed hidden progression." % priority)
		context[priority] = false
		director.advance(3.3, context)
		var active_clock: float = director.elapsed
		var serial: int = director.cue_serial
		context[priority] = true
		_check(_quiet(director.advance(10, context)) and director.elapsed == active_clock and director.cue_serial == serial, "Priority %s failed to suspend an active manifestation." % priority)
		context[priority] = false
		_check(float(director.advance(0, context)["suites_alpha"]) > 0.0 and director.cue_serial == serial, "Resume after %s lost the frozen presentation or duplicated its cue." % priority)
	for floor_number: int in [31, 30, 27, 25, 24, 0]:
		director.reset()
		context["floor"] = floor_number
		_check(_quiet(director.advance(100, context)) and director.elapsed == 0.0, "Quiet or unbuilt floor %d received an early manifestation." % floor_number)
	director.reset()
	context = _context(29)
	director.advance(1.0, context)
	var original: float = director.elapsed
	for delta: float in [-1.0, NAN, INF, -INF, 0.0]:
		director.advance(delta, context)
		_check(director.elapsed == original and director.cue_serial == 0, "Invalid delta advanced the quiet clock or emitted a cue.")

func _test_periphery() -> void:
	var director = Horror.new()
	var context: Dictionary = _context(29)
	director.advance(2.0, context)
	_check(_quiet(director.presentation()) and director.cue_serial == 0, "The suite figure appears before its quiet lead-in.")
	var frame: Dictionary = director.advance(1.3, context)
	_check(frame["id"] == "peripheral_29" and float(frame["suites_alpha"]) > 0.0 and float(frame["suites_alpha"]) <= 0.72, "Peripheral suite glance failed to appear with bounded opacity.")
	_check(frame["cue_id"] == "distant_steps" and frame["cue_serial"] == 1 and frame["cue_position"] == Horror.SUITES_POSITION, "Suite audio cue lacks a single spatial source.")
	var serial: int = director.cue_serial
	director.presentation()
	director.advance(0, context)
	_check(director.cue_serial == serial, "Redrawing a suite frame emitted a second cue.")
	context["camera_forward"] = (Horror.SUITES_POSITION + Vector3(0,1.15,0) - context["camera_position"]).normalized()
	var before: float = float(frame["suites_alpha"])
	frame = director.advance(0.3, context)
	_check(float(frame["suites_alpha"]) < before, "Looking directly at the peripheral impression did not fade it.")
	frame = director.advance(0.31, context)
	_check(_quiet(frame), "A suite impression survived the direct-look limit.")
	context = _context(29)
	director.advance(30, context)
	_check(_quiet(director.presentation()) and director.cue_serial == 1, "The consumed suite impression repeated in the same intervention.")
	for variation: String in ["far", "behind", "direct", "invalid", "flare"]:
		director.reset()
		context = _context(29)
		match variation:
			"far": context["player_position"] += Vector3(40,0,0)
			"behind": context["camera_forward"] *= -1.0
			"direct": context["camera_forward"] = (Horror.SUITES_POSITION + Vector3(0,1.15,0) - context["camera_position"]).normalized()
			"invalid": context["camera_position"] = Vector3(INF,0,0)
			"flare": context["flare_active"] = true
		director.advance(3.3, context)
		_check(_quiet(director.presentation()) and director.cue_serial == 0, "Suite trigger ignores %s eligibility." % variation)
	director.reset()
	context = _context(29)
	director.advance(3.3, context)
	director.advance(1, _context(28))
	director.advance(3.3, context)
	_check(float(director.presentation()["suites_alpha"]) == 0.0, "Leaving the floor parked a half-faded figure for a return visit.")

func _test_traces() -> void:
	var director = Horror.new()
	var context: Dictionary = _context(28)
	context["incident_state"] = "intact"
	_check(_quiet(director.advance(20, context)), "Damp aftermath traces appeared before the impact.")
	context["incident_state"] = "aftermath"
	director.advance(3.5, context)
	var first: Dictionary = director.presentation()
	_check(float(first["trace_progress"]) > 0.0 and float(first["trace_progress"]) < 1.0 and first["phase"] == "forming", "Archive traces have no gradual material appearance.")
	_check(first["cue_serial"] == 1 and first["cue_id"] == "water_step", "Archive trace did not issue its one spatial step cue.")
	context["carrying"] = true
	var clock: float = director.elapsed
	var held: Dictionary = director.advance(10, context)
	_check(held["trace_progress"] == first["trace_progress"] and director.elapsed == clock, "A rescue advanced the material trace.")
	_check(float(held["trace_alpha"]) > 0.0, "A physical damp trace vanished when a person was picked up.")
	context["carrying"] = false
	director.advance(20, context)
	var settled: Dictionary = director.presentation()
	_check(settled["trace_progress"] == 1.0 and settled["phase"] == "settled", "Archive trace did not settle into persistent dressing.")
	context["flare_active"] = true
	_check(director.advance(1, context)["trace_progress"] == 1.0 and director.cue_serial == 1, "Lighting a flare erased material dressing or replayed its cue.")
	director.advance(1, _context(26))
	_check(director.advance(1, context)["trace_progress"] == 1.0, "Returning to the archives discarded a settled trace.")
	context["incident_state"] = "intact"
	_check(_quiet(director.advance(0, context)), "Restoring intact structure left aftermath dressing visible.")

func _test_spa() -> void:
	var director = Horror.new()
	var context: Dictionary = _context(26)
	director.advance(5.5, context)
	var frame: Dictionary = director.presentation()
	_check(frame["id"] == "presence_26" and frame["phase"] == "lingering" and float(frame["spa_alpha"]) > 0.0, "Spa presence did not wait then linger at its fixed position.")
	_check(frame["recurrence"] == 1 and frame["cue_serial"] == 1, "Spa first occurrence has an invalid count or cue.")
	for field: String in ["health", "damage", "stress", "velocity", "target", "attack"]:
		_check(not frame.has(field), "Non-combat presentation exported an enemy or damage field: %s." % field)
	context["flare_active"] = true
	var clock: float = director.elapsed
	_check(float(director.advance(2, context)["spa_alpha"]) == 0.0 and director.cue_serial == 1, "A flare failed to mask the impression or repeated its cue.")
	_check(director.elapsed == clock + 2.0, "A flare unexpectedly paused mission-eligible ambience time.")
	context["flare_active"] = false
	director.advance(4.5, context)
	_check(_quiet(director.presentation()), "Spa first occurrence exceeded its duration.")
	director.advance(30, context)
	_check(_quiet(director.presentation()) and director.cue_serial == 1, "Spa recurrence started without looking away.")
	context["camera_forward"] *= -1.0
	director.advance(1.1, context)
	_check(_quiet(director.presentation()), "Spa recurrence was activated behind the player.")
	context["camera_forward"] *= -1.0
	director.advance(0.1, context)
	director.advance(1.5, context)
	frame = director.presentation()
	_check(frame["phase"] == "returning" and frame["recurrence"] == 2 and float(frame["spa_alpha"]) > 0.64, "The second spa impression failed to become more persistent without an attack.")
	_check(frame["cue_serial"] == 2, "Returning spa impression did not produce exactly one new cue.")
	director.advance(20, context)
	context["camera_forward"] *= -1.0
	director.advance(50, context)
	context["camera_forward"] *= -1.0
	director.advance(50, context)
	_check(_quiet(director.presentation()) and director.cue_serial == 2, "Spa recurrence is not bounded to two occurrences.")

func _test_restore_and_isolation() -> void:
	var director = Horror.new()
	var saved_visits: Array = [31,30,29,28,27,26]
	var original: Array = saved_visits.duplicate()
	director.reset(saved_visits)
	_check(_quiet(director.advance(3.3, _context(29))) and director.cue_serial == 0, "A checkpoint replayed its visited suite glimpse.")
	_check(_quiet(director.advance(5.5, _context(26))) and director.cue_serial == 0, "A checkpoint replayed its visited spa impression.")
	var restored: Dictionary = director.advance(0.0, _context(28))
	_check(restored["trace_progress"] == 1.0 and director.cue_serial == 0, "Stable aftermath dressing did not restore without inventing a cue.")
	_check(saved_visits == original, "Director reset mutated the caller’s checkpoint visit list.")
	var changed: Dictionary = director.presentation()
	changed["trace_alpha"] = 99.0
	_check(float(director.presentation()["trace_alpha"]) < 1.0, "A presentation snapshot aliases mutable director state.")
	director.reset()
	_check(_quiet(director.presentation()) and director.cue_serial == 0 and director.elapsed == 0.0, "New-world reset retained prior manifestations.")
	seed(4817)
	var expected: float = randf()
	seed(4817)
	director.advance(3.3, _context(29))
	_check(randf() == expected, "Horror progression perturbed the global generation RNG.")
	var context: Dictionary = _context(29)
	var original_context: Dictionary = context.duplicate(true)
	director.advance(0.2, context)
	_check(context == original_context, "The pure director modified the caller’s mission context.")
	var single = Horror.new()
	var partitioned = Horror.new()
	single.advance(3.5, _context(29))
	for step: int in range(35):
		partitioned.advance(0.1, _context(29))
	_check(is_equal_approx(float(single.presentation()["suites_alpha"]), float(partitioned.presentation()["suites_alpha"])) and single.cue_serial == partitioned.cue_serial, "Splitting quiet frames changed the first impression or cue count.")

func _test_visibility() -> void:
	for floor_number: int in [29,26]:
		var director = Horror.new()
		var context: Dictionary = _context(floor_number)
		context["line_of_sight"] = false
		director.advance(30, context)
		_check(_quiet(director.presentation()) and director.cue_serial == 0, "An occluded impression consumed an occurrence before it could be seen.")
		context["line_of_sight"] = true
		director.advance(3.3 if floor_number == 29 else 5.5, context)
		_check(not _quiet(director.presentation()) and director.cue_serial == 1, "Clearing an occlusion did not preserve the first eligible occurrence.")
		context["line_of_sight"] = false
		director.advance(0.61, context)
		_check(_quiet(director.presentation()) and director.cue_serial == 1, "An obstructed active impression kept showing or emitted another cue.")

func _test_presentation() -> void:
	for seed_value: int in [1, 271104, 999999]:
		var world: Node3D = World.new()
		root.add_child(world)
		var data: Dictionary = world.build(seed_value, Generator.generate(seed_value))
		world.set_process(false)
		var before_collision: int = _collision_count(world)
		var before_interactions: int = data["interactables"].size()
		var before_rng: int = world.rng.state
		var visuals: Node3D = Visuals.new()
		world.add_child(visuals)
		visuals.build(world)
		_check(_collision_count(world) == before_collision and _collision_count(visuals) == 0, "Horror dressing added collision on a seeded route.")
		_check(world.rng.state == before_rng and data["interactables"].size() == before_interactions, "Building impressions changed the world RNG or interaction registry.")
		_check(not visuals.is_processing() and not visuals.is_physics_processing(), "Presentation contains an autonomous clock.")
		_check(visuals.suites_figure.position == Horror.SUITES_POSITION and visuals.spa_figure.position == Horror.SPA_POSITION, "A manifestation moved away from its inspected anchor.")
		_check(visuals.trace_root.get_child_count() == 8, "Damp traces lost their bounded eight-print footprint.")
		var visible: Dictionary = {"suites_alpha":0.72,"spa_alpha":0.76,"trace_alpha":0.78,"trace_progress":1.0}
		visuals.sample(visible, true)
		_check(visuals.suites_figure.visible and visuals.spa_figure.visible and visuals.trace_root.visible, "Native presentation failed to show the sampled components.")
		var suites_pose: Transform3D = visuals.suites_figure.transform
		var spa_pose: Transform3D = visuals.spa_figure.transform
		visuals.sample(visible, false)
		await process_frame
		_check(visuals.suites_figure.transform == suites_pose and visuals.spa_figure.transform == spa_pose, "An impression animated, tracked or approached without a sampled frame.")
		for subject: Node3D in [visuals.suites_figure, visuals.spa_figure]:
			var y: float = subject.position.y
			var origin: Vector3 = Vector3(0.7, y + 1.65, 0.2)
			var target: Vector3 = subject.position + Vector3(0,1.2,0)
			_check(_opaque_obstruction(world, origin, target, visuals).is_empty(), "A fixed figure anchor is hidden behind an opaque world prop for seed %d." % seed_value)
		for footprint: Node3D in visuals.trace_root.get_children():
			_check(absf(footprint.position.x) > 4.3 and footprint.position.x < 0 and footprint.position.z > 0.5 and footprint.position.z < 5.0, "A wet print entered the shaft or east rescue corridor.")
		visuals.sample({"suites_alpha":NAN,"spa_alpha":INF,"trace_alpha":-2.0,"trace_progress":100.0})
		_check(not visuals.suites_figure.visible and not visuals.spa_figure.visible and not visuals.trace_root.visible, "Invalid presentation input created visible or unbounded material effects.")
		visuals.sample(visible)
		visuals.clear()
		_check(not visuals.suites_figure.visible and not visuals.spa_figure.visible and not visuals.trace_root.visible, "Clearing a rebuilt world left an impression visible.")
		var child_count: int = visuals.get_child_count()
		visuals.build(world)
		_check(visuals.get_child_count() == child_count and _collision_count(visuals) == 0, "Repeated build duplicated figures or colliders.")
		world.free()
		await process_frame

func _quiet(frame: Dictionary) -> bool:
	return float(frame["suites_alpha"]) == 0.0 and float(frame["spa_alpha"]) == 0.0 and float(frame["trace_alpha"]) == 0.0

func _collision_count(node: Node) -> int:
	var count: int = 1 if node is CollisionObject3D else 0
	for child: Node in node.get_children():
		count += _collision_count(child)
	return count

func _opaque_obstruction(node: Node, from: Vector3, to: Vector3, excluded: Node) -> String:
	if node == excluded:
		return ""
	if node is MeshInstance3D and node.is_visible_in_tree():
		var material: Material = node.material_override
		var translucent: bool = material is StandardMaterial3D and material.transparency != BaseMaterial3D.TRANSPARENCY_DISABLED
		if not translucent and node.get_aabb().intersects_segment(node.to_local(from),node.to_local(to)) != null:
			return str(node.get_path())
	for child: Node in node.get_children():
		var obstruction: String = _opaque_obstruction(child,from,to,excluded)
		if not obstruction.is_empty():
			return obstruction
	return ""

func _check(condition: bool, message: String) -> void:
	checks += 1
	if not condition:
		failures.append(message)
