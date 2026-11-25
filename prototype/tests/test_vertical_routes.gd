extends SceneTree
## Capsule traversal, real slab cut-outs and isolated adjacent-floor routes.
## Fixture placement happens only before a route/scenario, never within one.
## godot --headless --fixed-fps 60 --path prototype --script tests/test_vertical_routes.gd

const Routes = preload("res://scripts/route_catalog.gd")
const World = preload("res://scripts/world_builder.gd")
const Player = preload("res://scripts/player_controller.gd")
const Generator = preload("res://scripts/floor_generator.gd")
const Rescue = preload("res://scripts/rescue_presentation.gd")
var checks: int = 0
var failures: Array[String] = []
var segments: int = 0
var driver: StairDriver
var world: Node3D
var player: CharacterBody3D


class StairDriver:
	extends Node
	signal finished(success: bool, position_value: Vector3, obstacle: String)
	var body: CharacterBody3D
	var target: Vector3
	var moving: bool = false
	var speed: float = 3.7
	var frames_left: int = 0
	var stalled: int = 0
	var previous_distance: float = 100000.0
	var lower_y: float = 0.0
	var upper_y: float = 50.0

	func go(p: Vector3, lower: float, upper: float) -> void:
		target = p
		lower_y = lower
		upper_y = upper
		frames_left = 900
		stalled = 0
		previous_distance = 100000.0
		moving = true

	func _physics_process(delta: float) -> void:
		if not moving:
			return
		frames_left -= 1
		var offset: Vector3 = Vector3(target.x - body.position.x, 0, target.z - body.position.z)
		var planar_distance: float = offset.length()
		var distance: float = body.position.distance_to(target)
		if planar_distance < 0.08 and absf(body.position.y - target.y) < 0.20 and body.is_on_floor():
			_finish(true, "")
			return
		if body.position.y < lower_y - 0.4 or body.position.y > upper_y + 0.4:
			_finish(false, "Left the two-floor traversal volume")
			return
		stalled = stalled + 1 if previous_distance - distance < 0.0005 else 0
		previous_distance = distance
		if frames_left <= 0 or stalled > 120:
			var obstacle: String = "No collision"
			if body.get_slide_collision_count() > 0:
				var object: Object = body.get_slide_collision(body.get_slide_collision_count() - 1).get_collider()
				if object is Node:
					obstacle = str(object.get_path())
			_finish(false, obstacle)
			return
		var planar: Vector3 = offset.normalized() * minf(speed, planar_distance / maxf(delta, 0.0001))
		body.velocity.x = planar.x
		body.velocity.z = planar.z
		body.velocity.y = 0.0 if body.is_on_floor() else body.velocity.y - 16.0 * delta
		body.move_and_slide()

	func _finish(success: bool, obstacle: String) -> void:
		moving = false
		body.velocity = Vector3.ZERO
		finished.emit(success, body.position, obstacle)


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	Engine.physics_ticks_per_second = 60
	_test_catalogue()
	driver = StairDriver.new()
	root.add_child(driver)
	for seed_value: int in [3, 47, 69]:
		world = World.new()
		root.add_child(world)
		var original_specs: Array = Generator.generate(seed_value)
		var data: Dictionary = world.build(seed_value, original_specs)
		world.set_process(false)
		_check(Generator.generate(seed_value) == original_specs, "Building traversal geometry changed floor generation for seed %d." % seed_value)
		player = Player.new()
		root.add_child(player)
		player.set_physics_process(false)
		driver.body = player
		await physics_frame
		await physics_frame
		_test_stations(data)
		_test_hoist_envelope()
		await _test_rappel_openings(seed_value)
		for route: Dictionary in Routes.all_routes():
			if route["kind"] == "stairs":
				await _test_stair_pair(route, seed_value)
		player.free()
		world.free()
		await physics_frame
	driver.free()
	if failures.is_empty():
		print("PASS vertical routes: %d checks; %d real move_and_slide segments; three local stair pairs descended and climbed empty/carried across three layout-covering seeds; adjacent rope apertures, solid arrival landings and continuous rescue-hoist envelope verified." % [checks, segments])
		quit(0)
	else:
		for failure: String in failures:
			push_error(failure)
		print("FAIL vertical routes: %d failures / %d checks; %d physical segments." % [failures.size(), checks, segments])
		quit(1)


