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
const TEST_PATH: String = "user://qa_v010_external_pack.json"
const PREFS_PATH: String = "user://qa_v010_external_pack.cfg"
var failures: Array[String] = []
var checks: int = 0


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	_cleanup()
	_check(ProjectSettings.get_setting("application/config/version", "") == "0.10.0", "Packed project has the wrong application version.")
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
	_check(mission._save_checkpoint(27), "The mounted runtime could not create its isolated schema-4 checkpoint.")
	var saved: Dictionary = Store.load_data(TEST_PATH)
	_check(saved.get("version") == 4 and saved.get("radio_events") == mission.radio_events and saved.get("transmissions", []).size() == received_before + 3, "Packed storage lost schema-4 received words or event markers.")
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
	mission.free()
	await process_frame
	await process_frame
	_cleanup()
	_finish()


func _test_packed_continuation(mission: Node3D) -> void:
	_check(Store.SAVE_VERSION == 4 and mission.continuation.phase == "dormant", "The mounted continuation or schema-4 storage is missing.")
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
	_check(started.get("version", 0) == 4 and started.get("floor", 0) == 25 and started.get("continuation", {}).get("started_at_refuge", false), "The mounted chapter choice did not first persist a schema-4 refuge checkpoint.")
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
	for path: String in [TEST_PATH, PREFS_PATH, PREFS_PATH + ".tmp"]:
		if FileAccess.file_exists(path):
			DirAccess.remove_absolute(ProjectSettings.globalize_path(path))


func _check(condition: bool, message: String) -> void:
	checks += 1
	if not condition:
		failures.append(message)


func _finish() -> void:
	if failures.is_empty():
		print("PASS exported pack: %d checks; mounted v0.10 resources, historical rescue/menu/cinematic/audio/rope checks, schema-4 persistence, real debrief-button continuation, optional eight-route world, physical civilian resources, lower-floor reload and retained exhibition readings. Developer tests remain excluded. Linux headless engine loads the pack; this is not a Windows executable or browser launch or a visual approval." % checks)
		quit(0)
	else:
		for failure: String in failures:
			push_error(failure)
		print("FAIL exported pack: %d failures / %d checks." % [failures.size(), checks])
		quit(1)
