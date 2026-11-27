extends SceneTree
## Real capsule/physics route checks for the six playable floors.
## Only the initial placement on each floor is assigned directly. All route
## segments and returns use move_and_slide(), gravity and the world's colliders.
## Run with --fixed-fps 60 to simulate quickly without changing the timestep:
## godot --headless --fixed-fps 60 --path prototype --script tests/test_routes.gd

const World = preload("res://scripts/world_builder.gd")
const Player = preload("res://scripts/player_controller.gd")
const Generator = preload("res://scripts/floor_generator.gd")
var failures: Array[String] = []
var checks: int = 0
var route_segments: int = 0
var objectives_reached: int = 0
var driver: RouteDriver
var world: Node3D
var player: CharacterBody3D


class RouteDriver:
	extends Node
	signal finished(success: bool, last_position: Vector3, collider: String)
	var body: CharacterBody3D
	var destination: Vector3
	var floor_y: float = 0.0
	var moving: bool = false
	var frames_left: int = 0
	var stalled_frames: int = 0
	var previous_distance: float = 100000.0
	var speed: float = 3.7

	func go(target: Vector3, level_y: float) -> void:
		destination = target
		floor_y = level_y
		frames_left = 600
		stalled_frames = 0
		previous_distance = 100000.0
		moving = true

	func _physics_process(delta: float) -> void:
		if not moving:
			return
		frames_left -= 1
		var planar_delta: Vector3 = Vector3(destination.x - body.position.x, 0.0, destination.z - body.position.z)
		var distance: float = planar_delta.length()
		if distance < 0.10 and body.is_on_floor():
			body.velocity = Vector3.ZERO
			moving = false
			finished.emit(true, body.position, "")
			return
		if body.position.y < floor_y - 0.5 or body.position.y > floor_y + 0.6:
			_finish_failure("Left the expected walking surface")
			return
		if previous_distance - distance < 0.001:
			stalled_frames += 1
		else:
			stalled_frames = 0
		previous_distance = distance
		if frames_left <= 0 or stalled_frames > 90:
			var collision_name: String = "No collision reported"
			if body.get_slide_collision_count() > 0:
				var collision: KinematicCollision3D = body.get_slide_collision(body.get_slide_collision_count() - 1)
				var collider: Object = collision.get_collider()
				if collider is Node:
					collision_name = str(collider.get_path())
			_finish_failure(collision_name)
			return
		var velocity_planar: Vector3 = planar_delta.normalized() * minf(speed, distance / maxf(delta, 0.0001))
		body.velocity.x = velocity_planar.x
		body.velocity.z = velocity_planar.z
		body.velocity.y = 0.0 if body.is_on_floor() else body.velocity.y - 16.0 * delta
		body.move_and_slide()

	func _finish_failure(collider: String) -> void:
		moving = false
		body.velocity = Vector3.ZERO
		finished.emit(false, body.position, collider)


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	Engine.physics_ticks_per_second = 60
	var selected_seeds: Array[int] = _select_seed_cover()
	_check(selected_seeds.size() == 3, "Could not find three seeds covering every layout variant on every floor.")
	if selected_seeds.size() != 3:
		_finish()
		return
	print("Route seed coverage: %s — each floor exercises layouts 0, 1 and 2." % str(selected_seeds))
	driver = RouteDriver.new()
	root.add_child(driver)
	for seed_value in selected_seeds:
		world = World.new()
		root.add_child(world)
		var specs: Array = Generator.generate(seed_value)
		var world_data: Dictionary = world.build(seed_value, specs)
		world.set_process(false)
		player = Player.new()
		root.add_child(player)
		player.set_physics_process(false)
		driver.body = player
		await physics_frame
		await physics_frame
		for floor_number in [30, 29, 28, 27, 26, 25]:
			var y: float = (floor_number - 24) * 6.0
			# Fixture setup only: no direct position assignment until the next floor.
			player.position = Vector3(3.85, y + 0.10, 0.0)
			player.velocity = Vector3.ZERO
			player.carrying = false
			driver.speed = 3.7
			await physics_frame
			var setup_ok: bool = await _walk(Vector3(3.85, y, 0.0), y, seed_value, floor_number, "settle on the entry lip")
			if not setup_ok:
				continue
			for kind in ["survivor", "evidence", "supply", "refuge"]:
				var target: Node3D = _find_target(world_data, kind, floor_number)
				if target == null:
					continue
				var outbound: Array[Vector3] = []
				var inbound: Array[Vector3] = []
				if kind == "survivor":
					outbound = [Vector3(7,y,0), Vector3(7,y,-4.7)]
					inbound = [Vector3(7,y,0), Vector3(3.85,y,0)]
				elif kind == "supply":
					outbound = [Vector3(4,y,4.5), Vector3(0,y,4.5), Vector3(-7,y,4.5), Vector3(-7,y,4.8)]
					inbound = [Vector3(-7,y,4.5), Vector3(0,y,4.5), Vector3(4,y,4.5), Vector3(3.85,y,0)]
				else:
					outbound = [Vector3(7,y,0), Vector3(7,y,4.7)]
					inbound = [Vector3(7,y,0), Vector3(3.85,y,0)]
				var outbound_ok: bool = await _follow(outbound, y, seed_value, floor_number, kind + " outward")
				if not outbound_ok:
					break
				var target_distance: float = Vector2(player.position.x - target.global_position.x, player.position.z - target.global_position.z).length()
				_check(target_distance < 2.7, "Seed %d floor %d %s ended outside interaction range: %.3f m." % [seed_value,floor_number,kind,target_distance])
				if target_distance < 2.7:
					objectives_reached += 1
				if kind == "survivor":
					player.carrying = true
					driver.speed = 2.4
				var inbound_ok: bool = await _follow(inbound, y, seed_value, floor_number, kind + " return to beacon")
				player.carrying = false
				driver.speed = 3.7
				if not inbound_ok:
					break
				_check(Vector2(player.position.x - 3.6, player.position.z).length() < 2.7, "Return did not reach the beacon interaction radius.")
		player.free()
		world.free()
		await physics_frame
	driver.free()
	_finish()


