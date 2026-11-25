extends Node

## Capture the actual Godot renderer at prepared states. This is not a human playthrough.
const MainScene = preload("res://scenes/main.tscn")
const Preferences = preload("res://scripts/preferences_store.gd")
const Horror = preload("res://scripts/horror_director.gd")
const Routes = preload("res://scripts/route_catalog.gd")
const SAVE: String = "user://qa_visual_frontend_v09.json"
const PREFS: String = "user://qa_visual_frontend_v09.cfg"
var mission: Node3D
var output: String = "res://../docs/captures/v0.10/baseline"
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
	mission.menu_camera.fov = 64.0
	mission.menu_camera.global_position = Vector3(13, 52.35, 16)
	mission.menu_camera.look_at(Vector3(1, 43.75, -3.5))
	await _shot("14_toit_equipe", "Détail du toit : Alpha posé, porte et équipe dans leur état final")
	mission.player.camera.current = true
	mission.hud.show_game()
	# Prepared rescue states use the same interaction and timing paths as gameplay.
	var casualty: Node3D = _mission_object("survivor", 30)
	mission.player.teleport_to_floor(30)
	_disable_ticks()
	mission.player.position = Vector3(7, 36.1, -4.7)
	mission.player.camera.look_at(Vector3(3.6, 37.1, 0))
	mission._interact_node(casualty)
	mission.rescue_visuals.advance(0.0, true)
	mission._update_hud()
	await _shot("15_portage", "Portage d’Ana : harnais, personne et mains visibles, objectif dégagé")
	mission.player.position = Vector3(4.8, 36.1, 1.4)
	mission.player.camera.look_at(Vector3(1.8, 39.3, 0))
	mission._start_hoist(casualty, 30)
	mission._process_hoist(1.8)
	mission._update_hud()
	await _shot("16_treuillage", "Remontée d’Ana dans le puits : harnais et câble sous tension")
	mission._process_hoist(3.2)
	mission.rescue_visuals.advance(1.8, true)
	mission.hud.game.hide()
	mission.menu_camera.current = true
	mission.menu_camera.fov = 60.0
	mission.menu_camera.global_position = Vector3(13, 49.5, 4.5)
	mission.menu_camera.look_at(Vector3(6, 43, -5.5))
	await _shot("17_reception", "Réception confirmée, transfert d’Ana vers l’abri avec l’équipe médicale")
	mission.rescue_visuals.advance(10.0, true)
	mission.world.atmosphere.sample_world(13.0, "intact", false)
	mission.menu_camera.fov = 66.0
	mission.menu_camera.global_position = Vector3(13, 48, 17)
	mission.menu_camera.look_at(Vector3(26, 46, -30))
	await _shot("18_meteo_toit", "Atmosphère maritime : plafond nuageux, pluie extérieure et horizon de Nacre")
	mission.player.camera.current = true
	mission.hud.show_game()
	mission._pause()
	mission.hud.show_comfort_settings()
	await _shot("19_options_pause", "Réglages complets accessibles pendant une intervention suspendue")
	mission.hud.menu.close_modals()
	mission._resume()
	mission._start_new(271104)
	mission._finish_arrival()
	_disable_ticks()
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
	_disable_ticks()
	mission._interact_node(_mission_object("evidence", 29))
	mission._save_checkpoint(28)
	mission._open_journal()
	for record: Array in [["situation", "20_journal_situation"], ["survivors", "21_journal_rescapes"], ["clues", "22_journal_indices"], ["transmissions", "23_journal_transmissions"]]:
		mission.hud.journal_panel.select_tab(str(record[0]))
		await _shot(str(record[1]), "Journal de l’intervention en cours : " + str(record[0]) + ", une réception et un indice confirmés")
	mission._resume()
	_disable_ticks()
	# Complete the remaining actual hoists before sampling the closing sequence.
	for floor_number: int in [28, 26]:
		mission.player.teleport_to_floor(floor_number)
		mission._interact_node(_mission_object("survivor", floor_number))
		mission._interact_node(_mission_object("beacon", floor_number))
		mission._process_hoist(5.01)
		mission.rescue_visuals.finish_reception()
	mission._interact_node(_mission_object("evidence", 27))
	mission.elapsed = 210.0
	mission.player.teleport_to_floor(25)
	mission._interact_node(_mission_object("refuge", 25))
	_disable_ticks()
	previous = 0.0
	for moment: float in [2.0, 7.0, 12.0]:
		mission._process_epilogue(moment - previous)
		previous = moment
		await _shot("24_epilogue_%02d" % int(moment), "Épilogue en jeu : plan %d à %d secondes, trois personnes réceptionnées" % [int(moment / 5.0) + 1, int(moment)])
	mission._process_epilogue(3.01)
	await _shot("25_bilan_refuge", "Bilan nominatif au refuge : trois réceptions, deux indices et historique de cette intervention")
	mission._return_to_menu()
	mission.set_process(false)
	await _shot("10_menu_refuge","Accueil après une intervention terminée, point sûr du refuge")
	if not await _capture_early_manifestations():
		return
	if not await _capture_local_traversal():
		return
	var manifest: Dictionary = {"version":ProjectSettings.get_setting("application/config/version"), "engine":Engine.get_version_info().get("string"),"display":DisplayServer.get_name(),"rendering_method":RenderingServer.get_current_rendering_method(),"viewport":str(get_viewport().get_visible_rect().size),"prepared_states":true,"human_playthrough":false,"captures":shots}
	var file: FileAccess = FileAccess.open(output.path_join("MANIFEST.json"),FileAccess.WRITE)
	file.store_string(JSON.stringify(manifest,"  ")+"\n")
	file.close()
	mission.queue_free()
	mission = null
	# Drain actual renderer frames after releasing the scene, before GL shutdown.
	for frame in range(5):
		await get_tree().process_frame
		await RenderingServer.frame_post_draw
	_clean()
	print("PASS visual frontend review: %d native Godot captures" % shots.size())
	get_tree().quit(0)

