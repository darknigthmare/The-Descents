extends SceneTree
## Abort blocked engagement/exit through real collision-controlled motion.

const MainScene = preload("res://scenes/main.tscn")
const Routes = preload("res://scripts/route_catalog.gd")
const Preferences = preload("res://scripts/preferences_store.gd")
const SAVE: String = "user://qa_rope_abort.json"
const PREFS: String = SAVE + ".cfg"
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
	mission._start_new(271104)
	mission._finish_arrival()
	_freeze()
	await physics_frame
	await _blocked_engagement()
	await _blocked_exit()
	Input.action_release("move_forward")
	Input.action_release("move_back")
	mission.free()
	_clean()
	if failures.is_empty():
		print("PASS rope abort: %d checks; obstructed attachment and exit, physical reverse transfer, retained belay, blocked retreat and pause." % checks)
		quit(0)
	else:
		for message: String in failures:
			push_error(message)
		print("FAIL rope abort: %d failures / %d checks" % [failures.size(), checks])
		quit(1)

func _blocked_engagement() -> void:
	var route: Dictionary = Routes.for_id("R31_30")
	await _station(route, 31)
	var start: Vector3 = mission.player.global_position
	var stock: int = mission.anchors
	var bytes: PackedByteArray = FileAccess.get_file_as_bytes(SAVE)
	mission._interact()
	_check(mission.player.on_rope and mission.player.rope_transfer == "attach", "The engagement fixture did not attach.")
	mission.player._process_rope(0.20)
	var wall: StaticBody3D = _wall(Vector3(-1.9, 43.05, 0), Vector3(0.24, 2.1, 1.7))
	await physics_frame
	mission.player._process_rope(0.65)
	var blocked: Vector3 = mission.player.global_position
	_check(mission.player.rope_obstructed and mission.player.can_cancel_rope_transfer(), "A newly blocked engagement offers no retreat.")
	mission._update_hud()
	_check(mission.hud.prompt_label.text.contains("Annuler le transfert"), "The blocked-transfer prompt does not explain E to retreat.")
	var back_wall: StaticBody3D = _wall(Vector3(-3.2, 43.05, 0), Vector3(0.15, 2.1, 1.7))
	await physics_frame
	_check(not mission.player.cancel_rope_transfer() and mission.player.global_position == blocked and mission.player.on_rope, "A blocked retreat teleported or released the rescuer.")
	back_wall.free()
	await physics_frame
	mission._interact()
	_check(mission.player.rope_transfer == "cancel_attach" and mission.player.on_rope and mission.player.global_position == blocked, "E did not begin a belayed reversal without teleporting.")
	mission.player._process_rope(0.40)
	var midpoint: Vector3 = mission.player.global_position
	_check(midpoint.distance_to(start) < blocked.distance_to(start) and midpoint.distance_to(start) > 0.01 and mission.player.on_rope, "The return skipped its intermediate physical position.")
	mission._pause()
	mission.player._process_rope(10.0)
	_check(mission.player.global_position == midpoint and mission.player.rope_transfer == "cancel_attach", "Pause advanced an interrupted return.")
	mission._resume()
	_freeze()
	mission.player._process_rope(0.45)
	_check(not mission.player.on_rope and mission.player.is_at_landing() and mission.player.global_position.distance_to(start) < 0.002, "Cancelled engagement did not reach its supported original landing.")
	_check(is_instance_valid(wall) and mission.anchors == stock and FileAccess.get_file_as_bytes(SAVE) == bytes, "Retreat removed the obstacle, spent an anchor, or rewrote the checkpoint.")
	_check(not mission.player.can_cancel_rope_transfer() and not mission.player.cancel_rope_transfer(), "A completed retreat remained cancelable on foot.")
	wall.free()
	await physics_frame

func _blocked_exit() -> void:
	var route: Dictionary = Routes.for_id("R31_30")
	await _station(route, 31)
	mission._interact()
	mission.player._process_rope(0.85)
	_drive("move_back", 40)
	mission.player._process_rope(0.30)
	_check(mission.player.can_exit_rope(), "The exit fixture did not reach the lower endpoint.")
	var suspended: Vector3 = mission.player.global_position
	mission._interact()
	mission.player._process_rope(0.15)
	var wall: StaticBody3D = _wall(Vector3(-2.75, 37.05, 0), Vector3(0.24, 2.1, 1.7))
	await physics_frame
	mission.player._process_rope(0.70)
	var blocked: Vector3 = mission.player.global_position
	_check(mission.player.rope_transfer == "exit" and mission.player.rope_obstructed and mission.player.can_cancel_rope_transfer(), "A blocked exit did not preserve an actionable belay.")
	mission._interact()
	_check(mission.player.rope_transfer == "cancel_exit" and mission.player.global_position == blocked, "Exit cancellation moved instantly instead of starting a return.")
	mission.player._process_rope(0.40)
	_check(mission.player.global_position.distance_to(suspended) < blocked.distance_to(suspended) and mission.player.on_rope, "Exit cancellation did not move back toward the rope.")
	mission.player._process_rope(0.45)
	_check(mission.player.on_rope and mission.player.rope_transfer.is_empty() and not mission.player.rope_obstructed and mission.player.global_position.distance_to(suspended) < 0.002, "Cancelled exit failed to restore controlled suspension.")
	mission._interact()
	_check(mission.player.on_rope and mission.player.rope_transfer.is_empty(), "The unchanged blocked landing accepted a second unsafe exit.")
	# The obstruction remains. The player can climb to the other local endpoint.
	_drive("move_forward", 80)
	mission.player._process_rope(0.30)
	_check(mission.player.can_exit_rope() and mission.player.rope_snapshot().get("exit_floor", 0) == 31, "Retreat did not restore ascent to the reachable opposite landing.")
	mission._interact()
	mission.player._process_rope(0.85)
	_check(not mission.player.on_rope and mission.player.is_at_landing() and mission.player.nearest_floor() == 31, "The safe alternate landing could not be reached after cancellation.")
	wall.free()
	await physics_frame

func _station(route: Dictionary, number: int) -> void:
	mission.player.teleport_to_floor(number)
	mission.player.position = route["top_entry"] if number == int(route["upper"]) else route["bottom_entry"]
	mission.player.velocity = Vector3.ZERO
	mission.player.active = true
	mission.last_floor = number
	await physics_frame
	mission._find_nearest()

func _drive(action: String, samples: int) -> void:
	Input.action_press(action)
	for index in range(samples):
		mission.player._process_rope(0.10)
	Input.action_release(action)

func _wall(position_value: Vector3, size_value: Vector3) -> StaticBody3D:
	var body: StaticBody3D = StaticBody3D.new()
	var collider: CollisionShape3D = CollisionShape3D.new()
	var box: BoxShape3D = BoxShape3D.new()
	box.size = size_value
	collider.shape = box
	body.add_child(collider)
	mission.add_child(body)
	body.global_position = position_value
	return body

func _freeze() -> void:
	mission.set_process(false)
	mission.set_physics_process(false)
	mission.player.set_physics_process(false)
	mission.world.set_process(false)

func _check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures.append(message)

func _clean() -> void:
	for path: String in [SAVE, PREFS]:
		if FileAccess.file_exists(path):
			DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
