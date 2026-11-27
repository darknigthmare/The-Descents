extends Node3D
class_name MaritimeAtmosphere

## Decorative weather only. Every pose is reconstructed from an explicit clock;
## this node never advances itself or touches mission RNG, save data or physics.
const SKY_SHADER = preload("res://shaders/storm_sky.gdshader")
const RAIN_SHADER = preload("res://shaders/maritime_rain.gdshader")
const CURTAIN_SHADER = preload("res://shaders/storm_curtain.gdshader")
const HORIZON_TINT: Color = Color("3c5965")
const FOG_DENSITY: float = 0.0036
const SEA_LEVEL: float = -138.0
const RAIN_HEIGHT: float = 240.0
const NEAR_DROPS: int = 640
const FAR_DROPS: int = 384
const CURTAIN_COUNT: int = 8

var rain_layers: Array[MultiMeshInstance3D] = []
var curtains: Array[MeshInstance3D] = []
var sky_material: ShaderMaterial
var water_material: ShaderMaterial
var current_clock: float = 0.0
var motion_reduced: bool = false
var initialized: bool = false

func build(world: Node3D) -> void:
	if initialized:
		return
	name = "MaritimeAtmosphere"
	var environment_node: WorldEnvironment = world.get_node_or_null("environment")
	if environment_node == null or environment_node.environment == null:
		push_error("Maritime atmosphere requires the existing world environment.")
		return
	var environment: Environment = environment_node.environment
	sky_material = ShaderMaterial.new()
	sky_material.shader = SKY_SHADER
	sky_material.set_shader_parameter("horizon_tint", HORIZON_TINT)
	# Reuse the world Sky RID. Replacing a newly dirtied sky before its first
	# GL update can strand its queued radiance allocation in Godot 4.7.2.
	var sky: Sky = environment.sky
	if sky == null:
		sky = Sky.new()
	sky.sky_material = sky_material
	sky.radiance_size = Sky.RADIANCE_SIZE_64
	sky.process_mode = Sky.PROCESS_MODE_QUALITY
	environment.sky = sky
	environment.fog_enabled = true
	environment.fog_light_color = HORIZON_TINT
	environment.fog_light_energy = 1.0
	environment.fog_density = FOG_DENSITY
	environment.fog_sky_affect = 0.0
	var sea: MeshInstance3D = world.get_node_or_null("water")
	if is_instance_valid(sea) and sea.material_override is ShaderMaterial:
		water_material = sea.material_override
	# Leave the legacy grid allocated so its original RNG draws remain intact.
	# Its replacement excludes the room envelopes at every height.
	var legacy_rain: Node3D = world.get_node_or_null("Rain")
	if is_instance_valid(legacy_rain):
		legacy_rain.hide()
	_build_rain_layer(0, NEAR_DROPS, Vector3(0.016, 0.78, 0.016), 18.0, 0.28)
	_build_rain_layer(1, FAR_DROPS, Vector3(0.055, 1.9, 0.055), 22.0, 0.18)
	_build_curtains()
	initialized = true
	sample_world(0.0, "intact", false)

static func rain_column(index: int, band: int) -> Vector3:
	# An arithmetic low-discrepancy distribution never consumes a random source.
	var angle: float = fposmod(float(index) * 2.39996323 + float(band) * 0.71, TAU)
	var scatter: float = fposmod(float(index) * 0.75487766 + 0.31, 1.0)
	var radius: float = 18.0 + sqrt(scatter) * 64.0 if band == 0 else 100.0 + sqrt(scatter) * 250.0
	var point: Vector3 = Vector3(cos(angle) * radius, SEA_LEVEL, sin(angle) * radius)
	# The first-person rooms have a 24 m square envelope. Keep an extra 2.5 m
	# margin around Aube and the intact Hesperie footprint.
	if absf(point.x) < 14.5 and absf(point.z) < 14.5:
		point.x = 14.6 if point.x >= 0.0 else -14.6
	if absf(point.x - 46.0) < 14.5 and absf(point.z + 6.0) < 14.5:
		point.x = 60.6 if point.x >= 46.0 else 31.4
	return point

