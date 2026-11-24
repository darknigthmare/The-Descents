extends Node

## Capture the actual Godot renderer at prepared states. This is not a human playthrough.
const MainScene = preload("res://scenes/main.tscn")
const Preferences = preload("res://scripts/preferences_store.gd")
const SAVE: String = "user://qa_visual_frontend_v05.json"
const PREFS: String = "user://qa_visual_frontend_v05.cfg"
var mission: Node3D
var output: String = "res://../docs/captures/v0.5"
var shots: Array[Dictionary] = []

func _ready() -> void:
	call_deferred("_capture")

func _capture() -> void:
	if DisplayServer.get_name() == "headless":
		push_error("Visual review requires a real renderer, for example Xvfb + GL Compatibility.")
		get_tree().quit(1)
		return
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with("--capture-root="):
			output = argument.trim_prefix("--capture-root=")
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(output))
	_clean()
	var settings: Dictionary = Preferences.DEFAULTS.duplicate()
	settings["audio"] = false
	settings["startup_intro"] = false
	settings["reduced_motion"] = false
	Preferences.save_settings(settings,PREFS)
	mission = MainScene.instantiate()
	mission.save_path = SAVE
	mission.preferences_path = PREFS
	mission.sound_enabled = false
	add_child(mission)
	mission.set_process(false)
	await _shot("01_menu_arrivee","Menu initial, deux tours intactes, aucune sauvegarde")
	mission.hud.menu._open_modal(mission.hud.menu.options)
	await _shot("02_options","Options avant la partie")
	mission.hud.menu.close_modals()
	mission.hud.menu._open_modal(mission.hud.menu.new_panel)
	await _shot("03_nouvelle_intervention","Préparation de la première intervention")
	mission.hud.menu.close_modals()
	mission._start_studio_intro()
	mission.cinematic.elapsed = 2.0
	mission._render_cinematic()
	await _shot("04_signature_studio","Signature du studio, carton à deux secondes")
	mission.cinematic.elapsed = 11.0
	mission._render_cinematic()
	await _shot("05_titre","Révélation du titre à onze secondes")
	mission._finish_studio_intro()
	mission._start_new(271104)
	mission.set_process(false)
	var previous: float = 0.0
	for moment: float in [3.0,10.0,17.0,25.0]:
		mission._process(moment - previous)
		previous = moment
		await _shot("06_approche_%02d" % int(moment),"Approche en jeu, état préparé à %d secondes" % int(moment))
	mission._pause()
	await _shot("07_pause_intro","Pause pendant l’approche")
	mission._resume()
	mission._finish_arrival()
	_disable_ticks()
	# Prepared close view of the real parked aircraft and roof staging.
	mission.hud.game.hide()
	mission.menu_camera.current = true
	var parked_origin: Vector3 = mission.world_data["helicopter_origins"][0]
	mission.menu_camera.global_position = parked_origin + Vector3(9, 5, 12)
	mission.menu_camera.look_at(parked_origin + Vector3(0, 0.9, 0))
	await _shot("14_toit_equipe", "Détail du toit : Alpha posé, porte et équipe dans leur état final")
	mission.player.camera.current = true
	mission.hud.show_game()
	if not await _open_field("inspect_roof_register"):
		return
	await _shot("11_inspection_toit", "Fiche du registre de réception, avant les sauvetages")
	_close_field()
	if not await _open_field("inspect_28_archive"):
		return
	await _shot("12_inspection_archives", "Fiche des archives, avant l’incident structurel")
	_close_field()
	mission.elapsed = 98.0
	mission.rescued = ["survivor_30"]
	mission.incident.restore("aftermath")
	mission.world.apply_incident("aftermath",0.0)
	if not await _open_field("inspect_28_archive"):
		return
	await _shot("13_inspection_apres", "Même fiche des archives après l’impact confirmé, consigne actualisée")
	_close_field()
	mission._save_checkpoint(28)
	mission._return_to_menu()
	mission.set_process(false)
	await _shot("08_menu_archives","Accueil au point sûr du 28 après la réplique")
	mission.hud.menu._open_modal(mission.hud.menu.dossier)
	await _shot("09_dossier_apres","Dossier actualisé après l’impact confirmé")
	mission.hud.menu.close_modals()
	mission._continue_game()
	mission.rescued = ["survivor_30","survivor_28","survivor_26"]
	mission.elapsed = 210.0
	mission.completed = true
	mission._save_checkpoint(25)
	mission._return_to_menu()
	mission.set_process(false)
	await _shot("10_menu_refuge","Accueil après une intervention terminée, point sûr du refuge")
	var manifest: Dictionary = {"version":ProjectSettings.get_setting("application/config/version"), "engine":Engine.get_version_info().get("string"),"display":DisplayServer.get_name(),"rendering_method":RenderingServer.get_current_rendering_method(),"viewport":str(get_viewport().get_visible_rect().size),"prepared_states":true,"human_playthrough":false,"captures":shots}
	var file: FileAccess = FileAccess.open(output.path_join("MANIFEST.json"),FileAccess.WRITE)
	file.store_string(JSON.stringify(manifest,"  ")+"\n")
	file.close()
	mission.queue_free()
	await get_tree().process_frame
	_clean()
	print("PASS visual frontend review: %d native Godot captures" % shots.size())
	get_tree().quit(0)

