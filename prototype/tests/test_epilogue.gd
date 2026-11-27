extends SceneTree
## Read-only ending timeline, shared overlay transitions and real-world framing.
const Epilogue = preload("res://scripts/epilogue_director.gd")
const Cinematic = preload("res://scripts/cinematic_director.gd")
const Overlay = preload("res://scripts/cinematic_overlay.gd")
const World = preload("res://scripts/world_builder.gd")
const Generator = preload("res://scripts/floor_generator.gd")
var failures: Array[String] = []
var checks: int = 0

func _initialize() -> void:
	_run.call_deferred()

func _run() -> void:
	_test_clock()
	_test_sampling()
	_test_transmissions()
	await _test_overlay()
	await _test_world_framing()
	if failures.is_empty():
		print("PASS epilogue: %d checks; three absolute shots, honest relay excerpts, skip/replay, reduced motion, overlay reset and real scene framing." % checks)
		quit(0)
	else:
		for failure: String in failures:
			push_error(failure)
		print("FAIL epilogue: %d failures / %d checks." % [failures.size(), checks])
		quit(1)

func _test_clock() -> void:
	var director = Epilogue.new()
	director.advance(2.0)
	_check(not director.active and director.elapsed == 0.0, "An unstarted epilogue advanced its clock.")
	director.start()
	_check(director.active and director.duration() == 15.0, "Epilogue did not start its fifteen-second sequence.")
	director.advance(2.25)
	var frozen: Dictionary = director.presentation()
	for invalid: float in [0.0, -1.0, NAN, INF, -INF]:
		director.advance(invalid)
		_check(director.elapsed == 2.25 and director.presentation() == frozen, "Zero or invalid delta changed the ending clock.")
	director.advance(1000.0)
	_check(not director.active and director.elapsed == 15.0 and director.presentation()["progress"] == 1.0, "A long frame overran the ending.")
	_check(str(director.transmission()["message"]).is_empty(), "The finished ending retained a subtitle.")
	director.advance(1000.0)
	_check(director.elapsed == 15.0, "A completed ending continued advancing.")
	for skip_at: float in [0.0, 2.5, 5.0, 9.9, 14.9]:
		director.start()
		director.advance(skip_at)
		director.finish()
		var finished: Dictionary = director.presentation()
		director.finish()
		_check(not director.active and director.elapsed == 15.0 and finished == director.presentation(), "Skip was not final and idempotent.")
		_check(str(finished["speaker"]).is_empty() and str(finished["message"]).is_empty(), "Skip displayed an unseen future transmission.")
	director.start()
	_check(director.elapsed == 0.0 and director.active and director.presentation()["shot"] == 0, "Replay failed to reset the completed sequence.")
	for sample: Array in [[4.999, 0], [5.0, 1], [9.999, 1], [10.0, 2], [15.0, 2]]:
		director.elapsed = float(sample[0])
		_check(int(director.presentation()["shot"]) == int(sample[1]), "A shot changed on the wrong boundary at %s." % sample[0])
	for value: float in [-100.0, 0.0, 4.99, 5.0, 10.0, 15.0, 1.0e20, -INF, INF, NAN]:
		director.elapsed = value
		var frame: Dictionary = director.presentation()
		for key: String in ["alpha", "fade", "progress"]:
			var scalar: float = float(frame[key])
			_check(is_finite(scalar) and scalar >= 0.0 and scalar <= 1.0, "Out-of-range timeline produced invalid %s." % key)
		_check(int(frame["shot"]) >= 0 and int(frame["shot"]) < 3, "Invalid clock selected an unbuilt shot.")
		_check(_valid_camera(director.camera_sample()), "Invalid clock poisoned a camera pose.")

func _test_sampling() -> void:
	var direct = Epilogue.new()
	var partitioned = Epilogue.new()
	for moment: float in [2.5, 5.0, 7.5, 10.0, 12.5, 15.0]:
		direct.start()
		partitioned.start()
		direct.advance(moment)
		for frame in range(int(moment * 8.0)):
			partitioned.advance(0.125)
		_check(direct.presentation() == partitioned.presentation() and direct.camera_sample() == partitioned.camera_sample(), "Frame partitioning changed the absolute ending at %s." % moment)
		_check(direct.presentation() == direct.presentation() and direct.camera_sample() == direct.camera_sample(), "Sampling alone changed a frozen sequence.")
	for shot in range(3):
		direct.elapsed = float(shot) * 5.0 + 0.8
		var fixed: Dictionary = direct.camera_sample(true)
		var moving: Dictionary = direct.camera_sample(false)
		direct.elapsed += 3.4
		_check(direct.camera_sample(true) == fixed, "Reduced-motion camera drifts within shot %d." % shot)
		_check(direct.camera_sample(false) != moving, "Regular shot %d lost its sampled movement." % shot)
		_check(_valid_camera(fixed), "Shot %d has an invalid look-at or field of view." % shot)
		var end: Vector3 = direct.camera_sample(false)["position"]
		_check(end.distance_to(moving["position"]) < 6.0, "A slow epilogue shot contains an excessive camera jump.")
	for boundary: float in [5.0, 10.0]:
		direct.elapsed = boundary
		_check(direct.presentation()["fade"] == 1.0 and direct.presentation()["alpha"] == 0.0, "A shot cut occurs outside its black transition.")
		direct.elapsed = boundary - 0.01
		var before: float = float(direct.presentation()["fade"])
		direct.elapsed = boundary + 0.01
		_check(is_equal_approx(float(direct.presentation()["fade"]), before), "Black transition is discontinuous across the cut.")
	_check(_valid_camera(Epilogue.debrief_camera()), "Debrief has no valid fixed refuge camera.")

