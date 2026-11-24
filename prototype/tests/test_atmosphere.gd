extends SceneTree
## Weather must remain decorative, seekable, paused and absent from interiors.
const WorldScript = preload("res://scripts/world_builder.gd")
const Generator = preload("res://scripts/floor_generator.gd")
const AtmosphereScript = preload("res://scripts/maritime_atmosphere.gd")
var checks: int = 0
var failures: Array[String] = []

func _initialize() -> void:
	_run.call_deferred()

func _run() -> void:
	_test_existing_sky_retained()
	var world = WorldScript.new()
	root.add_child(world)
	world.set_process(false)
	world.build(47, Generator.generate(47))
	var atmosphere: Node3D = world.get_node_or_null("MaritimeAtmosphere")
	_check(is_instance_valid(atmosphere), "World build did not install the maritime atmosphere.")
	if atmosphere == null:
		world.free()
		_finish()
		return
	var node_count: int = _node_count(world)
	var collision_count: int = _collision_count(world)
	var interactions: Array = world.interactables.duplicate()
	var rng_state: int = world.rng.state
	var environment: Environment = world.get_node("environment").environment
	_check(environment.sky.sky_material == atmosphere.sky_material, "Weather does not own the visible sky material.")
	_check(environment.fog_light_color.is_equal_approx(AtmosphereScript.HORIZON_TINT) and is_equal_approx(environment.fog_light_energy, 1.0), "Fog and the authored sea horizon use different colours or exposure.")
	_check(is_equal_approx(environment.fog_density, AtmosphereScript.FOG_DENSITY), "Far-water absorption is weaker than the authored horizon contract.")
	_check(atmosphere.sky_material.get_shader_parameter("horizon_tint").is_equal_approx(environment.fog_light_color), "Sky horizon uniform differs from the distance fog.")
	_check(not world.rain.visible, "The legacy rain grid still falls through rooms.")
	_check(atmosphere.rain_layers.size() == 2 and atmosphere.curtains.size() == 8, "The bounded near/far rain and distant veil layers are missing.")
	_check(_collision_count(atmosphere) == 0, "Weather adds a collider to rescue routes.")
	_check(not _has_interaction(atmosphere), "Weather adds a gameplay interaction.")
	for path: String in ["res://shaders/storm_sky.gdshader", "res://shaders/maritime_rain.gdshader", "res://shaders/storm_curtain.gdshader", "res://shaders/water.gdshader"]:
		var shader_text: String = FileAccess.get_file_as_string(path)
		_check(not shader_text.is_empty() and not shader_text.contains("TIME"), "A weather shader can advance independently of pause: " + path)
	_test_rain_volumes(atmosphere)
	atmosphere.sample_world(13.5, "intact", false)
	var sampled: Dictionary = atmosphere.snapshot()
	_check(is_equal_approx(float(atmosphere.water_material.get_shader_parameter("clock")), 13.5), "Water still uses a clock outside world pause/seek.")
	_check(_all_rain_clocks(atmosphere, 13.5) and _all_curtain_clocks(atmosphere, 13.5), "Explicit clock did not reach every weather material.")
	atmosphere.sample_world(42.25, "quake", false)
	atmosphere.sample_world(13.5, "aftermath", false)
	_check(atmosphere.snapshot() == sampled and _all_rain_clocks(atmosphere, 13.5), "Seeking or changing the incident accumulates weather state.")
	atmosphere.sample_world(-12.0, "intact", false)
	_check(is_zero_approx(atmosphere.current_clock) and _all_rain_clocks(atmosphere, 0.0), "A negative weather clock creates an invalid pose.")
	atmosphere.sample_world(NAN, "intact", false)
	_check(is_zero_approx(atmosphere.current_clock), "A non-finite clock reached a shader.")
	atmosphere.sample_world(INF, "intact", false)
	_check(is_zero_approx(atmosphere.current_clock), "An infinite clock reached a shader.")
	atmosphere.sample_world(25.0, "collapse", true)
	var rain_hidden: bool = true
	for layer: MultiMeshInstance3D in atmosphere.rain_layers:
		rain_hidden = rain_hidden and not layer.visible
	_check(rain_hidden and _all_rain_clocks(atmosphere, 0.0) and _all_curtain_clocks(atmosphere, 0.0), "Reduced motion leaves moving rain or drifting veils.")
	_check(is_zero_approx(float(atmosphere.water_material.get_shader_parameter("clock"))), "Reduced motion leaves the water shader animated.")
	var looped: Dictionary = AtmosphereScript.presentation_sample(120.0, false)
	_check(is_zero_approx(float(looped["rain_clock"])), "The rain clock loses its seamless bounded period.")
	var large: Dictionary = AtmosphereScript.presentation_sample(1.0e20, false)
	_check(float(large["rain_clock"]) >= 0.0 and float(large["rain_clock"]) < 120.0 and float(large["curtain_clock"]) < TAU / 0.07 and float(large["water_clock"]) < TAU * 100.0, "Long presentation clocks exceed the shader precision envelope.")
	var curtains_visible: bool = true
	for curtain: MeshInstance3D in atmosphere.curtains:
		curtains_visible = curtains_visible and curtain.visible
	_check(curtains_visible and environment.sky.sky_material == atmosphere.sky_material, "Reduced motion removed the static storm composition.")
	atmosphere.build(world)
	_check(_node_count(world) == node_count, "Repeated weather setup duplicated geometry.")
	world.set_reduced_motion(false)
	world._process(5.5)
	_check(is_equal_approx(atmosphere.current_clock, world.elapsed) and _all_rain_clocks(atmosphere, world.elapsed), "The real world process did not pass its presentation clock.")
	_check(not atmosphere.motion_reduced, "The world did not forward the motion preference.")
	var paused: Dictionary = atmosphere.snapshot()
	var paused_material_clock: float = float(atmosphere.rain_layers[0].material_override.get_shader_parameter("clock"))
	await process_frame
	await process_frame
	_check(atmosphere.snapshot() == paused and is_equal_approx(float(atmosphere.rain_layers[0].material_override.get_shader_parameter("clock")), paused_material_clock) and is_equal_approx(float(atmosphere.water_material.get_shader_parameter("clock")), float(paused["water_clock"])), "Weather or water advanced through actual paused frames.")
	world.set_process(true)
	await process_frame
	await process_frame
	world.set_process(false)
	_check(atmosphere.current_clock > float(paused["clock"]), "Resumed world frames did not resume weather.")
	world.set_reduced_motion(true)
	_check(atmosphere.motion_reduced and _all_rain_clocks(atmosphere, 0.0), "A live reduced-motion toggle did not apply immediately.")
	_check(not world.rain.visible, "Changing preferences resurrected interior rain.")
	_check(_node_count(world) == node_count and _collision_count(world) == collision_count, "Weather sampling changes the world hierarchy or collision count.")
	_check(world.interactables == interactions, "Weather sampling changes rescue interactions.")
	_check(world.rng.state == rng_state, "Weather consumed the mission random stream.")
	world.set_lightning_enabled(false)
	world._process(24.0)
	_check(is_equal_approx(world.get_node("StormLight").light_energy, 0.60), "Weather overrode the disabled-flashes preference.")
	world.free()
	_finish()

