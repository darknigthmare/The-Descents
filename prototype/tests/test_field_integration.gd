extends SceneTree
## Reachable inspection, real modal signals, occlusion and unmodified mission state.

const MainScene = preload("res://scenes/main.tscn")
const Field = preload("res://scripts/field_props.gd")
const Preferences = preload("res://scripts/preferences_store.gd")
const TEST_PATH: String = "user://qa_v05_field_integration.json"
const PREFS_PATH: String = "user://qa_v05_field_integration.cfg"
var mission: Node3D
var checks: int = 0
var failures: Array[String] = []

func _initialize() -> void:
	_run.call_deferred()

func _run() -> void:
	_cleanup()
	Preferences.save_settings({"audio":false,"flashes":false,"reduced_motion":true,"startup_intro":false},PREFS_PATH)
	mission = MainScene.instantiate()
	mission.save_path = TEST_PATH
	mission.preferences_path = PREFS_PATH
	root.add_child(mission)
	_disable_ticks()
	mission._start_new(271104)
	mission._finish_arrival()
	_disable_ticks()
	await physics_frame
	var props: Array[Node3D] = []
	for object: Node3D in mission.world_data["interactables"]:
		if object.get_meta("kind", "") == "inspect":
			props.append(object)
	_check(props.size() == 12, "The mission did not register exactly twelve inspectable props.")
	var initial_bytes: String = FileAccess.get_file_as_string(TEST_PATH)
	for object: Node3D in props:
		var reachable: bool = _face_from_clear_position(object)
		_check(reachable, "No nearby unobstructed standing position reaches %s." % object.get_meta("id"))
		if not reachable:
			continue
		mission._find_nearest()
		_check(mission.nearest == object, "An unobstructed, aimed prop failed to become the current interaction: %s." % object.get_meta("id"))
		var before: Dictionary = _state()
		# These imported streams are muted, but must be playing to test stream_paused.
		mission.audio_wind.play()
		mission.audio_radio.play()
		# Let the audio thread establish these voices before testing their pause.
		await physics_frame
		mission._interact()
		_check(mission.paused and mission.hud.inspection_panel.visible and not mission.hud.pause_panel.visible, "Examining %s did not open an exclusive reading modal." % object.get_meta("id"))
		_check(not mission.player.active and not mission.world.is_processing() and mission.audio_wind.stream_paused and mission.audio_radio.stream_paused, "Inspection left movement, world effects or audio running.")
		var entry: Dictionary = Field.read(str(object.get_meta("id")), {"incident_state":"intact","rescued":[],"supplies_used":[]})
		var visible_text: String = _panel_text()
		_check(visible_text.contains(str(entry.get("observation",""))) and visible_text.contains(str(entry.get("usage",""))) and visible_text.contains(str(entry.get("action",""))), "The inspection panel dropped an observation, usage or action field.")
		mission._process(100.0)
		_check(_state() == before and FileAccess.get_file_as_string(TEST_PATH) == initial_bytes, "Reading consumed resources, advanced radio/incident time or rewrote progress.")
		var buttons: Array[Node] = mission.hud.inspection_panel.find_children("*","Button",true,false)
		_check(not buttons.is_empty(), "The reading panel has no focusable close button.")
		if not buttons.is_empty():
			buttons[0].pressed.emit()
		else:
			mission._resume()
		_check(not mission.paused and not mission.hud.inspection_panel.visible and mission.player.active and mission.world.is_processing() and not mission.audio_radio.stream_paused, "Closing inspection failed to restore live controls, world or audio.")
		mission.audio_wind.stop()
		mission.audio_radio.stop()
		_check(not object.get_meta("used",false) and object.visible, "Reading consumed a reusable field prop.")
		_disable_ticks()
		# Do not stack twelve start/stop pairs in one mixer cycle. The audio
		# driver runs on wall time, separately from the sampled mission clock.
		await physics_frame
		await create_timer(0.04).timeout
	if not props.is_empty():
		await _test_guards(props[0])
		_test_context_and_resume(props[0])
	_check(FileAccess.get_file_as_string(TEST_PATH) == initial_bytes, "Field observations changed the checkpoint during interaction tests.")
	# Let the audio mixer release the muted playback objects before quitting the tree.
	await create_timer(0.15).timeout
	mission.free()
	await process_frame
	await process_frame
	_cleanup()
	_finish()

