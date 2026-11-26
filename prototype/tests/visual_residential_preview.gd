extends Node
## Native prepared scenes for visual review. Travel is verified separately by
## test_residential_routes.gd; these camera placements are not a playthrough.
const MainScene = preload("res://scenes/main.tscn")
const Store = preload("res://scripts/save_store.gd")
const Preferences = preload("res://scripts/preferences_store.gd")
const Residential = preload("res://scripts/residential_director.gd")
const Presentation = preload("res://scripts/residential_presentation.gd")
const Interaction = preload("res://tests/interaction_fixture.gd")
const LARGE := Vector2i(1280, 800)
const SMALL := Vector2i(1024, 640)
const SAVE := "user://qa_residential_visual_v013.json"
const PREFS := SAVE + ".cfg"
const FORWARD_SHOTS := ["02_residences_19", "05_duplex_18", "08_telecom_17"]
var output := "res://../docs/captures/v0.13/compatibility"
var expected_renderer := "gl_compatibility"
var mission: Node3D
var shots: Array[Dictionary] = []
var capture_size := LARGE

func _ready() -> void:
	_capture.call_deferred()

func _capture() -> void:
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with("--capture-root="): output = argument.trim_prefix("--capture-root=")
		elif argument.begins_with("--expected-renderer="): expected_renderer = argument.trim_prefix("--expected-renderer=")
	if DisplayServer.get_name() == "headless" or RenderingServer.get_current_rendering_method() != expected_renderer:
		_fail("A native display and the requested renderer are required."); return
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(output))
	get_window().size = LARGE
	get_window().content_scale_size = LARGE
	Preferences.save_settings(Preferences.normalize({"audio": false, "startup_intro": false, "reduced_motion": true}), PREFS)
	if Store.save_data(_checkpoint(), SAVE) != OK: _fail("Cannot seed the prior report."); return
	mission = MainScene.instantiate()
	mission.save_path = SAVE
	mission.preferences_path = PREFS
	add_child(mission)
	mission._continue_game()
	_freeze()
	await _settle()
	await _shot("01_bilan_20", "Bilan précédent, huit réceptions et choix explicite vers les résidences")
	mission.hud.end_panel.descent_button.pressed.emit()
	_freeze()
	await _settle()
	if mission.residential.phase != "active": _fail("The real report button did not open the chapter."); return
	await _view(Vector3(4.5,-29.94,-4.6),Vector3(8.6,-28.3,-9.2))
	await _shot("02_residences_19", "Résidence habitable, matières originales et accès auprès de Jeanne")
	await _view(Vector3(9.4,-29.94,-5.6),Vector3(9.1,-28.5,-8.4))
	await _shot("03_jeanne_care", "Jeanne, fauteuil et armoire de soins, avant mise en sécurité")
	await _view(Vector3(5.35,-29.94,-0.65),Vector3(8.1,-35.55,0.25))
	await _shot("04_duplex_upper", "Ouverture réelle et appui inférieur visible depuis le rappel personnel du duplex")
	await _view(Vector3(6.0,-35.94,3.6),Vector3(8.0,-30.5,0))
	await _shot("05_duplex_18", "Duplex inférieur, vue vers le salon haut et corde indépendante du noyau")
	await _view(Vector3(1.3,-35.94,3.2),Vector3(0,-34.6,5.6))
	await _shot("06_service_closed", "Escalier de service fermé et commande accessible côté 18")
	if not await _action("service_access", "halligan"): return
	await _view(Vector3(1.3,-35.94,3.2),Vector3(0,-34.6,6.9))
	await _shot("07_service_open", "Passage dégagé au Halligan ; route de remontée destinée aux rescapés")
	await _view(Vector3(4.6,-41.94,-4.2),Vector3(8.2,-40.4,-8.2))
	await _shot("08_telecom_17", "Baies techniques, sol antistatique et éclairage local au 17")
	if not await _action("care", "halligan"): return
	if not await _action("power", "halligan"): return
	if not await _action("reference", "halligan"): return
	await _view(Vector3(-7.65,-41.94,-10.0),Vector3(-9.9,-40.42,-10.0))
	await _shot("09_reference_plate", "Plaque lisible de destination et référence avant émission")
	await _face(mission.residential_visuals.action_targets["relay"])
	mission._interact_node(mission.residential_visuals.action_targets["relay"])
	await _shot("10_relay_form", "Vérification du routage, avec temps de mission suspendu")
	mission.relay_panel.destination_input.text = "HESPERIE"
	mission.relay_panel.reference_input.text = "NACRE-204"
	mission.relay_panel._submit()
	await _shot("11_relay_retry", "Erreur réessayable ; la destination n’est pas acceptée par simple ressemblance de voix")
	mission.relay_panel.destination_input.text = "AUBE-20"
	mission.relay_panel._submit()
	_freeze()
	for tick: int in range(45): mission._process_residential_action(0.05, 1)
	if not mission.residential.has_action("relay"): _fail("Verified held relay action failed."); return
	# The following receipts are prepared for review of their visuals only.
	for id: String in Residential.PERSON_IDS:
		mission.residential.toggle_person(id)
		mission.residential_visuals.people[id].global_position = Presentation.RECEIVING[id]
		mission.residential_visuals.people[id].velocity = Vector3.ZERO
		mission.residential_visuals.cursors[id] = mission.residential_visuals.paths[id].size()
		mission.residential_visuals.arrived[id] = true
	mission.residential_visuals.apply_state(mission.residential.snapshot())
	await _view(Vector3(-7.4,-23.94,4.2),Vector3(-7.4,-22.4,7.2))
	for tick: int in range(12):
		mission._process_residential(1.0/60.0)
		await get_tree().physics_frame
	await _shot("12_refuge_reunited", "Jeanne, Marc et Inès reçus au refuge 20 ; placements préparés pour cette vue")
	for id: String in Residential.CLUES:
		var target: Node3D = mission.residential_visuals.clue_targets[id]
		await _face(target)
		mission._interact_node(target)
	mission._open_journal()
	mission.hud.journal_panel.select_tab("survivors")
	await _scroll_people_to("JEANNE MOREL")
	await _shot("13_journal_people", "Journal : réception de Jeanne et Marc, onze personnes à l’abri et quinze étages")
	capture_size = SMALL
	get_window().size = SMALL
	get_window().content_scale_size = SMALL
	await _scroll_people_to("MARC MOREL")
	await _shot("14_compact_journal", "Journal compact 1024 × 640, lecture défilée jusqu’à Marc et Inès")
	mission._resume()
	_freeze()
	await _face(mission.residential_visuals.action_targets["relay"])
	# Reopen the review-only form for the compact layout; no new relay command.
	mission._pause(false)
	mission.relay_panel.open_panel()
	await _shot("15_compact_relay", "Formulaire de relais sur affichage compact")
	mission._cancel_residential_relay()
	_freeze()
	capture_size = LARGE
	get_window().size = LARGE
	get_window().content_scale_size = LARGE
	var finish: Node3D
	for target: Node3D in mission.world_data["interactables"]:
		if target.get_meta("kind", "") == "residential_finish": finish = target
	await _face(finish)
	mission._interact_node(finish)
	if not mission.completed: _fail("Prepared final report failed."); return
	await _shot("16_bilan_17", "Bilan final du 17, onze réceptions et relais vérifié")
	mission._return_to_menu()
	_freeze()
	await _shot("17_menu_17", "Accueil contextuel du dernier point sûr, sans relancer les secours")
	var file := FileAccess.open(output.path_join("MANIFEST.json"), FileAccess.WRITE)
	file.store_string(JSON.stringify({"version":"0.13.0", "engine":Engine.get_version_info().string, "display":DisplayServer.get_name(), "renderer":RenderingServer.get_current_rendering_method(), "captures":shots, "prepared_states":true, "human_playthrough":false},"\t"))
	file.close()
	mission.free()
	for path: String in [SAVE,PREFS]:
		if FileAccess.file_exists(path): DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
	print("PASS residential native captures: %d checks; prepared camera states, renderer=%s" % [shots.size(),expected_renderer])
	get_tree().quit()

