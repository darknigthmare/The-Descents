extends SceneTree
## External smoke test: run from an EMPTY directory, with the EXE/PCK mounted
## by --main-pack and this script supplied by its absolute filesystem path.
## This script is excluded from the exported resources and is counted separately.

const Store = preload("res://scripts/save_store.gd")
const Preferences = preload("res://scripts/preferences_store.gd")
const Director = preload("res://scripts/cinematic_director.gd")
const FieldProps = preload("res://scripts/field_props.gd")
const Dossier = preload("res://scripts/mission_dossier.gd")
const DossierPanel = preload("res://scripts/mission_dossier_panel.gd")
const Epilogue = preload("res://scripts/epilogue_director.gd")
const Horror = preload("res://scripts/horror_director.gd")
const HorrorPresentation = preload("res://scripts/horror_presentation.gd")
const Routes = preload("res://scripts/route_catalog.gd")
const Rope = preload("res://scripts/rope_traversal.gd")
const RopePresentation = preload("res://scripts/rope_presentation.gd")
const Continuation = preload("res://scripts/continuation_director.gd")
const ContinuationPresentation = preload("res://scripts/continuation_presentation.gd")
const Commerce = preload("res://scripts/commerce_director.gd")
const CommercePresentation = preload("res://scripts/commerce_presentation.gd")
const CommerceAssets = preload("res://scripts/commerce_asset_catalog.gd")
const Residential = preload("res://scripts/residential_director.gd")
const ResidentialPresentation = preload("res://scripts/residential_presentation.gd")
const ResidentialAssets = preload("res://scripts/residential_asset_catalog.gd")
const RescueAssets = preload("res://scripts/rescue_asset_catalog.gd")
const Surfaces = preload("res://scripts/surface_materials.gd")
const Equipment = preload("res://scripts/equipment_director.gd")
const TEST_PATH: String = "user://qa_v013_external_pack.json"
const PREFS_PATH: String = "user://qa_v013_external_pack.cfg"
const COMMERCE_MODELS: Array[String] = ["retail_display_case", "cash_register", "shutter_control", "service_trolley", "industrial_sink", "kitchen_stove", "extraction_hood", "utility_cutoff_panel", "fire_blanket_cabinet", "folding_cot", "water_canister", "privacy_screen"]
const RESIDENTIAL_MODELS: Array[String] = ["rest_armchair", "medicine_cabinet", "resident_bookcase", "coffee_table", "reading_lamp", "wall_intercom", "service_latch_panel", "telecom_rack", "patch_panel", "ups_battery", "relay_console", "voice_recorder"]
var failures: Array[String] = []
var checks: int = 0


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	_cleanup()
	_check(RescueAssets.all_ids().size() == 16, "The exported kit lost an authored rescue model.")
	for id: String in RescueAssets.all_ids():
		_check(ResourceLoader.exists(RescueAssets.asset_path(id)), "Missing exported model: " + id)
		var model: Node3D = RescueAssets.instantiate(id)
		_check(is_instance_valid(model), "Exported GLB cannot instantiate: " + id)
		if is_instance_valid(model): model.free()
	for id: String in ["salt_concrete", "smoked_oak", "dark_stone", "brushed_steel", "rescue_red_paint", "black_rubber", "teal_carpet", "porcelain_tile"]:
		var texture: Texture2D = load("res://assets/materials/v011/" + id + ".png")
		_check(texture != null and texture.get_width() == 1254 and texture.get_height() == 1254, "Missing or resized exported albedo: " + id)
	_test_packed_commerce_assets()
	_test_packed_residential_assets()
	var kit = Equipment.new()
	kit.select_tool("extinguisher")
	_check(kit.begin("equipment_fire_28"), "Packed equipment cannot begin its contextual action.")
	for tick: int in range(24): kit.advance(0.125, true, true)
	_check(kit.charges_left() == 2 and "equipment_fire_28" in kit.completed, "Packed extinguisher action or receipt is missing.")
	_check(not ResourceLoader.exists("res://tests/test_equipment.gd") and not ResourceLoader.exists("res://tests/test_rescue_assets_v011.gd"), "New developer tests shipped in the pack.")
	_check(ProjectSettings.get_setting("application/config/version", "") == "0.13.0", "Packed project has the wrong application version.")
	_check(not ResourceLoader.exists("res://tests/test_save.gd") and not ResourceLoader.exists("res://tests/test_cinematic_integration.gd"), "Developer tests unexpectedly shipped inside the pack.")
	var scene: PackedScene = load("res://scenes/main.tscn")
	_check(scene != null, "The mounted pack has no loadable main scene.")
	if scene == null:
		_cleanup()
		_finish()
		return
	_check(Preferences.save_settings({"audio": false, "reduced_motion": true, "flashes": false, "startup_intro": false}, PREFS_PATH) == OK, "Packed preferences code could not write an isolated valid configuration.")
	var mission: Node3D = scene.instantiate()
	mission.save_path = TEST_PATH
	mission.preferences_path = PREFS_PATH
	mission.sound_enabled = false
	root.add_child(mission)
	_disable_ticks(mission)
	await process_frame
	_check(not mission.started and mission.hud.menu.visible and not mission.hud.cinematic.visible and mission.menu_context["id"] == "approach", "Packed scene failed to enter its accessible initial menu.")
	_check(mission.world_data.get("helicopters", []).size() == 2 and mission.world_data.get("rotors", []).size() == 2, "Mounted resources lost one of the two rescue helicopters.")
	_check(ResourceLoader.exists("res://scripts/rescue_presentation.gd") and ResourceLoader.exists("res://scripts/maritime_atmosphere.gd"), "The mounted pack lost the v0.6 rescue or atmosphere module.")
	_check(ResourceLoader.exists("res://scripts/mission_dossier.gd") and ResourceLoader.exists("res://scripts/mission_dossier_panel.gd") and ResourceLoader.exists("res://scripts/epilogue_director.gd"), "The mounted pack lost a v0.7 dossier or epilogue module.")
	_check(not ResourceLoader.exists("res://tests/test_mission_dossier.gd") and not ResourceLoader.exists("res://tests/test_epilogue.gd") and not ResourceLoader.exists("res://tests/test_epilogue_integration.gd"), "The v0.7 developer tests unexpectedly shipped inside the pack.")
	_check(mission.rescue_visuals != null and mission.rescue_visuals.is_inside_tree(), "The exported main scene did not instantiate its rescue presentation.")
	var director = Director.new()
	director.start("boot")
	_check(director.duration() == 15.0 and director.presentation()["card"] == "studio", "Packed studio director is missing or outdated.")
	director.start("arrival")
	_check(director.duration() == 28.0 and director.advance(28.0).size() == 4, "Packed arrival director lost its duration or four cues.")
	var approach: Dictionary = Director.staging_sample(3.0)
	var parked: Dictionary = Director.staging_sample(28.0)
	_check(approach.get("aircraft", []).size() == 2 and parked.get("aircraft", []).size() == 2 and approach["aircraft"][0]["offset"].distance_to(parked["aircraft"][0]["offset"]) > 1.0, "Packed arrival has no actual aircraft approach motion.")
	var epilogue = Epilogue.new()
	epilogue.start()
	_check(epilogue.active and epilogue.duration() == 15.0, "Packed closing director did not start its fifteen-second sequence.")
	for shot: int in range(3):
		epilogue.elapsed = float(shot) * 5.0 + 2.5
		var card: Dictionary = epilogue.presentation()
		var camera: Dictionary = epilogue.camera_sample()
		_check(card["card"] == "epilogue" and card["shot"] == shot and not str(card["message"]).is_empty() and (camera["position"] as Vector3).is_finite() and (camera["target"] as Vector3).is_finite(), "Packed closing director lost a staged shot or transmission.")
	epilogue.finish()
	_check(not epilogue.active and epilogue.elapsed == 15.0 and epilogue.presentation()["progress"] == 1.0, "Packed closing director did not reach its stable final state.")
	_check(ResourceLoader.exists("res://scripts/horror_director.gd") and ResourceLoader.exists("res://scripts/horror_presentation.gd"), "The mounted pack lost the v0.8 perception director or presentation module.")
	_check(not ResourceLoader.exists("res://tests/test_horror.gd") and not ResourceLoader.exists("res://tests/test_horror_integration.gd"), "The v0.8 developer tests unexpectedly shipped inside the pack.")
	var perception = Horror.new()
	perception.reset()
	var dormant: Dictionary = perception.advance(20.0, {"running": false})
	_check(float(dormant.get("suites_alpha", 0.0)) == 0.0 and float(dormant.get("trace_alpha", 0.0)) == 0.0 and float(dormant.get("spa_alpha", 0.0)) == 0.0 and perception.elapsed == 0.0, "The packed perception director advanced or exposed an anomaly outside live gameplay.")
	var detached_frame: Dictionary = perception.presentation()
	detached_frame["spa_alpha"] = 1.0
	_check(float(perception.presentation().get("spa_alpha", 0.0)) == 0.0, "The packed director exposes a mutable alias of its live frame.")
	var perception_visuals = HorrorPresentation.new()
	mission.world.add_child(perception_visuals)
	perception_visuals.build(mission.world)
	_check(is_instance_valid(perception_visuals.suites_figure) and is_instance_valid(perception_visuals.trace_root) and is_instance_valid(perception_visuals.spa_figure), "Packed perception presentation failed to create its three authored anchors.")
	_check(_perception_colliders(perception_visuals) == 0, "Packed perceptive manifestations added a collider to the playable rescue routes.")
	perception_visuals.sample({"suites_alpha": 0.3, "trace_alpha": 0.3, "trace_progress": 1.0, "spa_alpha": 0.3}, true)
	_check(perception_visuals.suites_figure.visible and perception_visuals.trace_root.visible and perception_visuals.spa_figure.visible, "The packed presentation cannot display the sampled manifestations with reduced motion.")
	perception_visuals.clear()
	_check(not perception_visuals.suites_figure.visible and not perception_visuals.trace_root.visible and not perception_visuals.spa_figure.visible, "The packed perception presentation did not clear all three manifestations.")
	perception_visuals.free()
	var uncertain_steps: AudioStream = load("res://assets/audio/uncertain_steps.wav")
	_check(uncertain_steps != null and uncertain_steps.get_length() > 0.0, "The mounted pack is missing the imported positional footstep cue.")
	_check(ResourceLoader.exists("res://scripts/route_catalog.gd") and ResourceLoader.exists("res://scripts/rope_traversal.gd") and ResourceLoader.exists("res://scripts/rope_presentation.gd"), "The mounted pack lost a v0.9 route, rope control or descender-presentation module.")
	_check(not ResourceLoader.exists("res://tests/test_rope_traversal.gd") and not ResourceLoader.exists("res://tests/test_vertical_routes.gd") and not ResourceLoader.exists("res://tests/test_traversal_integration.gd"), "The v0.9 developer tests unexpectedly shipped inside the pack.")
	var local_routes: Array[Dictionary] = Routes.all_routes()
	_check(local_routes.size() == 6 and Routes.validate(local_routes).is_empty(), "The packed route catalogue does not preserve its six adjacent links.")
	var route_kinds: Array[String] = []
	for route: Dictionary in local_routes:
		route_kinds.append(str(route["kind"]))
	_check(route_kinds == ["rope", "stairs", "rope", "stairs", "rope", "stairs"], "The packed route catalogue no longer alternates local holes and stairs.")
	_check(mission.world_data.get("routes", []).size() == 6, "The exported scene failed to build the catalogue's six local routes.")
	_check(is_instance_valid(mission.player.rope_presentation) and mission.player.rope_presentation.get_script() == RopePresentation, "The packed player is missing its sampled descender and hands.")
	var belay = Rope.new()
	var upper_route: Dictionary = Routes.for_id("R31_30")
	_check(belay.attach(upper_route,31,80.0), "A packed local rope cannot attach at its upper landing.")
	var moving_rope: Dictionary = belay.advance(0.5,{"running":true,"vertical":1.0,"wind_strength":0.0})
	_check(moving_rope["position"].y < upper_route["rope_top"].y and moving_rope["speed"] > 0.0 and not moving_rope["can_exit"], "The packed descender does not move under control or allows a moving dismount.")
	_check(belay.toggle_lock() and belay.snapshot()["locked"] and belay.snapshot()["speed"] == 0.0, "Packed persistent lock does not hold immediately.")
	var locked_rope: Dictionary = belay.snapshot()
	_check(belay.advance(20.0,{"running":false,"vertical":1.0}) == locked_rope, "A paused exported belay advances position, time or endurance.")
	_check(belay.secure() and not belay.secure(), "Packed stabilizer can be refreshed while active or refuses its first use.")
	belay.toggle_lock()
	var lower_rope: Dictionary = belay.advance(20.0,{"running":true,"vertical":1.0,"wind_strength":0.0})
	_check(lower_rope["position"] == upper_route["rope_bottom"] and lower_rope["exit_floor"] == 30 and lower_rope["landing"] == upper_route["bottom_entry"], "The packed personal rope bypasses its one-floor limit or loses its safe landing.")
	var rope_visuals = RopePresentation.new()
	mission.player.camera.add_child(rope_visuals)
	rope_visuals.sample(lower_rope,true)
	_check(rope_visuals.visible and is_instance_valid(rope_visuals.lever) and is_instance_valid(rope_visuals.left_hand) and is_instance_valid(rope_visuals.right_hand), "Packed descender presentation cannot instantiate and sample its geometry.")
	_check(_perception_colliders(rope_visuals) == 0, "Packed camera-space rope presentation adds a gameplay collider.")
	belay.toggle_lock()
	rope_visuals.sample(belay.snapshot(),true)
	_check(is_zero_approx(rope_visuals.lever.rotation.z), "Packed descender lever ignores the persistent locked state.")
	belay.detach()
	rope_visuals.sample(belay.snapshot(),true)
	_check(not rope_visuals.visible and not belay.active, "Packed detach leaves a live belay or visible descender presentation.")
	rope_visuals.free()
	_check(ResourceLoader.exists("res://scripts/presentation_geometry.gd") and ResourceLoader.exists("res://shaders/weathered_surface.gdshader") and ResourceLoader.exists("res://shaders/rotor_wash.gdshader"), "The final procedural model or material resources are absent from the pack.")
	_check(mission.audio_score.stream != null and mission.audio_rotors.stream != null, "Export is missing the cinematic audio resources.")
	mission._start_new(928401)
	_disable_ticks(mission)
	mission._process_arrival(3.0)
	var flight_position: Vector3 = mission.world_data["helicopters"][0].global_position
	mission._process_arrival(7.0)
	_check(flight_position.distance_to(mission.world_data["helicopters"][0].global_position) > 1.0 and mission.elapsed == 0.0, "Mounted arrival camera advanced without moving the aircraft, or advanced the mission clock.")
	mission._finish_arrival()
	_disable_ticks(mission)
	_check(mission.started and mission.player.active and mission.player.camera.current and mission.elapsed == 0.0, "The exported new-game/skip path did not return control.")
	_check(mission.world_data["helicopters"][0].global_position.is_equal_approx(mission.world_data["helicopter_origins"][0]) and mission.world_data["helicopters"][1].global_position.is_equal_approx(mission.world_data["helicopter_origins"][1]), "Skipping the packed arrival did not restore both parked aircraft.")
	var inspectable: Array[Node3D] = []
	var roof_register: Node3D
	for object: Node3D in mission.world_data.get("interactables", []):
		if is_instance_valid(object) and object.get_meta("kind", "") == "inspect":
			inspectable.append(object)
			if object.get_meta("id", "") == "inspect_roof_register":
				roof_register = object
	_check(inspectable.size() == 12 and roof_register != null, "Mounted world is missing one or more of its twelve contextual props.")
	if roof_register != null:
		mission.player.teleport_to_floor(31)
		await physics_frame
		await physics_frame
		_check(_face_field(mission, roof_register), "The exported rooftop inspection has no clear reachable standing position.")
		var saved_before_inspection: String = FileAccess.get_file_as_string(TEST_PATH)
		mission._open_inspection(roof_register)
		_check(mission.paused and mission.hud.inspection_panel.visible and not mission.player.active, "Exported field panel did not suspend gameplay.")
		_check(not mission.hud.inspection_panel.title_label.text.is_empty() and not mission.hud.inspection_panel.observation_label.text.is_empty(), "Packed field panel lost its authored content.")
		mission.hud.inspection_panel.close_button.pressed.emit()
		_disable_ticks(mission)
		_check(not mission.paused and mission.player.active and not mission.hud.inspection_panel.visible and FileAccess.get_file_as_string(TEST_PATH) == saved_before_inspection, "Exported inspection close path lost control or rewrote the checkpoint.")
	_check(FieldProps.read("inspect_28_archive", {"incident_state": "intact", "rescued": [], "supplies_used": []}) != FieldProps.read("inspect_28_archive", {"incident_state": "aftermath", "rescued": [], "supplies_used": []}), "Packed archive field note does not reflect the confirmed incident.")
	mission.radio.advance(1000.0)
	mission._sync_radio()
	var received_before: int = mission.radio.history.size()
	mission._say("PACK A", "Première transmission exportée", 8.0)
	mission._say("PACK B", "Deuxième transmission exportée", 8.0)
	_check(mission.radio.current.get("speaker") == "PACK A" and mission.radio.pending.size() == 1 and mission.radio.history.size() == received_before + 2, "Packed radio did not serialize ordinary subtitles.")
	mission._say("PACK PRIORITAIRE", "Consigne prioritaire exportée", 8.0, true)
	_check(mission.radio.current.get("speaker") == "PACK PRIORITAIRE" and mission.radio.pending.is_empty() and mission.radio.history.size() == received_before + 3, "Packed radio priority or journal retention is outdated.")
	mission.incident.restore("aftermath")
	mission.rescued = ["survivor_30", "survivor_28"]
	mission.radio_events = ["bravo_echo", "bravo_verification"]
	mission.world.set_rescued_people(mission.rescued)
	_check(mission._save_checkpoint(27), "The mounted runtime could not create its isolated schema-6 checkpoint.")
	var saved: Dictionary = Store.load_data(TEST_PATH)
	_check(saved.get("version") == Store.SAVE_VERSION and saved.get("radio_events") == mission.radio_events and saved.get("transmissions", []).size() == received_before + 3, "Packed storage lost schema-6 received words or event markers.")
	var before: String = FileAccess.get_file_as_string(TEST_PATH)
	var invalid: Dictionary = saved.duplicate(true)
	invalid["radio_events"] = ["unknown_event"]
	_check(Store.save_data(invalid, TEST_PATH) == ERR_INVALID_DATA and FileAccess.get_file_as_string(TEST_PATH) == before, "Packed validation accepted an invalid event or destroyed its previous checkpoint.")
	mission._restore(saved)
	_disable_ticks(mission)
	_check(mission.player.nearest_floor() == 27 and mission.incident.phase == "aftermath" and mission.rescued == ["survivor_30", "survivor_28"], "Packed loading did not reconstruct the saved floor, incident and rescue progress.")
	_check(not mission.radio.is_busy() and mission.radio.history_snapshot() == saved["transmissions"] and mission.radio_events == saved["radio_events"], "Packed loading replayed or altered the received radio exchange.")
	_check(mission.world.roof_rescued_people["survivor_30"].visible and mission.world.roof_rescued_people["survivor_28"].visible and not mission.world.roof_rescued_people["survivor_26"].visible, "The exported world failed to rebuild the named reception figures.")
	var dossier: Dictionary = Dossier.build(saved)
	_check(dossier["rescued_count"] == 2 and dossier["survivors"][0]["confirmed"] and dossier["survivors"][1]["confirmed"] and not dossier["survivors"][2]["confirmed"], "Packed dossier does not distinguish confirmed rescues from the remaining casualty.")
	_check(dossier["transmissions"] == saved["transmissions"] and dossier["incident_state"] == "aftermath", "Packed dossier lost the received words or confirmed structural situation.")
	_check(mission.hud.journal_panel.get_script() == DossierPanel, "The exported HUD did not instantiate the four-tab dossier panel.")
	mission.hud.journal_panel.present(saved)
	for tab_id: String in ["situation", "survivors", "clues", "transmissions"]:
		mission.hud.journal_panel.select_tab(tab_id)
		_check(mission.hud.journal_panel.selected_tab == tab_id and mission.hud.journal_panel.journal_text.text == dossier["pages"][tab_id], "Packed dossier tab does not display its matching mission projection.")
	_check(FileAccess.get_file_as_string(TEST_PATH) == before and mission.radio.history_snapshot() == saved["transmissions"], "Reading the exported dossier rewrote the checkpoint or received-radio ledger.")
	await _test_packed_continuation(mission)
	await _test_packed_commerce(mission)
	await _test_packed_residential(mission)
	mission.free()
	await process_frame
	await process_frame
	_cleanup()
	_finish()


