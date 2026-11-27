extends SceneTree
## Re-enter a real v4 debrief, then start v5 without losing its five people.
## This suite validates restoration/transition guards, not escort path traversal.

const MainScene = preload("res://scenes/main.tscn")
const Store = preload("res://scripts/save_store.gd")
const Preferences = preload("res://scripts/preferences_store.gd")
const Dossier = preload("res://scripts/mission_dossier.gd")
const InteractionFixture = preload("res://tests/interaction_fixture.gd")
const SAVE: String = "user://qa_addon_schema.json"
const PREFS: String = SAVE + ".cfg"
var mission: Node3D
var checks: int = 0
var failures: Array[String] = []

func _initialize() -> void:
	_run.call_deferred()

func _run() -> void:
	_clean()
	var legacy: Dictionary = _v4_fixture()
	var file: FileAccess = FileAccess.open(SAVE, FileAccess.WRITE)
	file.store_string(JSON.stringify(legacy))
	file.close()
	var original: PackedByteArray = FileAccess.get_file_as_bytes(SAVE)
	var migrated: Dictionary = Store.load_data(SAVE)
	_check(migrated.get("version") == Store.SAVE_VERSION and migrated.get("continuation") == legacy["continuation"], "Reading v4 did not retain the completed congress reconnaissance.")
	_check(migrated.get("rescued") == legacy["rescued"] and migrated.get("clues") == legacy["clues"] and migrated.get("supplies_used") == legacy["supplies_used"], "Migration discarded original rescue, clue or equipment receipts.")
	_check(FileAccess.get_file_as_bytes(SAVE) == original, "Reading the v4 checkpoint rewrote it.")
	Preferences.save_settings(Preferences.normalize({"audio": false, "startup_intro": false}), PREFS)
	mission = MainScene.instantiate()
	mission.save_path = SAVE
	mission.preferences_path = PREFS
	root.add_child(mission)
	_freeze()
	await physics_frame
	mission.hud.descent_requested.emit()
	_check(not mission.started and mission.commerce.phase == "dormant" and FileAccess.get_file_as_bytes(SAVE) == original, "A stale descent signal opened commerce from the menu.")
	mission._continue_game()
	_freeze()
	await physics_frame
	_check(mission.completed and mission.continuation.phase == "complete" and mission.commerce.phase == "dormant" and mission.hud.end_panel.visible, "Loading a v4 ending silently began the lower chapter.")
	_check_five(legacy, "v4 debrief")
	mission._open_journal()
	mission.hud.descent_requested.emit()
	_check(mission.paused and mission.commerce.phase == "dormant" and FileAccess.get_file_as_bytes(SAVE) == original, "A stale descent signal began the lower chapter behind the journal.")
	mission._resume()
	_freeze()
	mission.hud.end_panel.hide()
	mission.hud.descent_requested.emit()
	_check(mission.commerce.phase == "dormant" and FileAccess.get_file_as_bytes(SAVE) == original, "A hidden debrief started the lower chapter.")
	mission.hud.show_debrief(mission._dossier_snapshot())
	mission.player.teleport_to_floor(24)
	await physics_frame
	mission.hud.descent_requested.emit()
	_check(mission.commerce.phase == "dormant" and FileAccess.get_file_as_bytes(SAVE) == original, "A debrief signal accepted a different departure floor.")
	mission.player.teleport_to_floor(23)
	await physics_frame
	var previous_world: Node3D = mission.world
	mission.save_path = "user://qa_addon_missing_%d/checkpoint.json" % Time.get_ticks_usec()
	mission.hud.descent_requested.emit()
	_check(mission.completed and mission.commerce.phase == "dormant" and mission.world == previous_world and FileAccess.get_file_as_bytes(SAVE) == original, "A failed chapter-start save rebuilt the world or discarded the previous ending.")
	_check_five(legacy, "failed transition")
	mission.save_path = SAVE
	mission.hud.descent_requested.emit()
	_freeze()
	await physics_frame
	var started_bytes: PackedByteArray = FileAccess.get_file_as_bytes(SAVE)
	_check(mission.started and not mission.completed and mission.commerce.phase == "active" and mission.player.nearest_floor() == 23, "A valid visible ending could not durably start commerce at the real landing.")
	_check(Store.load_data(SAVE).get("commerce", {}).get("phase") == "active" and JSON.parse_string(FileAccess.get_file_as_string(SAVE)).get("version") == Store.SAVE_VERSION, "The lower chapter began before its v5 checkpoint existed.")
	_check_five(legacy, "new chapter")
	mission.hud.descent_requested.emit()
	_check(mission.commerce.phase == "active" and FileAccess.get_file_as_bytes(SAVE) == started_bytes, "A repeated stale signal restarted or resaved an active lower chapter.")
	for index in range(2):
		mission._continue_game()
		_freeze()
		await physics_frame
		_check_five(legacy, "active reload %d" % index)
		_check(FileAccess.get_file_as_bytes(SAVE) == started_bytes and mission.commerce.received_count() == 0, "Loading commerce rewrote the checkpoint or invented a lower-floor reception.")
	var refuge: Node3D
	for target: Node3D in mission.world_data.get("interactables", []):
		if target.get_meta("kind", "") == "refuge" and int(target.get_meta("floor", 0)) == 25:
			refuge = target
			break
	InteractionFixture.face(mission, refuge)
	await physics_frame
	mission._find_nearest()
	_check(mission.nearest == refuge, "The old refuge could not be reached after starting commerce.")
	mission._interact()
	var refuge_save: Dictionary = Store.load_data(SAVE)
	_check(refuge_save.get("floor") == 25 and refuge_save.get("commerce", {}).get("phase") == "active" and not refuge_save.get("completed", true), "Returning to refuge 25 no longer records a safe lower-chapter checkpoint.")
	var refuge_bytes: PackedByteArray = FileAccess.get_file_as_bytes(SAVE)
	mission._continue_game()
	_freeze()
	await physics_frame
	_check(mission.player.nearest_floor() == 25 and not mission.completed and FileAccess.get_file_as_bytes(SAVE) == refuge_bytes, "Reloading the old refuge restarted an ending or changed the saved chapter.")
	_check_five(legacy, "refuge reload")
	mission.free()
	_clean()
	if failures.is_empty():
		print("PASS addon schema: %d checks; genuine v4 migration, five preserved receptions, stale-signal gates, failed transition rollback and reusable refuge 25." % checks)
		quit(0)
	else:
		for message: String in failures: push_error(message)
		print("FAIL addon schema: %d failures / %d checks" % [failures.size(), checks])
		quit(1)

