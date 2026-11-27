extends SceneTree
## Actual controller integration: early fear never becomes a hidden combat system.
const MainScene = preload("res://scenes/main.tscn")
const InteractionFixture = preload("res://tests/interaction_fixture.gd")
const Horror = preload("res://scripts/horror_director.gd")
const Store = preload("res://scripts/save_store.gd")
const SAVE: String = "user://qa_horror_v08.json"
const PREFS: String = SAVE + ".cfg"
var mission: Node3D
var checks: int = 0
var failures: Array[String] = []

func _initialize() -> void:
	_run.call_deferred()

func _run() -> void:
	_clean()
	mission = MainScene.instantiate()
	mission.save_path = SAVE
	mission.preferences_path = PREFS
	mission.sound_enabled = false
	root.add_child(mission)
	mission.set_process(false)
	await process_frame
	mission._setting_changed("audio",false)
	_check(mission.horror.elapsed == 0.0 and not _visible(), "The initial menu reveals a manifestation.")
	mission._start_new(271104)
	mission.set_process(false)
	mission._process_horror(30.0, 29)
	_check(mission.horror.elapsed == 0.0 and not _visible(), "The arrival ran early horror before player control.")
	mission._finish_arrival()
	_disable_ticks()
	await _pose(29)
	_check(mission._horror_line_of_sight(29), "Suite review pose is obstructed by a physical collider.")
	var before: Dictionary = _mission_facts()
	var save_bytes: PackedByteArray = FileAccess.get_file_as_bytes(SAVE)
	_tick(3.4)
	_check(mission.horror.active_id == "peripheral_29" and mission.horror_visuals.suites_figure.visible, "The real controller did not show a peripheral suite impression.")
	_check(_mission_facts() == before, "A suite impression modified mission facts or transcripts.")
	_check(FileAccess.get_file_as_bytes(SAVE) == save_bytes, "A visual impression rewrote the checkpoint.")
	var serial: int = mission.horror_cue_serial
	mission._process_horror(0.0, 29)
	_check(mission.horror_cue_serial == serial, "Redrawing an impression repeated its sound event.")
	# Use actual playback for the pause assertion, even on the dummy audio driver.
	mission.audio_horror.play()
	mission._pause()
	await physics_frame
	var clock: float = mission.horror.elapsed
	var alpha: float = float(mission.horror.presentation()["suites_alpha"])
	mission._process(5.0)
	_check(mission.horror.elapsed == clock and float(mission.horror.presentation()["suites_alpha"]) == alpha, "Pause advanced the manifestation clock or fade.")
	_check(not mission.audio_horror.playing or mission.audio_horror.stream_paused, "Pause left spatial footsteps playing.")
	mission._resume()
	_disable_ticks()
	_check(not mission.audio_horror.stream_paused and mission.horror_cue_serial == serial, "Resume failed audio continuity or replayed the cue.")
	mission._open_journal()
	mission._process(8.0)
	_check(mission.paused and mission.horror.elapsed == clock, "Journal reading advanced the early manifestation.")
	mission._resume()
	_disable_ticks()
	mission.player.camera.look_at(Horror.SUITES_POSITION + Vector3(0, 1.15, 0))
	_tick(0.7)
	_check(not mission.horror_visuals.suites_figure.visible, "Direct inspection failed to dissolve the fleeting suite impression.")
	# A physical occluder must not consume an unseen cue.
	mission.horror.reset()
	await _pose(29)
	var blocker: StaticBody3D = StaticBody3D.new()
	var shape: CollisionShape3D = CollisionShape3D.new()
	var box: BoxShape3D = BoxShape3D.new()
	box.size = Vector3(2, 3, 0.5)
	shape.shape = box
	blocker.add_child(shape)
	mission.world.add_child(blocker)
	blocker.global_position = mission.player.camera.global_position.lerp(Horror.SUITES_POSITION + Vector3(0,1.15,0),0.5)
	await physics_frame
	_check(not mission._horror_line_of_sight(29), "The actual physics ray ignored an opaque blocker.")
	_tick(8.0)
	_check(mission.horror.cue_serial == 0 and not mission.horror_visuals.suites_figure.visible, "An obstructed suite consumed or exposed a cue.")
	blocker.free()
	shape = null
	box = null
	blocker = null
	await physics_frame
	_tick(3.4)
	_check(mission.horror_visuals.suites_figure.visible, "An unconsumed cue did not become available after the blocker was removed.")
	# Operational actions suppress new perceptions without losing mission receipts.
	await _pose(26)
	mission.horror.reset()
	mission._say("NORA / SECOURS", "Ici !", 8.0, true)
	_tick(9.0)
	_check(mission.horror.cue_serial == 0, "An active rescue transmission allowed a new manifestation.")
	_silence()
	var casualty: Node3D = _object("survivor",26)
	InteractionFixture.face(mission, casualty)
	mission._interact_node(casualty)
	_silence()
	_tick(12.0)
	_check(mission.carried == casualty and mission.horror.cue_serial == 0 and not _visible(), "Carrying a person allowed a new manifestation.")
	InteractionFixture.face(mission, _object("beacon",26))
	mission._interact_node(_object("beacon",26))
	_silence()
	_tick(12.0)
	_check(mission.hoisting == casualty and mission.horror.cue_serial == 0 and not _visible(), "An active hoist allowed a new manifestation.")
	mission._process_hoist(5.1)
	mission.rescue_visuals.finish_reception()
	await _pose(26)
	mission.horror.reset()
	before = _mission_facts()
	_tick(5.5)
	_check(mission.horror_visuals.spa_figure.visible, "The spa presence failed to appear through actual controller gating.")
	var anchor: Vector3 = mission.horror_visuals.spa_figure.global_position
	_check(_mission_facts() == before, "The spa perception damaged the player or changed rescue state.")
	mission.player.global_position = anchor + Vector3(0.3,0.1,0.3)
	mission._process_hazards(30.0,26)
	mission._process_horror(1.0,26)
	_check(mission.health == float(before["health"]), "The retired early E00 attack still inflicts contact damage.")
	_check(mission.horror_visuals.spa_figure.global_position == anchor, "The spa perception chases or teleports toward the player.")
	await _pose(26)
	mission.horror.reset()
	_tick(5.5)
	var old_flares: int = mission.flares
	mission._use_flare()
	mission._process_horror(0.1,26)
	_check(mission.flares == old_flares - 1 and mission.flare_time == 20.0, "The comfort light no longer uses the normal flare resource and duration.")
	_check(not mission.horror_visuals.spa_figure.visible, "The active flare leaves the stationary presence visible.")
	mission.flare_time = 0.0
	# Traces follow stable world state, including restore, without fabricating a clue.
	await _pose(28)
	mission.horror.reset()
	_tick(12.0)
	_check(not mission.horror_visuals.trace_root.visible, "Damp traces precede the structural incident in the opening.")
	mission.incident.restore("aftermath")
	mission.world.apply_incident("aftermath",0.0)
	before = _mission_facts()
	_tick(9.0)
	_check(mission.horror_visuals.trace_root.visible and float(mission.horror.presentation()["trace_progress"]) == 1.0, "Archive traces did not form and remain after impact.")
	_check(_mission_facts() == before, "Environmental traces fabricated clues, receipts or radio history.")
	mission.seen_floors = [29,28,26]
	_check(mission._save_checkpoint(28), "The unchanged schema3 failed to save a valid horror-era checkpoint.")
	var checkpoint: Dictionary = Store.load_data(SAVE)
	_check(checkpoint.get("version",0) == Store.SAVE_VERSION and not checkpoint.has("horror_events"), "Cosmetic impression state leaked into the checkpoint schema.")
	save_bytes = FileAccess.get_file_as_bytes(SAVE)
	mission._restore(checkpoint)
	_disable_ticks()
	await _pose(28)
	mission._process_horror(0.0,28)
	_check(mission.horror_visuals.trace_root.visible, "Stable archive dressing did not restore from aftermath and visited-floor state.")
	await _pose(29)
	_tick(10.0)
	_check(not mission.horror_visuals.suites_figure.visible, "Loading an already visited floor replayed its initial fleeting impression.")
	await _pose(26)
	_tick(10.0)
	_check(not mission.horror_visuals.spa_figure.visible, "Loading an already visited spa replayed its initial presence.")
	_check(FileAccess.get_file_as_bytes(SAVE) == save_bytes, "Restore or atmospheric sampling rewrote the saved intervention.")
	# A stale presentation cannot reappear behind the ending when options change.
	mission.horror.reset()
	_tick(5.5)
	_check(mission.horror_visuals.spa_figure.visible, "Ending regression fixture has no active presence to clear.")
	mission.rescued = ["survivor_30","survivor_28","survivor_26"]
	mission.world.set_rescued_people(mission.rescued)
	mission.player.teleport_to_floor(25)
	mission._complete_game()
	_check(mission.completed and mission.epilogue_playing and not _visible(), "Closing the mission retained early manifestations in the film world.")
	mission._setting_changed("reduced_motion",true)
	_check(not _visible(), "Changing comfort during the ending revived a stale perception.")
	mission._finish_epilogue()
	mission._return_to_menu()
	_disable_ticks()
	_check(not mission.started and not _visible() and not mission.audio_horror.playing, "Returning to the menu leaked perception visuals or spatial sound.")
	mission._start_new(271104)
	mission._finish_arrival()
	_disable_ticks()
	await _pose(29)
	_tick(3.4)
	_check(mission.horror_visuals.suites_figure.visible, "A new intervention inherited consumed perception state.")
	mission.audio_horror.play()
	mission._setting_changed("audio",false)
	_check(not mission.audio_horror.playing, "Muting audio left a spatial horror channel running.")
	mission.queue_free()
	await process_frame
	_clean()
	if failures.is_empty():
		print("PASS horror_integration: %d checks; real controller, occlusion, rescue priority, no early damage, pause, journal, flare, save continuity, completion and new-game isolation." % checks)
		quit(0)
	else:
		for message: String in failures:
			push_error(message)
		print("FAIL horror_integration: %d failures / %d checks" % [failures.size(),checks])
		quit(1)

