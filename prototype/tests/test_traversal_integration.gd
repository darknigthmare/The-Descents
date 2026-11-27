extends SceneTree
## Actual controller + capsule tests. Only scenario setup assigns a position;
## tested rope travel and transfers use the player's real move_and_collide.

const MainScene = preload("res://scenes/main.tscn")
const InteractionFixture = preload("res://tests/interaction_fixture.gd")
const Store = preload("res://scripts/save_store.gd")
const Routes = preload("res://scripts/route_catalog.gd")
const PhysicalRoutes = preload("res://tests/test_vertical_routes.gd")
const SAVE: String = "user://qa_traversal_v09.json"
const PREFS: String = SAVE + ".cfg"
var mission: Node3D
var checks: int = 0
var failures: Array[String] = []
var rope_samples: int = 0
var stair_driver


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
	mission._start_new(271104)
	mission._finish_arrival()
	_check(Store.load_data(SAVE).get("floor", 0) == 31, "A fresh intervention could not save its supported rooftop before the first physics frame.")
	_disable_ticks()
	await physics_frame
	await physics_frame
	await _test_three_local_links()
	await _test_physical_obstructions()
	await _test_stair_checkpoint()
	await _test_airborne_checkpoint()
	await _test_operational_priority()
	await _test_stair_radio_gate()
	_release_inputs()
	mission.free()
	_clean()
	if failures.is_empty():
		print("PASS traversal integration: %d checks; %d real capsule rope samples; three adjacent links both ways, timed transfers, brakes, lock, anchors, obstacles, pause/journal, stable checkpoints, stair HUD and rescue priorities." % [checks, rope_samples])
		quit(0)
	else:
		for failure: String in failures:
			push_error(failure)
		print("FAIL traversal integration: %d failures / %d checks; %d rope samples." % [failures.size(), checks, rope_samples])
		quit(1)


