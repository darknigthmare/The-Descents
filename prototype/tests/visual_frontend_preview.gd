extends Node

## Capture the actual Godot renderer at prepared states. This is not a human playthrough.
const MainScene = preload("res://scenes/main.tscn")
const Preferences = preload("res://scripts/preferences_store.gd")
const SAVE: String = "user://qa_visual_frontend_v04.json"
const PREFS: String = "user://qa_visual_frontend_v04.cfg"
var mission: Node3D
var output: String = "res://../docs/captures/v0.4"
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
		mission._process_arrival(moment - previous)
		previous = moment
		await _shot("06_approche_%02d" % int(moment),"Approche en jeu, état préparé à %d secondes" % int(moment))
	mission._pause()
	await _shot("07_pause_intro","Pause pendant l’approche")
	mission._resume()
	mission._finish_arrival()
	mission.elapsed = 98.0
	mission.rescued = ["survivor_30"]
	mission.incident.restore("aftermath")
	mission.world.apply_incident("aftermath",0.0)
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
	var manifest: Dictionary = {"version":"0.4.0", "engine":Engine.get_version_info().get("string"),"display":DisplayServer.get_name(),"rendering_method":RenderingServer.get_current_rendering_method(),"viewport":str(get_viewport().get_visible_rect().size),"prepared_states":true,"human_playthrough":false,"captures":shots}
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
