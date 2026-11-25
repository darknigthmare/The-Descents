extends Node
## Eight native prepared-state captures, not a recorded human playthrough.
## Run with --rendering-method gl_compatibility and a native display.
const MainScene = preload("res://scenes/main.tscn")
const Preferences = preload("res://scripts/preferences_store.gd")
const SAVE: String = "user://qa_visual_equipment_v011.json"
const PREFS: String = "user://qa_visual_equipment_v011.cfg"
const CAPTURE_SIZE: Vector2i = Vector2i(1440, 900)
const WARMUP_FRAMES: int = 8
var output: String = "res://../docs/captures/v0.11/equipment"
var mission: Node3D
var shots: Array[Dictionary] = []

func _ready() -> void:
	_capture.call_deferred()

func _capture() -> void:
	if DisplayServer.get_name() == "headless" or RenderingServer.get_current_rendering_method() != "gl_compatibility":
		_fail("Equipment review requires the native Compatibility renderer.")
		return
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with("--capture-root="):
			output = argument.trim_prefix("--capture-root=")
	if DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(output)) != OK:
		_fail("Cannot create equipment capture directory.")
		return
	get_window().size = CAPTURE_SIZE
	get_window().content_scale_size = CAPTURE_SIZE
	_clean()
	Preferences.save_settings(Preferences.normalize({"audio": false, "startup_intro": false, "reduced_motion": true}), PREFS)
	mission = MainScene.instantiate()
	mission.save_path = SAVE
	mission.preferences_path = PREFS
	mission.sound_enabled = false
	add_child(mission)
	mission._start_new(271104)
	mission._finish_arrival()
	_freeze()
	mission.elapsed = 300.0
	mission.rescued = ["survivor_30", "survivor_28", "survivor_26"]
	mission.seen_floors = [31, 30, 29, 28, 27, 26, 25]
	mission.incident.restore("aftermath")
	mission.world.apply_incident("aftermath", 0.0)
	mission.world.set_rescued_people(mission.rescued)
	mission.radio.reset()
	mission._sync_radio()
	await _view(Vector3(-7.7, 42.06, -0.8), Vector3(-7.7, 42.85, 2.8))
	mission._select_equipment("fire_axe")
	mission._process_equipment(0.0, 0)
	if not (await _shot("01_rack_toit", "Râtelier du toit et outils de secours ; état après impact préparé.")):
		return
	# A raised review camera exposes the counter's upper surface.
	await _view(Vector3(8.2, 42.06, 5.8), Vector3(8.25, 44.25, 8.55), 1.1)
	if not (await _shot("02_comptoir_toit", "Radio, casque, sac de soins et lampe sur le comptoir ; caméra de revue relevée.")):
		return
	if not (await _face_worksite("equipment_boards_29", "fire_axe")):
		return
	if not _begin_hold("equipment_boards_29", 4):
		return
	if not (await _shot("03_hache_29", "Hache sélectionnée et action réelle en cours sur la réserve de balisage du 29.")):
		return
	if not _finish_action("equipment_boards_29"):
		return
	if not (await _face_worksite("equipment_fire_28", "extinguisher")):
		return
	if not _begin_hold("equipment_fire_28", 8):
		return
	if not (await _shot("04_extincteur_28_actif", "Extincteur sélectionné, action maintenue et jet cosmétique vers le foyer du 28.")):
		return
	if not _finish_action("equipment_fire_28"):
		return
	if mission.equipment_visuals.local_fire.visible:
		_fail("The completed extinguisher action still displays the local fire.")
		return
	if not (await _shot("05_foyer_28_eteint", "Foyer du 28 éteint par la logique d’action ; réserve de l’extincteur mise à jour.")):
		return
	if not (await _face_worksite("equipment_cabinet_25", "halligan")):
		return
	if not _begin_hold("equipment_cabinet_25", 4):
		return
	if not (await _shot("06_halligan_25", "Halligan en main et intervention en cours sur l’armoire de soins du refuge.")):
		return
	if not _finish_action("equipment_cabinet_25"):
		return
	if not (await _open_continuation()):
		return
	if not (await _face_worksite("equipment_chain_24", "bolt_cutter")):
		return
	if not _begin_hold("equipment_chain_24", 4):
		return
	if not _finish_action("equipment_chain_24"):
		return
	if not mission.equipment_visuals.work_light.visible:
		_fail("The released worklight is not enabled.")
		return
	if not (await _shot("07_coupe_boulon_24", "Coupe-boulon au congrès, chaîne ouverte et projecteur libéré après le choix réel de poursuite.")):
		return
	await _view(Vector3(-8.6, 6.06, 0.0), Vector3(-8.7, 6.90, -4.9))
	mission._select_equipment("halligan")
	mission._process_equipment(0.0, 0)
	mission._update_hud()
	if not (await _shot("08_inventaire_refuge25", "Poste matériel du refuge : brancard, sac de soins, bouteille et balise ; HUD des outils visible.")):
		return
	if shots.size() != 8:
		_fail("The equipment review must contain exactly eight captures.")
		return
	var manifest: Dictionary = {
		"version": ProjectSettings.get_setting("application/config/version"),
		"engine": Engine.get_version_info().get("string"),
		"display": DisplayServer.get_name(),
		"rendering_method": RenderingServer.get_current_rendering_method(),
		"prepared_states": true, "human_playthrough": false,
		"warmup_frames_per_capture": WARMUP_FRAMES,
		"width": CAPTURE_SIZE.x, "height": CAPTURE_SIZE.y,
		"source": "res://tests/visual_equipment_v011.tscn",
		"captures": shots
	}
	var file: FileAccess = FileAccess.open(output.path_join("MANIFEST.json"), FileAccess.WRITE)
	if file == null:
		_fail("Cannot write equipment capture manifest.")
		return
	file.store_string(JSON.stringify(manifest, "\t"))
	file.close()
	mission.free()
	_clean()
	print("PASS visual equipment v0.11: eight native Compatibility captures")
	get_tree().quit(0)