func _test_transmissions() -> void:
	var director = Epilogue.new()
	director.start()
	_check(str(director.transmission()["message"]).is_empty(), "An opening cue appears before the fade.")
	for interval: Array in [[0.45, 4.7], [5.4, 9.7], [10.4, 14.7]]:
		director.elapsed = float(interval[0]) - 0.0001
		_check(str(director.transmission()["message"]).is_empty(), "A relay excerpt appears before its readable interval.")
		director.elapsed = float(interval[0])
		var cue: Dictionary = director.transmission()
		_check(not str(cue["message"]).is_empty() and not str(cue["speaker"]).is_empty(), "A subtitle fails to appear at its exact cue time.")
		director.elapsed = float(interval[1])
		_check(str(director.transmission()["message"]).is_empty(), "A subtitle overlaps the next black transition.")
	director.start()
	director.advance(12.5)
	var last_cue: Dictionary = director.transmission()
	_check(str(last_cue["speaker"]).contains("ORIGINE NON CONFIRMÉE") and str(last_cue["message"]).contains("au 24"), "Final signal lost its uncertainty or source wording.")
	_check(director.presentation()["message"] == last_cue["message"], "Overlay frame and directly sampled subtitle disagree.")
	last_cue["message"] = "changed externally"
	_check(director.transmission()["message"] != "changed externally", "A caller can mutate the authored relay text.")
	var latest: Dictionary = director.transmission()
	director.start()
	director.elapsed = 12.5
	_check(director.transmission() == latest, "Replay depends on previously emitted cues.")
	director.elapsed = 7.5
	_check(str(director.transmission()["message"]).contains("baie Est"), "Seeking backwards fails to recover the preceding relay fragment.")

func _test_overlay() -> void:
	var overlay = Overlay.new()
	root.add_child(overlay)
	var ending = Epilogue.new()
	ending.elapsed = 12.5
	overlay.set_frame(ending.presentation(), "epilogue")
	_check(overlay.radio_text.text.contains("au 24") and overlay.skip_button.text.contains("BILAN"), "Ending overlay lost its current subtitle or debrief action.")
	_check(overlay.title.horizontal_alignment == HORIZONTAL_ALIGNMENT_LEFT and overlay.progress.value > 80.0, "Ending overlay lost its readable scenic layout.")
	ending.elapsed = 10.0
	overlay.set_frame(ending.presentation(), "epilogue")
	_check(overlay.transition_veil.color.a == 1.0 and overlay.radio_text.text.is_empty(), "Cut retained an obsolete subtitle or exposed an unmasked camera jump.")
	var intro = Cinematic.new()
	intro.start("boot")
	intro.advance(11.0)
	overlay.set_frame(intro.presentation(), "boot")
	_check(overlay.transition_veil.color.a == 0.0 and overlay.skip_button.text.begins_with("PASSER"), "Epilogue transition or skip text leaked into the startup signature.")
	_check(overlay.radio_text.text.is_empty() and overlay.title.horizontal_alignment == HORIZONTAL_ALIGNMENT_CENTER, "Boot inherited an ending subtitle or left-aligned title.")
	overlay.set_frame(ending.presentation(), "epilogue")
	intro.start("arrival")
	intro.advance(3.0)
	overlay.set_frame(intro.presentation(), "arrival")
	_check(overlay.transition_veil.color.a == 0.0 and overlay.radio_text.text.is_empty(), "Arrival inherited the closing fade or relay dialogue.")
	overlay.set_transmission("ALPHA", "Liaison d’approche")
	intro.advance(0.5)
	overlay.set_frame(intro.presentation(), "arrival")
	_check(overlay.radio_text.text == "Liaison d’approche", "A normal arrival frame erased its separately managed radio cue.")
	_check(overlay.title.get_theme_constant("line_spacing") == 0 and overlay.skip_button.size.x == 256.0, "Scenic title or skip geometry was not restored after the boot title.")
	overlay.free()
	await process_frame