func _action(id: String, tool: String) -> bool:
	var target: Node3D = mission.residential_visuals.action_targets[id]
	await _face(target)
	mission._select_equipment(tool)
	mission._interact_node(target)
	for tick: int in range(70): mission._process_residential_action(0.05, 1)
	if not mission.residential.has_action(id): _fail("Action failed: " + id); return false
	return true

func _face(target: Node3D) -> void:
	Interaction.face(mission,target)
	if target.get_meta("action_id", "") == "service_access":
		mission.player.global_position = target.global_position + Vector3(0,0.06,-1.3)
	mission.player.camera.look_at(target.global_position + target.get_meta("focus_offset",Vector3.UP*1.2))
	mission.last_floor = mission.player.nearest_floor()
	if mission.last_floor not in mission.seen_floors: mission.seen_floors.append(mission.last_floor)
	mission.radio.reset()
	mission._sync_radio()
	mission.hud.show_game()
	_freeze()
	await _settle()
	mission._find_nearest()
	mission._update_hud()

func _view(position_value: Vector3, target: Vector3) -> void:
	var floor_number := clampi(roundi((position_value.y-0.06)/6.0)+24,17,31)
	mission.player.teleport_to_floor(floor_number)
	mission.player.global_position = position_value
	mission.player.velocity = Vector3.ZERO
	mission.player.camera.current = true
	mission.player.camera.look_at(target)
	mission.player.active = true
	mission.last_floor = floor_number
	if floor_number not in mission.seen_floors: mission.seen_floors.append(floor_number)
	mission.radio.reset()
	mission._sync_radio()
	mission.hud.show_game()
	mission.hud.notify_label.text = ""
	_freeze()
	await _settle()
	mission._find_nearest()
	mission._update_hud()