func _pose(floor_number: int) -> void:
	mission.player.teleport_to_floor(floor_number)
	_disable_ticks()
	mission.last_floor = floor_number
	_silence()
	if floor_number == 29:
		mission.player.position = Vector3(-3.0,30.1,2.0)
		mission.player.camera.look_at(Vector3(-3.0,31.3,-5))
	elif floor_number == 26:
		mission.player.position = Vector3(-2.5,12.1,4.5)
		mission.player.camera.look_at(Vector3(-10,13,2))
	else:
		mission.player.position = Vector3(-2.6,24.1,3.0)
		mission.player.camera.look_at(Horror.TRACE_POSITION)
	await physics_frame

func _tick(seconds: float) -> void:
	for index in range(roundi(seconds * 10.0)):
		mission._process_horror(0.1,mission.player.nearest_floor())

func _silence() -> void:
	mission.radio.reset()
	mission._sync_radio()

func _disable_ticks() -> void:
	mission.set_process(false)
	mission.player.set_process(false)
	mission.player.set_physics_process(false)
	mission.world.set_process(false)

func _object(kind: String, floor_number: int) -> Node3D:
	for object: Node3D in mission.world_data["interactables"]:
		if object.get_meta("kind","") == kind and int(object.get_meta("floor",0)) == floor_number:
			return object
	return null

func _visible() -> bool:
	return mission.horror_visuals.suites_figure.visible or mission.horror_visuals.spa_figure.visible or mission.horror_visuals.trace_root.visible

func _mission_facts() -> Dictionary:
	return {"health":mission.health,"oxygen":mission.oxygen,"stress":mission.stress,"elapsed":mission.elapsed,"rescued":mission.rescued.duplicate(),"clues":mission.clues.duplicate(),"supplies":mission.supplies_used.duplicate(),"transmissions":mission.radio.history_snapshot(),"radio_events":mission.radio_events.duplicate()}

func _check(condition: bool, message: String) -> void:
	checks += 1
	if not condition:
		failures.append(message)

func _clean() -> void:
	for path: String in [SAVE,PREFS]:
		if FileAccess.file_exists(path):
			DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
