extends SceneTree
## Real menu, mission interaction and disk boundaries. Standing placements are
## fixtures; actual capsule traversal belongs to the physical route suite.
const MainScene = preload("res://scenes/main.tscn")
const Store = preload("res://scripts/save_store.gd")
const Preferences = preload("res://scripts/preferences_store.gd")
const Director = preload("res://scripts/residential_director.gd")
const Dossier = preload("res://scripts/mission_dossier.gd")
const Interaction = preload("res://tests/interaction_fixture.gd")
const SAVE := "user://qa_residential_integration_v013.json"
const PREFS := SAVE + ".cfg"
var mission: Node3D
var checks: int = 0
var failures: Array[String] = []

func _initialize() -> void:
	_run.call_deferred()

func _run() -> void:
	_clean()
	var legacy := _v5_fixture()
	var file := FileAccess.open(SAVE, FileAccess.WRITE)
	file.store_string(JSON.stringify(legacy))
	file.close()
	var original := FileAccess.get_file_as_bytes(SAVE)
	Preferences.save_settings(Preferences.normalize({"audio": false, "startup_intro": false, "reduced_motion": true}), PREFS)
	mission = MainScene.instantiate()
	mission.save_path = SAVE
	mission.preferences_path = PREFS
	root.add_child(mission)
	_freeze()
	await physics_frame
	mission.hud.descent_requested.emit()
	_check(not mission.started and mission.residential.phase == "dormant" and FileAccess.get_file_as_bytes(SAVE) == original, "A stale menu signal opened residences or changed v5 bytes.")
	mission._continue_game()
	_freeze()
	await _settle()
	_check(mission.completed and mission.hud.end_panel.visible and mission.residential.phase == "dormant", "v5 load did not remain at its completed refuge20 report.")
	_check(mission.hud.end_panel.descent_button.visible and mission.hud.end_panel.descent_button.text == "Poursuivre vers les résidences", "v5 report did not label its explicit residential choice.")
	_check(FileAccess.get_file_as_bytes(SAVE) == original and Dossier.build(mission._dossier_snapshot())["total_received"] == 8, "Read-only v5 load changed bytes or lost prior receptions.")
	mission._open_journal()
	mission.hud.descent_requested.emit()
	_check(mission.residential.phase == "dormant" and FileAccess.get_file_as_bytes(SAVE) == original, "A journal-hidden ending signal opened residences.")
	mission._resume()
	_freeze()
	var old_world: Node3D = mission.world
	mission.save_path = "user://qa_missing_residential_start_%d/save.json" % Time.get_ticks_usec()
	mission.hud.end_panel.descent_button.pressed.emit()
	_check(mission.completed and mission.residential.phase == "dormant" and mission.world == old_world and FileAccess.get_file_as_bytes(SAVE) == original, "Failed chapter-start persistence rebuilt the world or discarded the old report.")
	mission.save_path = SAVE
	mission.hud.end_panel.descent_button.pressed.emit()
	_freeze()
	await _settle()
	if not _require(mission.residential.phase == "active" and not mission.completed and is_instance_valid(mission.residential_visuals), "Visible refuge20 button did not begin the playable residential chapter."): return
	_check(Store.load_data(SAVE).get("residential", {}).get("phase") == "active" and Store.load_data(SAVE).get("version") == 6, "Chapter opened before its schema6 departure checkpoint.")
	_check(mission.commerce.snapshot() == legacy["commerce"] and mission.continuation.snapshot() == legacy["continuation"] and mission.rescued == legacy["rescued"], "Residential transition changed previous durable receptions.")
	_check(Dossier.build(mission._dossier_snapshot())["total_received"] == 8, "Residential start invented or duplicated new receptions.")
	var started_bytes := FileAccess.get_file_as_bytes(SAVE)
	mission.hud.descent_requested.emit()
	_check(FileAccess.get_file_as_bytes(SAVE) == started_bytes, "Repeated active-chapter signal wrote a new checkpoint.")
	if not await _action("care", "halligan"): return
	var jeanne: Node3D = mission.residential_visuals.person_targets["jeanne"]
	if not await _face(jeanne): return
	mission._interact_node(jeanne)
	_check(mission.residential.person_state("jeanne") == "following" and Store.load_data(SAVE).get("residential", {}).get("people", {}).get("jeanne") == "waiting", "Live following did not remain separate from stable disk waiting.")
	var before_pause: Vector3 = mission.residential_visuals.people["jeanne"].global_position
	mission._pause()
	mission._process_residential(0.05)
	_check(mission.residential_visuals.people["jeanne"].global_position == before_pause, "A paused residential escort moved behind its modal.")
	mission._resume()
	_freeze()
	if not await _action("service_access", "halligan"): return
	if not await _action("power", "halligan"): return
	if not await _action("reference", "halligan"): return
	var relay: Node3D = mission.residential_visuals.action_targets["relay"]
	if not await _face(relay): return
	mission._interact_node(relay)
	_check(mission.paused and mission.relay_panel.visible and not mission.player.active, "Relay entry did not pause gameplay and focus its panel.")
	var pending_state: Dictionary = mission.residential.snapshot()
	var before_wrong := FileAccess.get_file_as_bytes(SAVE)
	var previous_elapsed: float = mission.elapsed
	mission.relay_panel.destination_input.text = "HESPERIE"
	mission.relay_panel.reference_input.text = "NACRE-204"
	mission.relay_panel._submit()
	mission._process(5.0)
	_check(mission.paused and mission.relay_panel.visible and mission.residential.snapshot() == pending_state and FileAccess.get_file_as_bytes(SAVE) == before_wrong, "Wrong relay submission changed live escorts, durable progress or dismissed the retry panel.")
	_check(mission.elapsed == previous_elapsed and not mission.relay_panel.error_label.text.is_empty(), "Relay retry advanced mission time or gave no readable error.")
	mission._cancel_residential_relay()
	_freeze()
	_check(not mission.paused and not mission.relay_panel.visible and mission.residential.active_action.is_empty(), "Relay cancel failed to return to the same playable landing.")
	mission._interact_node(relay)
	mission.relay_panel.destination_input.text = " aube-20 "
	mission.relay_panel.reference_input.text = " nacre-204 "
	mission.relay_panel._submit()
	_freeze()
	_check(not mission.paused and not mission.relay_panel.visible and mission.residential.active_action == "relay" and not mission.residential.has_action("relay"), "Valid form did not arm the separate held transmission.")
	Input.action_release("interact")
	for tick: int in range(8):
		mission._process(1.0 / 60.0)
		await physics_frame
	_check(mission.residential.active_action == "relay" and mission.residential.progress == 0.0 and not mission.residential.has_action("relay"), "After the real panel closed, input-free frames cancelled verification before the player could hold E.")
	Input.action_press("interact")
	mission._process(1.0 / 60.0)
	_check(mission.residential.progress > 0.0 and not mission.residential.has_action("relay"), "The first real E hold failed to start the verified emission.")
	Input.action_release("interact")
	mission._process(1.0 / 60.0)
	_check(mission.residential.active_action.is_empty() and not mission.residential.has_action("relay"), "Releasing E after emission started did not cancel the held transmission.")
	mission._interact_node(relay)
	mission.relay_panel._submit()
	_freeze()
	_check(mission.residential.active_action == "relay", "Interrupted real-key transmission could not be verified again.")
	mission._pause()
	mission._resume()
	_freeze()
	_check(mission.residential.active_action.is_empty() and not mission.residential.has_action("relay"), "Pause silently finished or retained the armed relay action.")
	mission._interact_node(relay)
	mission.relay_panel._submit()
	_freeze()
	var live_position: Vector3 = mission.residential_visuals.people["jeanne"].global_position
	var live_cursor: int = int(mission.residential_visuals.cursors["jeanne"])
	mission.save_path = "user://qa_missing_residential_relay_%d/save.json" % Time.get_ticks_usec()
	for tick: int in range(45): mission._process_residential_action(0.05, 1)
	_check(not mission.residential.has_action("relay") and mission.residential.person_state("jeanne") == "following" and mission.residential_visuals.people["jeanne"].global_position == live_position and int(mission.residential_visuals.cursors["jeanne"]) == live_cursor, "Failed relay write lost the live escort, its physical cursor, or retained the unsaved receipt.")
	_check(FileAccess.get_file_as_bytes(SAVE) == before_wrong, "Failed relay write damaged the previous durable save.")
	mission.save_path = SAVE
	mission._interact_node(relay)
	mission.relay_panel._submit()
	_freeze()
	for tick: int in range(45): mission._process_residential_action(0.05, 1)
	_check(mission.residential.has_action("relay") and "relay" in Store.load_data(SAVE).get("residential", {}).get("actions", []), "Relay could not be retried and durably completed after I/O failure.")
	_check(mission.residential.person_state("jeanne") == "following", "Successful relay persistence reset the live escort.")
	var dossier: Dictionary = Dossier.build(mission._dossier_snapshot())
	_check(dossier.get("survivors", []).size() == 11 and dossier.get("total_received") == 8, "Journal did not distinguish eleven people from eight confirmed receptions.")
	_check(dossier.get("route", []).size() == 15 and dossier.get("clues", []).size() == 10 and mission.world_data.get("routes", []).size() == 16, "Current dossier or world omitted floors, ten evidence slots or one of sixteen local links.")
	mission._open_journal()
	_check(mission.hud.journal_panel.route_rows.size() >= 15 and mission.hud.journal_panel.model["roster_total"] == 11 and mission.hud.journal_panel.model["evidence_total"] == 10, "The real journal panel cannot display the expanded chapter data.")
	mission._resume()
	_freeze()
	var saved_bytes := FileAccess.get_file_as_bytes(SAVE)
	mission._continue_game()
	_freeze()
	await _settle()
	_check(mission.residential.phase == "active" and mission.residential.person_state("jeanne") == "waiting" and mission.residential.has_action("reference") and mission.residential.has_action("relay"), "Stable reload lost reference/relay or restored movement midway through an escort.")
	_check(FileAccess.get_file_as_bytes(SAVE) == saved_bytes and Dossier.build(mission._dossier_snapshot())["total_received"] == 8, "Reload rewrote its bytes or changed prior reception counts.")
	# Prepare supported receiving placements, independently from the route suite,
	# then let production logic confirm each receipt and finish its real report.
	for id: String in Director.PERSON_IDS:
		var target: Node3D = mission.residential_visuals.person_targets[id]
		if not await _face(target): return
		mission._interact_node(target)
		if not _require(mission.residential.person_state(id) == "following", "Recovered civilian cannot begin its safe escort: " + id): return
	mission.player.teleport_to_floor(20)
	for id: String in Director.PERSON_IDS:
		mission.residential_visuals.people[id].global_position = mission.residential_visuals.RECEIVING[id]
		mission.residential_visuals.people[id].velocity = Vector3.ZERO
		mission.residential_visuals.cursors[id] = mission.residential_visuals.paths[id].size()
		mission.residential_visuals.arrived[id] = true
	await _settle()
	var before_receipts := FileAccess.get_file_as_bytes(SAVE)
	mission.save_path = "user://qa_missing_residential_receipt_%d/save.json" % Time.get_ticks_usec()
	mission._process_residential(1.0 / 60.0)
	_check(mission.residential.received_count() == 0 and mission.residential.person_state("jeanne") == "following" and FileAccess.get_file_as_bytes(SAVE) == before_receipts, "A failed physical-reception write committed an unsaved receipt or discarded the escort.")
	mission.save_path = SAVE
	mission.residential_retry_timer = 0.0
	for tick: int in range(12):
		mission._process_residential(1.0 / 60.0)
		await physics_frame
	if not _require(mission.residential.received_count() == 3 and Dossier.build(mission._dossier_snapshot())["total_received"] == 11, "Production reception logic did not confirm the three supported arrivals without losing the earlier eight."): return
	for id: String in Director.CLUES:
		var clue: Node3D = mission.residential_visuals.clue_targets[id]
		if not await _face(clue): return
		mission._interact_node(clue)
		_check(id in mission.clues and id in Store.load_data(SAVE).get("clues", []), "Real clue interaction was not durably recorded: " + id)
	var finish: Node3D
	for object: Node3D in mission.world_data["interactables"]:
		if object.get_meta("kind", "") == "residential_finish": finish = object
	if not _require(is_instance_valid(finish), "The authored chapter has no reachable final-report interaction."): return
	if not await _face(finish): return
	mission._interact_node(finish)
	_check(mission.completed and mission.residential.phase == "complete" and mission.hud.end_panel.visible and not mission.hud.end_panel.descent_button.visible, "Complete rescue+relay dossier did not finish at17 or exposed an unbuilt next chapter.")
	_check(Store.load_data(SAVE).get("floor") == 17 and Dossier.build(mission._dossier_snapshot())["clue_count"] == 10 and Dossier.build(mission._dossier_snapshot())["total_received"] == 11, "Final checkpoint lost its landing, ten constats or eleven confirmed people.")
	var final_bytes := FileAccess.get_file_as_bytes(SAVE)
	mission._return_to_menu()
	_freeze()
	_check(mission.menu_context.get("id") == "residential_debrief" and mission.menu_context.get("floor") == 17 and mission.menu_context.get("rescued") == 11, "Contextual menu retained the previous chapter after the final17 report.")
	mission._continue_game()
	_freeze()
	await _settle()
	_check(mission.completed and mission.residential.received_count() == 3 and FileAccess.get_file_as_bytes(SAVE) == final_bytes, "Final report reload reset reception state or rewrote its saved bytes.")
	mission.free()
	_clean()
	_finish()