func _test_packed_continuation(mission: Node3D) -> void:
	_check(Store.SAVE_VERSION == 6 and mission.continuation.phase == "dormant", "The mounted continuation or schema-6 storage is missing.")
	_check(ResourceLoader.exists("res://scripts/continuation_director.gd") and ResourceLoader.exists("res://scripts/continuation_presentation.gd"), "The mounted pack lost a v0.10 mission or world module.")
	for path: String in ["test_continuation.gd", "test_continuation_routes.gd", "test_continuation_integration.gd", "visual_continuation_preview.gd", "visual_continuation_preview.tscn"]:
		_check(not ResourceLoader.exists("res://tests/" + path), "The v0.10 developer fixture unexpectedly ships in the exported pack: " + path)
	var expanded_routes: Array[Dictionary] = Routes.all_routes(true)
	_check(expanded_routes.size() == 8 and Routes.validate(expanded_routes, true).is_empty() and Routes.all_routes().size() == 6, "The mounted optional route graph changed the historical baseline or lacks the extension.")
	_check(Routes.for_id("S25_24")["kind"] == "stairs" and Routes.for_id("S25_24")["top_entry"].z < 0.0 and Routes.for_id("R24_23")["kind"] == "rope", "The pack does not contain the authored north staircase and 24–23 rappel.")
	var lower_belay = Rope.new()
	_check(lower_belay.attach(Routes.for_id("R24_23"), 24), "The mounted rope validator still rejects the lower playable floors.")
	var lower_state: Dictionary = lower_belay.advance(15.0, {"vertical": 1.0, "wind_strength": 0.0})
	_check(lower_state["exit_floor"] == 23 and lower_state["position"] == Routes.for_id("R24_23")["rope_bottom"], "The packed lower belay does not stop on the exhibition landing.")
	# Fixture preparation establishes the already-tested rescue receipts. The
	# chapter transition itself travels through the real visible Button signal.
	mission.hud.journal_panel.hide()
	mission.rescued = Continuation.RESCUE_IDS.duplicate()
	mission.seen_floors = [31, 30, 29, 28, 27, 26, 25]
	mission.incident.restore("aftermath")
	mission.world.set_rescued_people(mission.rescued)
	mission.player.teleport_to_floor(25)
	await physics_frame
	mission._complete_game(false)
	_disable_ticks(mission)
	_check(mission.completed and mission.hud.end_panel.visible and mission.hud.end_panel.descent_button.visible, "The mounted rescue debrief does not expose the next-chapter button.")
	var rescue_save: Dictionary = Store.load_data(TEST_PATH)
	_check(rescue_save.get("completed", false) and rescue_save.get("continuation", {}).get("phase", "") == "dormant", "The rescue debrief fabricated an active continuation before the choice.")
	var stock: Array = [mission.health, mission.oxygen, mission.stress, mission.anchors, mission.flares]
	mission.hud.end_panel.descent_button.pressed.emit()
	_disable_ticks(mission)
	await physics_frame
	await physics_frame
	var started: Dictionary = Store.load_data(TEST_PATH)
	_check(mission.started and not mission.completed and mission.continuation.phase == "active" and mission.player.active, "The mounted debrief button did not resume an active continuation.")
	_check(started.get("version", 0) == Store.SAVE_VERSION and started.get("floor", 0) == 25 and started.get("continuation", {}).get("started_at_refuge", false), "The mounted chapter choice did not first persist a schema-6 refuge checkpoint.")
	_check(mission.rescued == Continuation.RESCUE_IDS and stock == [mission.health, mission.oxygen, mission.stress, mission.anchors, mission.flares], "The packed chapter transition lost earlier rescue receipts or material resources.")
	_check(mission.player.continuation_enabled and mission.world_data.get("routes", []).size() == 8 and mission.world.get_node_or_null("Floor24") != null and mission.world.get_node_or_null("Floor23") != null, "The mounted transition failed to build the new levels or player bounds.")
	var visuals: Node3D = mission.world_data.get("continuation_visuals")
	_check(is_instance_valid(visuals) and visuals.get_script() == ContinuationPresentation and visuals.people.size() == 2 and visuals.escort_state == "waiting", "The exported chapter failed to instantiate its two physical waiting civilians.")
	_check(is_instance_valid(visuals) and not mission.world.continuation_access_cover.visible and not visuals.both_arrived(), "The packed chapter either kept its access shut or invented a reception.")
	for id: String in ["continuation_duo_24", "continuation_model_23", "continuation_photo_23", "continuation_terminal_23"]:
		_check(is_instance_valid(_packed_object(mission, id)), "The mounted scene omitted an authored continuation interaction: " + id)
	mission.player.teleport_to_floor(24)
	mission.seen_floors.append(24)
	await physics_frame
	_check(mission.player.nearest_floor() == 24 and mission._save_checkpoint(24), "The packed runtime cannot record the supported congress landing.")
	var active_save: Dictionary = Store.load_data(TEST_PATH)
	mission._restore(active_save)
	_disable_ticks(mission)
	await physics_frame
	_check(mission.player.nearest_floor() == 24 and mission.continuation.phase == "active" and mission.player.active and not mission.hud.end_panel.visible, "The mounted active save reloads as the old debrief or wrong floor.")
	_check(mission.continuation_visuals.escort_state == "waiting" and not mission.continuation_visuals.both_arrived(), "The packed reload invented an escorted reception.")
	# Read the actual packed evidence objects through normal interaction guards.
	# These placements verify resource/integration delivery, not physical travel.
	mission.player.teleport_to_floor(23)
	mission.seen_floors.append(23)
	await physics_frame
	for id: String in Continuation.PROOF_IDS:
		var object: Node3D = _packed_object(mission, id)
		if not is_instance_valid(object):
			continue
		_check(_face_continuation(mission, object), "Packed evidence has no clear inspection approach: " + id)
		mission._interact_node(object)
		_check(id in mission.clues and object.is_visible_in_tree() and object.get_meta("used", false), "Reading the mounted evidence failed or removed its exhibition prop: " + id)
	var evidence_save: Dictionary = Store.load_data(TEST_PATH)
	_check(evidence_save.get("floor", 0) == 23 and Continuation.has_proofs(evidence_save), "The mounted evidence collection was not retained in the exhibition checkpoint.")
	var before_reload: String = FileAccess.get_file_as_string(TEST_PATH)
	mission._restore(evidence_save)
	_disable_ticks(mission)
	await physics_frame
	_check(mission.player.nearest_floor() == 23 and mission.continuation.phase == "active" and Continuation.has_proofs(mission._dossier_snapshot()), "The mounted lower-floor reload lost its active chapter or discoveries.")
	_check(FileAccess.get_file_as_string(TEST_PATH) == before_reload, "Reading the packed active checkpoint rewrote it.")
	for id: String in Continuation.PROOF_IDS:
		var object: Node3D = _packed_object(mission, id)
		_check(is_instance_valid(object) and object.is_visible_in_tree() and object.get_meta("used", false), "Packed restoration removed or reopened a previously read exhibition prop: " + id)
	var terminal: Node3D = _packed_object(mission, "continuation_terminal_23")
	if is_instance_valid(terminal) and _face_continuation(mission, terminal):
		mission._interact_node(terminal)
		_check(not mission.completed and mission.continuation.phase == "active" and FileAccess.get_file_as_string(TEST_PATH) == before_reload, "The packed exhibition terminal accepts missing civilian reception.")
	else:
		_check(false, "The packed exhibition terminal has no clear interaction approach.")


