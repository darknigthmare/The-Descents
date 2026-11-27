extends Node3D
## Native visual sampling only: this is not a human playthrough or performance test.
## Open visual_incident_preview.tscn and press F6 in Godot.
## All samples use the real Main, world and HUD. A dedicated save path is set
## before Main enters the tree, so the player's actual save is never written.

const Main = preload("res://scripts/main.gd")
const OUTPUT_DIRECTORY: String = "res://tests/visual_output"
const QA_SAVE_PATH: String = "user://qa_visual_incident_v02.json"

var mission: Node3D
var proof_label: Label
var captured_paths: PackedStringArray = []


func _ready() -> void:
	if DisplayServer.get_name() == "headless":
		push_error("Native visual preview requires a graphical Godot run. Open this scene and press F6.")
		return
	_run.call_deferred()


func _run() -> void:
	var output: String = ProjectSettings.globalize_path(OUTPUT_DIRECTORY)
	var directory_error: Error = DirAccess.make_dir_recursive_absolute(output)
	if directory_error != OK:
		push_error("Cannot create visual QA directory: %s (error %d)" % [output, directory_error])
		return
	mission = Main.new()
	mission.name = "VisualSampleOfRealMain"
	mission.save_path = QA_SAVE_PATH
	mission.sound_enabled = false
	mission.reduced_motion = true
	# Disabling this entire branch also disables all normal gameplay input,
	# world ticks and player physics while the explicit samples are prepared.
	mission.process_mode = Node.PROCESS_MODE_DISABLED
	add_child(mission)
	mission.set_process(false)
	mission.set_physics_process(false)
	mission._start_new(271104)
	_freeze_gameplay()
	_make_proof_label()

	mission.arrival_time = 0.0
	mission._process_arrival(3.0)
	mission._update_hud()
	await _capture("01_arrivee", "1 / 7 · Arrivée sur les deux tours")

	mission.arrival_playing = false
	mission.elapsed = 40.0
	mission.intro_stage = 3
	mission.rescued = ["survivor_30"]
	for target: Node3D in mission.world_data.get("interactables", []):
		if str(target.get_meta("id", "")) == "survivor_30":
			target.set_meta("used", true)
			target.hide()
	mission._process_departure()
	_set_view(Vector3(9.8, 30.06, 0), mission.world_data["twin_view_target"])
	_set_phase("intact", 0.0)
	mission._say("BRAVO / HESPÉRIE", "On vous voit à la baie Est. Les deux équipes sont en place.", 12.0, true)
	mission.hud.notify_label.hide()
	await _capture("02_baie_intacte", "2 / 7 · Baie Est avant la réplique")

	_set_phase("quake", 3.0)
	await _capture("03_replique", "3 / 7 · Réplique — 3 secondes")

	_set_phase("collapse", 3.5)
	await _capture("04_basculement", "4 / 7 · Basculement — 3,5 secondes")

	_set_phase("impact", 1.2)
	await _capture("05_impact", "5 / 7 · Impact — 1,2 seconde")

	_set_phase("aftermath", 0.0)
	await _capture("06_apres", "6 / 7 · Façade après l’impact")

	_set_view(Vector3(7, 24.06, 0), Vector3(7, 25.2, -6))
	_set_phase("aftermath", 0.0)
	mission._say("VARGA / DÉTOUR DU 28", "Le passage Est est coupé. Suivez le balisage vers le noyau pour rejoindre Samuel.", 12.0, true)
	mission.hud.notify_label.hide()
	await _capture("07_detour28", "7 / 7 · Passage coupé et détour du 28")

	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	proof_label.text = "CONTRÔLE VISUEL · %d / 7 images enregistrées\nÉtats préparés — aucun parcours humain" % captured_paths.size()
	print(("VISUAL_PREVIEW_COMPLETE: " if captured_paths.size() == 7 else "VISUAL_PREVIEW_INCOMPLETE: ") + output)
	for path: String in captured_paths:
		print("VISUAL_CAPTURE: %s" % path)
	print("QA_SAVE_ISOLATED: %s" % ProjectSettings.globalize_path(QA_SAVE_PATH))
	# Keep the last sample visible for inspection. F8 stops this QA scene.


func _freeze_gameplay() -> void:
	mission.set_process(false)
	mission.set_physics_process(false)
	mission.set_process_unhandled_input(false)
	mission.player.active = false
	mission.player.set_process(false)
	mission.player.set_physics_process(false)
	mission.player.set_process_unhandled_input(false)
	mission.world.set_process(false)
	mission.world.set_physics_process(false)
	mission.audio_wind.stop()
	mission.audio_radio.stop()
	mission.audio_effect.stop()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func _make_proof_label() -> void:
	var layer: CanvasLayer = CanvasLayer.new()
	layer.layer = 100
	add_child(layer)
	proof_label = Label.new()
	proof_label.position = Vector2(550, 31)
	proof_label.size = Vector2(410, 70)
	proof_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	proof_label.add_theme_font_size_override("font_size", 16)
	proof_label.add_theme_color_override("font_color", Color("f5d89e"))
	proof_label.add_theme_color_override("font_shadow_color", Color("101820"))
	proof_label.add_theme_constant_override("shadow_offset_x", 2)
	proof_label.add_theme_constant_override("shadow_offset_y", 2)
	proof_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(proof_label)


func _set_view(feet_position: Vector3, target: Vector3) -> void:
	mission.player.position = feet_position
	mission.player.rotation = Vector3.ZERO
	mission.player.head.position = Vector3(0, 1.62, 0)
	mission.player.head.rotation = Vector3.ZERO
	mission.player.camera.position = Vector3.ZERO
	mission.player.camera.rotation = Vector3.ZERO
	mission.player.head.look_at(target, Vector3.UP)
	mission.player.camera.current = true
	mission.player.velocity = Vector3.ZERO
	mission.player.on_rope = false
	mission.player.rope_mesh.hide()
	mission.player.flashlight.visible = true
	mission.world.set_incident_player_position(mission.player.global_position)


func _set_phase(phase: String, sample_time: float) -> void:
	mission.incident.phase = phase
	mission.incident.phase_elapsed = sample_time
	mission.world.set_incident_player_position(mission.player.global_position)
	mission.world.apply_incident(phase, sample_time)
	mission._on_incident_phase(phase)
	mission._find_nearest()
	mission._update_hud()
	mission.hud.radio_panel.visible = mission.radio_time > 0.0
	_freeze_gameplay()


func _capture(file_stem: String, sample_title: String) -> void:
	proof_label.text = "CONTRÔLE VISUEL · État préparé\n" + sample_title
	# Wait for deferred collision changes, label layout and two complete draws.
	await get_tree().physics_frame
	await RenderingServer.frame_post_draw
	await RenderingServer.frame_post_draw
	var screenshot: Image = get_viewport().get_texture().get_image()
	if screenshot == null or screenshot.is_empty():
		push_error("The native viewport returned an empty image for %s." % file_stem)
		return
	var path: String = OUTPUT_DIRECTORY.path_join(file_stem + ".png")
	var image_error: Error = screenshot.save_png(path)
	if image_error != OK:
		push_error("Could not save %s: error %d." % [path, image_error])
		return
	captured_paths.append(ProjectSettings.globalize_path(path))
	print("VISUAL_SAMPLE_SAVED: %s (%d x %d)" % [path, screenshot.get_width(), screenshot.get_height()])
