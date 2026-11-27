extends "res://tests/test_vertical_routes.gd"
## Actual CharacterBody3D journeys through A20-A17, at 60 physics ticks/s.
## Only initial player fixtures set positions. Civilian positions are never
## written during a journey. Their rescuer lead is synthetic to isolate route
## collision from player input; this is not a human-controlled playthrough.

const Residential = preload("res://scripts/residential_director.gd")
const Presentation = preload("res://scripts/residential_presentation.gd")

var visual: Node3D
var chapter: RefCounted
var civilian_clock: CivilianClock
var rope_clock: RopeClock
var civilian_samples: int = 0
var rope_samples: int = 0
var completed_journeys: Array[String] = []

class CivilianClock:
	extends Node
	var presentation: Node3D
	var running: bool = false
	var lead_id: String = ""
	var lead_position := Vector3(0, 100, 0)
	func _physics_process(delta: float) -> void:
		if not is_instance_valid(presentation): return
		var lead: Vector3 = lead_position
		if not lead_id.is_empty():
			var body: CharacterBody3D = presentation.people[lead_id]
			var cursor: int = int(presentation.cursors[lead_id])
			var path: Array = presentation.paths[lead_id]
			var target: Vector3 = path[mini(cursor, path.size() - 1)]
			lead = body.global_position + (target - body.global_position).normalized() * 1.8
		presentation.advance(delta, lead, running, false, false, true)

class RopeClock:
	extends Node
	var body: CharacterBody3D
	var running: bool = false
	func _physics_process(delta: float) -> void:
		if running and is_instance_valid(body): body._process_rope(delta)

func _run() -> void:
	Engine.physics_ticks_per_second = 60
	for action: String in ["move_forward", "move_back", "move_left", "move_right", "crouch", "sprint"]:
		if not InputMap.has_action(action): InputMap.add_action(action)
	_check(Routes.all_routes().size() == 6 and Routes.all_routes(true).size() == 8 and Routes.all_routes(true, true).size() == 12 and Routes.all_routes(true, true, true).size() == 16, "The residential chapter changed previous route counts or omitted its four new links.")
	_check(Routes.validate(Routes.all_routes(true, true, true), true, true, true).is_empty(), "The residential route graph violates its authored contract.")
	_check(bool(Routes.for_id("S20_19").get("north", false)), "The 20-19 stair must use the separate north bay.")
	world = World.new()
	root.add_child(world)
	var data: Dictionary = world.build(271104, Generator.generate(271104), true, true, true)
	world.set_process(false)
	world.set_continuation_state({"phase": "complete", "escort_state": "received"})
	visual = world.residential_visuals
	_check(is_instance_valid(visual) and data["routes"].size() == 16, "The world omitted residential presentation or its traversal links.")
	player = Player.new()
	root.add_child(player)
	player.set_physics_process(false)
	player.configure_continuation(true, true, true)
	driver = StairDriver.new()
	driver.body = player
	root.add_child(driver)
	rope_clock = RopeClock.new()
	rope_clock.body = player
	root.add_child(rope_clock)
	chapter = Residential.new()
	var fixture: Dictionary = Residential.dormant_state()
	fixture["phase"] = "active"
	fixture["actions"] = ["care", "service_access", "power", "reference"]
	_check(chapter.restore(fixture), "The stable rescue route fixture was rejected.")
	visual.apply_state(chapter.snapshot())
	civilian_clock = CivilianClock.new()
	civilian_clock.presentation = visual
	root.add_child(civilian_clock)
	await physics_frame
	await physics_frame
	await _test_closed_service_gate()
	await _test_three_stairs()
	await _test_duplex_rope()
	await _test_civilian_waiting_and_obstruction()
	for id: String in Residential.PERSON_IDS:
		await _test_civilian_journey(id)
	_check(completed_journeys == Residential.PERSON_IDS and chapter.received_count() == 3, "Three distinct physical civilian journeys did not finish at refuge 20.")
	for action: String in ["move_forward", "move_back", "move_left", "move_right", "crouch", "sprint"]: Input.action_release(action)
	civilian_clock.free()
	rope_clock.free()
	driver.free()
	player.free()
	world.free()
	if failures.is_empty():
		print("PASS residential routes: %d checks; %d real player stair segments; %d rope physics samples; %d civilian samples; three individual refuge receptions, real obstruction, distance, waiting and pause verified. Civilian lead is synthetic; all civilian movement uses move_and_slide at 60 Hz." % [checks, segments, rope_samples, civilian_samples])
		quit(0)
	else:
		for failure: String in failures: push_error(failure)
		print("FAIL residential routes: %d failures / %d checks; civilian arrivals=%s" % [failures.size(), checks, str(completed_journeys)])
		quit(1)

