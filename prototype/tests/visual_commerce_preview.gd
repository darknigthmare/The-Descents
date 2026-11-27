extends Node
## Prepared native scenes, not a human playthrough. The headless check mode
## exercises the same mission/UI interactions but never writes image evidence.
const MainScene = preload("res://scenes/main.tscn")
const Store = preload("res://scripts/save_store.gd")
const Preferences = preload("res://scripts/preferences_store.gd")
const Commerce = preload("res://scripts/commerce_director.gd")
const Presentation = preload("res://scripts/commerce_presentation.gd")
const Dossier = preload("res://scripts/mission_dossier.gd")
const Routes = preload("res://scripts/route_catalog.gd")
const SAVE := "user://qa_commerce_review_v012.json"
const PREFS := SAVE + ".cfg"
const LARGE := Vector2i(1440, 900)
const COMPACT := Vector2i(1024, 640)
const FORWARD_SHOTS := ["02_gallery_22", "07_kitchen_before", "11_refuge_20"]
var output := "res://../docs/captures/v0.12/commerce/compatibility"
var expected_renderer := "gl_compatibility"
var check_only := false
var mission: Node3D
var shots: Array[Dictionary] = []
var checks := 0
var failed := false
var capture_size := LARGE

func _ready() -> void:
	_capture.call_deferred()

