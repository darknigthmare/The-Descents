extends SceneTree
## Real mission/UI/persistence integration. Placements are prepared fixtures;
## actual walking, climbing and civilian traversal belong to continuation_routes.
const MainScene = preload("res://scenes/main.tscn")
const Store = preload("res://scripts/save_store.gd")
const Preferences = preload("res://scripts/preferences_store.gd")
const Dossier = preload("res://scripts/mission_dossier.gd")
const SAVE: String = "user://qa_v010_continuation_integration.json"
const PREFS: String = "user://qa_v010_continuation_integration.cfg"
var mission: Node3D
var checks: int = 0
var failures: Array[String] = []

func _initialize() -> void:
	_run.call_deferred()

func _run() -> void:
	_clean()
	Preferences.save_settings(Preferences.normalize({"audio": false, "startup_intro": false}), PREFS)
	mission = MainScene.instantiate()
	mission.save_path = SAVE
	mission.preferences_path = PREFS
	root.add_child(mission)
	_freeze()
	await physics_frame
	mission.hud.descent_requested.emit()
	_check(mission.continuation.phase == "dormant" and not FileAccess.file_exists(SAVE), "A hidden continuation signal created a chapter before the mission.")
	mission._start_new(271104)
	mission._finish_arrival()
	_freeze()
	mission.hud.descent_requested.emit()
	_check(mission.continuation.phase == "dormant", "A hidden continuation signal skipped the first intervention.")
	mission.elapsed = 220.0
	mission.rescued = ["survivor_30", "survivor_28", "survivor_26"]
	mission.incident.restore("aftermath")
	mission.world.apply_incident("aftermath", 0.0)
	mission.world.set_rescued_people(mission.rescued)
	mission.player.teleport_to_floor(25)
	await physics_frame
	await physics_frame
	mission._complete_game(false)
	_check(mission.completed and mission.hud.end_panel.visible and mission.hud.end_panel.descent_button.visible, "The first valid debrief did not expose its continuation action.")
	# Materialise an exact legacy-v3 checkpoint without touching the v4 writer.
	var legacy: Dictionary = Store.load_data(SAVE)
	legacy.erase("continuation")
	legacy.erase("commerce")
	legacy["version"] = 3
	var file: FileAccess = FileAccess.open(SAVE, FileAccess.WRITE)
	file.store_string(JSON.stringify(legacy))
	file.close()
	var legacy_bytes: String = FileAccess.get_file_as_string(SAVE)
	mission._return_to_menu()
	_freeze()
	mission._continue_game()
	_freeze()
	await physics_frame
	_check(mission.completed and mission.continuation.phase == "dormant" and FileAccess.get_file_as_string(SAVE) == legacy_bytes, "Reading a legacy completed save restarted the chapter or rewrote the old save.")
	mission._open_journal()
	mission.hud.descent_requested.emit()
	_check(mission.paused and mission.continuation.phase == "dormant", "A stale continuation signal escaped the journal modal.")
	mission._resume()
	_freeze()
	mission.save_path = "user://missing_v010_%d/save.json" % Time.get_ticks_usec()
	mission.hud.end_panel.descent_button.pressed.emit()
	_check(mission.completed and mission.continuation.phase == "dormant" and not mission.player.active, "A failed continuation save opened a live chapter.")
	_check(mission.hud.end_panel.subtitle_label.text.contains("Sauvegarde impossible") and FileAccess.get_file_as_string(SAVE) == legacy_bytes, "Failed continuation hid the error or damaged the original checkpoint.")
	mission.save_path = SAVE
	mission.hud.end_panel.descent_button.pressed.emit()
	_freeze()
	await physics_frame
	await physics_frame
	var started: Dictionary = Store.load_data(SAVE)
	_check(mission.continuation.phase == "active" and not mission.completed and mission.player.active, "The real debrief button did not return control to an active chapter.")
	_check(started.get("version") == Store.SAVE_VERSION and started["continuation"]["phase"] == "active" and started["floor"] == 25 and 25 in started["seen_floors"], "The chapter did not establish its durable starting checkpoint.")
	_check(mission.world_data["routes"].size() == 8 and not mission.world.continuation_access_cover.visible, "The recorded continuation did not open the two new routes.")
	var active_bytes: String = FileAccess.get_file_as_string(SAVE)
	mission.hud.descent_requested.emit()
	_check(FileAccess.get_file_as_string(SAVE) == active_bytes, "A stale continuation action restarted an active chapter.")
	var duo: Node3D = _object("continuation_duo_24")
	await _face(duo, Vector3(0, 0, 2.3))
	mission.player.camera.rotate_y(PI)
	mission._interact_node(duo)
	_check(not mission.continuation.duo_briefed, "The visual briefing accepted a player facing away from the group.")
	mission.player.camera.look_at(duo.global_position + Vector3(0, 1.2, 0))
	mission._interact_node(duo)
	_check(mission.continuation.escort_state == "following" and mission.continuation_visuals.escort_state == "following", "A visible briefing failed to engage the physical escort.")
	_check(Store.load_data(SAVE)["continuation"]["duo_briefed"] and Store.load_data(SAVE)["continuation"]["escort_state"] == "waiting", "First visual contact did not preserve a safe resumable briefing.")
	var dossier: Dictionary = Dossier.build(mission._dossier_snapshot())
	_check(dossier["pages"]["situation"].contains("Accompagner") and dossier["survivors"].size() == 5, "The live dossier reset following to a waiting briefing or omitted the duo.")
	mission._save_checkpoint(24)
	var moving_save: Dictionary = Store.load_data(SAVE)
	_check(moving_save["continuation"]["escort_state"] == "waiting" and mission.continuation.escort_state == "following", "Checkpointing persisted mid-route movement or stopped the live escort.")
	var before_pause: Dictionary = mission.continuation_visuals.snapshot()
	mission._pause()
	mission._process_continuation(1.0)
	_check(mission.continuation_visuals.snapshot() == before_pause, "A paused mission advanced the physical escort or optional cue.")
	mission._resume()
	_freeze()
	mission._interact_node(duo)
	_check(mission.continuation.escort_state == "waiting" and mission.continuation_visuals.snapshot()["positions"] == before_pause["positions"], "A visible wait signal teleported the duo.")
	var rope: Node3D = _object("R24_23_24")
	mission.player.teleport_to_floor(24)
	mission.player.global_position = Vector3(-3.8, 0.06, 0)
	await physics_frame
	mission._interact_node(rope)
	_check(not mission.player.on_rope, "Waiting manually let the player abandon a briefed escort through the rope.")
	mission._restore(moving_save)
	_freeze()
	await physics_frame
	await physics_frame
	_check(mission.continuation.escort_state == "waiting" and mission.continuation.duo_briefed and mission.continuation_visuals.people[0].position.distance_to(Vector3(7.7, 0.06, -8.1)) < 0.05, "Restoration did not return the interrupted escort to its protected booth.")
	var terminal: Node3D = _object("continuation_terminal_23")
	await _face(terminal, Vector3(0, 0, -2.0))
	mission._interact_node(terminal)
	_check(not mission.completed and mission.continuation.phase == "active", "The terminal completed before reception and investigation.")
	for id: String in ["continuation_model_23", "continuation_photo_23"]:
		var evidence: Node3D = _object(id)
		await _face(evidence, Vector3(0, 0, -2.3) if id.ends_with("model_23") else Vector3(0, 0, 2.0))
		mission._interact_node(evidence)
		_check(id in mission.clues and evidence.visible and evidence.get_meta("used", false), "An exhibition reading was lost or removed the physical exhibit: " + id)
		var count: int = mission.clues.size()
		mission._interact_node(evidence)
		_check(mission.clues.size() == count, "Repeated reading duplicated a historical proof.")
	await _face(terminal, Vector3(0, 0, -2.0))
	mission._interact_node(terminal)
	_check(not mission.completed, "Historical clues alone invented the civilian reception.")
	# A prepared stable reception fixture exercises persistence and final UI;
	# continuation_routes independently proves both bodies can physically arrive.
	mission.continuation.state["escort_state"] = "received"
	mission.world.set_continuation_state(mission.continuation.snapshot())
	var proof_bytes: String = FileAccess.get_file_as_string(SAVE)
	mission.save_path = "user://missing_final_v010_%d/save.json" % Time.get_ticks_usec()
	mission._interact_node(terminal)
	_check(not mission.completed and mission.continuation.phase == "active" and mission.player.active, "An unsuccessful final write locked the mission into an undurable report.")
	_check(FileAccess.get_file_as_string(SAVE) == proof_bytes, "A failed final write changed the prior checkpoint.")
	mission.save_path = SAVE
	mission._interact_node(terminal)
	_check(mission.completed and mission.continuation.phase == "complete" and mission.hud.end_panel.visible and not mission.player.active and not mission.world.is_processing(), "Final recognition did not stop gameplay and display its recorded report.")
	_check(mission.hud.end_panel.model["total_received"] == 5 and not mission.hud.end_panel.replay_button.visible and mission.hud.end_panel.descent_button.visible and mission.hud.end_panel.descent_button.text == "Poursuivre vers les commerces", "The final report lost received people or exposed old phase controls.")
	var final_bytes: String = FileAccess.get_file_as_string(SAVE)
	mission.hud.epilogue_replay_requested.emit()
	_check(not mission.epilogue_playing, "A stale old-epilogue signal replaced the new final report.")
	mission._return_to_menu()
	_freeze()
	_check(mission.menu_context["id"] == "recon_debrief" and mission.menu_context["floor"] == 23 and mission.menu_context["rescued"] == 5, "The contextual menu forgot the new chapter or receiving floor.")
	mission._continue_game()
	_freeze()
	await physics_frame
	_check(mission.completed and mission.continuation.phase == "complete" and mission.hud.end_panel.visible and FileAccess.get_file_as_string(SAVE) == final_bytes, "Reading the final report wrote a new save or restarted gameplay.")
	_check(mission.continuation_visuals.both_arrived(), "Confirmed civilians did not remain at the refuge on reload.")
	_check(_object("continuation_model_23").visible and _object("continuation_photo_23").visible, "Restoration made the collected exhibition props disappear.")
	mission.free()
	_clean()
	if failures.is_empty():
		print("PASS continuation integration: %d checks; legacy read-only debrief, visible continuation, failed-write rollback, visual escort consent, pause, stable restart, preserved exhibits, collected proofs and final report." % checks)
		quit(0)
	else:
		for failure: String in failures:
			push_error(failure)
		print("FAIL continuation integration: %d failures / %d checks" % [failures.size(), checks])
		quit(1)

func _face(object: Node3D, offset: Vector3) -> void:
	var number: int = int(object.get_meta("floor"))
	mission.player.teleport_to_floor(number)
	mission.player.position = Vector3(object.global_position.x, float(number - 24) * 6.0 + 0.06, object.global_position.z) + offset
	mission.player.camera.look_at(object.global_position + Vector3(0, 1.2, 0))
	await physics_frame
	await physics_frame
	mission._find_nearest()
	_check(mission._valid_continuation_interaction(object), "Prepared interaction has no legal visible supported position: " + str(object.get_meta("id")))

func _object(id: String) -> Node3D:
	for object: Node3D in mission.world_data.get("interactables", []):
		if object.get_meta("id", "") == id:
			return object
	push_error("Missing continuation fixture object: " + id)
	return null

func _freeze() -> void:
	mission.set_process(false)
	mission.set_physics_process(false)
	mission.player.set_physics_process(false)
	mission.world.set_process(false)

func _check(condition: bool, message: String) -> void:
	checks += 1
	if not condition:
		failures.append(message)

func _clean() -> void:
	for path: String in [SAVE, PREFS]:
		if FileAccess.file_exists(path):
			DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