func _follow(points: Array[Vector3], y: float, seed_value: int, number: int, label: String) -> bool:
	for point in points:
		if not await _walk(point, y, seed_value, number, label):
			return false
	return true


func _walk(target: Vector3, y: float, seed_value: int, number: int, label: String) -> bool:
	driver.go(target, y)
	var outcome: Array = await driver.finished
	route_segments += 1
	var success: bool = outcome[0]
	_check(success, "Blocked route seed=%d floor=%d step='%s' goal=%s actual=%s collider=%s" % [seed_value,number,label,str(target),str(outcome[1]),str(outcome[2])])
	return success


func _find_target(world_data: Dictionary, kind: String, number: int) -> Node3D:
	for target: Node3D in world_data.get("interactables", []):
		if target.get_meta("kind", "") == kind and int(target.get_meta("floor", 0)) == number:
			return target
	return null


func _select_seed_cover() -> Array[int]:
	# Find a compact deterministic coverage set. Every architectural floor, not
	# merely the whole building, must exercise all three collision variants.
	var variants: Array = []
	for seed_value in range(1, 81):
		var row: Array[int] = []
		for spec in Generator.generate(seed_value):
			row.append(int(spec["layout_variant"]))
		variants.append(row)
	for a in range(variants.size() - 2):
		for b in range(a + 1, variants.size() - 1):
			for c in range(b + 1, variants.size()):
				var covers_all: bool = true
				for index in range(6):
					if variants[a][index] == variants[b][index] or variants[a][index] == variants[c][index] or variants[b][index] == variants[c][index]:
						covers_all = false
						break
				if covers_all:
					return [a + 1, b + 1, c + 1]
	return []


func _check(condition: bool, message: String) -> void:
	checks += 1
	if not condition:
		failures.append(message)


func _finish() -> void:
	if failures.is_empty():
		print("PASS physical routes: %d checks; %d real move_and_slide segments; %d objective approaches plus returns; three seeds cover all three layouts on every floor. No route teleports, noclip or geometry modifications." % [checks,route_segments,objectives_reached])
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		print("FAIL physical routes: %d failures / %d checks, %d route segments." % [failures.size(),checks,route_segments])
		quit(1)
