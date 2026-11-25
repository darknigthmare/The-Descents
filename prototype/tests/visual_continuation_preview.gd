extends Node
## Native prepared-state captures; not a recorded human playthrough.
const MainScene = preload("res://scenes/main.tscn")
const Preferences = preload("res://scripts/preferences_store.gd")
const Routes = preload("res://scripts/route_catalog.gd")
const SAVE: String = "user://qa_visual_continuation_v010.json"
const PREFS: String = "user://qa_visual_continuation_v010.cfg"
var output: String = "res://../docs/captures/v0.10/continuation"
var mission: Node3D
var shots: Array[Dictionary] = []

func _ready() -> void:
	_capture.call_deferred()

func _capture() -> void:
	if DisplayServer.get_name() == "headless":
		push_error("Continuation review requires the native Compatibility renderer.")
		get_tree().quit(1)
		return
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with("--capture-root="):
			output = argument.trim_prefix("--capture-root=")
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(output))
	_clean()
	Preferences.save_settings(Preferences.normalize({"audio": false, "startup_intro": false, "reduced_motion": true}), PREFS)
	mission = MainScene.instantiate()
	mission.save_path = SAVE
	mission.preferences_path = PREFS
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
	mission.player.teleport_to_floor(25)
	await get_tree().physics_frame
	await get_tree().physics_frame
	mission._complete_game(false)
	await _shot("01_bilan_poursuite", "Bilan supérieur conservé et bouton de poursuite vers le congrès")
	mission.hud.end_panel.descent_button.pressed.emit()
	_freeze()
	await get_tree().physics_frame
	await get_tree().physics_frame
	if mission.continuation.phase != "active":
		push_error("The real continuation choice did not open the new chapter.")
		get_tree().quit(1)
		return
	mission.radio.reset()
	mission._sync_radio()
	_view(Vector3(4.0, 6.10, -4.3), Vector3(0.1, 3.8, -9.5))
	await _shot("02_escalier_25_24", "Accès nord à l’escalier local, séparé de la liaison 26–25")
	_view(Vector3(4.1, 0.10, -3.2), Vector3(8.0, 1.9, 7.7))
	mission.seen_floors.append(24)
	mission._update_hud()
	await _shot("03_congres_auditorium", "Auditorium du congrès et écran Pelagos incliné, foyer de secours libre")
	var duo: Node3D = _object("continuation_duo_24")
	_view(Vector3(8.1, 0.10, -5.7), duo.global_position + Vector3(0.3, 1.3, 0))
	await _shot("04_cabine_signes", "Léa Mercier et Idris Kaci attendent un signe visible dans la cabine")
	mission._interact_node(duo)
	mission.radio.reset()
	mission._sync_radio()
	# Prepared walking poses on a route whose real traversal has its own tests.
	var visual: Node3D = mission.continuation_visuals
	visual.people[0].position = Vector3(-1.3, 2.12, -8.82)
	visual.people[1].position = Vector3(-1.3, 1.28, -7.59)
	mission.world._pose_human_walk(visual.figures[0], 0.8, 0.7)
	mission.world._pose_human_walk(visual.figures[1], 2.4, 0.7)
	_view(Vector3(-1.3, 3.12, -10.8), Vector3(-1.3, 2.3, -7.6))
	await _shot("05_escorte_escalier", "États préparés des deux personnes sur la volée nord, vers le refuge")
	mission.continuation.state["escort_state"] = "received"
	mission.world.set_continuation_state(mission.continuation.snapshot())
	_view(Vector3(5.6, 6.10, -0.8), Vector3(7.2, 7.3, -3.9))
	mission._save_checkpoint(25)
	await _shot("06_reception_refuge", "Réception stable préparée des deux personnes dans le refuge 25")
	mission.player.teleport_to_floor(24)
	mission.player.position = Vector3(-3.8, 0.06, 0)
	mission.player.camera.current = true
	mission.hud.show_game()
	await get_tree().physics_frame
	await get_tree().physics_frame
	mission.player.active = true
	if not mission.player.engage_rope(24, "R24_23"):
		push_error("Visual fixture cannot engage the new physical rope.")
		get_tree().quit(1)
		return
	mission.player._process_rope(0.85)
	Input.action_press("move_back")
	for tick in range(8):
		mission.player._process_rope(0.1)
	Input.action_release("move_back")
	mission.player._process_rope(0.3)
	mission.player.camera.look_at(Vector3(-1.0, -5.3, -0.6))
	mission._update_hud()
	await _shot("07_rappel_24_23", "Nouvelle ligne entre congrès et exposition avec descendeur et mesures actives")
	mission.player.teleport_to_floor(23)
	mission.seen_floors.append(23)
	_view(Vector3(7.4, -5.90, -3.6), Vector3(7.4, -4.85, -6.3))
	await _shot("08_maquette_souterrains", "Maquette des deux tours et volumes absents du plan touristique actuel")
	_view(Vector3(-7.4, -5.90, 10.3), Vector3(-7.4, -4.5, 7.5))
	await _shot("09_archive_bains", "Panneau d’archive procédural des anciens bains, forme de porte et légende")
	# Sample the optional repeated gesture through its director with radio quiet.
	for tick in range(420):
		visual.advance(1.0 / 60.0, Vector3(-4.8, -5.94, -4.7), true, true)
	_view(Vector3(-4.8, -5.90, -4.7), Vector3(-8.6, -4.8, -8.0))
	await _shot("10_remanence_exposition", "Routine facultative E01 à l’écart du passage, sans attaque ni dégâts")
	mission.clues = ["evidence_29", "evidence_27", "evidence_26", "continuation_model_23", "continuation_photo_23"]
	mission._open_journal()
	mission.hud.journal_panel.select_tab("clues")
	await get_tree().process_frame
	await get_tree().process_frame
	mission.hud.journal_text.get_v_scroll_bar().value = mission.hud.journal_text.get_v_scroll_bar().max_value
	await _shot("11_dossier_nacre", "Dossier des cinq pièces effectivement présentes dans l’instantané préparé")
	mission._resume()
	_freeze()
	var terminal: Node3D = _object("continuation_terminal_23")
	_view(Vector3(7.0, -5.94, 7.0), terminal.global_position + Vector3(0, 1.2, 0))
	await get_tree().physics_frame
	mission._interact_node(terminal)
	if not mission.completed:
		push_error("Visual fixture did not reach a valid final reconnaissance report.")
		get_tree().quit(1)
		return
	await _shot("12_bilan_reconnaissance", "Compte rendu au 23, deux réceptions au refuge et trois au toit conservées")
	mission._return_to_menu()
	_freeze()
	await _shot("13_menu_exposition", "Accueil contextuel sur l’exposition au dernier point sûr enregistré")
	var manifest: Dictionary = {"version": ProjectSettings.get_setting("application/config/version"), "engine": Engine.get_version_info().get("string"), "display": DisplayServer.get_name(), "rendering_method": RenderingServer.get_current_rendering_method(), "prepared_states": true, "human_playthrough": false, "captures": shots}
	var file: FileAccess = FileAccess.open(output.path_join("MANIFEST.json"), FileAccess.WRITE)
	file.store_string(JSON.stringify(manifest, "\t"))
	file.close()
	mission.free()
	_clean()
	print("PASS visual continuation review: %d native Godot captures" % shots.size())
	get_tree().quit(0)