func _test_packed_commerce_assets() -> void:
	for path: String in ["commerce_director.gd", "commerce_presentation.gd", "commerce_asset_catalog.gd", "surface_materials.gd"]:
		_check(ResourceLoader.exists("res://scripts/" + path), "The mounted pack lost a v0.12 production module: " + path)
	for path: String in ["test_commerce.gd", "test_commerce_routes.gd", "test_commerce_integration.gd", "test_addon_schema.gd", "test_interaction_safety.gd", "test_rope_abort.gd", "interaction_fixture.gd", "visual_commerce_preview.gd", "visual_commerce_preview.tscn"]:
		_check(not ResourceLoader.exists("res://tests/" + path), "A v0.12 developer fixture unexpectedly ships in the pack: " + path)
	_check(CommerceAssets.all_ids().size() == COMMERCE_MODELS.size(), "The packed commerce catalogue lost one of its twelve authored models.")
	for id: String in COMMERCE_MODELS:
		var path: String = CommerceAssets.asset_path(id)
		_check(id in CommerceAssets.all_ids() and path == "res://assets/models/commerce_v012/" + id + ".glb" and ResourceLoader.exists(path), "Missing mounted commerce GLB: " + id)
		var model: Node3D = CommerceAssets.instantiate(id)
		_check(is_instance_valid(model) and _mesh_count(model) > 0, "The mounted commerce GLB has no instantiable mesh: " + id)
		if is_instance_valid(model):
			_check(model.get_meta("authored_model", false) and model.get_meta("commerce_asset_id", "") == id and CommerceAssets.dimensions(id).length() > 0.0, "The packed commerce model lost its authored metadata: " + id)
			model.free()
	var surfaces = Surfaces.new()
	for id: String in ["ivory_terrazzo", "kitchen_sage_tile"]:
		var path: String = Surfaces.asset_path(id)
		_check(path == "res://assets/materials/v012/" + id + ".png" and ResourceLoader.exists(path), "Missing mounted v0.12 albedo or catalogue path: " + id)
		var texture: Texture2D = load(path) as Texture2D
		_check(texture != null and texture.get_width() == 1254 and texture.get_height() == 1254, "The mounted v0.12 albedo is missing or resized: " + id)
		var material: StandardMaterial3D = surfaces.get_surface(id)
		_check(material.albedo_texture == texture and material.get_meta("asset_loaded", false) and material.get_meta("albedo_asset", "") == path and material.uv1_triplanar and material.uv1_world_triplanar, "The packed v0.12 surface silently uses a flat fallback or lost its texture projection: " + id)