func _test_existing_sky_retained() -> void:
	var shell: Node3D = Node3D.new()
	root.add_child(shell)
	var environment_node: WorldEnvironment = WorldEnvironment.new()
	environment_node.name = "environment"
	var environment: Environment = Environment.new()
	var existing_sky: Sky = Sky.new()
	environment.sky = existing_sky
	environment_node.environment = environment
	shell.add_child(environment_node)
	var atmosphere: Node3D = AtmosphereScript.new()
	shell.add_child(atmosphere)
	atmosphere.build(shell)
	_check(environment.sky == existing_sky, "Weather replaced an existing Sky before its pending renderer update.")
	shell.free()

func _test_rain_volumes(atmosphere: Node3D) -> void:
	var total: int = 0
	var outside_rooms: bool = true
	var valid_bounds: bool = true
	var phases_valid: bool = true
	var deterministic: bool = true
	for band in range(atmosphere.rain_layers.size()):
		var layer: MultiMeshInstance3D = atmosphere.rain_layers[band]
		var multi: MultiMesh = layer.multimesh
		total += multi.instance_count
		var buffer: PackedFloat32Array = multi.buffer
		_check(buffer.size() == multi.instance_count * 16, "Uploaded rain buffer has an invalid transform/custom-data stride.")
		if buffer.size() != multi.instance_count * 16:
			continue
		_check(layer.cast_shadow == GeometryInstance3D.SHADOW_CASTING_SETTING_OFF, "Rain casts an artificial solid shadow.")
		for index in range(multi.instance_count):
			var offset: int = index * 16
			var point: Vector3 = Vector3(buffer[offset + 3], buffer[offset + 7], buffer[offset + 11])
			outside_rooms = outside_rooms and (absf(point.x) >= 14.5 or absf(point.z) >= 14.5)
			outside_rooms = outside_rooms and (absf(point.x - 46.0) >= 14.5 or absf(point.z + 6.0) >= 14.5)
			valid_bounds = valid_bounds and multi.custom_aabb.has_point(point) and multi.custom_aabb.has_point(point + Vector3.UP * AtmosphereScript.RAIN_HEIGHT)
			var custom: Color = Color(buffer[offset + 12], buffer[offset + 13], buffer[offset + 14], buffer[offset + 15])
			phases_valid = phases_valid and is_finite(custom.r) and custom.r >= 0.0 and custom.r <= 1.0 and custom.g >= 0.0 and custom.g <= 1.0
			deterministic = deterministic and point.is_equal_approx(AtmosphereScript.rain_column(index, band))
	_check(total == 1024, "Rain exceeded its bounded instance budget.")
	_check(outside_rooms, "A rain column intersects a protected interior envelope.")
	_check(valid_bounds, "Shader-displaced rain can leave its declared culling bounds.")
	_check(phases_valid and deterministic, "Rain instances have invalid phase data or depend on a random stream.")