func _test_three_local_links() -> void:
	for route_id: String in ["R31_30", "R29_28", "R27_26"]:
		var route: Dictionary = Routes.for_id(route_id)
		await _station_fixture(route_id, int(route["upper"]))
		var entry: Vector3 = mission.player.position
		var stock: int = mission.anchors
		mission._find_nearest()
		_check(mission.nearest == _object("rappel", int(route["upper"])), "%s: proximity did not select the blue station." % route_id)
		_send("interact")
		_check(mission.player.on_rope and mission.player.rope_transfer == "attach", "%s: E did not begin the local entry transfer." % route_id)
		_check(mission.player.position.is_equal_approx(entry), "%s: attachment teleported the capsule." % route_id)
		_send("anchor")
		_check(mission.anchors == stock, "%s: an anchor was consumed during entry transfer." % route_id)
		_step(0.20)
		_check(mission.player.position.x > entry.x and mission.player.position.x < float(route["rope_top"].x), "%s: entry did not interpolate through the physical gap." % route_id)
		_check(mission.player.on_rope and mission.player.rope_transfer == "attach", "%s: entry finished before 0.85 seconds." % route_id)
		if route_id == "R31_30":
			_test_modal_freeze("entry transfer")
		_step(0.65)
		_check(mission.player.rope_transfer.is_empty() and mission.player.position.is_equal_approx(route["rope_top"]), "%s: 0.85-second entry did not reach the authored rope endpoint." % route_id)
		_send("anchor")
		_check(mission.anchors == stock - 1 and mission.player.secured_time > 15.9, "%s: a successful stabilization did not consume exactly one anchor." % route_id)
		_send("anchor")
		_check(mission.anchors == stock - 1, "%s: repeated stabilization consumed a second anchor." % route_id)
		_drive("move_back", 1, 0.10)
		_check(not mission.player.can_exit_rope(), "%s: a moving player could exit near the departure lip." % route_id)
		_send("interact")
		_check(mission.player.on_rope and mission.player.rope_transfer.is_empty(), "%s: E bypassed the braking requirement." % route_id)
		_drive("move_back", 5, 0.10)
		_check(not mission.player.can_exit_rope(), "%s: a suspended player could exit between floors." % route_id)
		mission._update_hud()
		_check(mission.hud.traversal_panel.visible and mission.hud.traversal_title.text.contains("%d ↔ %d" % [route["upper"], route["lower"]]), "%s: HUD omits the actual local route." % route_id)
		_check(mission.hud.traversal_metrics.text.contains("m/s") and mission.hud.traversal_metrics.text.contains("Corde") and is_equal_approx(mission.hud.traversal_stamina.value, mission.player.stamina), "%s: HUD omits speed/rope length or shows stale stamina." % route_id)
		if route_id == "R31_30":
			_test_lock()
			_test_modal_freeze("suspension")
			var previous: PackedByteArray = FileAccess.get_file_as_bytes(SAVE)
			_check(not mission._save_checkpoint(30) and mission.traversal_checkpoint_pending, "Suspension was saved as a stable floor or lost its pending request.")
			_check(FileAccess.get_file_as_bytes(SAVE) == previous, "A suspension save attempt overwrote the previous safe checkpoint.")
		_drive("move_back", 40, 0.10)
		_check(is_equal_approx(mission.player.position.y, route["rope_bottom"].y), "%s: descent did not stop at its immediately adjacent floor." % route_id)
		var bottom_y: float = mission.player.position.y
		_drive("move_back", 20, 0.10)
		_check(is_equal_approx(mission.player.position.y, bottom_y), "%s: continuing downward skipped another floor." % route_id)
		_step(0.25)
		await _exit_to(route["bottom_entry"], int(route["lower"]), route_id + " lower")
		mission._process(0.01)
		if route_id == "R31_30":
			_check(not mission.traversal_checkpoint_pending and Store.load_data(SAVE).get("floor", 0) == 30, "A pending suspended checkpoint did not commit at the next stable landing.")
		# Reattach from the reached lower landing: no new fixture or position write.
		mission._find_nearest()
		_send("interact")
		_check(mission.player.on_rope and mission.player.rope_snapshot().get("route_id", "") == route_id, "%s: the return station selected another segment." % route_id)
		_step(0.85)
		_drive("move_forward", 100, 0.10)
		_check(is_equal_approx(mission.player.position.y, route["rope_top"].y), "%s: ascending did not stop at the upper endpoint." % route_id)
		var top_y: float = mission.player.position.y
		_drive("move_forward", 10, 0.10)
		_check(is_equal_approx(mission.player.position.y, top_y), "%s: ascending escaped above the local connection." % route_id)
		_step(0.30)
		await _exit_to(route["top_entry"], int(route["upper"]), route_id + " upper")
		stock = mission.anchors
		_send("anchor")
		_check(mission.anchors == stock, "%s: anchoring on foot consumed an item." % route_id)
		mission._update_hud()
		_check(not mission.hud.traversal_panel.visible, "%s: the suspended HUD survived a completed dismount." % route_id)


func _test_lock() -> void:
	_send("jump")
	var locked: Dictionary = mission.player.rope_snapshot()
	_check(bool(locked["locked"]) and is_zero_approx(float(locked["speed"])), "Space did not lock the actual descender and brake immediately.")
	var y: float = mission.player.position.y
	_drive("move_back", 12, 0.10)
	_check(is_equal_approx(mission.player.position.y, y), "Vertical input moved the player through a locked descender.")
	_check(mission.player.stamina >= float(locked["stamina"]), "A locked rest drained stamina.")
	_send("jump")
	_check(not bool(mission.player.rope_snapshot()["locked"]), "Space did not release the descender lock.")
	Input.action_press("crouch")
	_drive("move_back", 6, 0.10)
	Input.action_release("crouch")
	_check(mission.player.rope_snapshot()["mode"] == "precision" and float(mission.player.rope_snapshot()["speed"]) <= 0.751, "Ctrl did not select a precise descent through the input/controller path.")
	Input.action_press("sprint")
	_drive("move_back", 6, 0.10)
	Input.action_release("sprint")
	_check(mission.player.rope_snapshot()["mode"] == "rapid" and float(mission.player.rope_snapshot()["speed"]) > 4.0, "Shift did not select the faster descent through the input/controller path.")
	_step(0.4)
	_check(is_zero_approx(float(mission.player.rope_snapshot()["speed"])), "Releasing movement did not apply the automatic brake.")