func _test_packed_commerce(mission: Node3D) -> void:
	var routes: Array[Dictionary] = Routes.all_routes(true, true)
	_check(routes.size() == 12 and Routes.validate(routes, true, true).is_empty(), "The mounted commerce catalogue lacks its twelve valid adjacent links.")
	_check(Routes.all_routes().size() == 6 and Routes.all_routes(true).size() == 8 and Routes.all_routes(false, true).size() == 6, "The packed commerce graph bypasses the previous chapter or changes a historical route set.")
	for id: String in ["S23_22", "S22_21", "S21_20", "R22_21"]:
		var route: Dictionary = Routes.for_id(id)
		_check(not route.is_empty() and int(route.get("upper", 0)) - int(route.get("lower", 0)) == 1, "A packed commerce link is missing or skips a storey: " + id)
	_check(Routes.for_id("S23_22")["top_entry"].z > 0.0 and Routes.for_id("S22_21")["top_entry"].z < 0.0 and Routes.for_id("S21_20")["top_entry"].z > 0.0, "The packed lower stairs lost their separate south/north/south bays.")
	var belay = Rope.new()
	var optional_rope: Dictionary = Routes.for_id("R22_21")
	_check(belay.attach(optional_rope, 22), "The mounted validator rejects the optional 22–21 belay.")
	var lower: Dictionary = belay.advance(15.0, {"vertical": 1.0, "wind_strength": 0.0})
	_check(lower["exit_floor"] == 21 and lower["position"] == optional_rope["rope_bottom"], "The packed 22–21 belay does not stop on its adjacent lower landing.")
	var upper: Dictionary = belay.advance(15.0, {"vertical": -1.0, "wind_strength": 0.0})
	_check(upper["exit_floor"] == 22 and upper["position"] == optional_rope["rope_top"], "The packed 22–21 belay lost its return ascent.")
	# Establish previously confirmed receipts as fixture data. The following
	# transition still uses the real visible debrief button; no escort is faked.
	var previous: Dictionary = Store.load_data(TEST_PATH)
	previous["floor"] = 23
	previous["completed"] = true
	previous["continuation"] = {"phase": "complete", "started_at_refuge": true, "duo_briefed": true, "escort_state": "received"}
	previous["commerce"] = Commerce.dormant_state()
	var prepared: bool = Store.save_data(previous, TEST_PATH) == OK
	_check(prepared, "The mounted store rejects a valid completed exhibition fixture.")
	if not prepared: return
	mission._restore(Store.load_data(TEST_PATH))
	_disable_ticks(mission)
	await physics_frame
	_check(mission.completed and mission.hud.end_panel.visible and mission.hud.end_panel.descent_button.visible and mission.commerce.phase == "dormant", "The mounted exhibition ending does not offer the commerce continuation.")
	var stock: Array = [mission.health, mission.oxygen, mission.stress, mission.anchors, mission.flares]
	mission.hud.end_panel.descent_button.pressed.emit()
	_disable_ticks(mission)
	await physics_frame
	await physics_frame
	var started: Dictionary = Store.load_data(TEST_PATH)
	_check(mission.started and not mission.completed and mission.commerce.phase == "active" and mission.player.active, "The mounted exhibition button did not begin the playable commerce chapter.")
	_check(started.get("version", 0) == Store.SAVE_VERSION and started.get("floor", 0) == 23 and started.get("commerce", {}).get("phase", "") == "active", "The packed lower chapter began without its durable schema-6 departure checkpoint.")
	_check(mission.rescued == previous["rescued"] and mission.continuation.snapshot() == previous["continuation"] and mission.clues == previous["clues"] and stock == [mission.health, mission.oxygen, mission.stress, mission.anchors, mission.flares], "The packed commerce transition changed previous receipts or material resources.")
	_check(Dossier.build(mission._dossier_snapshot())["total_received"] == 5 and mission.continuation_visuals.both_arrived(), "The packed lower chapter lost or duplicated an earlier civilian reception.")
	_check(mission.player.commerce_enabled and mission.world_data.get("routes", []).size() == 12, "The mounted transition did not enable the lower player bounds and complete route set.")
	for number: int in [22, 21, 20]:
		_check(mission.world.get_node_or_null("Floor%d" % number) != null, "The mounted commerce world omitted floor %d." % number)
	var visuals: Node3D = mission.world_data.get("commerce_visuals")
	_check(is_instance_valid(visuals) and visuals.get_script() == CommercePresentation and visuals.people.size() == 3, "The packed commerce presentation is missing its three physical civilians.")
	var mounted_models: Dictionary = {}
	_collect_commerce_models(mission.world, mounted_models)
	for id: String in COMMERCE_MODELS:
		_check(int(mounted_models.get(id, 0)) > 0, "A commerce model is in the catalogue but absent from the mounted playable world: " + id)
	_check(_has_surface(mission.world.get_node("Floor22"), "ivory_terrazzo") and _has_surface(mission.world.get_node("Floor21"), "kitchen_sage_tile"), "The mounted new floors do not actually use both authored v0.12 textures.")
	for id: String in Commerce.PERSON_IDS:
		_check(is_instance_valid(_packed_object(mission, "commerce_person_" + id)) and visuals.people[id] is CharacterBody3D and not visuals.physically_arrived(id), "A packed civilian lacks its physical interaction or already invents a refuge receipt: " + id)
	var before: String = FileAccess.get_file_as_string(TEST_PATH)
	mission.hud.descent_requested.emit()
	_check(FileAccess.get_file_as_string(TEST_PATH) == before and mission.commerce.received_count() == 0, "A repeated packed descent signal restarted the chapter or fabricated a rescue.")
	# Normal guarded actions and evidence readings exercise production resources
	# in the mounted pack. Standing placements are fixtures, not traversal proof.
	mission.equipment.select_tool("halligan")
	mission.player.lamp_enabled = false
	for id: String in ["shutter", "resident", "isolation", "blanket", "relay"]:
		var object: Node3D = _packed_object(mission, "commerce_action_" + id)
		_check(is_instance_valid(object), "Missing mounted commerce operation: " + id)
		if not is_instance_valid(object): continue
		var number: int = int(object.get_meta("floor"))
		mission.player.teleport_to_floor(number)
		if number not in mission.seen_floors: mission.seen_floors.append(number)
		await physics_frame
		_check(_face_commerce(mission, object), "The mounted commerce operation has no reachable clear approach: " + id)
		mission._interact_node(object)
		_check(mission.commerce.active_action == id, "The mounted commerce operation did not begin through its normal guard: " + id)
		for tick: int in range(16): mission._process_commerce_action(0.25, 1)
		_check(mission.commerce.has_action(id) and id in Store.load_data(TEST_PATH).get("commerce", {}).get("actions", []), "The mounted operation did not complete and save its receipt: " + id)
	_check(not visuals.fire_group.visible and not visuals.smoke_group.visible and visuals.blanket_mesh.visible and visuals.shutter_body.collision_layer == 0, "The packed completed operations did not update the fire, smoke, blanket and shutter.")
	for id: String in Commerce.CLUES:
		var object: Node3D = _packed_object(mission, id)
		_check(is_instance_valid(object), "Missing mounted commerce evidence: " + id)
		if not is_instance_valid(object): continue
		mission.player.teleport_to_floor(int(object.get_meta("floor")))
		await physics_frame
		_check(_face_commerce(mission, object), "The mounted commerce evidence has no clear inspection approach: " + id)
		mission._interact_node(object)
		_check(id in mission.clues and object.is_visible_in_tree() and object.get_meta("used", false), "The mounted evidence is unreadable or removes its physical prop: " + id)
	var theo: Node3D = _packed_object(mission, "commerce_person_theo")
	_check(is_instance_valid(theo) and _face_commerce(mission, theo), "The mounted kitchen civilian has no clear contact approach.")
	mission._interact_node(theo)
	var active_save: Dictionary = Store.load_data(TEST_PATH)
	_check(mission.commerce.person_state("theo") == "following" and active_save.get("commerce", {}).get("people", {}).get("theo", "") == "waiting", "The mounted contact failed or persisted an unfinished escort as completed movement.")
	before = FileAccess.get_file_as_string(TEST_PATH)
	mission._restore(active_save)
	_disable_ticks(mission)
	await physics_frame
	_check(mission.player.nearest_floor() == 21 and mission.commerce.phase == "active" and mission.commerce.person_state("theo") == "waiting" and mission.commerce.received_count() == 0, "The mounted lower reload loses the checkpoint or invents a civilian reception.")
	_check(FileAccess.get_file_as_string(TEST_PATH) == before and mission.commerce.snapshot()["actions"] == active_save["commerce"]["actions"], "Reloading the packed commerce checkpoint rewrites it or loses intervention receipts.")
	for id: String in Commerce.CLUES:
		var object: Node3D = _packed_object(mission, id)
		_check(id in mission.clues and is_instance_valid(object) and object.is_visible_in_tree() and object.get_meta("used", false), "A packed commerce reload loses or reopens a collected document: " + id)
	mission.player.teleport_to_floor(20)
	await physics_frame
	var terminal: Node3D = _packed_object(mission, "commerce_finish_20")
	_check(is_instance_valid(terminal) and _face_commerce(mission, terminal), "The packed refuge 20 terminal has no clear interaction approach.")
	mission._interact_node(terminal)
	_check(not mission.completed and mission.commerce.phase == "active" and FileAccess.get_file_as_string(TEST_PATH) == before, "The packed refuge terminal accepts missing physical civilian receptions.")
	# A separately prepared stable ending checks exported restoration and dossier
	# resources. Actual three-civilian traversal is covered by the source suites.
	var ending: Dictionary = active_save.duplicate(true)
	ending["floor"] = 20
	ending["completed"] = true
	ending["commerce"]["phase"] = "complete"
	ending["commerce"]["contacted"] = Commerce.PERSON_IDS.duplicate()
	for id: String in Commerce.PERSON_IDS: ending["commerce"]["people"][id] = "received"
	prepared = Store.save_data(ending, TEST_PATH) == OK
	_check(prepared, "The mounted schema-6 store rejects the stable refuge 20 ending.")
	if not prepared: return
	before = FileAccess.get_file_as_string(TEST_PATH)
	mission._restore(Store.load_data(TEST_PATH))
	_disable_ticks(mission)
	await physics_frame
	_check(mission.completed and mission.commerce.phase == "complete" and mission.hud.end_panel.visible and mission.hud.end_panel.descent_button.visible and mission.hud.end_panel.descent_button.text == "Poursuivre vers les résidences", "The packed refuge ending fails to restore or omits the residential continuation.")
	_check(Dossier.build(mission._dossier_snapshot())["total_received"] == 8 and mission.rescued == previous["rescued"] and mission.continuation_visuals.both_arrived(), "The packed final dossier loses or duplicates one of the eight confirmed civilians.")
	for id: String in Commerce.PERSON_IDS:
		_check(mission.commerce_visuals.physically_arrived(id), "The packed ending failed to restore a confirmed civilian at the supported refuge mark: " + id)
	_check(FileAccess.get_file_as_string(TEST_PATH) == before, "Loading the packed refuge 20 ending rewrites its checkpoint.")


