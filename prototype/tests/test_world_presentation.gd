extends SceneTree
## Native visual models and reconstructible arrival poses must preserve gameplay.
const WorldScript = preload("res://scripts/world_builder.gd")
const Generator = preload("res://scripts/floor_generator.gd")
var checks: int = 0
var failures: Array[String] = []

func _initialize() -> void:
	_run.call_deferred()

func _run() -> void:
	var world = WorldScript.new()
	root.add_child(world)
	world.build(47, Generator.generate(47))
	world.set_process(false)
	var collision_count: int = _collision_count(world)
	var interaction_count: int = world.interactables.size()
	var node_count: int = _node_count(world)
	var rest: Array = _poses(world)
	_check(world.helicopters.size() == 2 and world.alpha_roof_members.size() == 3 and world.bravo_roof_members.size() == 3, "Arrival must reuse exactly two aircraft and the six existing roof members.")
	for aircraft: Node3D in world.helicopters:
		_check(aircraft.get_parent() == world, "An aircraft is attached to the moving twin tower.")
		_check(aircraft.has_node("DoorLeft") and aircraft.has_node("DoorRight") and aircraft.has_node("Rotor") and aircraft.has_node("TailRotor"), "An aircraft lacks a named articulation.")
		_check(_collision_count(aircraft) == 0, "Aircraft presentation introduced collision.")
		for skid_name in ["SkidLeft", "SkidRight"]:
			var skid: MeshInstance3D = aircraft.get_node(skid_name)
			var bounds: AABB = skid.global_transform * skid.mesh.get_aabb()
			_check(absf(bounds.position.y - 42.0) < 0.02, "Landing skid does not touch its roof: %s/%s" % [aircraft.name, skid_name])
	for member: Node3D in world.alpha_roof_members + world.bravo_roof_members:
		_check(member.has_node("LeftLeg") and member.has_node("RightLeg") and member.has_node("LeftArm") and member.has_node("RightArm"), "A deployed figure lacks limb pivots.")
		_check(_collision_count(member) == 0, "Crew presentation introduced collision.")
	for decoration in [world.get_node("RoofCommandPost/RoofRescueEquipment"), world.get_node("NacreSubmergedCity/CoastalLandmarks")]:
		_check(_collision_count(decoration) == 0, "Decorative equipment introduced collision.")
	var entry: Dictionary = _sample(0.0, 0.0)
	entry["aircraft"][0]["offset"] = Vector3(-14, 28, 95)
	entry["aircraft"][1]["offset"] = Vector3(18, 24, 120)
	world.apply_arrival_staging(entry)
	_check(world.helicopters[0].global_position.is_equal_approx(world.helicopter_origins[0] + Vector3(-14, 28, 95)), "Alpha offset is not relative to its original world landing position.")
	_check(world.helicopters[1].global_position.is_equal_approx(world.helicopter_origins[1] + Vector3(18, 24, 120)), "Bravo offset is not relative to its original world landing position.")
	for member: Node3D in world.alpha_roof_members + world.bravo_roof_members:
		_check(not member.visible, "A roof crew member is already on the roof before disembarkation.")
	world.apply_arrival_staging(_sample(0.56, 19.8))
	var mid: Array = _poses(world)
	world.apply_arrival_staging(_sample(0.2, 17.0))
	world.apply_arrival_staging(_sample(0.56, 19.8))
	_check(_same_poses(mid, _poses(world)), "Seeking the same arrival sample changes its pose.")
	_check(absf(world.alpha_roof_members[0].get_node("LeftLeg").rotation.x) > 0.02, "Crew root moves without an articulated walking pose.")
	for wash: MeshInstance3D in world.arrival_wash:
		_check(wash.visible and is_equal_approx(float(wash.material_override.get_shader_parameter("strength")), 0.7), "Rotor wash did not sample the authored strength.")
	for index in range(81):
		world.apply_arrival_staging(_sample(float(index) / 80.0, 16.0 + index * 0.09))
		for member: Node3D in world.alpha_roof_members:
			var p: Vector3 = member.global_position
			_check(not (absf(p.x) < 2.75 and absf(p.z) < 2.75), "Alpha's deployment route crosses the open rope shaft.")
			_check(p.y >= 41.99, "A disembarking member sinks below the roof.")
	world.restore_arrival_staging()
	_check(_same_poses(rest, _poses(world)), "End/skip restoration differs from a fresh roof build.")
	world.restore_arrival_staging()
	_check(_same_poses(rest, _poses(world)), "Repeated restoration changes the ready pose.")
	for wash: MeshInstance3D in world.arrival_wash:
		_check(not wash.visible and is_zero_approx(float(wash.material_override.get_shader_parameter("strength"))), "Rotor wash survives cinematic handoff.")
	world.sample_aircraft_rotors(2.75)
	var main_rotor: Transform3D = world.rotors[0].transform
	var tail_rotor: Transform3D = world.helicopters[0].get_node("TailRotor").transform
	world.sample_aircraft_rotors(9.0)
	world.sample_aircraft_rotors(2.75)
	_check(main_rotor.is_equal_approx(world.rotors[0].transform) and tail_rotor.is_equal_approx(world.helicopters[0].get_node("TailRotor").transform), "Rotor sampling accumulates instead of reconstructing.")
	for incident in [["warning", 5.0], ["quake", 4.0], ["aftermath", 0.0]]:
		world.apply_incident(incident[0], incident[1])
		var incident_pose: Array = _poses(world)
		var tower_transform: Transform3D = world.twin_tower.transform
		world.restore_arrival_staging()
		world.apply_arrival_staging(_sample(0.0, 0.0))
		_check(_same_poses(incident_pose, _poses(world)) and tower_transform.is_equal_approx(world.twin_tower.transform), "Arrival reset rewound the active incident: %s" % incident[0])
	_check(_collision_count(world) == collision_count, "Sampling arrival changed collision objects.")
	_check(world.interactables.size() == interaction_count, "Sampling arrival changed gameplay interactions.")
	_check(_node_count(world) == node_count, "Sampling arrival duplicated or removed presentation nodes.")
	world.free()
	if failures.is_empty():
		print("PASS world presentation: %d checks; grounded aircraft, six articulated crew, deterministic poses, safe deployment and preserved incident." % checks)
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		quit(1)

