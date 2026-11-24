extends SceneTree
## Flight timing and real-scene convergence across natural finish, skip and reload.

const Director = preload("res://scripts/cinematic_director.gd")
const MainScene = preload("res://scenes/main.tscn")
const Store = preload("res://scripts/save_store.gd")
const Preferences = preload("res://scripts/preferences_store.gd")
const TEST_PATH: String = "user://qa_v05_arrival_staging.json"
const PREFS_PATH: String = "user://qa_v05_arrival_staging.cfg"
var mission: Node3D
var checks: int = 0
var failures: Array[String] = []

func _initialize() -> void:
	_run.call_deferred()

func _run() -> void:
	_cleanup()
	_test_timing()
	Preferences.save_settings({"audio":false,"flashes":false,"reduced_motion":false,"startup_intro":false}, PREFS_PATH)
	mission = MainScene.instantiate()
	mission.save_path = TEST_PATH
	mission.preferences_path = PREFS_PATH
	root.add_child(mission)
	_disable_ticks()
	mission._start_new(271104)
	_disable_ticks()
	var saved_bytes: String = FileAccess.get_file_as_string(TEST_PATH)
	var checkpoint: Dictionary = Store.load_data(TEST_PATH)
	_check(mission.arrival_playing and _aircraft_above_roofs(), "New mission did not stage both aircraft above their roofs.")
	mission._process(10.8)
	_check(mission.world.helicopters[1].global_position.is_equal_approx(mission.world.helicopter_origins[1]), "Bravo was not on its landing mark at its touchdown.")
	_check(mission.world.helicopters[0].global_position.y > mission.world.helicopter_origins[0].y, "Alpha landed before its own scheduled approach finished.")
	mission._process(6.2)
	var moving: Dictionary = _poses()
	# Headless mode does not autostart ambience; exercise an actual muted stream.
	mission.audio_rotors.play()
	mission._pause()
	mission._process(30.0)
	_check(_poses() == moving and mission.arrival_time == 17.0, "Paused arrival moved aircraft or deployed personnel.")
	_check(mission.audio_rotors.stream_paused and not mission.world.is_processing(), "Pause did not suspend rotor audio and world effects together.")
	mission._resume()
	_check(not mission.audio_rotors.stream_paused, "Resuming arrival left the actual rotor stream paused.")
	mission.audio_rotors.stop()
	_disable_ticks()
	mission._process(11.0)
	var natural: Dictionary = _poses()
	_check(not mission.arrival_playing and mission.player.active and mission.elapsed == 0.0, "Natural arrival failed its control and mission-clock handoff.")
	_check(FileAccess.get_file_as_string(TEST_PATH) == saved_bytes, "Natural arrival wrote transient flight data into the checkpoint.")
	_check(_aircraft_landed(), "Natural arrival left an aircraft displaced or banked.")
	mission.world.restore_arrival_staging()
	_check(_poses() == natural, "Restoring the final arrival pose is not idempotent.")
	for skip_time: float in [0.0,8.5,18.0,25.0]:
		mission._start_new(271104)
		_disable_ticks()
		mission._process(skip_time)
		mission._finish_arrival()
		_check(_poses() == natural, "Skip at %.1f s left a different aircraft, door or crew pose." % skip_time)
		_check(mission.elapsed == 0.0 and mission.health == 100.0 and mission.oxygen == 100.0, "Skip at %.1f s changed survival or mission timing." % skip_time)
		mission._finish_arrival()
		_check(_poses() == natural, "Repeated skip applied staging twice.")
	mission._restore(checkpoint)
	_disable_ticks()
	_check(not mission.arrival_playing and _poses() == natural, "Reloading the initial safe checkpoint replayed flight or changed the deployed team.")
	mission.incident.restore("aftermath")
	mission.world.apply_incident("aftermath",0.0)
	var retreat: Dictionary = _poses()
	mission.world.restore_arrival_staging()
	_check(_poses() == retreat, "Arrival restoration erased the already-applied Bravo retreat.")
	mission.free()
	await process_frame
	await process_frame
	_cleanup()
	_finish()