func _capture_early_manifestations() -> bool:
	# The three new views advance the actual director through controller gates.
	# Only starting poses and mission state are prepared; no opacity is injected.
	mission._start_new(271104)
	mission._finish_arrival()
	_disable_ticks()
	# Keep the later aftermath state consistent with the real first rescue.
	var casualty: Node3D = _mission_object("survivor", 30)
	mission.player.teleport_to_floor(30)
	mission._interact_node(casualty)
	mission._start_hoist(casualty, 30)
	mission._process_hoist(5.01)
	mission.rescue_visuals.finish_reception()
	# These views represent a later quiet interval, beyond the six-second toast.
	mission.notify_time = 0.0
	mission.hud.notify_label.hide()
	mission.player.teleport_to_floor(29)
	mission.player.position = Vector3(-3.0,30.1,2.0)
	mission.player.camera.look_at(Vector3(-3.0,31.3,-5))
	mission.radio.reset()
	mission._sync_radio()
	await get_tree().physics_frame
	for index in range(34):
		mission._process_horror(0.1,29)
	if not mission.horror_visuals.suites_figure.visible:
		push_error("Native suite fixture failed to produce its actual peripheral cue.")
		get_tree().quit(1)
		return false
	mission._update_hud()
	await _shot("26_suites_presence", "Manifestation des suites 29 : pose périphérique préparée, directeur avancé réellement de 3,4 s, silhouette sans dégâts")
	mission.incident.restore("aftermath")
	mission.world.apply_incident("aftermath",0.0)
	mission.player.teleport_to_floor(28)
	mission.player.position = Vector3(-3.4,24.1,4.9)
	mission.player.camera.look_at(Horror.TRACE_POSITION)
	mission.radio.reset()
	mission._sync_radio()
	for index in range(90):
		mission._process_horror(0.1,28)
	if not mission.horror_visuals.trace_root.visible or float(mission.horror.presentation()["trace_progress"]) < 1.0:
		push_error("Native archive fixture failed to settle the actual damp traces.")
		get_tree().quit(1)
		return false
	mission._update_hud()
	await _shot("27_archives_traces", "Archives 28 : huit traces humides après impact, neuf secondes de présentation réelle, sans indice ajouté au journal")
	mission.player.teleport_to_floor(26)
	mission.player.position = Vector3(-2.5,12.1,4.5)
	mission.player.camera.look_at(Vector3(-10,13,2))
	mission.radio.reset()
	mission._sync_radio()
	await get_tree().physics_frame
	for index in range(105):
		mission._process_horror(0.1,26)
	mission.player.camera.look_at(mission.player.camera.global_position + Vector3(8,0,1))
	for index in range(210):
		mission._process_horror(0.1,26)
	mission.player.camera.look_at(Horror.SPA_POSITION + Vector3(0,1.2,0))
	for index in range(17):
		mission._process_horror(0.1,26)
	if not mission.horror_visuals.spa_figure.visible or int(mission.horror.presentation()["recurrence"]) != 2:
		push_error("Native spa fixture failed to show the bounded second presence.")
		get_tree().quit(1)
		return false
	mission._update_hud()
	await _shot("28_spa_remanence", "Spa 26 : seconde présence après extinction, attente calme et regard détourné, sans poursuite ni dommage")
	return true