func _test_catalogue() -> void:
	var routes: Array = Routes.all_routes()
	_check(Routes.validate(routes).is_empty(), "The authored local graph is invalid.")
	_check(Routes.for_id("unknown").is_empty() and Routes.routes_at_floor(24).is_empty(), "Invalid route/floor lookup invents a connection.")
	_check(Routes.routes_at_floor(31).size() == 1 and Routes.routes_at_floor(25).size() == 1, "The traversal graph extends outside the playable slice.")
	for floor_number: int in [30, 29, 28, 27, 26]:
		_check(Routes.routes_at_floor(floor_number).size() == 2, "An intermediate landing lacks its return or onward link.")
	var fresh: Array = Routes.all_routes()
	routes[0]["lower"] = 25
	_check(not Routes.validate(routes).is_empty(), "A long rappel bypassing five floors was accepted.")
	_check(Routes.all_routes() == fresh, "Changing a returned route mutates the shared graph.")
	routes = Routes.all_routes()
	routes[1]["path_points"][0] = Vector3.INF
	_check(not Routes.validate(routes).is_empty() and Routes.all_routes() == fresh, "A modified nested stair path escaped validation or mutated the catalogue.")
	for malformed: Array in [[], ["wrong"]]:
		_check(not Routes.validate(malformed).is_empty(), "A malformed route list was accepted.")
	for route: Dictionary in fresh:
		_check(int(route["upper"]) == int(route["lower"]) + 1, "A route joins nonadjacent floors.")
		if route["kind"] == "stairs":
			var middle: Vector3 = Vector3(-1.3, Routes.floor_height(int(route["lower"])) + 3.05, 10.8)
			_check(Routes.stair_at_position(middle).get("id", "") == route["id"], "The intermediate stair landing is not identified.")
			_check(Routes.stair_at_position(route["top_entry"]).is_empty() and Routes.stair_at_position(route["bottom_entry"]).is_empty(), "A settled floor entry remains classified as mid-stair.")
	_check(Routes.stair_at_position(Vector3.INF).is_empty(), "Nonfinite positions identify a staircase.")


func _test_stations(data: Dictionary) -> void:
	var stations: Dictionary = {}
	for item: Node3D in data["interactables"]:
		if item.get_meta("kind", "") != "rappel":
			continue
		var route: Dictionary = Routes.for_id(str(item.get_meta("route_id", "")))
		_check(not route.is_empty() and route["kind"] == "rope", "A rappel station points to a missing/nonrope link.")
		var number: int = int(item.get_meta("floor", 0))
		stations["%s:%d" % [str(route.get("id", "")), number]] = true
		_check(is_equal_approx(item.global_position.x, -3.8) and is_zero_approx(item.global_position.z), "A rappel station obstructs or moves away from the protected west approach.")
		_check(_collision_count(item) == 0, "The rappel interaction creates collision on its own exit point.")
	_check(stations.size() == 6, "Each of the three rappel segments needs one station at both ends.")
	for route: Dictionary in Routes.all_routes():
		if route["kind"] == "rope":
			for number: int in [int(route["upper"]), int(route["lower"])]:
				_check(stations.has("%s:%d" % [str(route["id"]), number]), "A rope endpoint has no return station.")


func _test_hoist_envelope() -> void:
	var shape: BoxShape3D = BoxShape3D.new()
	shape.size = Vector3(1.0, 2.04, 1.0)
	for number: int in [30, 28, 26]:
		for sample in range(41):
			var p: Vector3 = Rescue.hoist_position(float(sample) / 8.0, number)
			var query: PhysicsShapeQueryParameters3D = PhysicsShapeQueryParameters3D.new()
			query.shape = shape
			query.transform = Transform3D(Basis.IDENTITY, p + Vector3(0, 1.02, 0))
			query.exclude = [player.get_rid()]
			var hits: Array[Dictionary] = world.get_world_3d().direct_space_state.intersect_shape(query, 8)
			var names: Array[String] = []
			for hit: Dictionary in hits:
				names.append(str((hit["collider"] as Node).get_path()))
			_check(hits.is_empty(), "The actual rescue-hoist envelope hits geometry from floor %d at %.3f s: %s" % [number, float(sample) / 8.0, str(names)])


