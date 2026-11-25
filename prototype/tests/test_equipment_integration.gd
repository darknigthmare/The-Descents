extends SceneTree
const MainScene = preload("res://scenes/main.tscn")
const Preferences = preload("res://scripts/preferences_store.gd")
const Save = preload("res://scripts/save_store.gd")
const SAVE: String = "user://qa_equipment_v011.json"
const PREFS: String = "user://qa_equipment_v011.cfg"
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
	_check(mission.equipment_visuals.targets.size() == 3, "Dormant chapter exposes the fourth worksite.")
	for target: Node3D in mission.equipment_visuals.targets.values():
		_check(not target.visible, "Worksite appeared before impact.")
	mission.incident.restore("aftermath")
	mission.world.apply_incident("aftermath", 0.0)
	mission._process_equipment(0.0, 0)
	var boards: Node3D = mission.equipment_visuals.targets["equipment_boards_29"]
	await _face(boards)
	mission._select_equipment("extinguisher")
	mission._interact_node(boards)
	_check(mission.equipment.active_id.is_empty(), "Wrong tool began work.")
	mission._select_equipment("fire_axe")
	mission.player.camera.rotate_y(PI)
	mission._interact_node(boards)
	_check(mission.equipment.active_id.is_empty(), "Action began facing away.")
	mission._find_nearest()
	_check(mission.nearest != boards, "An unaimed worksite retained the interaction prompt.")
	mission.player.camera.look_at(boards.global_position + Vector3(0, 0.85, 0))
	var obstacle: StaticBody3D = StaticBody3D.new()
	var collider: CollisionShape3D = CollisionShape3D.new()
	var box: BoxShape3D = BoxShape3D.new()
	box.size = Vector3(1.0, 2.0, 0.12)
	collider.shape = box
	obstacle.add_child(collider)
	mission.add_child(obstacle)
	obstacle.global_position = boards.global_position + Vector3(0, 1.0, 0.9)
	await physics_frame
	mission._interact_node(boards)
	_check(mission.equipment.active_id.is_empty(), "Work ignored an intervening wall.")
	mission._find_nearest()
	_check(mission.nearest != boards, "An occluded worksite replaced the visible interaction prompt.")
	obstacle.free()
	await physics_frame
	var beacon: Node3D
	for candidate: Node3D in mission.world_data.get("interactables", []):
		if candidate.get_meta("kind", "") == "beacon" and int(candidate.get_meta("floor", 0)) == 29:
			beacon = candidate
			break
	_check(is_instance_valid(beacon), "The real floor 29 rescue beacon is missing.")
	if is_instance_valid(beacon):
		var beacon_position: Vector3 = beacon.global_position
		beacon.global_position = mission.player.global_position + Vector3(0.65, 0, 0)
		await physics_frame
		mission._find_nearest()
		mission._update_hud()
		_check(mission.nearest == beacon and "Balise orange" in mission.hud.prompt_label.text, "Aimed optional equipment displaced an immediate rescue control.")
		mission._interact()
		_check(mission.equipment.active_id.is_empty() and "évacuation des rescapés" in mission.hud.notify_label.text, "E did not route to the nearby rescue beacon.")
		beacon.global_position = beacon_position
		await physics_frame
	mission._find_nearest()
	mission._update_hud()
	_check(mission.nearest == boards, "A nearby legacy supply crate stole the aimed axe worksite.")
	_check(mission.hud.prompt_label.text.begins_with("Maintenir E") and "réserve de balisage" in mission.hud.prompt_label.text, "Aimed axe worksite did not show its hold instruction.")
	mission._interact()
	_check(mission.equipment.active_id == "equipment_boards_29", "Valid close stable visible worksite did not begin.")
	mission._process_equipment(0.25, 1)
	mission._find_nearest()
	mission._update_hud()
	_check(mission.nearest == boards and "14 %" in mission.hud.prompt_label.text, "Active axe operation lost its progress prompt to a neighboring interaction.")
	mission._pause()
	_check(mission.equipment.active_id.is_empty() and not mission.equipment_visuals.view_root.visible, "Pause did not stow and cancel.")
	mission._resume()
	_freeze()
	mission._interact_node(boards)
	mission.player.position.x += 4.0
	mission._process_equipment(0.25, 1)
	_check(mission.equipment.active_id.is_empty(), "Distance did not cancel work.")
	await _face(boards)
	var flares: int = mission.flares
	mission._interact_node(boards)
	for tick: int in range(20): mission._process_equipment(0.125, 1)
	_check("equipment_boards_29" in mission.supplies_used and mission.flares == mini(6, flares + 1), "Axe reward missing.")
	_check(boards.visible and boards.get_meta("used") and mission.equipment_visuals.changing["equipment_boards_29"].rotation.y < -1.0, "Finished cabinet disappeared or stayed closed.")
	var first_bytes: String = FileAccess.get_file_as_string(SAVE)
	mission._interact_node(boards)
	for tick: int in range(20): mission._process_equipment(0.125, 1)
	_check(FileAccess.get_file_as_string(SAVE) == first_bytes and mission.flares == mini(6, flares + 1), "Repeated work duplicated reward or save.")
	var fire: Node3D = mission.equipment_visuals.targets["equipment_fire_28"]
	await _face(fire)
	mission._select_equipment("extinguisher")
	mission._interact_node(fire)
	mission._process_equipment(0.25, 1)
	mission._process_equipment(0.25, 0)
	_check(mission.equipment.charges_left() == 3 and mission.equipment_visuals.local_fire.visible, "Interrupted spray consumed or extinguished.")
	mission._interact_node(fire)
	for tick: int in range(26): mission._process_equipment(0.125, 1)
	_check(mission.equipment.charges_left() == 2 and not mission.equipment_visuals.local_fire.visible, "Fire did not extinguish with one charge.")
	var checkpoint: Dictionary = Save.load_data(SAVE)
	_check(checkpoint.get("version") == 4 and "equipment_fire_28" in checkpoint.get("supplies_used", []), "Checkpoint lost the work receipt.")
	mission._restore(checkpoint)
	_freeze()
	await physics_frame
	mission._process_equipment(0.0, 0)
	_check(mission.equipment.charges_left() == 2 and not mission.equipment_visuals.local_fire.visible and mission.equipment.active_id.is_empty(), "Reload revived work or resources.")
	var cabinet: Node3D = mission.equipment_visuals.targets["equipment_cabinet_25"]
	await _face(cabinet)
	mission.health = 70.0
	mission._select_equipment("halligan")
	mission._interact_node(cabinet)
	for tick: int in range(20): mission._process_equipment(0.125, 1)
	_check(mission.health == 90.0 and "equipment_cabinet_25" in mission.supplies_used, "Medical cabinet reward incorrect.")
	mission.player.on_rope = true
	mission._select_equipment("fire_axe")
	mission._process_equipment(0.25, 1)
	_check(mission.equipment.selected == "halligan" and not mission.equipment_visuals.view_root.visible, "Rope accepted a held tool.")
	mission.player.on_rope = false
	mission.player.teleport_to_floor(25)
	mission.rescued = ["survivor_30", "survivor_28", "survivor_26"]
	mission.elapsed = 200.0
	await physics_frame
	mission._complete_game(false)
	mission.hud.end_panel.descent_button.pressed.emit()
	_freeze()
	await physics_frame
	_check(mission.continuation.phase == "active" and mission.equipment_visuals.targets.has("equipment_chain_24"), "Continuation did not open its equipment site.")
	var chain: Node3D = mission.equipment_visuals.targets["equipment_chain_24"]
	await _face(chain)
	mission._process_equipment(0.0, 0)
	mission._select_equipment("bolt_cutter")
	mission._interact_node(chain)
	for tick: int in range(16): mission._process_equipment(0.125, 1)
	_check("equipment_chain_24" in mission.supplies_used and mission.equipment_visuals.work_light.visible, "Worklight was not released and enabled.")
	_check(mission.rescued.size() == 3 and mission.clues.is_empty() and mission.continuation.escort_state == "waiting", "Equipment altered narrative or rescue receipts.")
	mission._start_new(271104)
	_freeze()
	_check(mission.equipment.completed.is_empty() and mission.equipment.charges_left() == 3, "New game kept the equipment ledger.")
	mission.free()
	_clean()
	if failures.is_empty():
		print("PASS equipment integration: %d checks" % checks)
		quit(0)
	else:
		for message: String in failures: push_error(message)
		quit(1)

func _face(target: Node3D) -> void:
	mission.player.teleport_to_floor(int(target.get_meta("floor")))
	mission.player.position = target.global_position + Vector3(0, 0.06, 1.9)
	mission.player.camera.look_at(target.global_position + Vector3(0, 0.85, 0))
	await physics_frame
	await physics_frame
	mission._find_nearest()

func _freeze() -> void:
	mission.set_process(false)
	mission.set_physics_process(false)
	mission.player.set_physics_process(false)
	mission.world.set_process(false)

func _clean() -> void:
	for path: String in [SAVE, PREFS]:
		if FileAccess.file_exists(path): DirAccess.remove_absolute(ProjectSettings.globalize_path(path))

func _check(ok: bool, message: String) -> void:
	checks += 1
	if not ok: failures.append(message)