func _test_packed_residential_assets() -> void:
	for script: String in ["residential_director.gd", "residential_presentation.gd", "residential_asset_catalog.gd", "relay_verification_panel.gd"]:
		_check(ResourceLoader.exists("res://scripts/" + script), "The mounted pack lost a v0.13 runtime module: " + script)
	for path: String in ["test_residential.gd", "test_residential_save.gd", "test_residential_integration.gd", "test_residential_routes.gd", "test_residential_assets.gd", "visual_residential_preview.gd", "visual_residential_preview.tscn"]:
		_check(not ResourceLoader.exists("res://tests/" + path), "A v0.13 developer fixture unexpectedly ships in the pack: " + path)
	_check(ResidentialAssets.all_ids().size() == RESIDENTIAL_MODELS.size(), "The mounted residential catalogue is not the twelve-model authored set.")
	for id: String in RESIDENTIAL_MODELS:
		var path: String = ResidentialAssets.asset_path(id)
		_check(id in ResidentialAssets.all_ids() and path == "res://assets/models/residential_v013/" + id + ".glb" and ResourceLoader.exists(path), "Missing mounted residential GLB: " + id)
		var model: Node3D = ResidentialAssets.instantiate(id)
		_check(is_instance_valid(model) and _mesh_count(model) > 0, "The mounted residential model cannot instantiate real meshes: " + id)
		if is_instance_valid(model):
			_check(model.get_meta("authored_model", false) and model.get_meta("residential_asset_id", "") == id and ResidentialAssets.dimensions(id).length() > 0.0, "The packed residential model lost its authoring metadata: " + id)
			model.free()
	var surfaces := Surfaces.new()
	for id: String in ["linen_wallpaper", "antistatic_floor"]:
		var path: String = Surfaces.asset_path(id)
		_check(path == "res://assets/materials/v013/" + id + ".png" and ResourceLoader.exists(path), "Missing mounted v0.13 texture or surface catalogue mapping: " + id)
		var texture := load(path) as Texture2D
		_check(texture != null and texture.get_width() == 1254 and texture.get_height() == 1254, "The mounted v0.13 albedo is missing or resized: " + id)
		var material := surfaces.get_surface(id)
		_check(material.albedo_texture == texture and material.get_meta("asset_loaded", false) and material.get_meta("albedo_asset", "") == path, "The packed v0.13 material uses a flat fallback instead of its authored texture: " + id)