func _shot(name_value: String, description: String) -> void:
	if mission.hud.menu.visible:
		mission.hud.menu._process(1.0)
	for frame in range(5):
		await get_tree().process_frame
		await RenderingServer.frame_post_draw
	var captured: Image = get_viewport().get_texture().get_image()
	var error: Error = captured.save_png(output.path_join(name_value+".png"))
	if error != OK:
		push_error("Capture failed: "+name_value)
		get_tree().quit(1)
		return
	shots.append({"file":name_value+".png","description":description,"width":captured.get_width(),"height":captured.get_height()})
	print("CAPTURE "+name_value)

func _clean() -> void:
	for path: String in [SAVE,SAVE+".tmp",PREFS,PREFS+".tmp"]:
		if FileAccess.file_exists(path):
			DirAccess.remove_absolute(ProjectSettings.globalize_path(path))

func _disable_ticks() -> void:
	mission.set_process(false)
	mission.player.set_process(false)
	mission.player.set_physics_process(false)
	mission.world.set_process(false)

func _open_field(identifier: String) -> bool:
	var selected: Node3D
	for object: Node3D in mission.world_data.get("interactables", []):
		if is_instance_valid(object) and object.get_meta("id", "") == identifier:
			selected = object
			break
	if selected == null:
		push_error("Visual fixture has no field prop: " + identifier)
		get_tree().quit(1)
		return false
	var floor_number: int = int(selected.get_meta("floor"))
	mission.player.teleport_to_floor(floor_number)
	_disable_ticks()
	await get_tree().physics_frame
	await get_tree().physics_frame
	if not _face_field(selected):
		push_error("Visual fixture has no clear standing position beside " + identifier)
		get_tree().quit(1)
		return false
	mission._open_inspection(selected)
	if not mission.paused or not mission.hud.inspection_panel.visible:
		push_error("Visual fixture could not open the field inspection through the real gameplay gate: " + identifier)
		get_tree().quit(1)
		return false
	return true

func _close_field() -> void:
	mission.hud.inspection_panel.close_button.pressed.emit()
	_disable_ticks()

func _face_field(object: Node3D) -> bool:
	var y: float = float(int(object.get_meta("floor")) - 24) * 6.0 + 0.1
	var capsule: CapsuleShape3D = CapsuleShape3D.new()
	capsule.radius = 0.34
	capsule.height = 1.72
	for offset: Vector3 in [Vector3(0,0,1.65),Vector3(1.65,0,0),Vector3(-1.65,0,0),Vector3(0,0,-1.65),Vector3(1.3,0,1.3),Vector3(-1.3,0,1.3),Vector3(1.3,0,-1.3),Vector3(-1.3,0,-1.3)]:
		var candidate: Vector3 = Vector3(object.global_position.x,y,object.global_position.z) + offset
		var query: PhysicsShapeQueryParameters3D = PhysicsShapeQueryParameters3D.new()
		query.shape = capsule
		query.transform = Transform3D(Basis.IDENTITY,candidate + Vector3(0,0.87,0))
		query.exclude = [mission.player.get_rid()]
		if not mission.get_world_3d().direct_space_state.intersect_shape(query).is_empty():
			continue
		mission.player.global_position = candidate
		mission.player.camera.look_at(object.global_position + (object.get_meta("focus_offset") as Vector3))
		if mission._interaction_visible(object):
			return true
	return false
