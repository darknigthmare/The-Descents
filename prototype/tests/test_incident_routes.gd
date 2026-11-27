extends "res://tests/test_routes.gd"
## Focused physical regression tests for the changed façades and archive route.
## Reuses the real capsule RouteDriver; no teleport occurs inside a route.
## Each frame samples the player's location into the incident presentation,
## matching main.gd instead of freezing a collider state for the whole test.
## Run: godot --headless --fixed-fps 60 --path prototype --script tests/test_incident_routes.gd

var sampler: IncidentSampler
var expected_blockages: int = 0
var occupied_landings: int = 0


class IncidentSampler:
	extends Node
	var world_node: Node3D
	var body: CharacterBody3D
	var stage: String = "intact"
	var stage_time: float = 0.0

	func _physics_process(_delta: float) -> void:
		if is_instance_valid(world_node) and is_instance_valid(body):
			world_node.set_incident_player_position(body.global_position)
			world_node.apply_incident(stage, stage_time)


func _run() -> void:
	Engine.physics_ticks_per_second = 60
	var selected_seeds: Array[int] = _select_seed_cover()
	_check(selected_seeds.size() == 3, "Could not select three seeds covering the 28/29 layout variants.")
	if selected_seeds.size() != 3:
		_finish()
		return
	print("Incident route seeds: %s; each changed floor covers all three layout variants." % str(selected_seeds))
	driver = RouteDriver.new()
	root.add_child(driver)
	sampler = IncidentSampler.new()
	sampler.process_physics_priority = -10
	root.add_child(sampler)
	for seed_value in selected_seeds:
		world = World.new()
		root.add_child(world)
		var world_data: Dictionary = world.build(seed_value, Generator.generate(seed_value))
		world.set_process(false)
		player = Player.new()
		root.add_child(player)
		player.set_physics_process(false)
		driver.body = player
		sampler.body = player
		sampler.world_node = world
		_set_stage("intact")
		await physics_frame
		await physics_frame
		await _test_bay_round_trips(seed_value, world_data)
		await _test_archive_detour(seed_value, world_data)
		await _test_occupied_landing(seed_value)
		sampler.world_node = null
		sampler.body = null
		player.free()
		world.free()
		await physics_frame
	sampler.free()
	driver.free()
	_finish()


func _test_bay_round_trips(seed_value: int, world_data: Dictionary) -> void:
	# Initial fixture placement, followed entirely by capsule movement.
	player.position = Vector3(3.85, 30.10, 0.0)
	player.velocity = Vector3.ZERO
	player.carrying = false
	driver.speed = 3.7
	_set_stage("intact")
	await physics_frame
	await physics_frame
	var observation: Vector3 = world_data["observation_position"]
	var outward: Array[Vector3] = [Vector3(4.7, 30, 0), Vector3(observation.x, 30, observation.z)]
	var returning: Array[Vector3] = [Vector3(4.7, 30, 0), Vector3(3.85, 30, 0)]
	for stage_name in ["intact", "aftermath"]:
		_set_stage(stage_name)
		await physics_frame
		await physics_frame
		var reached: bool = await _follow(outward, 30, seed_value, 29, stage_name + " observation access")
		if reached:
			objectives_reached += 1
			_check(player.position.distance_to(observation) < 0.25, "The observation bay is not reachable close enough to trigger gaze or interaction.")
		var returned: bool = await _follow(returning, 30, seed_value, 29, stage_name + " observation return")
		_check(returned and Vector2(player.position.x - 3.6, player.position.z).length() < 2.7, "The player cannot return from the observation bay to the rope beacon.")