func _test_packed_residential(mission: Node3D) -> void:
	var previous: Dictionary = Store.load_data(TEST_PATH)
	if not previous.get("completed", false) or previous.get("commerce", {}).get("phase") != "complete":
		_check(false, "Cannot test residential pack: previous refuge20 ending did not validate.")
		return
	_check(Routes.all_routes(true, true, true).size() == 16 and Routes.validate(Routes.all_routes(true, true, true), true, true, true).is_empty(), "The mounted route catalogue lacks the four protected residential links.")
	mission.hud.end_panel.descent_button.pressed.emit()
	_disable_ticks(mission)
	await physics_frame
	await physics_frame
	var started: Dictionary = Store.load_data(TEST_PATH)
	_check(mission.residential.phase == "active" and not mission.completed and mission.player.residential_enabled and started.get("version") == 6 and started.get("residential", {}).get("phase") == "active", "The real packed refuge20 button did not durably open the residential chapter.")
	if mission.residential.phase != "active": return
	_check(mission.commerce.snapshot() == previous["commerce"] and mission.continuation.snapshot() == previous["continuation"] and mission.rescued == previous["rescued"], "Packed residential start discarded previous rescue records.")
	var visuals: Node3D = mission.world_data.get("residential_visuals")
	_check(is_instance_valid(visuals) and visuals.get_script() == ResidentialPresentation and visuals.people.size() == 3, "The mounted world lacks its physical residential presentation.")
	if not is_instance_valid(visuals): return
	for number: int in [19, 18, 17]: _check(mission.world.get_node_or_null("Floor%d" % number) != null, "The mounted playable world omitted residential floor %d." % number)
	var models: Dictionary = {}
	_collect_residential_models(mission.world, models)
	for id: String in RESIDENTIAL_MODELS: _check(int(models.get(id, 0)) > 0, "Residential GLB ships but is absent from the playable exported scene: " + id)
	_check(_has_surface(mission.world.get_node("Floor19"), "linen_wallpaper") and _has_surface(mission.world.get_node("Floor17"), "antistatic_floor"), "The mounted residential rooms do not apply their two authored textures.")
	var dossier: Dictionary = Dossier.build(mission._dossier_snapshot())
	_check(dossier["route"].size() == 15 and dossier["survivors"].size() == 11 and dossier["clues"].size() == 10 and mission.world_data["routes"].size() == 16 and dossier["total_received"] == 8, "The mounted dossier loses floors, people, evidence slots, links or the eight prior receipts.")
	mission.equipment.select_tool("halligan")
	for id: String in ["care", "service_access", "power", "reference"]:
		var object: Node3D = _packed_object(mission, "residential_action_" + id)
		_check(is_instance_valid(object), "Missing mounted residential operation: " + id)
		if not is_instance_valid(object): return
		mission.player.teleport_to_floor(int(object.get_meta("floor")))
		await physics_frame
		if not _face_residential(mission, object):
			_check(false, "Mounted residential operation has no clear supported approach: " + id)
			return
		mission._interact_node(object)
		_check(mission.residential.active_action == id, "Normal packed interaction cannot begin residential operation: " + id)
		for tick: int in range(16): mission._process_residential_action(0.25, 1)
		_check(mission.residential.has_action(id) and id in Store.load_data(TEST_PATH).get("residential", {}).get("actions", []), "The mounted residential operation does not save its completed receipt: " + id)
	var relay: Node3D = _packed_object(mission, "residential_action_relay")
	if not is_instance_valid(relay) or not _face_residential(mission, relay):
		_check(false, "The exported relay console has no clear reachable approach.")
		return
	mission._interact_node(relay)
	_check(mission.paused and mission.relay_panel.visible, "The exported relay input form is not playable.")
	var before: PackedByteArray = FileAccess.get_file_as_bytes(TEST_PATH)
	mission.relay_panel.destination_input.text = "HESPERIE"
	mission.relay_panel.reference_input.text = "NACRE-204"
	mission.relay_panel._submit()
	_check(mission.relay_panel.visible and mission.paused and not mission.residential.has_action("relay") and FileAccess.get_file_as_bytes(TEST_PATH) == before, "Wrong destination in the exported form changed the checkpoint or removed retry.")
	mission.relay_panel.destination_input.text = "AUBE-20"
	mission.relay_panel._submit()
	_disable_ticks(mission)
	Input.action_release("interact")
	for tick: int in range(8):
		mission._process(1.0 / 60.0)
		await physics_frame
	_check(not mission.paused and not mission.relay_panel.visible and mission.residential.active_action == "relay" and mission.residential.progress == 0.0, "The mounted verified relay is cancelled before the player can press E or emits without a hold.")
	Input.action_press("interact")
	mission._process(1.0 / 60.0)
	Input.action_release("interact")
	mission._process(1.0 / 60.0)
	_check(mission.residential.active_action.is_empty() and not mission.residential.has_action("relay"), "The mounted emission ignores release after its first E hold.")
	mission._interact_node(relay)
	mission.relay_panel._submit()
	_disable_ticks(mission)
	for tick: int in range(12): mission._process_residential_action(0.25, 1)
	var relay_save: Dictionary = Store.load_data(TEST_PATH)
	_check(mission.residential.has_action("relay") and relay_save.get("floor") == 17 and "relay" in relay_save.get("residential", {}).get("actions", []), "The mounted relay cannot retry and persist a safe floor17 checkpoint.")
	for id: String in Residential.CLUES:
		var object: Node3D = _packed_object(mission, id)
		if not is_instance_valid(object):
			_check(false, "Missing mounted residential evidence: " + id)
			return
		mission.player.teleport_to_floor(int(object.get_meta("floor")))
		await physics_frame
		_check(_face_residential(mission, object), "Exported residential evidence has no clear approach: " + id)
		mission._interact_node(object)
		_check(id in mission.clues and object.get_meta("used", false), "The mounted residential evidence cannot be retained: " + id)
	# Stable, explicitly prepared reception ledger verifies resources/restore.
	# The source route suite proves physical escort travel independently.
	var ending: Dictionary = Store.load_data(TEST_PATH)
	ending["floor"] = 17
	ending["completed"] = true
	ending["residential"]["phase"] = "complete"
	ending["residential"]["contacted"] = Residential.PERSON_IDS.duplicate()
	for id: String in Residential.PERSON_IDS: ending["residential"]["people"][id] = "received"
	var saved: bool = Store.save_data(ending, TEST_PATH) == OK
	_check(saved, "The mounted schema6 rejects a complete floor17 dossier with preserved previous receipts.")
	if not saved: return
	before = FileAccess.get_file_as_bytes(TEST_PATH)
	mission._restore(Store.load_data(TEST_PATH))
	_disable_ticks(mission)
	await physics_frame
	_check(mission.completed and mission.residential.phase == "complete" and mission.hud.end_panel.visible and not mission.hud.end_panel.descent_button.visible and Dossier.build(mission._dossier_snapshot())["total_received"] == 11, "The mounted final17 report loses receptions or exposes an unavailable next chapter.")
	for id: String in Residential.PERSON_IDS: _check(mission.residential_visuals.physically_arrived(id), "The mounted final17 restore lost the supported refuge20 arrival of " + id)
	_check(FileAccess.get_file_as_bytes(TEST_PATH) == before, "Reading the mounted final17 report rewrites its checkpoint.")