func _all_rain_clocks(atmosphere: Node3D, expected: float) -> bool:
	for layer: MultiMeshInstance3D in atmosphere.rain_layers:
		if not is_equal_approx(float(layer.material_override.get_shader_parameter("clock")), expected):
			return false
	return true

func _all_curtain_clocks(atmosphere: Node3D, expected: float) -> bool:
	for curtain: MeshInstance3D in atmosphere.curtains:
		if not is_equal_approx(float(curtain.material_override.get_shader_parameter("clock")), expected):
			return false
	return true

func _has_interaction(node: Node) -> bool:
	if node.has_meta("kind"):
		return true
	for child: Node in node.get_children():
		if _has_interaction(child):
			return true
	return false

func _node_count(node: Node) -> int:
	var total: int = 1
	for child: Node in node.get_children():
		total += _node_count(child)
	return total

func _collision_count(node: Node) -> int:
	var total: int = 1 if node is CollisionObject3D else 0
	for child: Node in node.get_children():
		total += _collision_count(child)
	return total

func _check(condition: bool, message: String) -> void:
	checks += 1
	if not condition:
		failures.append(message)

func _finish() -> void:
	if failures.is_empty():
		print("PASS maritime atmosphere: %d checks; matched horizon, bounded exterior rain, deterministic seeking, reduced motion, real pause/resume, unchanged collisions and mission RNG." % checks)
		quit(0)
	else:
		for failure: String in failures:
			push_error(failure)
		quit(1)
