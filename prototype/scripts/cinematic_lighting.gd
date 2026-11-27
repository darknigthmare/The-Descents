extends Node
class_name DescentCinematicLighting

## A native Forward+ profile, with a deliberately separate portable profile.
## SDFGI is semi-dynamic GI, not UE5 Lumen: only fixed opaque geometry is baked.
## Runtime capability checks must never rely on ProjectSettings' requested API.
## Call mark_dynamic_branch() for imported actors before their first drawn frame.

const VALID_PROFILES: Array[String] = ["auto", "cinematic", "portable"]
const GI_POLICY: StringName = &"descent_gi_policy"
const PRACTICAL_SHADOW: StringName = &"descent_practical_shadow"

var requested_profile: String = "auto"
var active_profile: String = "portable"
var fallback_reason: String = ""
var static_revision: int = 0
var last_refresh_reason: String = "initial_build"
var _environment: Environment
var _world: Node3D
var _moon: DirectionalLight3D
var _refresh_pending: bool = false
var _configured: bool = false

static func runtime_capabilities() -> Dictionary:
	var method: String = RenderingServer.get_current_rendering_method()
	var display: String = DisplayServer.get_name()
	var has_device: bool = RenderingServer.get_rendering_device() != null
	return {"rendering_method": method, "display": display, "rendering_device": has_device,
		"native_forward_plus": method == "forward_plus" and has_device and display != "headless"}

static func choose_profile(requested: String, capabilities: Dictionary) -> String:
	if requested == "portable":
		return "portable"
	return "cinematic" if bool(capabilities.get("native_forward_plus", false)) else "portable"

func configure(world: Node3D, environment: Environment, moon: DirectionalLight3D, requested: String = "auto") -> Dictionary:
	_world = world
	_environment = environment
	_moon = moon
	_configured = true
	return set_profile(requested)

func set_profile(requested: String = "auto") -> Dictionary:
	requested_profile = requested if requested in VALID_PROFILES else "auto"
	var capabilities: Dictionary = runtime_capabilities()
	active_profile = choose_profile(requested_profile, capabilities)
	fallback_reason = ""
	if active_profile != "cinematic" and requested_profile != "portable":
		fallback_reason = "headless_validation" if capabilities["display"] == "headless" else "renderer_without_forward_plus"
	if not _configured or _environment == null:
		return snapshot()
	var cinematic: bool = active_profile == "cinematic"
	# Ambient is a restrained readability floor. The Forward+ result also uses
	# actual GI and shadowed local practicals, not an ambient-colour imitation.
	_environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	_environment.ambient_light_color = Color("a1b4bd")
	_environment.ambient_light_energy = 0.17 if cinematic else 0.40
	_environment.ambient_light_sky_contribution = 0.0
	_environment.reflected_light_source = Environment.REFLECTION_SOURCE_SKY
	_environment.tonemap_mode = Environment.TONE_MAPPER_ACES if cinematic else Environment.TONE_MAPPER_FILMIC
	_environment.tonemap_exposure = 1.06 if cinematic else 1.0
	_environment.tonemap_white = 6.0
	_environment.sdfgi_enabled = cinematic
	_environment.sdfgi_cascades = 4
	_environment.sdfgi_min_cell_size = 0.25
	_environment.sdfgi_y_scale = Environment.SDFGI_Y_SCALE_100_PERCENT
	_environment.sdfgi_use_occlusion = true
	_environment.sdfgi_read_sky_light = true
	_environment.sdfgi_energy = 0.72
	_environment.sdfgi_bounce_feedback = 0.20
	_environment.sdfgi_normal_bias = 1.1
	_environment.sdfgi_probe_bias = 1.1
	_environment.ssil_enabled = cinematic
	_environment.ssil_radius = 2.2
	_environment.ssil_intensity = 0.42
	_environment.ssil_normal_rejection = 1.1
	_environment.ssao_enabled = cinematic
	_environment.ssao_radius = 0.55
	_environment.ssao_intensity = 0.65
	_environment.ssao_power = 1.25
	_environment.ssr_enabled = cinematic
	_environment.ssr_max_steps = 48
	_environment.ssr_depth_tolerance = 0.20
	_environment.ssr_fade_in = 0.12
	_environment.ssr_fade_out = 1.4
	_environment.glow_enabled = cinematic
	_environment.glow_normalized = true
	_environment.glow_intensity = 0.22
	_environment.glow_strength = 0.65
	_environment.glow_bloom = 0.0
	_environment.glow_hdr_threshold = 1.35
	_environment.glow_blend_mode = Environment.GLOW_BLEND_MODE_SOFTLIGHT
	_environment.volumetric_fog_enabled = cinematic
	_environment.volumetric_fog_density = 0.0025
	_environment.volumetric_fog_albedo = Color("a2b7bf")
	_environment.volumetric_fog_length = 64.0
	_environment.volumetric_fog_detail_spread = 1.5
	_environment.volumetric_fog_anisotropy = 0.25
	_environment.volumetric_fog_ambient_inject = 0.15
	_environment.volumetric_fog_gi_inject = 0.20
	_environment.volumetric_fog_sky_affect = 0.15
	# Moving direct lights should not leave long volumetric reprojection trails.
	_environment.volumetric_fog_temporal_reprojection_enabled = true
	_environment.volumetric_fog_temporal_reprojection_amount = 0.70
	# The maritime atmosphere owns ordinary fog/horizon matching in both APIs.
	if is_instance_valid(_moon):
		_moon.light_bake_mode = Light3D.BAKE_DYNAMIC
		_moon.light_indirect_energy = 0.45
		_moon.light_volumetric_fog_energy = 0.25
		_moon.shadow_enabled = true
		_moon.shadow_bias = 0.035
		_moon.shadow_normal_bias = 1.2
		_moon.directional_shadow_max_distance = 95.0 if cinematic else 70.0
		_moon.directional_shadow_mode = DirectionalLight3D.SHADOW_PARALLEL_4_SPLITS if cinematic else DirectionalLight3D.SHADOW_PARALLEL_2_SPLITS
	_update_practical_shadows(_world)
	return snapshot()