func _view(position_value: Vector3, target: Vector3) -> void:
	mission.player.teleport_to_floor(clampi(roundi(position_value.y / 6.0) + 24, 23, 31))
	mission.player.position = position_value
	mission.player.camera.current = true
	mission.player.camera.look_at(target)
	mission.hud.show_game()
	mission.hud.notify_label.text = ""
	if is_instance_valid(mission.continuation_visuals):
		mission.continuation_visuals._update_sign(mission.player.global_position)
	mission._find_nearest()
	mission._update_hud()

func _shot(name_value: String, description: String) -> void:
	for frame in range(5):
		await get_tree().process_frame
		await RenderingServer.frame_post_draw
	var captured: Image = get_viewport().get_texture().get_image()
	var path: String = output.path_join(name_value + ".png")
	if captured.save_png(path) != OK:
		push_error("Failed native continuation capture: " + name_value)
		get_tree().quit(1)
		return
	shots.append({"file": name_value + ".png", "description": description, "width": captured.get_width(), "height": captured.get_height(), "sha256": FileAccess.get_sha256(path)})
	print("CAPTURE " + name_value)

func _freeze() -> void:
	mission.set_process(false)
	mission.set_physics_process(false)
	mission.player.set_physics_process(false)
	mission.world.set_process(false)

func _object(id: String) -> Node3D:
	for object: Node3D in mission.world_data.get("interactables", []):
		if object.get_meta("id", "") == id:
			return object
	push_error("Missing continuation capture object " + id)
	return null

func _clean() -> void:
	for path: String in [SAVE, PREFS]:
		if FileAccess.file_exists(path):
			DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