func _test_archive_detour(seed_value: int, world_data: Dictionary) -> void:
	_set_stage("intact")
	await physics_frame
	await physics_frame
	player.position = Vector3(3.85, 24.10, 0.0)
	player.velocity = Vector3.ZERO
	player.carrying = false
	driver.speed = 3.7
	var old_path: Array[Vector3] = [Vector3(7, 24, 0), Vector3(7, 24, -4.7)]
	var old_return: Array[Vector3] = [Vector3(7, 24, 0), Vector3(3.85, 24, 0)]
	_check(await _follow(old_path, 24, seed_value, 28, "intact archive corridor"), "The original archive corridor was obstructed before the impact.")
	_check(_within_interaction_range(_find_target(world_data, "survivor", 28)), "The intact route did not reach Samuel's interaction radius.")
	player.carrying = true
	driver.speed = 2.4
	await _follow(old_return, 24, seed_value, 28, "intact carrying return")
	player.carrying = false
	driver.speed = 3.7
	_set_stage("aftermath")
	await physics_frame
	await physics_frame
	_check(world.route_obstacle.visible and world.route_obstacle_body.collision_layer != 0, "The archive blockage did not settle while its landing area was clear.")
	await _walk(Vector3(7, 24, 0), 24, seed_value, 28, "approach old archive route")
	await _expect_blocked(Vector3(7, 24, -4.7), seed_value, "old east archive route")
	await _walk(Vector3(7, 24, 0), 24, seed_value, 28, "back away from blocked corridor")
	var detour: Array[Vector3] = [Vector3(4.7, 24, 0), Vector3(4.7, 24, -5.2), Vector3(7, 24, -5.2)]
	var detour_return: Array[Vector3] = [Vector3(4.7, 24, -5.2), Vector3(4.7, 24, 0), Vector3(3.85, 24, 0)]
	var reached: bool = await _follow(detour, 24, seed_value, 28, "post-impact interior detour")
	_check(reached and _within_interaction_range(_find_target(world_data, "survivor", 28)), "Samuel is unreachable through the post-impact interior detour.")
	if reached:
		objectives_reached += 1
	player.carrying = true
	driver.speed = 2.4
	var returned: bool = await _follow(detour_return, 24, seed_value, 28, "post-impact carrying return")
	_check(returned and Vector2(player.position.x - 3.6, player.position.z).length() < 2.7, "A carried Samuel cannot return to the rope beacon through the detour.")
	player.carrying = false
	driver.speed = 3.7


func _test_occupied_landing(seed_value: int) -> void:
	# Separate initial condition: a fast player is already in the future landing
	# envelope when impact begins. No body should materialize around the capsule.
	_set_stage("intact")
	await physics_frame
	await physics_frame
	player.position = Vector3(8.55, 24.10, -3.7)
	player.velocity = Vector3.ZERO
	await _walk(Vector3(8.55, 24, -3.7), 24, seed_value, 28, "settle inside future landing envelope")
	_set_stage("impact", 2.0)
	for frame in range(8):
		await physics_frame
	_check(not world.route_obstacle.visible and world.route_obstacle_body.collision_layer == 0, "Impact created solid debris on a player already inside the landing envelope.")
	var escaped: bool = await _walk(Vector3(4.7, 24, -3.7), 24, seed_value, 28, "escape falling debris toward the core")
	_check(escaped, "The occupied landing area did not allow the player to leave toward the core.")
	if escaped:
		occupied_landings += 1
	await physics_frame
	await physics_frame
	_check(world.route_obstacle.visible and world.route_obstacle_body.collision_layer != 0, "Deferred debris did not activate after the player cleared its landing envelope.")
	await _expect_blocked(Vector3(8.55, 24, -3.7), seed_value, "reapproach after deferred landing")
	_check(world.route_obstacle.visible and world.route_obstacle_body.collision_layer != 0, "Reapproaching settled debris made the obstruction disappear.")
	var returning: Array[Vector3] = [Vector3(4.7, 24, -3.7), Vector3(4.7, 24, 0), Vector3(3.85, 24, 0)]
	_check(await _follow(returning, 24, seed_value, 28, "return after deferred debris landing"), "Activating the delayed obstruction trapped the player away from the rope.")


func _expect_blocked(target: Vector3, seed_value: int, label: String) -> void:
	# An expected failure is observed directly instead of using _walk, which
	# correctly treats failure as a regression for traversable routes.
	driver.go(target, 24.0)
	var outcome: Array = await driver.finished
	route_segments += 1
	var blocked: bool = not bool(outcome[0])
	_check(blocked, "Seed %d: %s remained traversable after the obstruction settled; end=%s." % [seed_value, label, str(outcome[1])])
	if blocked:
		expected_blockages += 1
		_check(str(outcome[2]).contains("FallenArchiveCeiling"), "The expected blocked route hit another collider: %s." % str(outcome[2]))


func _set_stage(stage_name: String, time_in_stage: float = 0.0) -> void:
	sampler.stage = stage_name
	sampler.stage_time = time_in_stage
	world.set_incident_player_position(player.global_position)
	world.apply_incident(stage_name, time_in_stage)


func _within_interaction_range(target: Node3D) -> bool:
	return is_instance_valid(target) and Vector2(player.position.x - target.global_position.x, player.position.z - target.global_position.z).length() < 2.7


func _finish() -> void:
	if failures.is_empty():
		print("PASS incident physical routes: %d checks; %d real move_and_slide segments; %d expected solid blockages; %d safe occupied landings; 3 seeds cover each 28/29 layout. Bay round trips, Samuel's detour and carried return passed before/after impact. Position is set only for each initial scenario." % [checks, route_segments, expected_blockages, occupied_landings])
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		print("FAIL incident physical routes: %d failures / %d checks, %d route segments." % [failures.size(), checks, route_segments])
		quit(1)
