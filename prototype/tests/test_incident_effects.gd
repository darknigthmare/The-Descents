extends SceneTree
## Regression coverage for dust settling, pause and restoration after the impact.
## Run: godot --headless --path prototype --script tests/test_incident_effects.gd
const MainScene = preload("res://scenes/main.tscn")
var checks: int = 0
var failures: Array[String] = []

func _initialize() -> void:
	_run.call_deferred()

func _run() -> void:
	var mission: Node3D = MainScene.instantiate()
	mission.save_path = "user://qa_cosmetic_settling_unused.json"
	mission.preferences_path = "user://qa_cosmetic_settling_preferences.cfg"
	mission.sound_enabled = false
	root.add_child(mission)
	mission.set_process(false)
	mission.player.set_physics_process(false)
	var world: Node3D = mission.world
	world.set_process(false)
	var glazing: Array[Node] = world.find_children("ExteriorGlazing", "MeshInstance3D", true, false)
	_test_exterior_glazing(glazing)
	_test_lower_shell(world)
	_check(not world.dust_group.visible, "Initial dust must be absent.")
	_check(world.hesperie_sign.visible, "The intact sign must remain visible.")
	world.apply_incident("impact", 1.2)
	_check(world.dust_group.visible, "Impact must create dust.")
	_check(not world.hesperie_sign.visible, "The sign must be removed at impact.")
	world.apply_incident("aftermath", 0.0)
	_check(_visible_glazing(glazing) == 66, "After impact must remove exactly the six damaged exterior panes, retaining the other sixty-six.")
	var damaged_hidden: bool = world.breakable_glass.size() == 6
	for pane: MeshInstance3D in world.breakable_glass:
		damaged_hidden = damaged_hidden and not pane.get_node("ExteriorGlazing").is_visible_in_tree()
	_check(damaged_hidden, "Exterior coating outlived its shattered east pane on floors 29/28.")
	_check(world.dust_group.visible and is_zero_approx(world.aftermath_dust_elapsed), "A witnessed impact must start its settling tail.")
	var pose: Transform3D = world.twin_tower.transform
	world._process(4.0)
	_check(is_equal_approx(world.aftermath_dust_elapsed, 4.0) and world.dust_group.scale.x < 1.15, "Cosmetic dust must advance and shrink.")
	world.apply_incident("aftermath", 0.0)
	_check(is_equal_approx(world.aftermath_dust_elapsed, 4.0), "Stable director samples must not reset the cosmetic timer.")
	_check(world.twin_tower.transform.is_equal_approx(pose), "Cosmetic settling changed tower geometry.")
	mission._pause()
	_check(not world.is_processing(), "Pause must disable the world cosmetic clock.")
	var paused_size: Vector3 = world.dust_group.scale
	for index in range(3):
		await process_frame
	_check(is_equal_approx(world.aftermath_dust_elapsed, 4.0) and world.dust_group.scale.is_equal_approx(paused_size), "Dust advanced through a real paused frame.")
	mission._resume()
	_check(world.is_processing(), "Resume must restore cosmetic processing.")
	await process_frame
	await process_frame
	_check(world.aftermath_dust_elapsed > 4.0, "The actual resumed world process did not advance dust.")
	world.set_process(false)
	world._process(10.0)
	_check(is_equal_approx(world.aftermath_dust_elapsed, 10.0) and not world.dust_group.visible, "Dust must disappear after ten active seconds.")
	world.apply_incident("aftermath", 0.0)
	_check(not world.dust_group.visible and world.twin_tower.transform.is_equal_approx(pose), "Settled sampling regenerated dust or changed geometry.")
	world.apply_incident("intact", 0.0)
	_check(_visible_glazing(glazing) == 72, "Restoring the intact building failed to restore its complete exterior glazing.")
	_check(world.hesperie_sign.visible and not world.dust_group.visible, "Reset to intact did not restore sign/dust state.")
	world.apply_incident("aftermath", 0.0)
	_check(not world.dust_group.visible and is_equal_approx(world.aftermath_dust_elapsed, 10.0), "A direct aftermath restore must have no fresh dust cloud.")
	_check(not world.hesperie_sign.visible and world.twin_tower.transform.is_equal_approx(pose), "Restored aftermath sign or geometry differs from the stable state.")
	mission.free()
	if failures.is_empty():
		print("PASS cosmetic settling: %d checks; witnessed impact, stable sampling, real pause/resume frames, ten-second decay, direct restoration, removed sign and one-sided exterior glazing." % checks)
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		quit(1)