func _test_modal_freeze(label: String) -> void:
	for journal: bool in [false, true]:
		if journal:
			_send("journal")
		else:
			_send("pause_game")
		var state: Dictionary = mission.player.rope_snapshot()
		var p: Vector3 = mission.player.position
		var clock: float = mission.player.rope_transfer_elapsed
		var stock: int = mission.anchors
		var mission_clock: float = mission.elapsed
		_check(mission.paused and not mission.player.active, "%s: modal failed to suspend player control." % label)
		Input.action_press("move_back")
		_step(3.0)
		Input.action_release("move_back")
		mission._process(5.0)
		_send("anchor")
		_send("jump")
		_check(mission.player.rope_snapshot() == state and mission.player.position == p and mission.player.rope_transfer_elapsed == clock, "%s: pause/journal advanced body, transfer, wind, velocity or rope model." % label)
		_check(mission.elapsed == mission_clock and mission.anchors == stock, "%s: pause/journal advanced mission time or consumed an anchor." % label)
		mission._resume()
		_disable_ticks()


func _test_physical_obstructions() -> void:
	var route: Dictionary = Routes.for_id("R31_30")
	await _station_fixture("R31_30", 31)
	var wall: StaticBody3D = _blocker(Vector3(-2.75, 43.05, 0), Vector3(0.24, 2.1, 1.7))
	await physics_frame
	var start: Vector3 = mission.player.position
	mission._interact_node(_object("rappel", 31))
	_check(not mission.player.on_rope and mission.player.position == start, "An obstructed entry attached or moved the capsule through a wall.")
	wall.free()
	await physics_frame
	mission._interact_node(_object("rappel", 31))
	_step(0.85)
	wall = _blocker(Vector3(-1.3, 39.0, 0), Vector3(1.8, 0.25, 2.3))
	await physics_frame
	_drive("move_back", 40, 0.10)
	# The capsule's bottom sits 1 cm above its origin; its standing origin is
	# therefore just below the obstacle's top at y=39.125, not above that top.
	_check(mission.player.on_rope and mission.player.rope_obstructed and mission.player.position.y >= 39.10 and mission.player.test_move(mission.player.global_transform, Vector3(0, -0.05, 0)), "The actual capsule passed through a shaft obstruction: position=%s obstructed=%s." % [str(mission.player.position), str(mission.player.rope_obstructed)])
	_check(Vector3(mission.player.rope_snapshot()["position"]).distance_to(mission.player.position) < 0.002, "The rope model continued below the physically blocked capsule.")
	mission._update_hud()
	_check(mission.hud.traversal_state.text.contains("ENCOMBRÉ"), "An obstruction is not reported in the rope HUD.")
	wall.free()
	await physics_frame
	_drive("move_back", 35, 0.10)
	_step(0.30)
	_check(is_equal_approx(mission.player.position.y, route["rope_bottom"].y) and not mission.player.rope_obstructed, "Removing a shaft obstacle did not restore controlled travel.")
	wall = _blocker(Vector3(-2.75, 37.05, 0), Vector3(0.24, 2.1, 1.7))
	await physics_frame
	var before: Vector3 = mission.player.position
	_send("interact")
	_check(mission.player.on_rope and mission.player.rope_transfer.is_empty() and mission.player.position == before, "E detached the player into a blocked landing exit.")
	wall.free()
	await physics_frame
	_send("interact")
	_step(0.35)
	_check(mission.player.rope_transfer == "exit", "The unobstructed return did not begin its timed transfer.")
	_test_modal_freeze("exit transfer")
	_step(0.50)
	_check(not mission.player.on_rope and mission.player.position.distance_to(route["bottom_entry"]) < 0.002, "The resumed exit failed to return to the actual lower landing.")
	# A new obstacle appearing after attachment must stop the transfer too.
	await _station_fixture("R31_30", 31)
	mission._interact_node(_object("rappel", 31))
	wall = _blocker(Vector3(-2.75, 43.05, 0), Vector3(0.24, 2.1, 1.7))
	await physics_frame
	_step(0.85)
	_check(mission.player.on_rope and mission.player.rope_transfer == "attach" and mission.player.rope_obstructed and mission.player.position.x < -2.8, "An obstacle introduced during transfer caused teleportation or unsafe detachment.")
	wall.free()
	await physics_frame
	_step(0.85)
	_check(mission.player.rope_transfer.is_empty() and mission.player.position.distance_to(route["rope_top"]) < 0.002, "Clearing an interrupted transfer did not safely resume it.")
	_step(0.2)
	await _exit_to(route["top_entry"], 31, "blocked-transfer recovery")


