extends "res://tests/test_vertical_routes.gd"
## Real capsule paths through A24/A23 and collision-driven civilian reception.
## Run with --fixed-fps 60. No position writes occur inside a tested journey.

var continuation: Node3D
var escort_clock: EscortClock

class EscortClock:
	extends Node
	var visual: Node3D
	var rescuer: CharacterBody3D
	var running: bool = false
	func _physics_process(delta: float) -> void:
		if is_instance_valid(visual) and is_instance_valid(rescuer):
			visual.advance(delta, rescuer.global_position, running)

func _run() -> void:
	Engine.physics_ticks_per_second = 60
	for action: String in ["move_forward", "move_back", "move_left", "move_right", "crouch", "sprint"]:
		if not InputMap.has_action(action):
			InputMap.add_action(action)
	_check(Routes.all_routes().size() == 6 and Routes.all_routes(true).size() == 8, "The optional continuation changed the original six-route contract.")
	_check(Routes.validate(Routes.all_routes(true), true).is_empty(), "The expanded route graph failed its own exact contract.")
	_check(Routes.for_id("S25_24")["kind"] == "stairs" and Routes.for_id("R24_23")["kind"] == "rope", "Authored continuation route kinds were derived from the old parity rule.")
	_check(Routes.for_id("S25_24")["top_entry"].z < -4.0, "The new staircase overlaps the southern 26–25 stair bay.")
	world = World.new()
	root.add_child(world)
	var data: Dictionary = world.build(271104, Generator.generate(271104), true)
	world.set_process(false)
	continuation = world.continuation_visuals
	_check(data["routes"].size() == 8 and is_instance_valid(continuation), "The world omitted its continuation data.")
	for item: Node3D in data["interactables"]:
		if int(item.get_meta("floor", 31)) < 25:
			_check(item.get_meta("kind", "") not in ["survivor", "beacon", "supply"], "An old rescue/hoist fallback leaked into the new chapter.")
	player = Player.new()
	root.add_child(player)
	player.set_physics_process(false)
	player.configure_continuation(true)
	driver = StairDriver.new()
	driver.body = player
	root.add_child(driver)
	await physics_frame
	await physics_frame
	var covered: bool = player.test_move(Transform3D(Basis.IDENTITY, Vector3(1.3, 6.08, -8.0)), Vector3(0, -4.0, 0))
	_check(covered and world.continuation_access_cover.visible, "The locked chapter lacks a real cover over its northern stair opening.")
	world.set_continuation_state({"phase": "active", "escort_state": "waiting"})
	await physics_frame
	_check(not world.continuation_access_cover.visible, "Starting continuation kept the chapter cover visible.")
	await _test_north_stairs()
	await _test_new_rope()
	await _test_physical_escort()
	_test_repeated_gesture()
	for action: String in ["move_forward", "move_back", "move_left", "move_right", "crouch", "sprint"]:
		Input.action_release(action)
	if is_instance_valid(escort_clock):
		escort_clock.free()
	driver.free()
	player.free()
	world.free()
	if failures.is_empty():
		print("PASS continuation routes: %d checks; %d move_and_slide path segments; optional northern stair both ways, adjacent 24–23 rope, closed access cover, physical two-person reception, waiting, distance, pause and bounded repeated gesture." % [checks, segments])
		quit(0)
	else:
		for failure: String in failures:
			push_error(failure)
		print("FAIL continuation routes: %d failures / %d checks." % [failures.size(), checks])
		quit(1)

func _test_north_stairs() -> void:
	var route: Dictionary = Routes.for_id("S25_24")
	player.position = Vector3(4.2, 6.08, 0.55)
	player.velocity = Vector3.ZERO
	await physics_frame
	await _follow([Vector3(4.2, 6.06, -4.5), Vector3(1.3, 6.06, -4.5), route["top_entry"]], 0.0, 6.0, "north stair approach")
	await _follow(route["path_points"], 0.0, 6.0, "north stair descent")
	_check(player.nearest_floor() == 24 and player.is_at_landing(), "The new stair did not reach a supported A24 landing.")
	var reverse: Array = route["path_points"].duplicate()
	reverse.reverse()
	await _follow(reverse, 0.0, 6.0, "north stair return")
	_check(player.nearest_floor() == 25 and player.is_at_landing(), "The new stair did not return to the refuge landing.")
	await _follow(route["path_points"], 0.0, 6.0, "north stair repeated descent")
	await _follow([Vector3(-1.3, 0.06, -4.5), Vector3(-4.0, 0.06, -4.5), Vector3(-3.8, 0.06, 0)], 0.0, 6.0, "congress west rappel approach")

