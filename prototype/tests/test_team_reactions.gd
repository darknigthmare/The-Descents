extends SceneTree
## Reconstructible visual reactions must never change routes or rescue truth.
## Run: godot --headless --path prototype --script tests/test_team_reactions.gd
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
	_check(world.bravo_members.size() == 2 and world.bravo_roof_members.size() == 3, "Both Bravo groups must be built.")
	_check(_visible_rescues(world) == 0, "A new game must start with no rescued figures.")
	_check(_collision_count(world.roof_medical_group) == 0, "Reception introduced collision.")
	_check(_collision_count(world.bravo_gallery) == 0 and _collision_count(world.bravo_roof_team) == 0, "Bravo presentation introduced collision.")
	var initial: Array = _poses(world)
	world.apply_incident("warning", 5.0)
	_check(not _same_poses(initial, _poses(world)), "Warning must visibly turn and start sheltering Bravo.")
	world.apply_incident("warning", 8.0)
	var boundary: Array = _poses(world)
	world.apply_incident("quake", 0.0)
	_check(_same_poses(boundary, _poses(world)), "Warning/quake boundary teleports Bravo.")
	world.apply_incident("quake", 6.0)
	boundary = _poses(world)
	_check(world.bravo_members[0].position.x > 1.0, "Gallery team failed to move toward the interior.")
	_check(world.bravo_roof_members[0].position.distance_to(Vector3(5, 186, -5.8)) < 4.0, "Roof team failed to approach its service core.")
	world.apply_incident("collapse", 0.0)
	_check(_same_poses(boundary, _poses(world)), "Quake/collapse boundary teleports Bravo.")
	world.apply_incident("collapse", 2.2)
	_check(not world.bravo_members[0].visible and not world.bravo_roof_members[0].visible, "Sheltered Bravo remains exposed.")
	for sample in [["warning", 3.0], ["quake", 4.0], ["collapse", 1.0], ["aftermath", 0.0]]:
		world.apply_incident(sample[0], sample[1])
		var expected: Array = _poses(world)
		world.apply_incident("intact", 0.0)
		world.apply_incident(sample[0], sample[1])
		_check(_same_poses(expected, _poses(world)), "Direct phase restore changed Bravo pose: %s" % sample[0])
	world.apply_incident("intact", 0.0)
	_check(_same_poses(initial, _poses(world)), "A new incident did not restore the initial team.")
	world.set_rescued_people(["survivor_30", "survivor_30", "unknown"])
	_check(_visible_rescues(world) == 1 and world.roof_rescued_people["survivor_30"].visible, "Reception must deduplicate and ignore unknown IDs.")
	_check(world.roof_medical_sign.text.contains("1 SUR 3"), "The reception count disagrees with the registry.")
	var child_count: int = world.roof_medical_group.get_child_count()
	world.set_rescued_people(["survivor_30", "survivor_28", "survivor_26"])
	world.set_rescued_people(["survivor_26", "survivor_30", "survivor_28", "survivor_28"])
	_check(_visible_rescues(world) == 3 and world.roof_medical_sign.text.contains("3 SUR 3"), "All three named patients must be shown.")
	_check(world.roof_medical_group.get_child_count() == child_count, "Repeated registry projection created duplicate nodes.")
	for id_value in world.roof_rescued_people:
		var patient: Node3D = world.roof_rescued_people[id_value]
		_check(patient.position.x >= 6.0 and patient.position.z < -8.0, "Medical figure occupies the rope or arrival route: %s" % id_value)
	world.apply_incident("aftermath", 0.0)
	_check(_visible_rescues(world) == 3, "Structural restore erased a confirmed rescue.")
	_check(_collision_count(world) == collision_count, "Reactions changed the number of collision objects.")
	_check(world.interactables.size() == interaction_count, "Cosmetic reception added gameplay interactions.")
	world.set_rescued_people([])
	_check(_visible_rescues(world) == 0 and world.roof_medical_sign.text.contains("0 SUR 3"), "New-game reset retained past rescue figures.")
	_check(world.roof_medical_group.get_child_count() == child_count, "Reset rebuilt or removed the presentation nodes.")
	world.free()
	if failures.is_empty():
		print("PASS team reactions: %d checks; phase continuity, direct restoration, named reception, idempotence and collision-free presentation." % checks)
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		quit(1)

func _poses(world: Node3D) -> Array:
	var result: Array = []
	for member: Node3D in world.bravo_members + world.bravo_roof_members:
		result.append([member.transform, member.visible])
	result.append([world.bravo_gallery.visible, world.bravo_roof_team.visible])
	return result

func _same_poses(a: Array, b: Array) -> bool:
	if a.size() != b.size():
		return false
	for index in range(a.size() - 1):
		if not (a[index][0] as Transform3D).is_equal_approx(b[index][0]) or a[index][1] != b[index][1]:
			return false
	return a.back() == b.back()

func _visible_rescues(world: Node3D) -> int:
	var count: int = 0
	for patient: Node3D in world.roof_rescued_people.values():
		if patient.visible:
			count += 1
	return count

func _collision_count(node: Node) -> int:
	var count: int = 1 if node is CollisionObject3D or node is CollisionShape3D else 0
	for child in node.get_children():
		count += _collision_count(child)
	return count

func _check(condition: bool, message: String) -> void:
	checks += 1
	if not condition:
		failures.append(message)