func _test_rappel_openings(seed_value: int) -> void:
	for route: Dictionary in Routes.all_routes():
		if route["kind"] != "rope":
			continue
		for endpoint: String in ["top", "bottom"]:
			var start: Vector3 = route[endpoint + "_entry"]
			var end: Vector3 = route["rope_" + endpoint]
			var transform_value: Transform3D = Transform3D(Basis.IDENTITY, start)
			var collision: KinematicCollision3D = KinematicCollision3D.new()
			_check(not player.test_move(transform_value, end - start, collision), "The %s transfer of %s is blocked by %s." % [endpoint, str(route["id"]), _collider_name(collision)])
			_check(not player.test_move(Transform3D(Basis.IDENTITY, end), start - end), "The %s return transfer of %s is blocked." % [endpoint, str(route["id"])])
		var top: Vector3 = route["rope_top"]
		var bottom: Vector3 = route["rope_bottom"]
		for sway: float in [-0.65, 0.0, 0.65]:
			var start: Vector3 = top + Vector3(0, 0, sway)
			_check(not player.test_move(Transform3D(Basis.IDENTITY, start), bottom - top), "A slab or guard blocks the authorized rope span %s at sway %.2f." % [str(route["id"]), sway])
			var landing_collision: KinematicCollision3D = KinematicCollision3D.new()
			var landed: bool = player.test_move(Transform3D(Basis.IDENTITY, bottom + Vector3(0, 0, sway)), Vector3(0, -0.2, 0), landing_collision)
			_check(landed and _collider_name(landing_collision).contains("RappelLanding"), "The lower endpoint of %s does not physically stop on its own landing." % str(route["id"]))
		# Initial physical placement on an arrival slab, followed by real walking
		# west out of the shaft and back. No fixture repositioning inside the trip.
		player.position = bottom + Vector3(0, 0.15, 0)
		player.velocity = Vector3.ZERO
		await physics_frame
		await _walk(bottom, bottom.y - 0.04, bottom.y + 0.2, "%d %s settle" % [seed_value, str(route["id"])])
		await _walk(route["bottom_entry"], bottom.y - 0.04, bottom.y + 0.2, "%d %s landing exit" % [seed_value, str(route["id"])])
		await _walk(bottom, bottom.y - 0.04, bottom.y + 0.2, "%d %s landing return" % [seed_value, str(route["id"])])


func _test_stair_pair(route: Dictionary, seed_value: int) -> void:
	var upper_y: float = Routes.floor_height(int(route["upper"]))
	var lower_y: float = Routes.floor_height(int(route["lower"]))
	var path: Array = route["path_points"]
	player.position = Vector3(3.85, upper_y + 0.1, 0)
	player.velocity = Vector3.ZERO
	await physics_frame
	await physics_frame
	await _follow([Vector3(4, upper_y + 0.06, 4.5), Vector3(-1.3, upper_y + 0.06, 4.5), route["top_entry"]], lower_y, upper_y, "%d %s upper approach" % [seed_value, str(route["id"])])
	for carrying: bool in [false, true]:
		player.carrying = carrying
		driver.speed = 2.4 if carrying else 3.7
		var label: String = "%d %s %s" % [seed_value, str(route["id"]), "carried" if carrying else "empty"]
		await _follow(path, lower_y, upper_y, label + " descent")
		await _follow([Vector3(1.3, lower_y + 0.06, 4.5), Vector3(4, lower_y + 0.06, 4.5), Vector3(3.85, lower_y + 0.06, 0)], lower_y, upper_y, label + " lower beacon")
		await _follow([Vector3(4, lower_y + 0.06, 4.5), Vector3(1.3, lower_y + 0.06, 4.5), route["bottom_entry"]], lower_y, upper_y, label + " lower return")
		var reversed: Array = path.duplicate()
		reversed.reverse()
		await _follow(reversed, lower_y, upper_y, label + " ascent")
	player.carrying = false
	driver.speed = 3.7
	await _follow([Vector3(-1.3, upper_y + 0.06, 4.5), Vector3(4, upper_y + 0.06, 4.5), Vector3(3.85, upper_y + 0.06, 0)], lower_y, upper_y, "%d %s upper return" % [seed_value, str(route["id"])])


func _follow(path: Array, lower: float, upper: float, label: String) -> bool:
	for point: Vector3 in path:
		if not await _walk(point, lower, upper, label):
			return false
	return true


func _walk(target: Vector3, lower: float, upper: float, label: String) -> bool:
	driver.go(target, lower, upper)
	var outcome: Array = await driver.finished
	segments += 1
	_check(bool(outcome[0]), "Blocked vertical route '%s': target=%s actual=%s collider=%s" % [label, str(target), str(outcome[1]), str(outcome[2])])
	return bool(outcome[0])


func _collision_count(node: Node) -> int:
	var count: int = 1 if node is CollisionObject3D or node is CollisionShape3D else 0
	for child in node.get_children():
		count += _collision_count(child)
	return count


func _collider_name(collision: KinematicCollision3D) -> String:
	if collision.get_collision_count() == 0:
		return "none"
	var object: Object = collision.get_collider()
	return str((object as Node).get_path()) if object is Node else "none"


func _check(condition: bool, message: String) -> void:
	checks += 1
	if not condition:
		failures.append(message)