func _collect_residential_models(parent: Node, result: Dictionary) -> void:
	var id: String = str(parent.get_meta("residential_asset_id", ""))
	if not id.is_empty() and _mesh_count(parent) > 0: result[id] = int(result.get(id, 0)) + 1
	for child: Node in parent.get_children(): _collect_residential_models(child, result)


func _face_residential(mission: Node3D, object: Node3D) -> bool:
	var number: int = int(object.get_meta("floor"))
	var y: float = Routes.floor_height(number) + 0.06
	var capsule := CapsuleShape3D.new()
	capsule.radius = 0.34
	capsule.height = 1.72
	for offset: Vector3 in [Vector3(0,0,1.3), Vector3(0,0,-1.3), Vector3(1.85,0,0), Vector3(-1.85,0,0), Vector3(1.3,0,1.3), Vector3(-1.3,0,1.3), Vector3(1.3,0,-1.3), Vector3(-1.3,0,-1.3)]:
		var candidate := Vector3(object.global_position.x, y, object.global_position.z) + offset
		var query := PhysicsShapeQueryParameters3D.new()
		query.shape = capsule
		query.transform = Transform3D(Basis.IDENTITY, candidate + Vector3(0,0.87,0))
		query.exclude = [mission.player.get_rid()]
		if not mission.get_world_3d().direct_space_state.intersect_shape(query).is_empty(): continue
		mission.player.global_position = candidate
		mission.player.velocity = Vector3.ZERO
		mission.last_floor = number
		if number not in mission.seen_floors: mission.seen_floors.append(number)
		mission.player.camera.look_at(object.global_position + (object.get_meta("focus_offset", Vector3(0,1.2,0)) as Vector3))
		if mission._residential_target_visible(object): return true
	return false