func _check_five(legacy: Dictionary, label: String) -> void:
	_check(mission.rescued == legacy["rescued"] and mission.continuation.snapshot() == legacy["continuation"] and mission.clues == legacy["clues"] and mission.supplies_used == legacy["supplies_used"], label + ": previous durable records changed.")
	var visible_roof: int = 0
	for person: Node3D in mission.world.roof_rescued_people.values():
		if person.is_visible_in_tree(): visible_roof += 1
	_check(visible_roof == 3 and mission.continuation_visuals.both_arrived(), label + ": a previously received person disappeared or left their refuge.")
	_check(Dossier.build(mission._dossier_snapshot())["total_received"] == 5, label + ": the journal lost or duplicated an original reception.")

func _v4_fixture() -> Dictionary:
	return {"version": 4, "seed": 271104, "floor": 23, "health": 83.0, "oxygen": 91.0, "stress": 27.0,
		"anchors": 3, "flares": 4, "rescued": ["survivor_30", "survivor_28", "survivor_26"],
		"clues": ["evidence_29", "continuation_model_23", "continuation_photo_23"], "supplies_used": ["equipment_fire_28"],
		"elapsed": 1260.0, "seen_floors": [30, 29, 28, 27, 26, 25, 24, 23], "completed": true, "incident_state": "aftermath",
		"transmissions": [{"speaker": "VARGA", "message": "Léa et Idris sont reçus au refuge 25.", "elapsed": 1200.0}],
		"radio_events": ["bravo_echo", "bravo_verification"],
		"continuation": {"phase": "complete", "started_at_refuge": true, "duo_briefed": true, "escort_state": "received"}}

func _freeze() -> void:
	mission.set_process(false)
	mission.set_physics_process(false)
	mission.player.set_physics_process(false)
	mission.world.set_process(false)

func _check(ok: bool, message: String) -> void:
	checks += 1
	if not ok: failures.append(message)

func _clean() -> void:
	for path: String in [SAVE, PREFS]:
		if FileAccess.file_exists(path): DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