func _test_stair_checkpoint() -> void:
	var route: Dictionary = Routes.for_id("S30_29")
	mission.player.teleport_to_floor(30)
	mission.last_floor = 30
	mission.seen_floors = [30]
	mission.traversal_checkpoint_pending = false
	_check(mission._save_checkpoint(30), "Could not create the stable pre-stair checkpoint.")
	var saved: PackedByteArray = FileAccess.get_file_as_bytes(SAVE)
	# Initial fixture on the real half landing, not a fake numbered floor.
	mission.player.position = Vector3(-1.3, 33.06, 10.8)
	mission.player.velocity = Vector3.ZERO
	await physics_frame
	_check(not mission.player.is_at_landing() and mission.player.stair_context().get("id", "") == route["id"], "The intermediate stair landing was mistaken for a numbered floor.")
	_check(not mission._save_checkpoint(29) and mission.traversal_checkpoint_pending, "Mid-stair save was accepted or not deferred.")
	_check(FileAccess.get_file_as_bytes(SAVE) == saved, "Mid-stair save replaced the safe checkpoint.")
	mission._process(0.01)
	_check(mission.last_floor == 30 and not 29 in mission.seen_floors, "An intermediate stair landing prematurely entered the lower floor.")
	mission._update_hud()
	_check(mission.hud.location_label.text.contains("ESCALIER 30 ↔ 29") and mission.hud.traversal_title.text == "ESCALIER 30 ↔ 29", "The intermediate stair HUD reports an already reached floor.")
	_check(not mission.hud.traversal_stamina.visible and mission.hud.prompt_label.text.contains("deux étages"), "The stair HUD displays rope endurance or hides the local-link rule.")
	stair_driver = PhysicalRoutes.StairDriver.new()
	root.add_child(stair_driver)
	stair_driver.body = mission.player
	await _stair_walk(Vector3(1.3, 33.06, 10.8))
	await _stair_walk(Vector3(1.3, 33.06, 10.2))
	await _stair_walk(Vector3(1.3, 31.56, 8.0))
	mission._process(0.01)
	_check(mission.player.nearest_floor() == 29 and mission.last_floor == 30 and not 29 in mission.seen_floors, "Nearest-floor rounding emitted arrival while still descending the lower flight.")
	_check(FileAccess.get_file_as_bytes(SAVE) == saved, "The pending checkpoint committed halfway down the lower flight.")
	await _stair_walk(Vector3(1.3, 30.21, 6.02))
	mission._process(0.01)
	_check(not mission.player.is_at_landing() and mission.traversal_checkpoint_pending and FileAccess.get_file_as_bytes(SAVE) == saved, "The last stair treads were incorrectly treated as a stable save landing.")
	await _stair_walk(route["bottom_entry"])
	mission._process(0.01)
	_check(mission.player.is_at_landing() and mission.last_floor == 29 and 29 in mission.seen_floors, "Reaching the lower slab did not commit the actual floor arrival.")
	_check(not mission.traversal_checkpoint_pending and Store.load_data(SAVE).get("floor", 0) == 29, "The pending staircase checkpoint did not save on the reached lower slab.")
	_check(Store.load_data(SAVE).get("version", 0) == Store.SAVE_VERSION and not Store.load_data(SAVE).has("rope_state"), "Transient traversal state leaked into the stable schema-4 checkpoint.")
	stair_driver.queue_free()
	stair_driver = null
	await process_frame