func _action(id: String, tool: String) -> bool:
	var target: Node3D = mission.residential_visuals.action_targets[id]
	if not await _face(target): return false
	mission._select_equipment(tool)
	mission._interact_node(target)
	if not _require(mission.residential.active_action == id, "Real target could not begin action " + id): return false
	for tick: int in range(70): mission._process_residential_action(0.05, 1)
	return _require(mission.residential.has_action(id), "Held work failed or could not persist: " + id)

func _face(target: Node3D) -> bool:
	Interaction.face(mission, target)
	if target.get_meta("action_id", "") == "service_access":
		mission.player.global_position = target.global_position + Vector3(0, 0.06, -1.3)
	mission.player.camera.look_at(target.global_position + target.get_meta("focus_offset", Vector3.UP * 1.2))
	await _settle()
	return _require(mission._residential_target_visible(target), "Prepared supported viewpoint cannot reach the real interaction: " + str(target.get_meta("id", target.name)))

func _settle() -> void:
	await physics_frame
	await physics_frame

func _freeze() -> void:
	mission.set_process(false)
	mission.set_physics_process(false)
	mission.player.set_process(false)
	mission.player.set_physics_process(false)
	mission.world.set_process(false)

func _v5_fixture() -> Dictionary:
	return {"version": 5, "seed": 271104, "floor": 20, "health": 91.0, "oxygen": 83.0, "stress": 29.0, "anchors": 4, "flares": 2,
		"rescued": ["survivor_30", "survivor_28", "survivor_26"], "clues": ["evidence_29", "evidence_27", "evidence_26", "continuation_model_23", "continuation_photo_23", "commerce_deliveries_22", "commerce_maintenance_21"], "supplies_used": ["equipment_fire_28"], "elapsed": 1600.0,
		"seen_floors": [31,30,29,28,27,26,25,24,23,22,21,20], "completed": true, "incident_state": "aftermath", "transmissions": [], "radio_events": ["bravo_echo", "bravo_verification"],
		"continuation": {"phase": "complete", "started_at_refuge": true, "duo_briefed": true, "escort_state": "received"},
		"commerce": {"phase": "complete", "actions": ["shutter", "isolation", "blanket", "relay"], "people": {"mina": "received", "theo": "received", "sofia": "received"}, "contacted": ["mina", "theo", "sofia"]}}

func _require(condition: bool, message: String) -> bool:
	_check(condition, message)
	if not condition:
		if is_instance_valid(mission): mission.free()
		_clean()
		_finish()
	return condition

func _check(condition: bool, message: String) -> void:
	checks += 1
	if not condition: failures.append(message)

func _clean() -> void:
	if InputMap.has_action("interact"): Input.action_release("interact")
	for path: String in [SAVE, PREFS]:
		if FileAccess.file_exists(path): DirAccess.remove_absolute(ProjectSettings.globalize_path(path))

func _finish() -> void:
	if failures.is_empty():
		print("PASS residential integration: %d checks; real v5 debrief migration, visible chapter choice, held work, radio form, paused clocks, I/O rollback preserving live escorts and stable reload. Prepared standing placements, not travel proof." % checks)
		quit(0)
	else:
		for failure: String in failures: push_error(failure)
		print("FAIL residential integration: %d failures / %d checks." % [failures.size(), checks])
		quit(1)