func _capture_local_traversal() -> bool:
	mission._start_new(271104)
	mission._finish_arrival()
	_disable_ticks()
	_quiet_traversal_frame()
	var route: Dictionary = Routes.for_id("R31_30")
	mission.player.position = route["top_entry"] + Vector3(-0.6, 0.04, 1.8)
	mission.player.camera.look_at(Vector3(-1.3, 42.8, 0))
	await get_tree().physics_frame
	mission._find_nearest()
	mission._update_hud()
	await _shot("29_station_rappel_toit", "Repère bleu du rappel personnel toit–30, distinct du treuil orange ; pose initiale préparée")
	mission.player.position = route["top_entry"]
	await get_tree().physics_frame
	await get_tree().physics_frame
	mission._interact_node(_mission_object("rappel", 31))
	if not mission.player.on_rope:
		return _traversal_capture_failure("The roof station did not engage its actual local rope.")
	await _drive_rope(0.9)
	if not str(mission.player.rope_transfer).is_empty():
		return _traversal_capture_failure("The physical entry transfer did not reach the rope.")
	await _drive_rope(1.25, "move_back")
	mission.player.camera.look_at(Vector3(-3.3, 36.8, 1.2))
	_quiet_traversal_frame()
	mission._update_hud()
	await _shot("30_rappel_descente", "Descente contrôlée sur R31_30 : transfert et 1,25 s de mouvement réels, capsule, descendeur et HUD du rappel")
	mission.player.toggle_rope_lock()
	await _drive_rope(0.25)
	mission._update_hud()
	await _shot("31_rappel_verrouille", "Même liaison, verrouillage réel du descendeur : vitesse nulle, repos assuré et état visible")
	mission.player.toggle_rope_lock()
	await _drive_rope(2.5, "move_back")
	await _drive_rope(0.7)
	await _drive_rope(1.1, "move_forward")
	mission.player.camera.look_at(Vector3(-2.3, 42.3, -0.8))
	mission._update_hud()
	await _shot("34_rappel_remontee", "Remontée réelle depuis l’extrémité basse du rappel toit–30 : effort, vitesse et disponibilité de corde")
	await _prepare_stair_view(30)
	await _shot("32_escalier_30_29", "Escalier local du restaurant 30 aux suites 29 : ouverture de dalle, première volée et signalétique")
	mission.player.position = Vector3(0, 33.08, 10.8)
	mission.player.camera.look_at(Vector3(-1.3, 36.6, 6.3))
	await _settle_stair_pose()
	mission._update_hud()
	await _shot("33_escalier_palier", "Palier intermédiaire du 30–29 : deux volées physiques, aucune entrée d’étage déclarée à mi-hauteur")
	await _prepare_stair_view(28)
	await _shot("36_escalier_28_27", "Escalier local des archives 28 au jardin 27, vue préparée de la dalle ouverte et du passage intérieur")
	await _prepare_stair_view(26)
	await _shot("37_escalier_26_25", "Dernier escalier local, du spa 26 au refuge 25 ; la cage s’arrête à la liaison prévue")
	mission._pause()
	mission.hud.show_help()
	await _shot("35_aide_deplacements", "Aide de mission : itinéraire des six liaisons, commandes de rappel, distinction des repères et treuil")
	return true

func _drive_rope(seconds: float, action: String = "") -> void:
	_release_traversal_actions()
	if not action.is_empty():
		Input.action_press(action)
	for frame in range(ceili(seconds * 60.0)):
		mission.player._process_rope(1.0 / 60.0)
		await get_tree().physics_frame
	_release_traversal_actions()

func _release_traversal_actions() -> void:
	for action: String in ["move_forward", "move_back", "move_left", "move_right", "crouch", "sprint"]:
		Input.action_release(action)

func _prepare_stair_view(upper: int) -> void:
	_release_traversal_actions()
	mission.player.teleport_to_floor(upper)
	_disable_ticks()
	mission.player.active = true
	var y: float = Routes.floor_height(upper)
	mission.player.position = Vector3(-1.3, y - 0.12, 6.05)
	mission.player.camera.look_at(Vector3(-1.3, y - 2.3, 9.8))
	await _settle_stair_pose()
	_quiet_traversal_frame()
	mission._update_hud()

func _settle_stair_pose() -> void:
	for frame in range(12):
		await get_tree().physics_frame
		mission.player._process_walk(1.0 / 60.0)

func _quiet_traversal_frame() -> void:
	mission.notify_time = 0.0
	mission.hud.notify_label.hide()
	mission.radio.reset()
	mission._sync_radio()

func _traversal_capture_failure(message: String) -> bool:
	push_error(message)
	get_tree().quit(1)
	return false

func _shot(name_value: String, description: String) -> void:
	if mission.started and mission.player.camera.current and mission.hud.game.visible:
		# Main ticks are frozen: sample the same equipment gates as gameplay.
		# Zero delta preserves timing; rope, stairs and rescue keep hands free.
		mission._process_equipment(0.0, 0)
		mission._update_hud()
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
	mission._update_hud()
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

func _mission_object(kind: String, floor_number: int) -> Node3D:
	for object: Node3D in mission.world_data.get("interactables", []):
		if object.get_meta("kind", "") == kind and int(object.get_meta("floor", 0)) == floor_number:
			return object
	push_error("Visual fixture missing mission object: %s %d" % [kind, floor_number])
	return null
