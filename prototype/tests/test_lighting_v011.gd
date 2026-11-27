extends SceneTree
## Capability fallback and GI exclusion are tested without pretending a headless
## run renders SDFGI. Native images use lighting_v011_preview.tscn separately.
const World = preload("res://scripts/world_builder.gd")
const Lighting = preload("res://scripts/cinematic_lighting.gd")
const Generator = preload("res://scripts/floor_generator.gd")
var checks: int = 0
var failures: Array[String] = []

func _initialize() -> void:
	_run.call_deferred()

func _run() -> void:
	var actual: Dictionary = Lighting.runtime_capabilities()
	_check(actual["rendering_method"] == RenderingServer.get_current_rendering_method(), "Lighting reported the configured renderer instead of the running renderer.")
	_check(actual["display"] == DisplayServer.get_name(), "Lighting reported an incorrect display server.")
	if DisplayServer.get_name() == "headless":
		_check(not actual["native_forward_plus"], "A headless test must not claim native Forward+ verification.")
	for requested: String in ["auto", "cinematic", "portable"]:
		_check(Lighting.choose_profile(requested, {"native_forward_plus": false}) == "portable", "Unsupported capabilities enabled advanced lighting.")
		_check(Lighting.choose_profile(requested, {"native_forward_plus": true}) == ("portable" if requested == "portable" else "cinematic"), "Supported capability profile selection is wrong.")
	var world: Node3D = World.new()
	root.add_child(world)
	world.build(271104, Generator.generate(271104), true)
	world.set_process(false)
	var snapshot: Dictionary = world.lighting_snapshot()
	_check(snapshot["active_profile"] == ("cinematic" if actual["native_forward_plus"] else "portable"), "World does not use its actual renderer capability.")
	_check(snapshot["geometry"]["static_meshes"] > 100, "Fixed Aube surfaces never contribute to static GI.")
	_check(snapshot["geometry"]["moving_static_violations"] == 0, "A moving object contributes stale static GI.")
	var static_count: int = int(snapshot["geometry"]["static_meshes"])
	var interactions: Array = world.interactables.duplicate()
	var rng_state: int = world.rng.state
	var floor30: Node = world.get_node("Floor30")
	_check(_static_meshes(floor30) > 20, "Restaurant slabs and furnishings are absent from fixed GI.")
	for branch: Node in [world.twin_tower, world.route_obstacle, world.dust_group, world.crack_group,
		world.broken_connection, world.emergency_group, world.roof_medical_group, world.continuation_visuals,
		world.continuation_access_cover, world.atmosphere, world.get_node("water")]:
		_check(_static_meshes(branch) == 0, "Dynamic branch was baked: " + str(branch.name))
	for aircraft: Node in world.helicopters:
		_check(_static_meshes(aircraft) == 0, "Aircraft fuselage/rotors were baked into a stationary silhouette.")
	for person: Node in world.alpha_roof_members + world.bravo_roof_members + world.bravo_members:
		_check(_static_meshes(person) == 0, "An articulated person contributes static GI.")
	for pane: Node in world.breakable_glass:
		_check(_static_meshes(pane) == 0, "A shattered glazing coat could leave a GI ghost.")
	var all_glazing: Array[Node] = world.find_children("ExteriorGlazing", "MeshInstance3D", true, false)
	_check(all_glazing.size() == 96, "Lighting changed the eight-floor glazing layout.")
	for pane: Node in all_glazing:
		_check(pane.gi_mode == GeometryInstance3D.GI_MODE_DISABLED, "A one-sided exterior coat blocks the interior GI as opaque glass.")
	_check(world.get_node("StormLight").light_bake_mode == Light3D.BAKE_DYNAMIC, "Changing storm light was baked as static.")
	_check(floor30.get_node("CeilingFillEast").light_bake_mode == Light3D.BAKE_STATIC, "Fixed practical lights lost their static contribution.")
	_check(world.get_node("Floor29/CeilingFillEast").light_bake_mode == Light3D.BAKE_DYNAMIC, "A lamp dimmed by the incident was baked as static.")
	_check(_baked_lights(world.twin_tower) == 0, "Moving Hesperie lamps leave indirect light behind.")
	var practicals: Array[Node] = world.find_children("Practical*", "SpotLight3D", true, false)
	_check(practicals.size() == 16, "Each playable floor must retain two bounded local practicals.")
	for practical: SpotLight3D in practicals:
		_check(practical.distance_fade_enabled and practical.distance_fade_shadow < practical.distance_fade_begin, "Local shadows have no conservative distance budget.")
		_check((-practical.global_basis.z).dot(Vector3.DOWN) > 0.99, "A ceiling practical points away from the floor.")
	var initial_revision: int = int(snapshot["static_revision"])
	for incident: Array in [["quake", 2.0], ["collapse", 4.0], ["impact", 1.0], ["aftermath", 0.0]]:
		world.apply_incident(incident[0], incident[1])
		var inventory: Dictionary = Lighting.geometry_inventory(world)
		_check(inventory["static_meshes"] == static_count and inventory["moving_static_violations"] == 0, "Incident sampling changed static contributors or baked a mover.")
	_check(int(world.lighting_snapshot()["static_revision"]) == initial_revision + 1, "Stable aftermath must request exactly one GI refresh.")
	world.apply_incident("aftermath", 0.0)
	_check(int(world.lighting_snapshot()["static_revision"]) == initial_revision + 1, "A repeated stable incident sample invalidates GI every frame.")
	for practical: SpotLight3D in world.affected_practicals:
		_check(is_equal_approx(practical.light_energy, 0.48), "After-impact local practicals do not match the dimmed interior.")
	world.apply_incident("intact", 0.0)
	_check(int(world.lighting_snapshot()["static_revision"]) == initial_revision + 2, "Restoring intact state did not reconcile the GI cache.")
	var portable: Dictionary = world.set_lighting_profile("portable")
	for effect: String in ["sdfgi", "ssil", "ssr", "ssao", "volumetric_fog", "glow"]:
		_check(not portable[effect], "Portable profile still enables unsupported effect: " + effect)
	var shadow_count: int = 0
	for practical: SpotLight3D in practicals:
		shadow_count += 1 if practical.shadow_enabled else 0
	_check(shadow_count == 8, "Portable profile must retain one shadowed local practical per floor.")
	var requested: Dictionary = world.set_lighting_profile("cinematic")
	_check(requested["sdfgi"] == bool(actual["native_forward_plus"]), "Requested cinematic profile ignored actual API capability.")
	if not actual["native_forward_plus"]:
		_check(not str(requested["fallback_reason"]).is_empty(), "An unsupported cinematic request silently claimed success.")
	# Imported or attached tools can arrive after the initial static scan.
	var actor: Node3D = Node3D.new()
	actor.name = "LateMovingTool"
	world.add_child(actor)
	var moving_mesh: MeshInstance3D = world._box(actor, Vector3.ZERO, Vector3.ONE, world.materials["metal"])
	moving_mesh.gi_mode = GeometryInstance3D.GI_MODE_STATIC
	var lamp: OmniLight3D = world._light(actor, Vector3.ZERO, Color.WHITE, 2.0, 5.0)
	world.mark_dynamic_lighting_branch(actor)
	_check(moving_mesh.gi_mode == GeometryInstance3D.GI_MODE_DISABLED and lamp.light_bake_mode == Light3D.BAKE_DISABLED, "Registering a late moving prop did not remove all static contributions.")
	_check(is_zero_approx(lamp.light_indirect_energy) and is_equal_approx(lamp.light_energy, 2.0), "Excluding a moving lamp altered its direct illumination.")
	_check(not moving_mesh.material_override.uv1_world_triplanar, "Moving textured prop retains swimming world-space UVs.")
	var added_later: MeshInstance3D = world._box(actor, Vector3.ONE, Vector3.ONE, world.materials["wood"])
	_check(added_later.gi_mode == GeometryInstance3D.GI_MODE_DISABLED and not added_later.material_override.uv1_world_triplanar, "A later child ignored its moving ancestor.")
	_check(world.interactables == interactions and world.rng.state == rng_state, "Lighting changed gameplay interactions or consumed procedural world RNG.")
	world.free()
	_finish()

func _static_meshes(branch: Node) -> int:
	if not is_instance_valid(branch):
		return 0
	return int(Lighting.geometry_inventory(branch)["static_meshes"])

func _baked_lights(branch: Node) -> int:
	var count: int = 1 if branch is Light3D and branch.light_bake_mode != Light3D.BAKE_DISABLED else 0
	for child: Node in branch.get_children():
		count += _baked_lights(child)
	return count

func _check(condition: bool, message: String) -> void:
	checks += 1
	if not condition:
		failures.append(message)

func _finish() -> void:
	if failures.is_empty():
		print("PASS lighting v0.11: %d checks; actual renderer fallback, fixed GI, moving exclusions, bounded practicals and stable impact refresh." % checks)
		quit(0)
	else:
		for failure: String in failures:
			push_error(failure)
		quit(1)