func _capture() -> void:
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with("--capture-root="): output = argument.trim_prefix("--capture-root=")
		elif argument.begins_with("--expected-renderer="): expected_renderer = argument.trim_prefix("--expected-renderer=")
		elif argument == "--fixture-check-only": check_only = true
	if not check_only:
		if not _require(DisplayServer.get_name() != "headless" and RenderingServer.get_current_rendering_method() == expected_renderer, "Native display and requested renderer are required for image evidence."): return
		DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(output))
	get_window().size = LARGE
	get_window().content_scale_size = LARGE
	_clean()
	Preferences.save_settings(Preferences.normalize({"audio": false, "startup_intro": false, "reduced_motion": true}), PREFS)
	if not _require(Store.save_data(_checkpoint(), SAVE) == OK, "Prepared prior chapter cannot be saved."): return
	mission = MainScene.instantiate()
	mission.save_path = SAVE
	mission.preferences_path = PREFS
	add_child(mission)
	mission._continue_game()
	_freeze()
	await _settle()
	if not _require(mission.hud.end_panel.visible and mission.hud.end_panel.descent_button.visible and mission.commerce.phase == "dormant", "The 23 debrief lost its explicit commerce choice."): return
	await _shot("01_bilan_23", "Bilan du 23 et choix explicite de poursuivre ; cinq réceptions antérieures conservées")
	mission.hud.end_panel.descent_button.pressed.emit()
	_freeze()
	await _settle()
	if not _require(mission.commerce.phase == "active" and not mission.completed and mission.world_data["routes"].size() == 12, "The actual continuation button did not open the commerce chapter."): return
	if not _require(Store.load_data(SAVE).get("commerce", {}).get("phase") == "active", "Commerce began before its durable checkpoint."): return
	mission.radio.reset()
	mission._sync_radio()
	await _view(Vector3(4.6, -11.94, -3.7), Vector3(8.0, -10.25, 5.8))
	await _shot("02_gallery_22", "Galerie au 22 : terrazzo, vitrines importées et circulations latérales")
	await _view(Vector3(8.0, -11.94, -3.8), Vector3(8.0, -10.7, -6.1))
	await _shot("03_mina_shutter_closed", "Volet fermé ; Mina reste dans la réserve avant intervention au Halligan")
	var shutter: Node3D = mission.commerce_visuals.action_targets["shutter"]
	mission._select_equipment("fire_axe")
	mission._interact_node(shutter)
	if not _require(mission.commerce.active_action.is_empty(), "The wrong tool began the shutter action."): return
	mission._select_equipment("halligan")
	mission._interact_node(shutter)
	mission._process_commerce_action(0.25, 1)
	mission.player.camera.look_at(Vector3(8.0, -10.2, 4.0))
	mission._process_commerce_action(0.25, 1)
	if not _require(mission.commerce.active_action.is_empty() and not mission.commerce.has_action("shutter"), "Looking away completed an interrupted worksite."): return
	if not await _action("shutter", Vector3(8.0, -11.94, -3.8), "halligan"): return
	if not _require(mission.commerce_visuals.shutter_body.collision_layer == 0, "The open shutter left an invisible barrier."): return
	await _shot("04_mina_shutter_open", "Volet soulevé après maintien réel de l’action ; passage et personne visibles")
	await _view(Vector3(8.0, -11.94, -6.8), mission.commerce_visuals.people["mina"].global_position + Vector3.UP * 1.2)
	mission._interact_node(mission.commerce_visuals.person_targets["mina"])
	if not _require(mission.commerce.person_state("mina") == "following", "Released Mina could not receive the follow signal."): return
	var saved_follow: Dictionary = Store.load_data(SAVE)
	if not _require(saved_follow.get("commerce", {}).get("people", {}).get("mina") == "waiting" and mission.commerce.person_state("mina") == "following", "Checkpoint serialization changed live escort state or stored transient motion."): return
	var position_before: Vector3 = mission.commerce_visuals.people["mina"].global_position
	mission._pause()
	mission._process_commerce(0.05)
	if not _require(mission.commerce_visuals.people["mina"].global_position == position_before, "A paused escort continued moving."): return
	mission._resume()
	_freeze()
	await _view(Vector3(-8.4, -11.94, -6.2), Vector3(-8.4, -10.5, -8.1))
	_lamp(true)
	mission.commerce_visuals._sample_resident(mission.player.global_position, true)
	if not _require(mission.commerce_visuals.resident_pressure(mission.player.global_position, true) > 0.0, "The close lamp posture did not raise local tension."): return
	await _shot("05_retranche_close", "Le Retranché protège son visage à courte distance ; consigne de recul visible")
	mission._interact_node(mission.commerce_visuals.action_targets["resident"])
	if not _require(mission.commerce.active_action.is_empty(), "Dialogue accepted a raised lamp or unsafe distance."): return
	_lamp(false)
	if not await _action("resident", Vector3(-8.4, -11.94, -5.3), "halligan"): return
	if not _require(mission.commerce_visuals.resident_pressure(mission.player.global_position, false) == 0.0, "The calmed resident kept applying pressure."): return
	await _shot("06_retranche_calm", "Distance conservée, lampe baissée et dialogue achevé ; les bras sont abaissés")
	_lamp(true)
	await _view(Vector3(5.3, -17.94, -2.8), Vector3(9.7, -16.25, 3.2))
	if not _require(mission.commerce_visuals.smoke_exposure(Vector3(8.0, -17.94, 3.0)), "Active kitchen smoke is missing from its local hazard volume."): return
	await _shot("07_kitchen_before", "Office au 21 : matériels importés, foyer local et fumée avant intervention")
	await _view(Vector3(8.4, -17.94, -1.7), Vector3(8.4, -16.8, 0.55))
	mission._interact_node(mission.commerce_visuals.action_targets["blanket"])
	if not _require(mission.commerce.active_action.is_empty(), "Blanket deployment bypassed circuit isolation."): return
	if not await _action("isolation", Vector3(6.0, -17.94, 0.7), "halligan"): return
	if not await _action("blanket", Vector3(8.4, -17.94, -1.7), "halligan"): return
	if not _require(not mission.commerce_visuals.smoke_exposure(Vector3(8.0, -17.94, 3.0)) and mission.commerce_visuals.blanket_mesh.visible and not mission.commerce_visuals.fire_group.visible, "The completed intervention did not remove the local fire hazard."): return
	await _view(Vector3(5.3, -17.94, -2.8), Vector3(9.7, -16.25, 3.2))
	await _shot("08_kitchen_after", "Réchauffeur isolé, couverture déployée et foyer contenu")
	await _view(Vector3(3.7, -11.94, -4.2), Vector3(-0.3, -14.0, -8.4))
	await _shot("09_stairs_22_21", "Escalier local nord 22–21, indépendant des liaisons voisines")
	var route: Dictionary = Routes.for_id("R22_21")
	await _view(route["top_entry"], route["rope_top"] + Vector3.DOWN)
	mission.player.active = true
	if not _require(mission.player.engage_rope(22, "R22_21"), "The new optional rope cannot be engaged."): return
	for tick: int in range(25):
		mission.player._process_rope(0.05)
		await get_tree().physics_frame
	Input.action_press("move_back")
	for tick: int in range(35):
		mission.player._process_rope(0.05)
		await get_tree().physics_frame
	Input.action_release("move_back")
	mission.player.camera.look_at(Vector3(-1.1, -17.0, -0.5))
	if not _require(mission.player.on_rope and mission.player.rope_snapshot().get("route_id") == "R22_21", "Rope preparation lost the attached local route."): return
	await _shot("10_rope_22_21", "État physique préparé sur le rappel optionnel 22–21, descendeur et mesures actifs")
	await _view(Vector3(4.5, -23.94, 0.0), Vector3(8.0, -22.55, 7.0))
	await _shot("11_refuge_20", "Refuge 20 avant réception : lits, paravents, eau et repères d’accueil")
	mission._process_commerce(0.05)
	if not _require(mission.commerce.received_count() == 0, "A distant escort was received without arriving."): return
	# Deliberate final-arrival fixture: full unteleported journeys are checked
	# independently by test_commerce_routes.gd. This prepares the real receipt UI.
	for id: String in Commerce.PERSON_IDS:
		mission.commerce.state["people"][id] = "following"
		if id not in mission.commerce.state["contacted"]: mission.commerce.state["contacted"].append(id)
		mission.commerce_visuals.people[id].global_position = Presentation.RECEIVING[id]
		mission.commerce_visuals.people[id].velocity = Vector3.ZERO
		mission.commerce_visuals.cursors[id] = mission.commerce_visuals.paths[id].size()
		mission.commerce_visuals.arrived[id] = true
	mission.commerce_visuals.apply_state(mission.commerce.snapshot())
	await _settle()
	for tick: int in range(12):
		mission._process_commerce(1.0 / 60.0)
		await get_tree().physics_frame
	if not _require(mission.commerce.received_count() == 3 and Dossier.build(mission._dossier_snapshot())["total_received"] == 8, "Real mission reception did not preserve and combine the eight rescue records."): return
	await _shot("12_receptions_20", "État de réception préparé des trois personnes au refuge 20 ; parcours testés séparément")
	if not await _collect("commerce_deliveries_22", Vector3(10.2, -11.94, 6.1)): return
	if not await _collect("commerce_maintenance_21", Vector3(-8.7, -17.94, 5.0)): return
	if not await _action("relay", Vector3(-7.7, -23.94, -3.6), "halligan"): return
	await _view(Vector3(4.5, -23.94, 0.0), Vector3(8.0, -22.55, 7.0))
	mission._open_journal()
	mission.hud.journal_panel.select_tab("survivors")
	if not _require(mission.paused and mission.hud.journal_panel.visible, "The journal did not pause the active mission."): return
	await _shot("13_journal_people", "Dossier des huit personnes, avec leurs lieux de réception distincts")
	mission.hud.journal_panel.select_tab("clues")
	await get_tree().process_frame
	mission.hud.journal_text.get_v_scroll_bar().value = mission.hud.journal_text.get_v_scroll_bar().max_value
	await _shot("14_journal_clues", "Constats effectivement recueillis ; registre et maintenance antérieurs au séisme")
	mission._resume()
	_freeze()
	await _view(Vector3(-7.7, -23.94, -5.4), Vector3(-7.7, -22.7, -7.8))
	mission._interact_node(_object("commerce_finish_20"))
	if not _require(mission.completed and mission.commerce.phase == "complete" and mission.hud.end_panel.visible, "A valid refuge report could not complete through its real terminal."): return
	if not _require(mission.hud.end_panel.descent_button.visible and mission.hud.end_panel.descent_button.text == "Poursuivre vers les résidences" and Store.load_data(SAVE).get("floor") == 20, "The refuge report lost its residential continuation or its safe landing."): return
	await _shot("15_bilan_20", "Bilan au refuge 20 : trois nouvelles réceptions, cinq anciennes conservées")
	mission._return_to_menu()
	_freeze()
	await _shot("16_menu_20", "Accueil contextuel correspondant au point de reprise du refuge 20")
	mission._continue_game()
	_freeze()
	await _settle()
	if not _require(mission.completed and mission.commerce.received_count() == 3 and Dossier.build(mission._dossier_snapshot())["total_received"] == 8, "Reloading the completed report lost a rescue receipt."): return
	capture_size = COMPACT
	get_window().size = COMPACT
	get_window().content_scale_size = COMPACT
	mission._open_journal()
	mission.hud.journal_panel.select_tab("survivors")
	await _shot("17_compact_journal", "Journal en fenêtre 1024 × 640 ; navigation et huit personnes accessibles")
	mission._resume()
	_freeze()
	await _shot("18_compact_bilan", "Bilan final en fenêtre 1024 × 640, contrôles de retour accessibles")
	if failed: return
	if not check_only:
		if not _require(shots.size() == (3 if expected_renderer == "forward_plus" else 18), "The exact native capture set is incomplete."): return
		var manifest: Dictionary = {"version": ProjectSettings.get_setting("application/config/version"), "engine": Engine.get_version_info().get("string"), "display": DisplayServer.get_name(), "rendering_method": RenderingServer.get_current_rendering_method(), "prepared_states": true, "human_playthrough": false, "captures": shots}
		var file := FileAccess.open(output.path_join("MANIFEST.json"), FileAccess.WRITE)
		file.store_string(JSON.stringify(manifest, "\t"))
		file.close()
	mission.free()
	_clean()
	print("PASS commerce integration: %d checks; real tool actions, interruptions, dialogue, journal, stable receipts and final report. Prepared placements, not a human playthrough; %d native captures." % [checks, shots.size()])
	get_tree().quit(0)