func _view(position_value: Vector3, target: Vector3, camera_lift: float = 0.0) -> void:
	mission.player.teleport_to_floor(clampi(roundi(position_value.y / 6.0) + 24, 24, 31))
	mission.player.position = position_value
	mission.player.velocity = Vector3.ZERO
	mission.player.camera.position.y = camera_lift
	mission.player.camera.current = true
	mission.player.camera.look_at(target)
	mission.hud.show_game()
	mission.hud.notify_label.text = ""
	await get_tree().physics_frame
	await get_tree().physics_frame
	mission._process_equipment(0.0, 0)
	mission._find_nearest()
	mission._update_hud()

func _face_worksite(id: String, tool: String) -> bool:
	var target: Node3D = mission.equipment_visuals.targets.get(id)
	if not is_instance_valid(target):
		_fail("Missing equipment worksite: " + id)
		return false
	await _view(target.global_position + Vector3(0, 0.06, 1.9), target.global_position + Vector3(0, 0.85, 0))
	mission._select_equipment(tool)
	mission._process_equipment(0.0, 0)
	mission._find_nearest()
	mission._update_hud()
	if not mission._can_use_equipment() or not mission._equipment_target_visible(target) or mission.equipment.selected != tool:
		_fail("Prepared worksite pose is not eligible and visible: " + id)
		return false
	return true

func _begin_hold(id: String, ticks: int) -> bool:
	var target: Node3D = mission.equipment_visuals.targets.get(id)
	mission._interact_node(target)
	if mission.equipment.active_id != id:
		_fail("The real interaction did not start equipment action: " + id)
		return false
	for tick: int in range(ticks):
		mission._process_equipment(0.125, 1)
	mission._find_nearest()
	mission._update_hud()
	if mission.equipment.active_id != id:
		_fail("Equipment action stopped before its active capture: " + id)
		return false
	return true

func _finish_action(id: String) -> bool:
	for tick: int in range(40):
		if id in mission.equipment.completed:
			break
		mission._process_equipment(0.125, 1)
	if id not in mission.equipment.completed or id not in mission.supplies_used:
		_fail("Equipment action did not complete through its director: " + id)
		return false
	mission._process_equipment(0.0, 0)
	mission._find_nearest()
	mission._update_hud()
	return true

func _open_continuation() -> bool:
	mission.player.teleport_to_floor(25)
	mission.player.velocity = Vector3.ZERO
	await get_tree().physics_frame
	await get_tree().physics_frame
	mission._complete_game(false)
	if not mission.completed or not mission.hud.end_panel.visible:
		_fail("The real upper debrief did not become available.")
		return false
	mission.hud.end_panel.descent_button.pressed.emit()
	_freeze()
	await get_tree().physics_frame
	await get_tree().physics_frame
	if mission.continuation.phase != "active":
		_fail("The real continuation choice did not open floor 24.")
		return false
	mission.radio.reset()
	mission._sync_radio()
	mission._process_equipment(0.0, 0)
	return true

func _shot(name_value: String, description: String) -> bool:
	for frame: int in range(WARMUP_FRAMES):
		await get_tree().process_frame
		await RenderingServer.frame_post_draw
	var captured: Image = get_viewport().get_texture().get_image()
	if captured == null or captured.is_empty() or captured.get_size() != CAPTURE_SIZE:
		_fail("Equipment capture must be a nonempty 1440 x 900 image: " + name_value)
		return false
	var path: String = output.path_join(name_value + ".png")
	if captured.save_png(path) != OK:
		_fail("Failed native equipment capture: " + name_value)
		return false
	shots.append({
		"file": name_value + ".png", "description": description,
		"width": captured.get_width(), "height": captured.get_height(),
		"sha256": FileAccess.get_sha256(path),
		"rendering_method": RenderingServer.get_current_rendering_method(),
		"prepared_state": true, "human_playthrough": false,
		"floor": mission.player.nearest_floor(),
		"selected_tool": mission.equipment.selected,
		"active_action": mission.equipment.active_id,
		"completed_actions": mission.equipment.completed.duplicate(),
		"continuation_phase": mission.continuation.phase,
		"camera_lift_m": mission.player.camera.position.y
	})
	print("CAPTURE " + name_value)
	return true

func _freeze() -> void:
	mission.set_process(false)
	mission.set_physics_process(false)
	mission.player.set_process(false)
	mission.player.set_physics_process(false)
	mission.world.set_process(false)
	mission.world.set_physics_process(false)

func _clean() -> void:
	for path: String in [SAVE, PREFS]:
		if FileAccess.file_exists(path):
			DirAccess.remove_absolute(ProjectSettings.globalize_path(path))

func _fail(message: String) -> void:
	push_error(message)
	_clean()
	get_tree().quit(1)