func _sample(crew: float, time: float) -> Dictionary:
	return {"time": time, "crew": crew, "aircraft": [
		{"offset": Vector3.ZERO, "rotation": Vector3.ZERO, "door": 0.8, "wash": 0.7},
		{"offset": Vector3.ZERO, "rotation": Vector3.ZERO, "door": 0.8, "wash": 0.7}
	]}

func _poses(world: Node3D) -> Array:
	var result: Array = []
	for aircraft: Node3D in world.helicopters:
		result.append([aircraft.transform, aircraft.visible])
		for door_name in ["DoorLeft", "DoorRight"]:
			var door: Node3D = aircraft.get_node(door_name)
			result.append([door.transform, door.visible])
	for member: Node3D in world.alpha_roof_members + world.bravo_roof_members + world.bravo_members:
		result.append([member.transform, member.visible])
		for pivot in ["LeftLeg", "RightLeg", "LeftArm", "RightArm"]:
			var limb: Node3D = member.get_node(pivot)
			result.append([limb.transform, limb.visible])
	result.append([world.bravo_gallery.transform, world.bravo_gallery.visible])
	result.append([world.bravo_roof_team.transform, world.bravo_roof_team.visible])
	return result

func _same_poses(a: Array, b: Array) -> bool:
	if a.size() != b.size():
		return false
	for index in range(a.size()):
		if not (a[index][0] as Transform3D).is_equal_approx(b[index][0]) or a[index][1] != b[index][1]:
			return false
	return true

func _collision_count(node: Node) -> int:
	var count: int = 1 if node is CollisionObject3D or node is CollisionShape3D else 0
	for child in node.get_children():
		count += _collision_count(child)
	return count

func _node_count(node: Node) -> int:
	var count: int = 1
	for child in node.get_children():
		count += _node_count(child)
	return count

func _check(condition: bool, message: String) -> void:
	checks += 1
	if not condition:
		failures.append(message)