func _action(id: String, position_value: Vector3, tool: String) -> bool:
	var target: Node3D = mission.commerce_visuals.action_targets[id]
	await _view(position_value, target.global_position + target.get_meta("focus_offset", Vector3.UP * 1.2))
	mission._select_equipment(tool)
	if not _require(mission._commerce_action_context(target), "Action has no physically visible supported context: " + id): return false
	mission._interact_node(target)
	if not _require(mission.commerce.active_action == id, "Cannot begin action: " + id): return false
	for tick: int in range(80): mission._process_commerce_action(0.05, 1)
	return _require(mission.commerce.has_action(id) and mission.commerce.active_action.is_empty(), "Held action did not complete exactly once: " + id)

func _collect(id: String, position_value: Vector3) -> bool:
	var target: Node3D = _object(id)
	await _view(position_value, target.global_position + target.get_meta("focus_offset", Vector3.UP * 1.2))
	mission._interact_node(target)
	return _require(id in mission.clues and target.get_meta("used", false), "A reachable clue could not be recorded: " + id)

func _view(position_value: Vector3, target: Vector3) -> void:
	var floor_number := clampi(roundi((position_value.y - 0.06) / 6.0) + 24, 20, 31)
	mission.player.teleport_to_floor(floor_number)
	mission.player.position = position_value
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