func _test_timing() -> void:
	_check(Director.staging_sample(-10.0) == Director.staging_sample(0.0), "Negative staging time escaped the start pose.")
	_check(Director.staging_sample(100.0) == Director.staging_sample(28.0), "Oversized staging time escaped the final pose.")
	var previous: Array = [Vector3.INF,Vector3.INF]
	for t: float in [0.0,3.0,6.5,8.0,10.8,13.4,16.0,20.0,23.0,26.0,28.0]:
		var sample: Dictionary = Director.staging_sample(t)
		_check(sample == Director.staging_sample(t), "A staging sample depends on frame history.")
		_check(sample["crew"] >= 0.0 and sample["crew"] <= 1.0, "Crew deployment escaped its normalized interval.")
		for index in range(2):
			var plane: Dictionary = sample["aircraft"][index]
			var offset: Vector3 = plane["offset"]
			_check(offset.is_finite() and offset.y >= 0.0 and offset.z >= 0.0, "An arrival flew below or behind its landing surface.")
			_check(offset.y <= previous[index].y and offset.z <= previous[index].z, "An approach reversed altitude or penetrated the roof on a later sample.")
			_check(plane["door"] >= 0.0 and plane["door"] <= 1.0 and plane["wash"] >= 0.0 and plane["wash"] <= 1.0, "Door or rotor wash escaped its normalized interval.")
			if offset.y > 0.001:
				_check(plane["door"] == 0.0, "An airborne cabin opened before touchdown.")
			previous[index] = offset
	var final: Dictionary = Director.staging_sample(28.0)
	_check(final["crew"] == 1.0, "The crew is not fully deployed at handoff.")
	for plane: Dictionary in final["aircraft"]:
		_check((plane["offset"] as Vector3).is_zero_approx() and (plane["rotation"] as Vector3).is_zero_approx() and plane["door"] == 0.0 and plane["wash"] == 0.0, "The final aircraft pose is not closed, level and settled.")

func _aircraft_above_roofs() -> bool:
	for index in range(2):
		if mission.world.helicopters[index].global_position.y <= mission.world.helicopter_origins[index].y + 20.0:
			return false
	return true

func _aircraft_landed() -> bool:
	for index in range(2):
		var aircraft: Node3D = mission.world.helicopters[index]
		if not aircraft.global_position.is_equal_approx(mission.world.helicopter_origins[index]) or not aircraft.rotation.is_zero_approx():
			return false
	return true

func _poses() -> Dictionary:
	var result: Dictionary = {}
	for aircraft: Node3D in mission.world.helicopters:
		result[str(aircraft.name)] = aircraft.transform
		for child: Node in aircraft.find_children("*", "Node3D", true, false):
			if "Door" in str(child.name):
				result[str(aircraft.name) + "/" + str(child.name)] = child.transform
	for team: String in ["alpha","bravo"]:
		var members: Array = mission.world.alpha_roof_members if team == "alpha" else mission.world.bravo_roof_members
		for index in range(members.size()):
			var member: Node3D = members[index]
			var pose: Array = [member.transform,member.visible]
			for limb: String in ["LeftLeg","RightLeg","LeftArm","RightArm"]:
				var node: Node3D = member.get_node_or_null(limb)
				if is_instance_valid(node):
					pose.append(node.transform)
			result["crew/" + team + "/" + str(index)] = pose
	return result

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
		print("PASS arrival staging: %d checks; sampled flight, touchdown order, pause, natural/skip/reload convergence and preserved incident poses." % checks)
		quit(0)
	else:
		for failure: String in failures:
			push_error(failure)
		print("FAIL arrival staging: %d failures / %d checks." % [failures.size(),checks])
		quit(1)