func _test_operational_priority() -> void:
	await _station_fixture("R31_30", 30)
	InteractionFixture.face(mission, _object("beacon", 30))
	var p: Vector3 = mission.player.position
	mission._interact_node(_object("beacon", 30))
	_check(not mission.player.on_rope and mission.player.position == p, "An orange beacon without a casualty starts the personal rope.")
	var casualty: Node3D = _object("survivor", 30)
	InteractionFixture.face(mission, casualty)
	mission._interact_node(casualty)
	InteractionFixture.face(mission, _object("rappel", 30))
	mission._interact_node(_object("rappel", 30))
	_check(mission.carried == casualty and mission.player.carrying and not mission.player.on_rope, "A carried casualty was admitted onto the personal descender.")
	InteractionFixture.face(mission, _object("beacon", 29))
	mission._interact_node(_object("beacon", 29))
	_check(mission.carried == casualty and mission.hoisting == null and mission.rescued.is_empty(), "A different-floor beacon evacuated a casualty from the wrong origin.")
	InteractionFixture.face(mission, _object("beacon", 30))
	mission._interact_node(_object("beacon", 30))
	_check(mission.hoisting == casualty and mission.carried == null, "The valid origin beacon could not begin the rescue after rejecting a wrong floor.")
	InteractionFixture.face(mission, _object("rappel", 30))
	mission._interact_node(_object("rappel", 30))
	_check(not mission.player.on_rope and mission.hoisting == casualty, "A live hoist allowed a new personal rappel.")
	mission._process_hoist(5.1)
	mission.rescue_visuals.finish_reception()
	_check(mission.rescued == ["survivor_30"], "Traversal priority corrupted the real completed rescue.")
	mission.incident.start()
	mission._interact_node(_object("rappel", 30))
	_check(mission.incident.is_active() and not mission.player.on_rope, "The active structural incident allowed new rope engagement.")
	mission.incident.restore("aftermath")
	mission.world.apply_incident("aftermath", 0.0)
	mission._interact_node(_object("rappel", 30))
	_check(mission.player.on_rope and mission.player.rope_transfer == "attach", "A stable aftermath permanently disabled the local rope.")


func _test_airborne_checkpoint() -> void:
	# Launch a real jump from a supported floor. Both the upward and downward
	# crossing of that floor's height tolerance must preserve the last safe save.
	_release_inputs()
	mission.player.teleport_to_floor(30)
	mission.last_floor = 30
	for frame in range(8):
		await physics_frame
		mission.player._physics_process(1.0 / 60.0)
	_check(mission.player.is_on_floor() and mission.player.is_at_landing(), "The jump fixture could not settle on the real floor-30 slab.")
	_check(mission._save_checkpoint(30), "The supported pre-jump floor could not save.")
	var previous: PackedByteArray = FileAccess.get_file_as_bytes(SAVE)
	Input.action_press("jump")
	await physics_frame
	mission.player._physics_process(1.0 / 60.0)
	Input.action_release("jump")
	_check(mission.player.velocity.y > 0.15 and absf(mission.player.position.y - 36.0) <= 0.35, "The real jump did not exercise upward movement inside the floor-height tolerance: position=%s velocity=%s." % [str(mission.player.position), str(mission.player.velocity)])
	_check(not mission.player.is_at_landing() and not mission._save_checkpoint(30), "The upward phase of a jump was accepted as a safe landing.")
	_check(FileAccess.get_file_as_bytes(SAVE) == previous, "Saving during the upward jump rewrote the safe checkpoint.")
	var descending_crossing: bool = false
	for frame in range(120):
		await physics_frame
		mission.player._physics_process(1.0 / 60.0)
		if mission.player.velocity.y < -0.15 and absf(mission.player.position.y - 36.0) <= 0.35:
			descending_crossing = true
			_check(not mission.player.is_at_landing() and not mission._save_checkpoint(30), "A falling capsule near floor height was accepted as a safe landing.")
			_check(FileAccess.get_file_as_bytes(SAVE) == previous, "Saving during the descending jump rewrote the safe checkpoint.")
			break
	_check(descending_crossing, "The physical jump did not cross the near-floor region while descending.")
	for frame in range(24):
		await physics_frame
		mission.player._physics_process(1.0 / 60.0)
		if mission.player.is_at_landing():
			break
	mission._process(0.01)
	_check(mission.player.is_at_landing() and not mission.traversal_checkpoint_pending and Store.load_data(SAVE).get("floor", 0) == 30, "A pending jump checkpoint did not recover after actual ground contact.")
	# Independent unsupported-opening fixture: matching height and zero vertical
	# velocity are insufficient when no slab exists under the capsule.
	previous = FileAccess.get_file_as_bytes(SAVE)
	mission.player.teleport_to_floor(31)
	mission.player.position = Routes.for_id("R31_30")["rope_top"]
	mission.player.velocity = Vector3.ZERO
	await physics_frame
	_check(not mission.player._has_landing_support(mission.player.position), "The unsupported fixture unexpectedly has a slab beneath its open shaft.")
	_check(not mission.player.is_at_landing() and not mission._save_checkpoint(31), "A stationary capsule over a hole was accepted as a stable rooftop.")
	mission._process(0.01)
	_check(FileAccess.get_file_as_bytes(SAVE) == previous and mission.traversal_checkpoint_pending, "The unsupported opening committed a pending checkpoint.")
	mission.player.teleport_to_floor(30)
	mission._process(0.01)
	_check(mission.player.is_at_landing() and not mission.traversal_checkpoint_pending, "Returning to an actual slab failed to clear the pending unsupported save request.")