func _scroll_people_to(person_name: String) -> void:
	# Scroll the real reader after layout; never substitute or shorten the dossier text.
	for tick: int in range(6): await get_tree().process_frame
	var reader: RichTextLabel = mission.hud.journal_text
	var paragraphs: PackedStringArray = reader.text.split("\n")
	for paragraph: int in range(paragraphs.size()):
		if paragraphs[paragraph] == person_name:
			reader.scroll_to_paragraph(paragraph)
			return
	_fail("Missing prepared dossier person: " + person_name)

func _shot(name_value: String, description: String) -> void:
	if expected_renderer == "forward_plus" and name_value not in FORWARD_SHOTS: return
	if mission.started and mission.player.camera.current and mission.hud.game.visible:
		mission._process_equipment(0.0,0)
		mission._update_hud()
	for tick: int in range(16 if expected_renderer == "forward_plus" else 6):
		await get_tree().process_frame
		await RenderingServer.frame_post_draw
	var captured: Image = get_viewport().get_texture().get_image()
	if captured == null or captured.is_empty() or captured.get_size() != capture_size:
		_fail("Invalid native image size: " + name_value); return
	var path := output.path_join(name_value+".png")
	if captured.save_png(path) != OK: _fail("Cannot save " + path); return
	shots.append({"file":name_value+".png","description":description,"width":captured.get_width(),"height":captured.get_height(),"sha256":FileAccess.get_sha256(path)})
	print("CAPTURE "+name_value)

func _checkpoint() -> Dictionary:
	return {"version":Store.SAVE_VERSION,"seed":271104,"floor":20,"health":91.0,"oxygen":83.0,"stress":29.0,"anchors":4,"flares":2,
		"rescued":["survivor_30","survivor_28","survivor_26"],"clues":["evidence_29","evidence_27","evidence_26","continuation_model_23","continuation_photo_23","commerce_deliveries_22","commerce_maintenance_21"],"supplies_used":["equipment_fire_28"],"elapsed":1600.0,
		"seen_floors":[31,30,29,28,27,26,25,24,23,22,21,20],"completed":true,"incident_state":"aftermath","transmissions":[],"radio_events":["bravo_echo","bravo_verification"],
		"continuation":{"phase":"complete","started_at_refuge":true,"duo_briefed":true,"escort_state":"received"},
		"commerce":{"phase":"complete","actions":["shutter","isolation","blanket","relay"],"people":{"mina":"received","theo":"received","sofia":"received"},"contacted":["mina","theo","sofia"]},"residential":Residential.dormant_state()}

func _freeze() -> void:
	mission.set_process(false)
	mission.set_physics_process(false)
	mission.player.set_process(false)
	mission.player.set_physics_process(false)
	mission.world.set_process(false)

func _settle() -> void:
	await get_tree().physics_frame
	await get_tree().physics_frame

func _fail(message: String) -> void:
	push_error(message)
	get_tree().quit(1)