func _test_guards(object: Node3D) -> void:
	_check(_face_from_clear_position(object), "Could not position the guard test beside the rooftop prop.")
	var standing: Vector3 = mission.player.position
	var forward: Vector3 = -mission.player.camera.global_basis.z
	mission.player.camera.look_at(mission.player.camera.global_position - forward)
	_check(not mission._interaction_visible(object), "An inspection is offered behind the player's view.")
	mission._open_inspection(object)
	_check(not mission.paused, "The direct inspection entry point bypassed the view requirement.")
	_face_from_clear_position(object)
	var origin: Vector3 = mission.player.camera.global_position
	var focus: Vector3 = object.global_position + (object.get_meta("focus_offset") as Vector3)
	var wall: StaticBody3D = StaticBody3D.new()
	var shape: CollisionShape3D = CollisionShape3D.new()
	var box: BoxShape3D = BoxShape3D.new()
	box.size = Vector3(0.5,2.5,0.5)
	shape.shape = box
	wall.add_child(shape)
	mission.world.add_child(wall)
	wall.global_position = origin.lerp(focus,0.5)
	await physics_frame
	_check(not mission._interaction_visible(object), "An inspection ray passed through solid geometry.")
	mission._open_inspection(object)
	_check(not mission.paused, "The direct inspection entry point bypassed physical occlusion.")
	wall.free()
	await physics_frame
	mission.player.position = standing + Vector3(0,0,8)
	mission.player.camera.look_at(focus)
	_check(not mission._interaction_visible(object), "An inspection is offered outside its 2.4 m range.")
	_face_from_clear_position(object)
	mission.player.on_rope = true
	_check(not mission._can_inspect(), "Reading can interrupt rope control.")
	mission.player.on_rope = false
	mission.carried = object
	_check(not mission._can_inspect(), "Reading can interrupt an active casualty carry.")
	mission.carried = null
	mission.hoisting = object
	_check(not mission._can_inspect(), "Reading can interrupt a running hoist.")
	mission.hoisting = null
	mission.incident.start()
	_check(not mission._can_inspect(), "Reading can replace an active emergency instruction.")
	mission.incident.restore("intact")
	# A real mission control remains preferred when it is within the protected range.
	var beacon: Node3D
	for target: Node3D in mission.world_data["interactables"]:
		if target.get_meta("kind", "") == "beacon" and target.get_meta("floor",0) == 31:
			beacon = target
			break
	if is_instance_valid(beacon):
		var original: Vector3 = object.global_position
		mission.player.position = beacon.global_position + Vector3(1.0,0.1,0)
		object.global_position = mission.player.global_position + Vector3(0,0,1.6)
		mission.player.camera.look_at(object.global_position + (object.get_meta("focus_offset") as Vector3))
		mission._find_nearest()
		_check(mission.nearest == beacon, "An optional inspection stole the nearby rope/hoist control.")
		object.global_position = original

func _test_context_and_resume(object: Node3D) -> void:
	mission.rescued = ["survivor_30"]
	mission.incident.restore("aftermath")
	mission.world.apply_incident("aftermath",0.0)
	_face_from_clear_position(object)
	mission._open_inspection(object)
	var entry: Dictionary = Field.read(str(object.get_meta("id")), {"incident_state":"aftermath","rescued":["survivor_30"],"supplies_used":[]})
	_check(mission.hud.inspection_panel.visible and _panel_text().contains(str(entry.get("team_note",""))), "The live panel did not project the current incident and confirmed rescue context.")
	var cancel: InputEventAction = InputEventAction.new()
	cancel.action = "pause_game"
	cancel.pressed = true
	mission._unhandled_input(cancel)
	_check(not mission.paused and not mission.hud.inspection_panel.visible and mission.incident.phase == "aftermath", "Escape failed to resume from inspection without changing the incident.")
	_disable_ticks()
	_face_from_clear_position(object)
	mission._open_inspection(object)
	_check(mission.hud.inspection_panel.visible, "A previously read prop could not be examined again.")
	mission._return_to_menu()
	_disable_ticks()
	_check(not mission.hud.inspection_panel.visible and mission.hud.menu.visible and not mission.paused, "Returning to the menu retained an inspection overlay or a paused session.")

func _face_from_clear_position(object: Node3D) -> bool:
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
		mission.player.position = candidate
		mission.player.camera.look_at(object.global_position + (object.get_meta("focus_offset") as Vector3))
		if mission._interaction_visible(object):
			return true
	return false

func _state() -> Dictionary:
	return {"elapsed":mission.elapsed,"health":mission.health,"oxygen":mission.oxygen,"stress":mission.stress,"anchors":mission.anchors,"flares":mission.flares,"rescued":mission.rescued.duplicate(),"clues":mission.clues.duplicate(),"supplies":mission.supplies_used.duplicate(),"radio_remaining":mission.radio.remaining,"radio_history":mission.radio.history.duplicate(true),"incident":mission.incident.phase,"phase_elapsed":mission.incident.phase_elapsed}

func _panel_text() -> String:
	var value: String = ""
	for node: Node in mission.hud.inspection_panel.find_children("*","",true,false):
		if node is Label or node is RichTextLabel:
			value += node.text + "\n"
	return value

func _disable_ticks() -> void:
	mission.set_process(false)
	mission.world.set_process(false)
	mission.player.set_process(false)
	mission.player.set_physics_process(false)

func _cleanup() -> void:
	for path: String in [TEST_PATH,PREFS_PATH,PREFS_PATH + ".tmp"]:
		if FileAccess.file_exists(path):
			DirAccess.remove_absolute(ProjectSettings.globalize_path(path))

func _check(condition: bool, message: String) -> void:
	checks += 1
	if not condition:
		failures.append(message)

func _finish() -> void:
	if failures.is_empty():
		print("PASS field integration: %d checks; twelve reachable inspections, real close/Escape, frozen mission and audio, optional priority, view/range/occlusion and contextual rereading." % checks)
		quit(0)
	else:
		for failure: String in failures:
			push_error(failure)
		print("FAIL field integration: %d failures / %d checks." % [failures.size(),checks])
		quit(1)