func _test_world_framing() -> void:
	var world = World.new()
	root.add_child(world)
	var data: Dictionary = world.build(271104, Generator.generate(271104))
	world.set_process(false)
	world.set_rescued_people(["survivor_30", "survivor_28", "survivor_26"])
	world.apply_incident("aftermath", 0.0)
	var viewport: SubViewport = SubViewport.new()
	viewport.size = Vector2i(1440, 900)
	root.add_child(viewport)
	viewport.world_3d = world.get_world_3d()
	var camera: Camera3D = Camera3D.new()
	viewport.add_child(camera)
	camera.cull_mask = 1
	camera.current = true
	var director = Epilogue.new()
	var relay: Node3D
	for object: Node3D in data["interactables"]:
		if object.get_meta("kind", "") == "refuge":
			relay = object
	_check(is_instance_valid(relay), "The real refuge relay is missing from the world.")
	await physics_frame
	await process_frame
	var original_clock: float = world.elapsed
	var original_twin: Transform3D = world.twin_tower.transform
	var original_count: int = data["interactables"].size()
	for moment: float in [0.7, 2.5, 4.3, 5.7, 7.5, 9.3, 10.7, 12.5, 14.3]:
		director.elapsed = moment
		var sample: Dictionary = director.camera_sample()
		camera.position = sample["position"]
		camera.fov = float(sample["fov"])
		camera.look_at(sample["target"])
		if moment < 5.0:
			for person: Node3D in world.roof_rescued_people.values():
				var subject: Vector3 = person.global_position + Vector3(0, 1.0, 0)
				_check(person.visible and _inside_picture(camera, subject), "The medical shot loses a confirmed rescued person.")
				var obstruction: String = _opaque_obstruction(world, camera.global_position, subject, person)
				_check(obstruction.is_empty(), "The medical shot hides %s behind %s at %.1f seconds." % [person.name, obstruction, moment])
		elif moment < 10.0 and is_instance_valid(relay):
			var screen: Vector3 = relay.global_position + Vector3(0, 1.2, 0.49)
			_check(_inside_picture(camera, screen), "The relay shot misses the real terminal screen.")
			var obstruction: String = _opaque_obstruction(world, camera.global_position, screen, relay)
			_check(obstruction.is_empty(), "The relay screen is blocked by %s at %.1f seconds." % [obstruction, moment])
			_check(camera.position.y > 6.3 and camera.position.y < 11.0 and camera.position.x < 11.5 and camera.position.z < 11.5, "The relay camera escaped the existing refuge room.")
		else:
			_check(_inside_picture(camera, world.twin_tower.to_global(Vector3(0, 177.0, 0))) and _inside_picture(camera, Vector3(0, 31, 0)), "Exterior shot loses one of the two settled towers.")
	_check((world.roof_medical_sign.layers & camera.cull_mask) == 0, "The medical status billboard leaks into the cinematic layer.")
	_check(world.elapsed == original_clock and world.twin_tower.transform == original_twin and data["interactables"].size() == original_count, "Sampling the ending changed world time, damage or playable objects.")
	viewport.free()
	world.free()
	await process_frame

func _inside_picture(camera: Camera3D, point: Vector3) -> bool:
	if camera.is_position_behind(point):
		return false
	# Keep subjects inside the letterbox and away from the screen edges.
	return Rect2(80, 245, 1280, 435).has_point(camera.unproject_position(point))

func _opaque_obstruction(node: Node, from: Vector3, to: Vector3, subject: Node3D) -> String:
	# Mesh bounds also catch non-colliding crew/canopy props. The subject's own
	# clothes are intentionally excluded; translucent glass and rain can remain.
	if node == subject:
		return ""
	if node is MeshInstance3D and node.is_visible_in_tree() and (node.layers & 1) != 0:
		var material: Material = node.material_override
		var translucent: bool = material is StandardMaterial3D and material.transparency != BaseMaterial3D.TRANSPARENCY_DISABLED
		if not translucent:
			var local_from: Vector3 = node.to_local(from)
			var local_to: Vector3 = node.to_local(to)
			if node.get_aabb().intersects_segment(local_from, local_to) != null:
				return str(node.get_path())
	for child: Node in node.get_children():
		var obstruction: String = _opaque_obstruction(child, from, to, subject)
		if not obstruction.is_empty():
			return obstruction
	return ""

func _valid_camera(sample: Dictionary) -> bool:
	var position: Vector3 = sample["position"]
	var target: Vector3 = sample["target"]
	var fov: float = float(sample["fov"])
	return position.is_finite() and target.is_finite() and position.distance_to(target) > 0.1 and is_finite(fov) and fov >= 35.0 and fov <= 80.0

func _check(condition: bool, message: String) -> void:
	checks += 1
	if not condition:
		failures.append(message)
