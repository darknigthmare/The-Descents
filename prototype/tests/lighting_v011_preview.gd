extends Node3D
## Native comparison of the same real world and cameras under each renderer.
## Prepared visual states, not a claim of human gameplay or Windows testing.
const World = preload("res://scripts/world_builder.gd")
const Generator = preload("res://scripts/floor_generator.gd")
const WARMUP_FRAMES: int = 96
var output: String = "res://../docs/captures/v0.11/lighting"
var expected_renderer: String = ""
var requested_profile: String = "auto"
var world: Node3D
var camera: Camera3D
var shots: Array[Dictionary] = []

func _ready() -> void:
	_capture.call_deferred()

func _capture() -> void:
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with("--capture-root="):
			output = argument.trim_prefix("--capture-root=")
		elif argument.begins_with("--expected-renderer="):
			expected_renderer = argument.trim_prefix("--expected-renderer=")
		elif argument.begins_with("--lighting-profile="):
			requested_profile = argument.trim_prefix("--lighting-profile=")
	var method: String = RenderingServer.get_current_rendering_method()
	if DisplayServer.get_name() == "headless" or (not expected_renderer.is_empty() and method != expected_renderer):
		push_error("Lighting review requires a real native renderer matching --expected-renderer; actual=" + method + "/" + DisplayServer.get_name())
		get_tree().quit(1)
		return
	if DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(output)) != OK:
		push_error("Cannot create lighting capture directory.")
		get_tree().quit(1)
		return
	world = World.new()
	world.requested_lighting_profile = requested_profile
	add_child(world)
	world.build(271104, Generator.generate(271104), true)
	world.set_process(false)
	world.set_reduced_motion(true)
	world.sample_aircraft_rotors(0.0)
	world.atmosphere.sample_world(0.0, "intact", true)
	camera = Camera3D.new()
	camera.fov = 71.0
	camera.near = 0.08
	camera.far = 800.0
	camera.cull_mask = 1
	add_child(camera)
	camera.current = true
	if not await _shot("01_roof_rescue", Vector3(11.0, 44.0, 4.0), Vector3(-4.4, 43.3, -5.6), "Poste de secours sur le toit, béton salin et éclairage de tempête"):
		return
	if not await _shot("02_restaurant_materials", Vector3(-8.7, 37.65, 3.8), Vector3(-6.2, 37.1, -6.5), "Restaurant 30 : pierre, bois fumé et luminaires chauds avec ombres locales"):
		return
	if not await _shot("03_congress_lighting", Vector3(4.0, 1.65, -3.4), Vector3(7.4, 1.8, 7.5), "Congrès 24 : moquette, scène et trajet de service sous éclairage froid"):
		return
	world.apply_incident("aftermath", 0.0)
	if not await _shot("04_archive_after_impact", Vector3(4.2, 25.65, -1.0), Vector3(8.0, 25.2, -6.5), "Archives 28 après impact : lumière de secours et Hespérie exclue du calcul statique"):
		return
	var manifest: Dictionary = {"version": ProjectSettings.get_setting("application/config/version"),
		"engine": Engine.get_version_info().get("string"), "display": DisplayServer.get_name(),
		"rendering_method": method, "prepared_states": true, "human_playthrough": false,
		"warmup_frames": WARMUP_FRAMES, "lighting": world.lighting_snapshot(), "captures": shots}
	var file: FileAccess = FileAccess.open(output.path_join("MANIFEST.json"), FileAccess.WRITE)
	if file == null:
		push_error("Cannot write native lighting manifest.")
		get_tree().quit(1)
		return
	file.store_string(JSON.stringify(manifest, "\t"))
	file.close()
	world.free()
	print("PASS visual lighting v0.11: %d native Godot captures; renderer=%s; warmup=%d frames per view" % [shots.size(), method, WARMUP_FRAMES])
	get_tree().quit(0)

func _shot(name_value: String, position_value: Vector3, target: Vector3, description: String) -> bool:
	camera.global_position = position_value
	camera.look_at(target)
	# Convergence must happen at the actual camera location, not only on load.
	for frame in range(WARMUP_FRAMES):
		await get_tree().process_frame
		await RenderingServer.frame_post_draw
	var state: Dictionary = world.lighting_snapshot()
	if state["geometry"]["moving_static_violations"] != 0 or state["refresh_pending"]:
		push_error("Native capture has stale moving GI or an unfinished cache refresh.")
		get_tree().quit(1)
		return false
	if RenderingServer.get_current_rendering_method() == "forward_plus" and requested_profile != "portable" and not state["sdfgi"]:
		push_error("Forward+ capture did not actually enable the cinematic GI profile.")
		get_tree().quit(1)
		return false
	var captured: Image = get_viewport().get_texture().get_image()
	var path: String = output.path_join(name_value + ".png")
	if captured == null or captured.save_png(path) != OK:
		push_error("Failed native lighting capture: " + name_value)
		get_tree().quit(1)
		return false
	shots.append({"file": name_value + ".png", "description": description,
		"width": captured.get_width(), "height": captured.get_height(), "sha256": FileAccess.get_sha256(path),
		"warmup_frames": WARMUP_FRAMES, "camera_position": [position_value.x, position_value.y, position_value.z],
		"camera_target": [target.x, target.y, target.z], "lighting": state})
	print("CAPTURE " + name_value + " renderer=" + str(state["rendering_method"]))
	return true