func _test_exterior_glazing(glazing: Array[Node]) -> void:
	_check(glazing.size() == 72, "Six playable floors must have twelve exterior glazing surfaces each.")
	var normals_outward: bool = not glazing.is_empty()
	var opaque: bool = true
	var back_culled: bool = true
	var casts_no_shadow: bool = true
	var non_solid: bool = true
	for node: Node in glazing:
		var coating: MeshInstance3D = node
		var pane: Node3D = coating.get_parent()
		var expected: Vector3 = Vector3(signf(pane.position.x), 0, 0) if absf(pane.position.x) > 11.0 else Vector3(0, 0, signf(pane.position.z))
		if not coating.mesh is QuadMesh:
			normals_outward = false
		else:
			var normals: PackedVector3Array = coating.mesh.surface_get_arrays(0)[Mesh.ARRAY_NORMAL]
			normals_outward = normals_outward and not normals.is_empty() and (coating.global_basis * normals[0]).normalized().dot(expected) > 0.999
		var material: BaseMaterial3D = coating.material_override
		opaque = opaque and material != null and material.transparency == BaseMaterial3D.TRANSPARENCY_DISABLED
		back_culled = back_culled and material != null and material.cull_mode == BaseMaterial3D.CULL_BACK
		casts_no_shadow = casts_no_shadow and coating.cast_shadow == GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		non_solid = non_solid and _count_colliders(pane) == 0
	_check(normals_outward, "An exterior quad faces inward, obstructing interior observation while leaving a facade open.")
	_check(opaque, "Exterior glazing is not opaque from outside the tower.")
	_check(back_culled, "Exterior glazing obscures the interior view instead of culling its back face.")
	_check(casts_no_shadow, "Exterior coating introduces an opaque shadow inside the observation bay.")
	_check(non_solid, "Cosmetic exterior glazing introduced a physical collider.")
	_check(_visible_glazing(glazing) == 72, "The intact tower starts with missing exterior panes.")


func _test_lower_shell(world: Node3D) -> void:
	var lower: Node3D = world.get_node("UnplayableLowerTowerFacade")
	var vertical_members: int = 0
	var reaches_playable_floor: bool = true
	for child: Node in lower.get_children():
		if child is MeshInstance3D and child.mesh is BoxMesh and child.mesh.size.y > 100.0:
			vertical_members += 1
			var upper_edge: float = child.position.y + child.mesh.size.y * 0.5
			reaches_playable_floor = reaches_playable_floor and is_equal_approx(upper_edge, float(world.floor_heights[25]))
	_check(vertical_members == 11 and reaches_playable_floor, "The opaque lower facade or one of its ten mullions leaves a gap below the first playable slab.")
	_check(_count_colliders(lower) == 0, "The cosmetic lower facade introduced a collider.")


func _visible_glazing(glazing: Array[Node]) -> int:
	var count: int = 0
	for pane: Node3D in glazing:
		if pane.is_visible_in_tree():
			count += 1
	return count


func _count_colliders(node: Node) -> int:
	var total: int = 1 if node is CollisionObject3D or node is CollisionShape3D else 0
	for child: Node in node.get_children():
		total += _count_colliders(child)
	return total


func _check(condition: bool, message: String) -> void:
	checks += 1
	if not condition:
		failures.append(message)