func _build_rain_layer(band: int, count: int, streak_size: Vector3, speed: float, opacity: float) -> void:
	var material: ShaderMaterial = ShaderMaterial.new()
	material.shader = RAIN_SHADER
	material.set_shader_parameter("fall_speed", speed)
	material.set_shader_parameter("volume_height", RAIN_HEIGHT)
	material.set_shader_parameter("opacity", opacity)
	var streak: BoxMesh = BoxMesh.new()
	streak.size = streak_size
	streak.material = material
	var multi: MultiMesh = MultiMesh.new()
	multi.transform_format = MultiMesh.TRANSFORM_3D
	multi.use_custom_data = true
	multi.mesh = streak
	multi.instance_count = count
	multi.custom_aabb = AABB(Vector3(-360, SEA_LEVEL - 2.0, -360), Vector3(720, RAIN_HEIGHT + 4.0, 720))
	# One row-major upload per layer: three transform rows plus four custom
	# floats. The exact uploaded buffer remains inspectable in headless mode,
	# where the rendering server's per-instance setters/getters are stubs.
	var buffer: PackedFloat32Array = PackedFloat32Array()
	buffer.resize(count * 16)
	for index in range(count):
		var point: Vector3 = rain_column(index, band)
		var offset: int = index * 16
		buffer[offset] = 1.0
		buffer[offset + 3] = point.x
		buffer[offset + 5] = 1.0
		buffer[offset + 7] = point.y
		buffer[offset + 10] = 1.0
		buffer[offset + 11] = point.z
		buffer[offset + 12] = fposmod(float(index) * 0.61803399 + float(band) * 0.37, 1.0)
		buffer[offset + 13] = fposmod(float(index) * 0.41421356 + 0.23, 1.0)
		buffer[offset + 15] = 1.0
	multi.buffer = buffer
	var layer: MultiMeshInstance3D = MultiMeshInstance3D.new()
	layer.name = "NearRain" if band == 0 else "DistantRain"
	layer.multimesh = multi
	layer.material_override = material
	layer.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(layer)
	rain_layers.append(layer)

func _build_curtains() -> void:
	for index in range(CURTAIN_COUNT):
		var angle: float = TAU * float(index) / float(CURTAIN_COUNT)
		var material: ShaderMaterial = ShaderMaterial.new()
		material.shader = CURTAIN_SHADER
		material.set_shader_parameter("sector", float(index))
		var mesh: QuadMesh = QuadMesh.new()
		mesh.size = Vector2(390.0, 280.0)
		var curtain: MeshInstance3D = MeshInstance3D.new()
		curtain.name = "RainCurtain%d" % index
		curtain.mesh = mesh
		curtain.material_override = material
		curtain.position = Vector3(sin(angle) * 540.0, -24.0, cos(angle) * 540.0)
		curtain.rotation.y = angle
		curtain.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		add_child(curtain)
		curtains.append(curtain)

static func presentation_sample(clock_value: float, reduce_motion: bool) -> Dictionary:
	var safe_clock: float = maxf(clock_value, 0.0) if is_finite(clock_value) else 0.0
	return {
		"clock": safe_clock,
		"rain_clock": fposmod(safe_clock, 120.0) if not reduce_motion else 0.0,
		"curtain_clock": fposmod(safe_clock, TAU / 0.07) if not reduce_motion else 0.0,
		"water_clock": fposmod(safe_clock, TAU * 100.0) if not reduce_motion else 0.0,
		"rain_visible": not reduce_motion,
		"reduced_motion": reduce_motion
	}

func sample_world(clock_value: float, _incident_stage: String = "intact", reduce_motion: bool = false) -> void:
	var sample: Dictionary = presentation_sample(clock_value, reduce_motion)
	current_clock = float(sample["clock"])
	motion_reduced = bool(sample["reduced_motion"])
	if is_instance_valid(water_material):
		water_material.set_shader_parameter("clock", float(sample["water_clock"]))
	for layer: MultiMeshInstance3D in rain_layers:
		layer.visible = bool(sample["rain_visible"])
		var material: ShaderMaterial = layer.material_override
		material.set_shader_parameter("clock", float(sample["rain_clock"]))
	for curtain: MeshInstance3D in curtains:
		var material: ShaderMaterial = curtain.material_override
		material.set_shader_parameter("clock", float(sample["curtain_clock"]))

func snapshot() -> Dictionary:
	return presentation_sample(current_clock, motion_reduced)