func _shot(name_value: String, description: String) -> void:
	if check_only:
		await _settle()
		return
	if expected_renderer == "forward_plus" and name_value not in FORWARD_SHOTS: return
	if mission.started and mission.player.camera.current and mission.hud.game.visible:
		mission._process_equipment(0.0, 0)
		mission._update_hud()
	for frame: int in range(24 if expected_renderer == "forward_plus" else 6):
		await get_tree().process_frame
		await RenderingServer.frame_post_draw
	var captured: Image = get_viewport().get_texture().get_image()
	if not _require(captured != null and not captured.is_empty() and captured.get_size() == capture_size, "Invalid native image dimensions: " + name_value): return
	var path := output.path_join(name_value + ".png")
	if not _require(captured.save_png(path) == OK, "Cannot save image: " + name_value): return
	shots.append({"file": name_value + ".png", "description": description, "width": captured.get_width(), "height": captured.get_height(), "sha256": FileAccess.get_sha256(path), "prepared_state": true, "human_playthrough": false})
	print("CAPTURE " + name_value)

func _checkpoint() -> Dictionary:
	return {"version": Store.SAVE_VERSION, "seed": 271104, "floor": 23, "health": 92.0, "oxygen": 83.0, "stress": 20.0, "anchors": 4, "flares": 2,
		"rescued": ["survivor_30", "survivor_28", "survivor_26"], "clues": ["evidence_29", "evidence_27", "evidence_26", "continuation_model_23", "continuation_photo_23"], "supplies_used": [], "elapsed": 1450.0,
		"seen_floors": [31,30,29,28,27,26,25,24,23], "completed": true, "incident_state": "aftermath", "transmissions": [], "radio_events": [],
		"continuation": {"phase": "complete", "started_at_refuge": true, "duo_briefed": true, "escort_state": "received"}, "commerce": Commerce.dormant_state(), "residential": preload("res://scripts/residential_director.gd").dormant_state()}

func _freeze() -> void:
	mission.set_process(false)
	mission.set_physics_process(false)
	mission.player.set_process(false)
	mission.player.set_physics_process(false)
	mission.world.set_process(false)

func _settle() -> void:
	await get_tree().physics_frame
	await get_tree().physics_frame

func _lamp(enabled: bool) -> void:
	mission.player.lamp_enabled = enabled
	mission.player.flashlight.visible = enabled

func _object(id: String) -> Node3D:
	for object: Node3D in mission.world_data.get("interactables", []):
		if object.get_meta("id", "") == id: return object
	_require(false, "Missing commerce object: " + id)
	return null

func _require(condition: bool, message: String) -> bool:
	checks += 1
	if not condition:
		failed = true
		push_error(message)
		get_tree().quit(1)
	return condition

func _clean() -> void:
	for path: String in [SAVE, PREFS]:
		if FileAccess.file_exists(path): DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