func _test_stair_radio_gate() -> void:
	# Complete Samuel's real hoist so every narrative prerequisite is genuine.
	mission.player.teleport_to_floor(28)
	mission.last_floor = 28
	InteractionFixture.face(mission, _object("survivor", 28))
	mission._interact_node(_object("survivor", 28))
	InteractionFixture.face(mission, _object("beacon", 28))
	mission._interact_node(_object("beacon", 28))
	mission._process_hoist(5.1)
	mission.rescue_visuals.finish_reception()
	_check("survivor_28" in mission.rescued and mission.incident.phase == "aftermath", "The stair-radio fixture lacks Samuel's confirmed rescue or settled impact.")
	mission.radio.reset(mission.radio.history_snapshot())
	mission._sync_radio()
	_check(mission.radio_events.is_empty(), "The stair-radio fixture already contains the optional exchange.")
	var previous: PackedByteArray = FileAccess.get_file_as_bytes(SAVE)
	var received: Array = mission.radio.history_snapshot()
	var route: Dictionary = Routes.for_id("S28_27")
	# Initial placement on the actual lower flight, close enough that integer
	# floor rounding already says 27 while Alex has not reached its floor slab.
	mission.player.position = Vector3(1.3, 19.56, 8.0)
	mission.player.velocity = Vector3.ZERO
	mission.radio_quiet_time = 5.9
	await physics_frame
	_check(mission.player.nearest_floor() == 27 and not mission.player.is_at_landing() and mission.player.stair_context().get("id", "") == route["id"], "The lower-flight fixture does not exercise premature floor-27 rounding.")
	mission._process_story_radio(0.2)
	mission._process_story_radio(100.0)
	_check(mission.radio_events.is_empty() and mission.radio_quiet_time == 0.0 and not mission.radio.is_busy(), "Bravo's optional echo triggered or accumulated silence while Alex was on S28_27.")
	_check(mission.radio.history_snapshot() == received and FileAccess.get_file_as_bytes(SAVE) == previous, "The mid-stair echo gate fabricated words or a saved receipt.")
	stair_driver = PhysicalRoutes.StairDriver.new()
	root.add_child(stair_driver)
	stair_driver.body = mission.player
	await _stair_walk(Vector3(1.3, 18.21, 6.02), 18.0, 24.0)
	mission._process_story_radio(100.0)
	_check(mission.radio_events.is_empty(), "The final treads of S28_27 triggered Bravo before a stable landing.")
	await _stair_walk(route["bottom_entry"], 18.0, 24.0)
	mission._process_story_radio(5.9)
	_check(mission.player.is_at_landing() and mission.radio_events.is_empty(), "Reaching the garden reused silence accumulated during stair travel.")
	mission._process_story_radio(0.11)
	_check(mission.radio_events == ["bravo_echo"] and str(mission.radio.current.get("speaker", "")).contains("BRAVO"), "Six quiet seconds on the reached garden slab failed to trigger the valid optional echo.")
	_check(Store.load_data(SAVE).get("floor", 0) == 27 and Store.load_data(SAVE).get("radio_events", []) == ["bravo_echo"], "The valid garden echo failed to persist at its supported floor.")
	stair_driver.queue_free()
	stair_driver = null
	await process_frame