func _test_new_rope() -> void:
	var route: Dictionary = Routes.for_id("R24_23")
	for endpoint: String in ["top", "bottom"]:
		var start: Vector3 = route[endpoint + "_entry"]
		var end: Vector3 = route["rope_" + endpoint]
		_check(not player.test_move(Transform3D(Basis.IDENTITY, start), end - start), "The %s congress/exhibition transfer is obstructed." % endpoint)
	for sway: float in [-0.65, 0.0, 0.65]:
		_check(not player.test_move(Transform3D(Basis.IDENTITY, route["rope_top"] + Vector3(0, 0, sway)), route["rope_bottom"] - route["rope_top"]), "A slab blocks the 24–23 rope span.")
	player.active = true
	_check(player.engage_rope(24, "R24_23"), "The physical 24 station refused its rope.")
	player._process_rope(0.85)
	Input.action_press("move_back")
	for index in range(55):
		player._process_rope(0.1)
	Input.action_release("move_back")
	player._process_rope(0.35)
	_check(absf(player.position.y + 5.96) < 0.005 and player.nearest_floor() == 23, "R24_23 did not stop on the exhibition slab.")
	_check(player.leave_rope(23), "The exhibition rope exit failed its collision/support checks.")
	player._process_rope(0.85)
	_check(not player.on_rope and player.is_at_landing(), "The exit left the player suspended or outside a supported exhibition landing.")
	_check(player.engage_rope(23, "R24_23"), "The lower rope station refused the return journey.")
	player._process_rope(0.85)
	Input.action_press("move_forward")
	for index in range(85):
		player._process_rope(0.1)
	Input.action_release("move_forward")
	player._process_rope(0.4)
	_check(player.leave_rope(24), "The upper rope exit failed on the return journey.")
	player._process_rope(0.85)
	_check(not player.on_rope and player.is_at_landing() and player.nearest_floor() == 24, "The rope return failed to reach the congress landing.")
	player.active = false

func _test_physical_escort() -> void:
	# Initial fixture outside the translation booth. From here the player and
	# both civilians traverse with their actual collision capsules.
	player.position = Vector3(8.0, 0.06, -5.5)
	player.velocity = Vector3.ZERO
	escort_clock = EscortClock.new()
	escort_clock.visual = continuation
	escort_clock.rescuer = player
	root.add_child(escort_clock)
	escort_clock.running = true
	for _index in range(10):
		await physics_frame
	var before: Dictionary = continuation.snapshot()
	escort_clock.running = false
	for _index in range(10):
		await physics_frame
	_check(continuation.snapshot() == before, "Paused continuation advances bodies, paths or the repeated gesture.")
	continuation.set_escort_state("following")
	before = continuation.snapshot()
	continuation.advance(0.05, Vector3(8, 30, -5), true)
	_check(continuation.snapshot()["path_indices"] == before["path_indices"] and continuation.snapshot()["positions"] == before["positions"], "The escort progresses while the rescuer is outside its visual range.")
	escort_clock.running = true
	for _index in range(60):
		await physics_frame
	_check(continuation.people[0].global_position.distance_to(before["positions"][0]) > 0.5, "The escort never started walking after its visual signal.")
	# Introduce an actual physical obstruction in the booth exit. The followers
	# must stop on its near side; a spline interpolation would pass through it.
	var blocker: MeshInstance3D = world._box(world, Vector3(8.4, 1.0, -5.8), Vector3(4.2, 2.0, 0.2), world.materials["metal"], true)
	blocker.name = "TemporaryEscortObstruction"
	for _index in range(100):
		await physics_frame
	_check(continuation.people[0].global_position.z < -6.16 and continuation.people[1].global_position.z < -6.16, "The civilians passed through an obstructed booth exit.")
	_check(not continuation.both_arrived(), "An obstructed escort fabricated a reception.")
	blocker.free()
	await physics_frame
	continuation.set_escort_state("waiting")
	for _index in range(4):
		await physics_frame
	before = continuation.snapshot()
	for _index in range(15):
		await physics_frame
	_check(continuation.snapshot()["positions"] == before["positions"] and continuation.snapshot()["path_indices"] == before["path_indices"], "Waiting resets or continues the escort's path.")
	continuation.set_escort_state("following")
	driver.speed = 1.15
	await _follow([Vector3(4.2, 0.06, -4.5), Vector3(-1.3, 0.06, -4.5)], 0.0, 6.0, "escort congress foyer")
	var reverse: Array = Routes.for_id("S25_24")["path_points"].duplicate()
	reverse.reverse()
	await _follow(reverse, 0.0, 6.0, "escort north ascent")
	await _follow([Vector3(1.3, 6.06, -4.5), Vector3(4.2, 6.06, -4.5), Vector3(7.3, 6.06, -2.5)], 0.0, 6.0, "escort refuge receiving area")
	for _index in range(400):
		if continuation.both_arrived():
			break
		await physics_frame
	_check(continuation.both_arrived(), "The two physical civilians did not both reach the refuge: %s" % str(continuation.snapshot()))
	_check(int(continuation.duo_interaction.get_meta("floor", 0)) == 25, "The moving interaction still claims the congress after arrival.")
	_check(not continuation.duo_interaction.get_meta("used", false), "The presentation invented a persisted receipt before the mission accepted it.")
	continuation.set_escort_state("received")
	_check(continuation.both_arrived() and continuation.duo_interaction.get_meta("used", false), "The accepted reception did not leave both people at the refuge.")
	escort_clock.running = false
	driver.speed = 3.7

func _test_repeated_gesture() -> void:
	for _index in range(100):
		continuation.advance(0.05, Vector3(4.2, -5.96, 0.5), true, false)
	_check(continuation.remanence_count == 0 and is_zero_approx(continuation.remanence_elapsed), "An operational priority consumed or triggered the archival gesture.")
	for _index in range(850):
		continuation.advance(0.05, Vector3(4.2, -5.96, 0.5), true)
	_check(continuation.remanence_count == 2 and not continuation.remanence.visible, "The exhibition does not finish after two nonhostile repeated gestures.")
	_check(int(continuation.remanence.get_meta("damage", -1)) == 0, "The archival manifestation is configured as a damaging opponent.")
	var state: Dictionary = continuation.snapshot()
	for _index in range(100):
		continuation.advance(0.05, Vector3(4.2, -5.96, 0.5), false)
	_check(continuation.snapshot() == state, "A paused archival observation kept its clock running.")