func _test_three_stairs() -> void:
	for route_id: String in ["S20_19", "S19_18", "S18_17"]:
		var route: Dictionary = Routes.for_id(route_id)
		var top_y: float = Routes.floor_height(int(route["upper"]))
		var bottom_y: float = Routes.floor_height(int(route["lower"]))
		# Initial fixture only; every tested descent/return is physical.
		player.position = route["top_entry"] + Vector3(0, 0.05, 0)
		player.velocity = Vector3.ZERO
		await physics_frame
		await physics_frame
		var walked: bool = await _follow(route["path_points"], bottom_y, top_y, route_id + " descent")
		_check(walked and player.nearest_floor() == int(route["lower"]) and player.is_at_landing(), route_id + " failed to reach its supported lower landing.")
		if walked:
			var reverse: Array = route["path_points"].duplicate()
			reverse.reverse()
			walked = await _follow(reverse, bottom_y, top_y, route_id + " ascent")
			_check(walked and player.nearest_floor() == int(route["upper"]) and player.is_at_landing(), route_id + " failed to return to its upper landing.")

func _test_duplex_rope() -> void:
	var route: Dictionary = Routes.for_id("R19_18")
	for endpoint: String in ["top", "bottom"]:
		var start: Vector3 = route[endpoint + "_entry"]
		var rope: Vector3 = route["rope_" + endpoint]
		_check(not player.test_move(Transform3D(Basis.IDENTITY, start), rope - start), "The duplex rope's %s entry is obstructed." % endpoint)
		_check(not player.test_move(Transform3D(Basis.IDENTITY, rope), start - rope), "The duplex rope's %s exit is obstructed." % endpoint)
	for sway: float in [-0.65, 0.0, 0.65]:
		_check(not player.test_move(Transform3D(Basis.IDENTITY, route["rope_top"] + Vector3(0, 0, sway)), route["rope_bottom"] - route["rope_top"]), "R19_18 has an obstructed span at sway %.2f." % sway)
	player.position = route["top_entry"]
	player.velocity = Vector3.ZERO
	player.active = true
	await physics_frame
	_check(player.engage_rope(19, "R19_18"), "The duplex rope refused attachment.")
	if not player.on_rope:
		player.active = false
		return
	rope_clock.running = true
	await _rope_frames(65)
	_check(player.rope_transfer.is_empty(), "R19_18 entry transfer never reached the line.")
	Input.action_press("move_back")
	for _frame in range(600):
		if absf(player.position.y - float(route["rope_bottom"].y)) < 0.005: break
		await _rope_frames(1)
	Input.action_release("move_back")
	await _rope_frames(30)
	_check(absf(player.position.y - float(route["rope_bottom"].y)) < 0.005 and player.nearest_floor() == 18, "The duplex rope skipped or failed to reach floor 18.")
	_check(player.leave_rope(18), "R19_18 refused the supported duplex lower exit.")
	await _rope_frames(65)
	_check(not player.on_rope and player.is_at_landing(), "R19_18 duplex lower exit left the capsule suspended.")
	_check(player.engage_rope(18, "R19_18"), "R19_18 refused the return attachment.")
	await _rope_frames(65)
	Input.action_press("move_forward")
	for _frame in range(900):
		if absf(player.position.y - float(route["rope_top"].y)) < 0.005: break
		await _rope_frames(1)
	Input.action_release("move_forward")
	await _rope_frames(30)
	_check(player.leave_rope(19), "R19_18 refused the upper return exit.")
	await _rope_frames(65)
	_check(not player.on_rope and player.is_at_landing() and player.nearest_floor() == 19, "R19_18 failed to return physically to the duplex upper landing.")
	rope_clock.running = false
	player.active = false

func _rope_frames(count: int) -> void:
	for _frame in range(count):
		rope_samples += 1
		await physics_frame

func _test_civilian_waiting_and_obstruction() -> void:
	civilian_clock.running = true
	for _frame in range(30): await physics_frame
	for id: String in Residential.PERSON_IDS:
		_check(not visual.physically_arrived(id), id + " was declared received at its initial location.")
		_check(visual.people[id].global_position.distance_to(Presentation.STARTS[id]) < 0.20, id + " starts embedded in environmental collision.")
	var before: Dictionary = visual.snapshot()
	civilian_clock.running = false
	for _frame in range(30): await physics_frame
	_check(visual.snapshot() == before, "Paused residential presentation advances civilian bodies or paths.")
	_check(chapter.toggle_person("jeanne"), "The prepared residence failed to prepare Jeanne's escort state.")
	visual.apply_state(chapter.snapshot())
	civilian_clock.lead_id = ""
	civilian_clock.lead_position = Vector3(0, 100, 0)
	civilian_clock.running = true
	before = visual.snapshot()
	for _frame in range(90): await physics_frame
	_check(visual.snapshot()["positions"] == before["positions"] and visual.snapshot()["cursors"] == before["cursors"], "An escort progresses while the rescuer is far outside the five-metre range.")
	_check(not chapter.receive("jeanne", 20, visual.physically_arrived("jeanne")), "A remote player fabricated Jeanne's receipt at refuge 20.")
	var blocker: MeshInstance3D = world._box(world, Vector3(8, -29, -6.0), Vector3(3.2, 2.0, 0.20), world.materials["metal"], true)
	blocker.name = "TemporaryResidentialEscortObstacle"
	await physics_frame
	civilian_clock.lead_id = "jeanne"
	for _frame in range(350): await physics_frame
	_check(visual.people["jeanne"].global_position.z < -6.35 and int(visual.cursors["jeanne"]) == 0, "Jeanne crossed a solid obstruction on the reserve exit path.")
	_check(not visual.physically_arrived("jeanne") and not chapter.receive("jeanne", 20, visual.physically_arrived("jeanne")), "A blocked escort fabricated arrival or a persistent receipt.")
	blocker.free()
	await physics_frame
	_check(chapter.toggle_person("jeanne"), "Jeanne could not be paused after the obstruction.")
	visual.apply_state(chapter.snapshot())
	for _frame in range(10): await physics_frame
	before = visual.snapshot()
	for _frame in range(60): await physics_frame
	_check(visual.snapshot()["positions"] == before["positions"] and visual.snapshot()["cursors"] == before["cursors"], "Waiting moves the civilian or resets the path.")
	civilian_clock.running = false