func snapshot() -> Dictionary:
	var result: Dictionary = runtime_capabilities()
	result.merge({"requested_profile": requested_profile, "active_profile": active_profile,
		"fallback_reason": fallback_reason, "static_revision": static_revision,
		"last_refresh_reason": last_refresh_reason, "refresh_pending": _refresh_pending,
		"gi_technique": "SDFGI: fixed opaque geometry only" if active_profile == "cinematic" else "direct lighting with ambient fill",
		"sdfgi": _environment != null and _environment.sdfgi_enabled,
		"ssil": _environment != null and _environment.ssil_enabled,
		"ssr": _environment != null and _environment.ssr_enabled,
		"ssao": _environment != null and _environment.ssao_enabled,
		"volumetric_fog": _environment != null and _environment.volumetric_fog_enabled,
		"glow": _environment != null and _environment.glow_enabled})
	return result

func finalize_static_geometry(world: Node) -> Dictionary:
	# Explicitly tagged movers stay excluded even when temporarily stationary.
	_classify_branch(world, false)
	_update_practical_shadows(world)
	return geometry_inventory(world)

static func mark_dynamic_branch(branch: Node) -> void:
	if not is_instance_valid(branch):
		return
	branch.set_meta(GI_POLICY, "dynamic")
	_set_dynamic_recursive(branch)

static func _set_dynamic_recursive(node: Node) -> void:
	if node is GeometryInstance3D:
		node.gi_mode = GeometryInstance3D.GI_MODE_DISABLED
	if node is Light3D:
		node.light_bake_mode = Light3D.BAKE_DISABLED
		# Moving lamps still illuminate directly and can cast real-time shadows.
		node.light_indirect_energy = 0.0
	for child: Node in node.get_children():
		_set_dynamic_recursive(child)

static func _is_moving(node: Node) -> bool:
	return str(node.get_meta(GI_POLICY, "")) == "dynamic" or node is CharacterBody3D or node is RigidBody3D or node.has_meta("presentation_model")

static func branch_is_dynamic(node: Node) -> bool:
	var cursor: Node = node
	while cursor != null:
		if _is_moving(cursor):
			return true
		cursor = cursor.get_parent()
	return false

static func _classify_branch(node: Node, inherited_dynamic: bool) -> void:
	var dynamic: bool = inherited_dynamic or _is_moving(node)
	if node is GeometryInstance3D:
		var opaque: bool = node is MeshInstance3D
		if node is MeshInstance3D and node.material_override is BaseMaterial3D:
			var material: BaseMaterial3D = node.material_override
			opaque = material.transparency == BaseMaterial3D.TRANSPARENCY_DISABLED and material.shading_mode != BaseMaterial3D.SHADING_MODE_UNSHADED
		node.gi_mode = GeometryInstance3D.GI_MODE_STATIC if opaque and not dynamic else GeometryInstance3D.GI_MODE_DISABLED
	if node is Light3D and dynamic:
		node.light_bake_mode = Light3D.BAKE_DISABLED
		node.light_indirect_energy = 0.0
	for child: Node in node.get_children():
		_classify_branch(child, dynamic)

static func geometry_inventory(branch: Node) -> Dictionary:
	var result: Dictionary = {"static_meshes": 0, "excluded_meshes": 0, "moving_static_violations": 0}
	_inventory_branch(branch, false, result)
	return result

static func _inventory_branch(node: Node, inherited_dynamic: bool, result: Dictionary) -> void:
	var dynamic: bool = inherited_dynamic or _is_moving(node)
	if node is GeometryInstance3D:
		if node.gi_mode == GeometryInstance3D.GI_MODE_STATIC:
			result["static_meshes"] += 1
			if dynamic:
				result["moving_static_violations"] += 1
		else:
			result["excluded_meshes"] += 1
	for child: Node in node.get_children():
		_inventory_branch(child, dynamic, result)

func _update_practical_shadows(branch: Node) -> void:
	if not is_instance_valid(branch):
		return
	if branch is Light3D and branch.has_meta(PRACTICAL_SHADOW):
		# Two local cone shadows per floor in Forward+, one in the portable
		# profile; distance fading bounds the number near the camera.
		branch.shadow_enabled = active_profile == "cinematic" or bool(branch.get_meta(PRACTICAL_SHADOW))
	for child: Node in branch.get_children():
		_update_practical_shadows(child)

func invalidate_static_lighting(reason: String = "static_geometry_changed") -> bool:
	static_revision += 1
	last_refresh_reason = reason
	if active_profile != "cinematic" or _environment == null or not is_inside_tree():
		return false
	if _refresh_pending:
		return true
	_refresh_pending = true
	_environment.sdfgi_enabled = false
	_restore_sdfgi_after_frame.call_deferred()
	return true

func _restore_sdfgi_after_frame() -> void:
	# Keep SDFGI disabled through a rendered frame so cached static voxels are
	# discarded. This is called once on a stable impact/reset, never per tick.
	await get_tree().process_frame
	await get_tree().process_frame
	if active_profile == "cinematic" and _environment != null:
		_environment.sdfgi_enabled = true
	_refresh_pending = false