func _station_fixture(route_id: String, number: int) -> void:
	_release_inputs()
	mission.player.teleport_to_floor(number)
	var route: Dictionary = Routes.for_id(route_id)
	mission.player.position = route["top_entry"] if number == int(route["upper"]) else route["bottom_entry"]
	mission.player.velocity = Vector3.ZERO
	mission.player.active = true
	mission.last_floor = number
	mission.anchors = 4
	mission.radio.reset()
	mission._sync_radio()
	await physics_frame
	await physics_frame


func _exit_to(expected: Vector3, number: int, label: String) -> void:
	_check(mission.player.can_exit_rope(), "%s: stationary endpoint cannot exit." % label)
	var p: Vector3 = mission.player.position
	_send("interact")
	_check(mission.player.on_rope and mission.player.rope_transfer == "exit" and mission.player.position == p, "%s: E skipped the timed return transfer." % label)
	_step(0.40)
	_check(mission.player.on_rope and mission.player.position.x < p.x and mission.player.position.x > expected.x, "%s: return did not pass through an intermediate physical position." % label)
	_step(0.45)
	_check(not mission.player.on_rope and mission.player.is_at_landing() and mission.player.nearest_floor() == number and mission.player.position.distance_to(expected) < 0.002, "%s: 0.85-second exit did not land at the authored point." % label)
	await physics_frame


func _test_position_bounds() -> void:
	if not mission.player.on_rope or not mission.player.rope_transfer.is_empty():
		return
	var frame: Dictionary = mission.player.rope_snapshot()
	var route: Dictionary = Routes.for_id(str(frame["route_id"]))
	_check(mission.player.position.y >= route["rope_bottom"].y - 0.002 and mission.player.position.y <= route["rope_top"].y + 0.002 and absf(mission.player.position.z) <= 0.652, "The actual capsule escaped its local vertical/sway bounds.")


func _step(delta: float) -> void:
	mission.player._process_rope(delta)
	rope_samples += 1
	_test_position_bounds()


func _drive(action: String, samples: int, delta: float) -> void:
	Input.action_press(action)
	for sample in range(samples):
		_step(delta)
	Input.action_release(action)


func _stair_walk(point: Vector3, lower: float = 30.0, upper: float = 36.0) -> void:
	stair_driver.go(point, lower, upper)
	var outcome: Array = await stair_driver.finished
	_check(bool(outcome[0]), "Controller staircase fixture was physically blocked: target=%s actual=%s collider=%s" % [str(point), str(outcome[1]), str(outcome[2])])


func _blocker(p: Vector3, size: Vector3) -> StaticBody3D:
	var body: StaticBody3D = StaticBody3D.new()
	body.name = "TraversalTestObstacle"
	var collider: CollisionShape3D = CollisionShape3D.new()
	var shape: BoxShape3D = BoxShape3D.new()
	shape.size = size
	collider.shape = shape
	body.add_child(collider)
	mission.world.add_child(body)
	body.global_position = p
	return body


func _object(kind: String, number: int) -> Node3D:
	for item: Node3D in mission.world_data["interactables"]:
		if item.get_meta("kind", "") == kind and int(item.get_meta("floor", 0)) == number:
			return item
	_check(false, "Missing %s at floor %d." % [kind, number])
	return null


func _send(action: String) -> void:
	var event: InputEventAction = InputEventAction.new()
	event.action = action
	event.pressed = true
	mission._unhandled_input(event)


func _disable_ticks() -> void:
	mission.set_process(false)
	mission.player.set_physics_process(false)
	mission.world.set_process(false)


func _release_inputs() -> void:
	for action: String in ["move_forward", "move_back", "move_left", "move_right", "sprint", "crouch"]:
		Input.action_release(action)


func _check(condition: bool, message: String) -> void:
	checks += 1
	if not condition:
		failures.append(message)


func _clean() -> void:
	for path: String in [SAVE, SAVE + ".tmp", PREFS, PREFS + ".tmp"]:
		if FileAccess.file_exists(path):
			DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