func _test_civilian_journey(id: String) -> void:
	_check(chapter.toggle_person(id), id + " cannot start/resume an eligible escort.")
	visual.apply_state(chapter.snapshot())
	civilian_clock.lead_id = id
	civilian_clock.running = true
	var body: CharacterBody3D = visual.people[id]
	var previous: Vector3 = body.global_position
	var previous_cursor: int = int(visual.cursors[id])
	var stalled: int = 0
	var frames: int = 0
	var maximum_step: float = 0.0
	var start_floor: int = int(Residential.PEOPLE[id]["floor"])
	var invalid_travel: bool = false
	for _frame in range(10800):
		await physics_frame
		civilian_samples += 1
		frames += 1
		var step: float = body.global_position.distance_to(previous)
		maximum_step = maxf(maximum_step, step)
		var cursor: int = int(visual.cursors[id])
		if cursor < previous_cursor or step > 0.45 or body.global_position.y < Routes.floor_height(start_floor) - 0.3 or body.global_position.y > -23.7:
			invalid_travel = true
			break
		stalled = stalled + 1 if step < 0.00001 and cursor == previous_cursor else 0
		previous = body.global_position
		previous_cursor = cursor
		if visual.physically_arrived(id) or stalled > 240: break
	civilian_clock.running = false
	var obstacle: String = "none"
	if body.get_slide_collision_count() > 0:
		var object: Object = body.get_slide_collision(body.get_slide_collision_count() - 1).get_collider()
		if object is Node: obstacle = str(object.get_path())
	_check(not invalid_travel, "%s left its allowed floor volume or made a nonphysical jump: position=%s max-step=%.4f cursor=%d" % [id, str(body.global_position), maximum_step, previous_cursor])
	var arrived_here: bool = visual.physically_arrived(id)
	_check(arrived_here, "%s failed its physical refuge path after %d frames: position=%s cursor=%d obstacle=%s" % [id, frames, str(body.global_position), int(visual.cursors[id]), obstacle])
	_check(not bool(visual.person_targets[id].get_meta("used", false)), id + " presentation invented a persistent rescue receipt.")
	if not arrived_here: return
	_check(int(visual.person_targets[id].get_meta("floor", 0)) == 20, id + " interaction remained on its origin floor after physical arrival.")
	_check(not chapter.receive(id, 21, true), id + " was received at the wrong floor.")
	_check(chapter.receive(id, 20, arrived_here), id + " physical refuge reception was rejected.")
	# The journey has ended; the standard stable-receipt placement may now apply.
	visual.apply_state(chapter.snapshot())
	_check(visual.physically_arrived(id) and bool(visual.person_targets[id].get_meta("used", false)), id + " accepted receipt did not keep the civilian at its refuge mark.")
	completed_journeys.append(id)
	print("RESIDENTIAL JOURNEY %s: %d physics frames; max-step %.4f m; actual capsule arrival at %s." % [id, frames, maximum_step, str(body.global_position)])

func _test_closed_service_gate() -> void:
	var closed: Dictionary = chapter.snapshot()
	closed["actions"].erase("service_access")
	visual.apply_state(closed)
	await physics_frame
	var before: Vector3 = Vector3(1.3, -35.94, 4.65)
	_check(player.test_move(Transform3D(Basis.IDENTITY, before), Vector3(0.0, 0.0, 1.6)), "The closed service grille lets a capsule bypass the duplex reconnaissance.")
	visual.apply_state(chapter.snapshot())
	await physics_frame
	_check(not player.test_move(Transform3D(Basis.IDENTITY, before), Vector3(0.0, 0.0, 0.7)), "The opened service grille still obstructs its supported entrance.")