func _mesh_count(parent: Node) -> int:
	var total: int = 1 if parent is MeshInstance3D and parent.mesh != null and parent.mesh.get_surface_count() > 0 else 0
	for child: Node in parent.get_children(): total += _mesh_count(child)
	return total


func _collect_commerce_models(parent: Node, result: Dictionary) -> void:
	var id: String = str(parent.get_meta("commerce_asset_id", ""))
	if not id.is_empty() and _mesh_count(parent) > 0: result[id] = int(result.get(id, 0)) + 1
	for child: Node in parent.get_children(): _collect_commerce_models(child, result)


func _has_surface(parent: Node, id: String) -> bool:
	if parent is MeshInstance3D:
		var material: Material = parent.material_override
		if material is StandardMaterial3D and material.get_meta("v011_surface", "") == id and material.get_meta("asset_loaded", false) and material.albedo_texture != null:
			return true
	for child: Node in parent.get_children():
		if _has_surface(child, id): return true
	return false


func _face_commerce(mission: Node3D, object: Node3D) -> bool:
	var y: float = Routes.floor_height(int(object.get_meta("floor"))) + 0.06
	var capsule := CapsuleShape3D.new()
	capsule.radius = 0.34
	capsule.height = 1.72
	for offset: Vector3 in [Vector3(0,0,2.4), Vector3(0,0,-2.4), Vector3(2.4,0,0), Vector3(-2.4,0,0), Vector3(1.65,0,1.65), Vector3(-1.65,0,1.65), Vector3(1.65,0,-1.65), Vector3(-1.65,0,-1.65), Vector3(0,0,1.85), Vector3(0,0,-1.85)]:
		var candidate := Vector3(object.global_position.x, y, object.global_position.z) + offset
		var query := PhysicsShapeQueryParameters3D.new()
		query.shape = capsule
		query.transform = Transform3D(Basis.IDENTITY, candidate + Vector3(0,0.87,0))
		query.exclude = [mission.player.get_rid()]
		if not mission.get_world_3d().direct_space_state.intersect_shape(query).is_empty(): continue
		mission.player.global_position = candidate
		mission.player.velocity = Vector3.ZERO
		mission.player.camera.look_at(object.global_position + (object.get_meta("focus_offset", Vector3(0,1.2,0)) as Vector3))
		if mission._commerce_target_visible(object):
			if str(object.get_meta("kind", "")) != "commerce_action" or mission._commerce_action_context(object): return true
	return false


func _packed_object(mission: Node3D, id: String) -> Node3D:
	for object: Node3D in mission.world_data.get("interactables", []):
		if is_instance_valid(object) and str(object.get_meta("id", "")) == id:
			return object
	return null


func _face_continuation(mission: Node3D, object: Node3D) -> bool:
	var y: float = float(int(object.get_meta("floor")) - 24) * 6.0 + 0.06
	var capsule: CapsuleShape3D = CapsuleShape3D.new()
	capsule.radius = 0.34
	capsule.height = 1.72
	for offset: Vector3 in [Vector3(0,0,1.85), Vector3(0,0,-1.85), Vector3(2.65,0,0), Vector3(-2.65,0,0)]:
		var candidate: Vector3 = Vector3(object.global_position.x,y,object.global_position.z) + offset
		var query: PhysicsShapeQueryParameters3D = PhysicsShapeQueryParameters3D.new()
		query.shape = capsule
		query.transform = Transform3D(Basis.IDENTITY,candidate + Vector3(0,0.87,0))
		query.exclude = [mission.player.get_rid()]
		if not mission.get_world_3d().direct_space_state.intersect_shape(query).is_empty():
			continue
		mission.player.global_position = candidate
		mission.player.velocity = Vector3.ZERO
		mission.player.camera.look_at(object.global_position + Vector3(0,1.2,0))
		if mission._valid_continuation_interaction(object):
			return true
	return false


func _face_field(mission: Node3D, object: Node3D) -> bool:
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


func _perception_colliders(parent: Node) -> int:
	var total: int = 1 if parent is CollisionObject3D else 0
	for child: Node in parent.get_children():
		total += _perception_colliders(child)
	return total


func _disable_ticks(mission: Node3D) -> void:
	mission.set_process(false)
	mission.set_physics_process(false)
	mission.player.set_process(false)
	mission.player.set_physics_process(false)
	mission.world.set_process(false)


func _cleanup() -> void:
	if InputMap.has_action("interact"): Input.action_release("interact")
	for path: String in [TEST_PATH, PREFS_PATH, PREFS_PATH + ".tmp"]:
		if FileAccess.file_exists(path):
			DirAccess.remove_absolute(ProjectSettings.globalize_path(path))


func _check(condition: bool, message: String) -> void:
	checks += 1
	if not condition:
		failures.append(message)


func _finish() -> void:
	if failures.is_empty():
		print("PASS exported pack: %d checks; mounted v0.13 resources, 40 authored model imports, twelve native albedos, historical rescue/menu/cinematic/audio/rope checks, schema6 persistence, three real debrief-button continuations, sixteen adjacent links, guarded commerce/residential operations, retryable relay form with first-key handoff and stable floor17 ending. Developer tests remain excluded. Standing/receipt fixtures check resources and restoration, not civilian route traversal. Linux headless engine loads the pack; this is not a Windows executable or browser launch or a visual approval." % checks)
		quit(0)
	else:
		for failure: String in failures:
			push_error(failure)
		print("FAIL exported pack: %d failures / %d checks." % [failures.size(), checks])
		quit(1)
