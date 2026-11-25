extends Node3D

const Generator = preload("res://scripts/floor_generator.gd")
const World = preload("res://scripts/world_builder.gd")
const Player = preload("res://scripts/player_controller.gd")
const HUD = preload("res://scripts/hud.gd")
const Save = preload("res://scripts/save_store.gd")
const Incident = preload("res://scripts/collapse_director.gd")
const Radio = preload("res://scripts/radio_director.gd")
const Cinematics = preload("res://scripts/cinematic_director.gd")
const Preferences = preload("res://scripts/preferences_store.gd")
const FieldProps = preload("res://scripts/field_props.gd")
const RescuePresentation = preload("res://scripts/rescue_presentation.gd")
const Epilogue = preload("res://scripts/epilogue_director.gd")
const Horror = preload("res://scripts/horror_director.gd")
const HorrorPresentation = preload("res://scripts/horror_presentation.gd")
const Routes = preload("res://scripts/route_catalog.gd")
const Continuation = preload("res://scripts/continuation_director.gd")
const Dossier = preload("res://scripts/mission_dossier.gd")
const Equipment = preload("res://scripts/equipment_director.gd")
const EquipmentPresentation = preload("res://scripts/rescue_equipment.gd")
const Commerce = preload("res://scripts/commerce_director.gd")

var commerce = Commerce.new()
var commerce_visuals: Node3D

var equipment = Equipment.new()
var equipment_visuals: Node3D

var continuation = Continuation.new()
var continuation_visuals: Node3D

var rescue_visuals: Node3D
var horror_visuals: Node3D
var horror = Horror.new()
var horror_cue_serial: int = 0
var world: Node3D
var player: CharacterBody3D
var hud: CanvasLayer
var menu_camera: Camera3D
var world_data: Dictionary = {}
var floor_specs: Array = []
var current_seed: int = 271104
var started: bool = false
var paused: bool = false
var completed: bool = false
var health: float = 100
var oxygen: float = 100
var stress: float = 8
var anchors: int = 4
var flares: int = 3
var rescued: Array = []
var clues: Array = []
var supplies_used: Array = []
var seen_floors: Array = []
var carried: Node3D
var hoisting: Node3D
var hoist_progress: float = 0.0
var hoist_floor: int = 30
var hoist_labels_enabled: bool = true
var nearest: Node3D
var last_floor: int = 31
var checkpoint_floor: int = 31
var elapsed: float = 0
var radio_time: float = 0
var notify_time: float = 0
var radio_cooldown: float = 0
var flare_time: float = 0
var damage_cooldown: float = 0
var flashes_enabled: bool = false
var sound_enabled: bool = true
var reduced_motion: bool = true
var audio_wind: AudioStreamPlayer
var audio_radio: AudioStreamPlayer
var audio_effect: AudioStreamPlayer
var audio_score: AudioStreamPlayer
var audio_rotors: AudioStreamPlayer
var audio_horror: AudioStreamPlayer3D
var flare_light: OmniLight3D
var intro_stage: int = 0
var helicopter_origin: Vector3
var menu_time: float = 0
var save_path: String = "user://save_v1.json"
var incident = Incident.new()
var radio = Radio.new()
var radio_events: Array = []
var radio_quiet_time: float = 0.0
var observation_hold: float = 0.0
var arrival_playing: bool = false
var arrival_time: float = 0.0
const ARRIVAL_DURATION: float = Cinematics.ARRIVAL_DURATION
var cinematic = Cinematics.new()
var epilogue = Epilogue.new()
var epilogue_playing: bool = false
var epilogue_voice_key: String = ""
var boot_playing: bool = false
var menu_context: Dictionary = {}
var menu_snapshot: Dictionary = {}
var preferences_path: String = Preferences.FILE
var preferences: Dictionary = Preferences.DEFAULTS.duplicate()
var traversal_checkpoint_pending: bool = false

func _ready() -> void:
	_bind_inputs()
	preferences = Preferences.load_settings(preferences_path)
	reduced_motion = bool(preferences["reduced_motion"])
	flashes_enabled = bool(preferences["flashes"])
	sound_enabled = sound_enabled and bool(preferences["audio"])
	AudioServer.set_bus_mute(0,not sound_enabled)
	_apply_master_volume()
	_make_audio()
	hud = HUD.new()
	add_child(hud)
	hud.start_requested.connect(_start_new)
	hud.continue_requested.connect(_continue_game)
	hud.resume_requested.connect(_resume)
	hud.return_requested.connect(_return_to_menu)
	if hud.has_signal("journal_requested"):
		hud.journal_requested.connect(_open_journal)
	hud.setting_changed.connect(_setting_changed)
	hud.replay_intro_requested.connect(_start_studio_intro)
	hud.cinematic_skip_requested.connect(_skip_cinematic)
	hud.epilogue_replay_requested.connect(_replay_epilogue)
	hud.descent_requested.connect(_begin_continuation)
	hud.inspection_closed.connect(_resume)
	hud.apply_settings(preferences)
	_prepare_menu()
	if DisplayServer.get_name() != "headless" and bool(preferences["startup_intro"]):
		_start_studio_intro()

func _prepare_menu() -> void:
	# A menu is a preview of the last validated checkpoint, never a new save.
	menu_snapshot = Save.load_data(save_path)
	equipment.restore(menu_snapshot.get("supplies_used", []))
	continuation.restore(menu_snapshot.get("continuation", Continuation.new().snapshot()))
	commerce.restore(menu_snapshot.get("commerce", Commerce.dormant_state()))
	menu_context = Cinematics.menu_context(menu_snapshot)
	started = false
	paused = false
	completed = false
	arrival_playing = false
	rescued = menu_snapshot.get("rescued",[]).duplicate()
	incident.restore(str(menu_context["incident"]))
	_build_world(int(menu_snapshot.get("seed",271104)))
	for target: Node3D in world_data.get("interactables",[]):
		var key: String = _key(target)
		if key in rescued or key in menu_snapshot.get("clues",[]) or key in menu_snapshot.get("supplies_used",[]):
			if str(target.get_meta("kind", "")) not in ["continuation_evidence", "commerce_clue", "equipment"]:
				target.hide()
			target.set_meta("used",true)
	if not menu_snapshot.is_empty():
		_position_helicopters(float(menu_snapshot.get("elapsed",0)))
	_show_menu_camera()
	_apply_camera_sample(Cinematics.menu_camera(menu_context,menu_time,reduced_motion))
	hud.show_menu()
	hud.set_menu_context(menu_context,not menu_snapshot.is_empty(),current_seed)
	if not menu_snapshot.is_empty() and float(menu_snapshot.get("health", 0.0)) <= 0.0:
		hud.continue_button.disabled = true
		hud.continue_button.text = "Point sûr sans état vital — nouvelle intervention requise"
	hud.apply_settings(preferences)
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	if DisplayServer.get_name() != "headless" and sound_enabled and is_instance_valid(audio_wind) and not audio_wind.playing:
		audio_wind.play()

func _start_studio_intro() -> void:
	if started:
		return
	# Replaying the signature does not erase or reveal saved progress.
	incident.restore("intact")
	rescued = []
	_build_world(271104)
	_show_menu_camera()
	boot_playing = true
	cinematic.start("boot")
	hud.menu.hide()
	hud.game.hide()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	_render_cinematic()
	_play_effect("intro_sting")

func _finish_studio_intro() -> void:
	boot_playing = false
	cinematic.finish()
	hud.cinematic.hide()
	_prepare_menu()

func _skip_cinematic() -> void:
	if paused:
		return
	if boot_playing:
		_finish_studio_intro()
	elif arrival_playing:
		_finish_arrival()
	elif epilogue_playing:
		_finish_epilogue()

func _apply_camera_sample(sample: Dictionary) -> void:
	menu_camera.position = sample["position"]
	menu_camera.fov = float(sample["fov"])
	menu_camera.look_at(sample["target"])

func _render_cinematic() -> void:
	_apply_camera_sample(cinematic.camera_sample(reduced_motion,player.camera.global_position,-player.camera.global_basis.z,player.camera.fov))
	hud.cinematic.set_frame(cinematic.presentation(),cinematic.mode)
	if arrival_playing:
		hud.cinematic.set_transmission(str(radio.current.get("speaker","")),str(radio.current.get("message","")))

func _bind_inputs() -> void:
	var keys: Dictionary = {
		"move_forward": [KEY_W, KEY_Z], "move_back": [KEY_S],
		"move_left": [KEY_A, KEY_Q], "move_right": [KEY_D],
		"look_left": [KEY_LEFT], "look_right": [KEY_RIGHT],
		"look_up": [KEY_UP], "look_down": [KEY_DOWN],
		"jump": [KEY_SPACE], "sprint": [KEY_SHIFT], "crouch": [KEY_CTRL],
		"interact": [KEY_E], "flashlight": [KEY_F], "flare": [KEY_G],
		"radio": [KEY_R], "journal": [KEY_J], "anchor": [KEY_X], "pause_game": [KEY_ESCAPE],
		"tool_1": [KEY_1, KEY_KP_1], "tool_2": [KEY_2, KEY_KP_2], "tool_3": [KEY_3, KEY_KP_3], "tool_4": [KEY_4, KEY_KP_4]
	}
	for action in keys:
		if not InputMap.has_action(action):
			InputMap.add_action(action)
		for key in keys[action]:
			var event: InputEventKey = InputEventKey.new()
			if str(action).begins_with("tool_") and key in [KEY_1, KEY_2, KEY_3, KEY_4]:
				event.physical_keycode = key
			else:
				event.keycode = key
			InputMap.action_add_event(action, event)

func _build_world(seed_value: int) -> void:
	equipment.cancel()
	commerce.cancel()
	commerce_visuals = null
	equipment_visuals = null
	traversal_checkpoint_pending = false
	continuation_visuals = null
	epilogue_playing = false
	epilogue.finish()
	epilogue_voice_key = ""
	rescue_visuals = null
	horror_visuals = null
	horror.reset()
	horror_cue_serial = 0
	if is_instance_valid(audio_horror):
		audio_horror.stop()
		audio_horror.stream_paused = false
	if is_instance_valid(world):
		world.free()
	if is_instance_valid(player):
		player.free()
	if is_instance_valid(menu_camera):
		menu_camera.free()
	carried = null
	hoisting = null
	hoist_labels_enabled = true
	nearest = null
	current_seed = seed_value
	floor_specs = Generator.generate(seed_value)
	world = World.new()
	add_child(world)
	world_data = world.build(seed_value, floor_specs, continuation.phase != "dormant", commerce.phase != "dormant")
	continuation_visuals = world_data.get("continuation_visuals")
	commerce_visuals = world_data.get("commerce_visuals")
	if is_instance_valid(commerce_visuals):
		commerce_visuals.apply_state(commerce.snapshot())
	world.set_continuation_state(continuation.snapshot())
	world_data["interactables"].append_array(FieldProps.new().build(world))
	world.set_rescued_people(rescued)
	world.apply_incident(incident.phase, incident.phase_elapsed)
	world.set_lightning_enabled(flashes_enabled)
	world.set_reduced_motion(reduced_motion)
	player = Player.new()
	add_child(player)
	player.configure_continuation(continuation.phase != "dormant", commerce.phase != "dormant")
	player.traversal_notice.connect(_notify)
	player.position = world_data.get("roof_spawn", Vector3(7,42.2,7))
	player.rotation.y = 0.75
	player.apply_comfort(preferences)
	equipment_visuals = EquipmentPresentation.new()
	world.add_child(equipment_visuals)
	world_data["interactables"].append_array(equipment_visuals.build(world, player.camera, continuation.phase != "dormant"))
	equipment_visuals.sample(equipment.snapshot(), false, incident.phase == "aftermath", reduced_motion)
	rescue_visuals = RescuePresentation.new()
	world.add_child(rescue_visuals)
	rescue_visuals.build(world, player.camera)
	horror_visuals = HorrorPresentation.new()
	world.add_child(horror_visuals)
	horror_visuals.build(world)
	player.lost_footing.connect(_fall_recovery)
	menu_camera = Camera3D.new()
	menu_camera.cull_mask = 1
	menu_camera.fov = 55
	menu_camera.far = 1600
	add_child(menu_camera)
	menu_camera.position = Vector3(95, 68, 112)
	menu_camera.look_at(Vector3(6, -8, 0))
	flare_light = OmniLight3D.new()
	flare_light.light_color = Color(1.0, 0.26, 0.06)
	flare_light.light_energy = 4.0
	flare_light.omni_range = 20
	flare_light.visible = false
	world.add_child(flare_light)
	var heli: Node3D = world_data.get("helicopter")
	if is_instance_valid(heli):
		helicopter_origin = heli.position

func _show_menu_camera() -> void:
	player.active = false
	menu_camera.current = true

func _start_new(seed_value: int) -> void:
	equipment.reset()
	# A new attempt does not erase the previous checkpoint until a new one is valid.
	continuation.reset()
	commerce.reset()
	health = 100
	oxygen = 100
	stress = 8
	anchors = 4
	flares = 3
	rescued = []
	clues = []
	supplies_used = []
	seen_floors = []
	elapsed = 0
	completed = false
	checkpoint_floor = 31
	intro_stage = 0
	incident.restore("intact")
	radio.reset()
	radio_events.clear()
	radio_quiet_time = 0.0
	radio_time = 0.0
	hud.radio_panel.hide()
	observation_hold = 0
	arrival_time = 0
	flare_time = 0
	radio_cooldown = 0
	damage_cooldown = 0
	hoist_progress = 0
	_build_world(clampi(seed_value, 1, 999999))
	_begin_game()
	_save_checkpoint(31)
	arrival_playing = true
	boot_playing = false
	player.active = false
	menu_camera.current = true
	cinematic.start("arrival")
	hud.game.hide()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	_process_arrival(0.0)

func _begin_game() -> void:
	started = true
	arrival_playing = false
	paused = false
	last_floor = 31
	player.active = true
	player.camera.current = true
	hud.show_game()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	if sound_enabled and is_instance_valid(audio_wind):
		audio_wind.play()
	_update_hud()

func _continue_game() -> void:
	var data: Dictionary = Save.load_data(save_path)
	if data.is_empty():
		hud.continue_button.text = "Sauvegarde indisponible — commencez une intervention"
		hud.continue_button.disabled = true
		return
	if float(data.get("health", 0.0)) <= 0.0:
		# Preserve an old dead checkpoint for diagnosis. Restoring it would
		# immediately lose the rescuer again; only an explicit new run replaces it.
		_return_to_menu()
		return
	_restore(data)
	if not completed:
		_say("VARGA  /  POSTE DU TOIT", "Point sûr rétabli. Votre compte rendu est à jour. Vérifiez votre matériel avant de continuer.", 8)

func _restore(data: Dictionary) -> void:
	equipment.restore(data.get("supplies_used", []))
	continuation.restore(data.get("continuation", Continuation.new().snapshot()))
	commerce.restore(data.get("commerce", Commerce.dormant_state()))
	incident.restore(str(data["incident_state"]))
	observation_hold = 0
	_build_world(int(data["seed"]))
	health = float(data["health"])
	oxygen = float(data["oxygen"])
	stress = float(data["stress"])
	anchors = int(data["anchors"])
	flares = int(data["flares"])
	rescued = data["rescued"].duplicate()
	clues = data["clues"].duplicate()
	supplies_used = data["supplies_used"].duplicate()
	seen_floors = data["seen_floors"].duplicate()
	# Atmospheric cues are not mission receipts. Loading does not invent an
	# observation or replay the initial fleeting cue on already visited floors.
	horror.reset(seen_floors)
	elapsed = float(data["elapsed"])
	completed = bool(data["completed"])
	checkpoint_floor = int(data["floor"])
	radio.reset(data["transmissions"])
	radio_events = data["radio_events"].duplicate()
	radio_quiet_time = 0.0
	radio_time = 0.0
	radio_cooldown = 0.0
	notify_time = 0.0
	damage_cooldown = 0.0
	hoist_progress = 0.0
	world.set_rescued_people(rescued)
	_sync_radio()
	intro_stage = 3 if elapsed > 34.0 or incident.phase == "aftermath" else (2 if elapsed > 22.0 else (1 if elapsed > 11.0 else 0))
	flare_time = 0
	for target: Node3D in world_data.get("interactables", []):
		var key: String = _key(target)
		if key in rescued or key in clues or key in supplies_used:
			if str(target.get_meta("kind", "")) not in ["continuation_evidence", "commerce_clue", "equipment"]:
				target.hide()
			target.set_meta("used", true)
	_begin_game()
	player.teleport_to_floor(checkpoint_floor)
	_process_departure()
	if completed:
		if continuation.phase == "complete":
			_show_continuation_debrief()
		else:
			_complete_game(false)
	elif continuation.phase == "active" and continuation.escort_state != "received" and continuation.duo_briefed:
		_notify("Point sûr rétabli. Léa et Idris attendent en sécurité dans la cabine du 24 ; reprenez leur accompagnement.")
	elif commerce.phase == "active":
		_notify("Point sûr rétabli. Les réceptions sont conservées ; toute escorte inachevée attend à son point de contact initial.")

func _save_checkpoint(floor_number: int) -> bool:
	# Damage and an equipment/hoist completion can share one frame. Never
	# replace a living checkpoint with a state that immediately dies on reload.
	if not is_finite(health) or health <= 0.0:
		_notify("État critique : le précédent point sûr est conservé.")
		return false
	# During the incident the preceding safe checkpoint remains authoritative.
	# Never persist a half-collapsed mesh or a transient collider configuration.
	if incident.is_active():
		_notify("La structure bouge. Le point sûr précédent est conservé jusqu’à la stabilisation.")
		return false
	if player.on_rope or not player.is_at_landing():
		traversal_checkpoint_pending = true
		_notify("Rejoignez un palier stable pour enregistrer. Le point sûr précédent est conservé.")
		return false
	traversal_checkpoint_pending = false
	var data: Dictionary = {
		"version": Save.SAVE_VERSION, "seed": current_seed, "floor": floor_number,
		"health": health, "oxygen": oxygen, "stress": stress,
		"anchors": anchors, "flares": flares, "rescued": rescued.duplicate(),
		"clues": clues.duplicate(), "supplies_used": supplies_used.duplicate(),
		"elapsed": elapsed, "seen_floors": seen_floors.duplicate(), "completed": completed,
		"incident_state": incident.stable_state(),
		"transmissions": radio.history_snapshot(), "radio_events": radio_events.duplicate(),
		"continuation": continuation.checkpoint_snapshot(),
		"commerce": commerce.checkpoint_snapshot()
	}
	var error: Error = Save.save_data(data, save_path)
	if error == OK:
		checkpoint_floor = floor_number
		_notify("Point sûr enregistré  ·  %s" % ("toit" if floor_number == 31 else "étage %d" % floor_number))
		return true
	else:
		_notify("Sauvegarde impossible : poursuivez cette session ou vérifiez le dossier utilisateur.")
	return false

func _unhandled_input(event: InputEvent) -> void:
	if boot_playing:
		if event.is_action_pressed("ui_accept") or event.is_action_pressed("pause_game") or event.is_action_pressed("interact"):
			_skip_cinematic()
			get_viewport().set_input_as_handled()
		return
	if not started:
		return
	if hud.help_panel.visible:
		if event.is_action_pressed("pause_game"):
			hud.close_help()
			get_viewport().set_input_as_handled()
		return
	if hud.menu.standalone_settings:
		if event.is_action_pressed("pause_game"):
			hud.menu.close_modals()
			get_viewport().set_input_as_handled()
		return
	if epilogue_playing:
		if event.is_action_pressed("pause_game"):
			if paused:
				_resume()
			else:
				_pause()
			get_viewport().set_input_as_handled()
		elif not paused and (event.is_action_pressed("interact") or event.is_action_pressed("ui_accept")):
			_finish_epilogue()
			get_viewport().set_input_as_handled()
		return
	if completed:
		if event.is_action_pressed("journal") or event.is_action_pressed("pause_game"):
			if hud.journal_panel.visible:
				_resume()
			else:
				_open_journal()
			get_viewport().set_input_as_handled()
		return
	if event.is_action_pressed("pause_game"):
		if paused:
			_resume()
		else:
			_pause()
		get_viewport().set_input_as_handled()
		return
	if paused:
		return
	if arrival_playing:
		if event.is_action_pressed("interact") or event.is_action_pressed("ui_accept"):
			_finish_arrival()
			get_viewport().set_input_as_handled()
		return
	for index: int in range(Equipment.TOOLS.size()):
		if event.is_action_pressed("tool_%d" % (index + 1)):
			_select_equipment(Equipment.TOOLS[index])
			get_viewport().set_input_as_handled()
			return
	if event.is_action_pressed("interact"):
		_interact()
	elif event.is_action_pressed("jump") and player.on_rope:
		if player.toggle_rope_lock():
			_notify("Descendeur verrouillé · Repos assuré" if bool(player.rope_snapshot().get("locked", false)) else "Descendeur libéré · S pour descendre, Z/W pour remonter")
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("flashlight"):
		player.lamp_enabled = not player.lamp_enabled
	elif event.is_action_pressed("flare"):
		_use_flare()
	elif event.is_action_pressed("anchor"):
		if player.on_rope and anchors > 0:
			if player.secure_anchor():
				anchors -= 1
				_notify("Ancrage secondaire posé  ·  Balancement stabilisé pendant 16 secondes")
			else:
				_notify("Stabilisation déjà active ou transfert en cours · Aucun ancrage consommé")
		elif not player.on_rope:
			_notify("Les ancrages secondaires se posent pendant le rappel.")
		else:
			_notify("Plus d’ancrages. Le frein principal reste opérationnel.")
	elif event.is_action_pressed("radio"):
		_call_radio()
	elif event.is_action_pressed("journal"):
		_open_journal()

func _process(delta: float) -> void:
	if paused:
		return
	if epilogue_playing:
		_process_epilogue(delta)
		return
	if completed:
		return
	menu_time += delta
	_update_soundscape(delta)
	world.sample_aircraft_rotors(menu_time)
	if boot_playing:
		cinematic.advance(delta)
		_render_cinematic()
		if not cinematic.active:
			_finish_studio_intro()
		return
	if not started:
		_apply_camera_sample(Cinematics.menu_camera(menu_context,menu_time,reduced_motion))
		return
	# The 28-second approach has its own clock. Skipping never changes mission timing.
	if not arrival_playing:
		elapsed += delta
	# Count only the silent tail if a long frame finishes an active subtitle.
	var quiet_radio_delta: float = maxf(0.0, delta - radio.remaining) if radio.is_busy() else delta
	var radio_changed: bool = radio.advance(delta)
	_sync_radio(radio_changed)
	notify_time = maxf(0, notify_time - delta)
	radio_cooldown = maxf(0, radio_cooldown - delta)
	damage_cooldown = maxf(0, damage_cooldown - delta)
	flare_time = maxf(0, flare_time - delta)
	hud.radio_panel.visible = radio_time > 0
	hud.notify_label.visible = notify_time > 0
	flare_light.visible = flare_time > 0
	if arrival_playing:
		_process_arrival(delta)
		_update_hud()
		return
	_process_departure()
	rescue_visuals.advance(delta, reduced_motion)
	_process_hoist(delta)
	var floor_number: int = player.nearest_floor()
	if player.is_at_landing() and floor_number != last_floor:
		last_floor = floor_number
		_enter_floor(floor_number)
	if traversal_checkpoint_pending and player.is_at_landing() and not incident.is_active():
		_save_checkpoint(floor_number)
	_process_incident(delta)
	_process_hazards(delta, floor_number)
	_process_story_radio(quiet_radio_delta)
	_process_horror(delta, floor_number)
	_find_nearest()
	_process_equipment(delta)
	_process_commerce_action(delta)
	_update_hud()
	if health <= 0:
		_fall_recovery()

func _process_arrival(delta: float) -> void:
	for cue: Dictionary in cinematic.advance(delta):
		_say(str(cue["speaker"]),str(cue["message"]),float(cue["duration"]),true)
	arrival_time = cinematic.elapsed
	world.apply_arrival_staging(Cinematics.staging_sample(arrival_time))
	_render_cinematic()
	if not cinematic.active:
		_finish_arrival()

func _finish_arrival() -> void:
	if not arrival_playing:
		return
	arrival_playing = false
	cinematic.finish()
	world.restore_arrival_staging()
	hud.cinematic.hide()
	hud.game.show()
	player.active = not paused and not completed
	player.camera.current = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE if paused else Input.MOUSE_MODE_CAPTURED
	_notify("AUBE  /  Équipe Alpha  ·  Secourez Ana au restaurant 30. Bravo se déploie sur Hespérie.")

func _position_helicopters(mission_time: float) -> void:
	var helicopters: Array = world_data.get("helicopters",[world_data.get("helicopter")])
	var origins: Array = world_data.get("helicopter_origins",[helicopter_origin])
	for index in range(helicopters.size()):
		var heli: Node3D = helicopters[index]
		if not is_instance_valid(heli):
			continue
		var departure: float = clampf((mission_time - 10.0 - index * 3.0) / 23.0,0,1)
		var origin: Vector3 = origins[index]
		heli.global_position = origin + Vector3((100 + index * 20) * departure * departure,25 * departure,-110 * departure)
		heli.rotation = Vector3(-sin(departure * PI) * 0.08, sin(departure * PI) * 0.18, -sin(departure * PI) * 0.035)
		heli.visible = departure < 1 and incident.phase != "aftermath"

func _process_departure() -> void:
	_position_helicopters(elapsed)
	# A resumed checkpoint starts with the correct flight state, not a replayed arrival.
	if incident.phase != "intact":
		return
	if intro_stage == 0 and elapsed > 11:
		intro_stage = 1
		_say("BRAVO  /  TOIT D’HESPÉRIE", "Bravo en place. Notre toit tient. À la baie Est du 29, on pourra se voir. Commencez par votre victime au restaurant.", 9)
	elif intro_stage == 1 and elapsed > 22:
		intro_stage = 2
		_say("HÉLIX 2 ET 3  /  APPAREILS DE SECOURS", "Les équipes sont déposées sur les deux tours. Le front se referme, on décroche. Retour dès que les conditions le permettront.", 10)
	elif intro_stage == 2 and elapsed > 34:
		intro_stage = 3
		_say("VARGA  /  POSTE D’AUBE", "Alpha tient le treuil. Bravo descend de son côté. Ramenez chaque rescapé à la balise de son étage.", 8)

func _incident_ready() -> bool:
	if not started or paused or completed or arrival_playing or incident.phase != "intact":
		return false
	if not "survivor_30" in rescued or elapsed < 36.0 or player.on_rope:
		return false
	if is_instance_valid(carried) or is_instance_valid(hoisting) or player.nearest_floor() != 29:
		return false
	var observation: Vector3 = world_data.get("observation_position", Vector3(9.8, 30.06, 0))
	return player.position.distance_to(observation) <= 3.1

func _can_observe_incident() -> bool:
	if not _incident_ready():
		return false
	var target: Vector3 = world_data.get("twin_view_target", Vector3(46, 32, -6))
	var toward: Vector3 = (target - player.camera.global_position).normalized()
	return (-player.camera.global_basis.z).dot(toward) > 0.65

func _start_incident() -> bool:
	if not _incident_ready():
		return false
	# Snapshot BEFORE the one-way event. If saving fails, keep the scene intact.
	if not _save_checkpoint(29):
		return false
	if not incident.start():
		return false
	observation_hold = 0
	_on_incident_phase("warning")
	world.set_incident_player_position(player.global_position)
	world.apply_incident(incident.phase, incident.phase_elapsed)
	return true

func _process_incident(delta: float) -> void:
	if paused or completed or arrival_playing:
		return
	if incident.phase == "intact":
		observation_hold = observation_hold + delta if _can_observe_incident() else 0.0
		if observation_hold >= 0.8:
			_start_incident()
		return
	var transitions: Array[String] = incident.advance(delta)
	for phase: String in transitions:
		_on_incident_phase(phase)
	world.set_incident_player_position(player.global_position)
	world.apply_incident(incident.phase, incident.phase_elapsed)
	var strength: float = {"quake": 0.45, "collapse": 0.75, "impact": 1.0}.get(incident.phase, 0.0)
	player.disaster_intensity = strength
	player.disaster_time = incident.phase_elapsed
	if "aftermath" in transitions:
		# Apply all persistent geometry before committing the stable post-event state.
		_save_checkpoint(player.nearest_floor())

func _on_incident_phase(phase: String) -> void:
	match phase:
		"warning":
			_say("BRAVO  /  BAIE D’HESPÉRIE", "Bravo à Aube. On vous voit à la baie Est... Attendez. Ça vibre ici. Vous le sentez aussi ?", 8, true)
			_notify("Un grondement monte dans la structure. Gardez le noyau intérieur à portée.")
			_play_effect("rumble")
		"quake":
			_say("VARGA  /  RÉPLIQUE", "Réplique ! Éloignez-vous des vitres. Restez près du noyau ; votre ligne tient !", 6, true)
			stress = minf(100, stress + 10)
			_play_effect("quake")
		"collapse":
			_say("BRAVO  /  LIAISON SATURÉE", "Hespérie bouge vers vous ! Reculez de la façade ! On essaie de rejoindre... Aube ? Aube !", 7, true)
			_play_effect("collapse")
		"impact":
			_say("VARGA  /  IMPACT", "Impact sur la façade Est ! Protégez-vous ! Le noyau tient, le treuil reste amarré !", 4, true)
			stress = minf(100, stress + 17)
			_play_effect("impact")
		"aftermath":
			_say("VARGA  /  POSTE D’AUBE — SIGNAL DÉGRADÉ", "Ana est à l’abri. Notre treuil tient. Bravo ne répond plus. Au 28, contournez les débris par l’intérieur et poursuivez les secours.", 12, true)
			player.disaster_intensity = 0

func _floor_spec(number: int) -> Dictionary:
	for spec: Dictionary in floor_specs:
		if int(spec["number"]) == number:
			return spec
	return {}

func _enter_floor(number: int) -> void:
	if number == 31:
		return
	var first: bool = not number in seen_floors
	if first:
		seen_floors.append(number)
	if commerce.phase == "active" and number in [22, 21, 20]:
		if first:
			var message: String = {22: "Mina est enfermée derrière le volet de sa réserve. Une autre personne refuse qu’on l’approche dans le salon ouest. Gardez vos distances.", 21: "Le réchauffeur fume encore. Le coupe-circuit est dans l’office, hors de la fumée. Isolez-le avant de déployer la couverture.", 20: "Le refuge des équipes tient. Trois emplacements sont libres. Sofia attend dans la réserve au nord-est. Réactivez le relais et conduisez chacun aux repères verts."}[number]
			_say("VARGA  /  RECONNAISSANCE A22–A20", message, 11)
		_save_checkpoint(number)
		return
	if first and number == 30:
		_say("ANA RIOS  /  VOIX PROCHE", "Ici ! Près des tables... J’ai vu votre hélicoptère. Ma jambe ne tient plus. Vous pouvez me remonter ?", 9)
	elif first and number == 29:
		_say("BRAVO  /  HESPÉRIE", "On progresse de notre côté. Si votre première victime est remontée, rejoignez la baie Est des suites : on établit un contact visuel.", 9)
	elif first and number == 28:
		var words: String = "Je l’ai vue tomber sur nous... Je suis aux archives. Passez par le noyau, le couloir Est est condamné." if incident.phase == "aftermath" else "Je suis coincé aux archives ! Les équipes de l’autre tour sont à leur fenêtre. Vous les voyez ?"
		_say("SAMUEL BRETON  /  ARCHIVES", words, 9)
	elif first and number == 27:
		_say("VARGA  /  POSTE DU TOIT", "Le jardin d’enfants a été évacué. Prenez le temps de souffler. On vous reçoit encore.", 9)
	elif number == 26:
		if first:
			_say("NORA HADDAD  /  SPA", "J’ai cru voir quelqu’un près du bassin… Je ne sais plus. Ne me laissez pas ici.", 10)
	elif number == 25:
		_say("VARGA  /  REFUGE 25", "Le refuge reste sûr. Accompagnez Léa et Idris jusqu’aux deux repères verts de réception." if continuation.phase == "active" and continuation.escort_state != "received" else ("Le groupe du congrès est à l’abri. Vous pouvez reconnaître l’exposition au 23." if continuation.phase == "active" else "Votre signal est propre. Le local technique est sécurisé. Activez son relais pour terminer l’intervention."), 9)
	elif number == 24 and continuation.phase == "active":
		if first:
			_say("LÉA MERCIER  /  CABINE D’INTERPRÉTATION", "Nous sommes deux dans la cabine. Idris entend mal : placez-vous devant nous et donnez un signe visible. Le foyer rejoint l’escalier de service.", 11)
		_save_checkpoint(24)
	elif number == 23 and continuation.phase == "active":
		if first:
			_say("ALEX  /  EXPOSITION", "L’histoire de Nacre… La maquette descend plus bas que les plans actuels. Je vais relever les documents et les comparer.", 9)
		_save_checkpoint(23)

func _process_hazards(delta: float, floor_number: int) -> void:
	player.environment_speed = 1.0
	# The catastrophe is a witnessed event, not an unavoidable damage timer.
	if incident.is_active():
		return
	if player.on_rope:
		stress = minf(100, stress + delta * 0.025)
		return
	if commerce.phase == "active" and is_instance_valid(commerce_visuals):
		if commerce_visuals.smoke_exposure(player.global_position):
			oxygen = maxf(0.0, oxygen - delta * 0.45)
			if oxygen <= 0.0: health = maxf(0.0, health - delta * 2.0)
		stress = minf(100.0, stress + commerce_visuals.resident_pressure(player.global_position, player.lamp_enabled) * delta)
		if floor_number == 20: stress = maxf(0.0, stress - delta * 1.2)
	var spec: Dictionary = _floor_spec(floor_number)
	var hazard: String = spec.get("hazard", "none")
	if incident.phase == "intact" and floor_number in [29, 28]:
		hazard = "none"
	if hazard == "smoke":
		oxygen = maxf(0, oxygen - delta * 0.65)
		stress = minf(100, stress + delta * 0.12)
		if oxygen <= 0:
			health = maxf(0, health - delta * 3.0)
	elif hazard == "water":
		player.environment_speed = 0.74
	elif hazard == "unstable":
		player.environment_speed = 0.87
		stress = minf(100, stress + delta * 0.07)
	if floor_number == 25 or floor_number == 31 or floor_number == 27:
		stress = maxf(0, stress - delta * 1.2)

func _process_horror(delta: float, floor_number: int) -> void:
	if not is_instance_valid(horror_visuals):
		return
	var context: Dictionary = {
		"floor": floor_number,
		"running": started and not paused and not completed and not arrival_playing and not boot_playing and not epilogue_playing,
		"on_rope": player.on_rope or not player.stair_context().is_empty(), "carrying": is_instance_valid(carried),
		"hoisting": is_instance_valid(hoisting), "incident_active": incident.is_active(),
		"incident_state": incident.stable_state(), "radio_busy": radio.is_busy(),
		"player_position": player.global_position, "camera_position": player.camera.global_position,
		"camera_forward": -player.camera.global_basis.z,
		"line_of_sight": _horror_line_of_sight(floor_number),
		"lamp_enabled": player.lamp_enabled, "flare_active": flare_time > 0,
		"reduced_motion": reduced_motion
	}
	var frame: Dictionary = horror.advance(delta, context)
	horror_visuals.sample(frame, reduced_motion)
	var serial: int = int(frame.get("cue_serial", 0))
	if serial > horror_cue_serial:
		horror_cue_serial = serial
		if sound_enabled and is_instance_valid(audio_horror) and context["running"]:
			audio_horror.global_position = frame.get("cue_position", player.global_position)
			audio_horror.play()
	if not context["running"] or context["on_rope"] or context["carrying"] or context["hoisting"] or context["incident_active"] or context["radio_busy"]:
		if is_instance_valid(audio_horror):
			audio_horror.stop()

func _horror_line_of_sight(floor_number: int) -> bool:
	if floor_number not in [29, 26]:
		return true
	var target: Vector3 = (Horror.SUITES_POSITION + Vector3(0, 1.15, 0)) if floor_number == 29 else (Horror.SPA_POSITION + Vector3(0, 1.2, 0))
	var query: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(player.camera.global_position, target, 1, [player.get_rid()])
	return get_world_3d().direct_space_state.intersect_ray(query).is_empty()

func _find_nearest() -> void:
	nearest = null
	if player.on_rope or not player.is_at_landing():
		return
	if commerce.phase == "active" and not commerce.active_action.is_empty() and is_instance_valid(commerce_visuals):
		var commerce_target: Node3D = commerce_visuals.action_targets.get(commerce.active_action)
		if _commerce_target_visible(commerce_target):
			nearest = commerce_target
			return
	# A held, still-visible operation owns its prompt until completion or cancellation.
	# An adjacent supply crate must not replace the tool's instruction/progress.
	if _can_use_equipment() and incident.phase == "aftermath" and is_instance_valid(equipment_visuals):
		var active_worksite: Node3D = equipment_visuals.targets.get(equipment.active_id)
		if is_instance_valid(active_worksite) and _equipment_target_visible(active_worksite):
			nearest = active_worksite
			return
	var best: float = 3.0
	var inspection: Node3D
	var inspection_distance: float = 2.4
	var worksite: Node3D
	var worksite_distance: float = 2.8
	for object: Node3D in world_data.get("interactables", []):
		if not is_instance_valid(object) or object.get_meta("used", false) or not object.is_visible_in_tree():
			continue
		var floor_number: int = int(object.get_meta("floor", 0))
		if floor_number != player.nearest_floor():
			continue
		var distance: float = Vector2(player.position.x - object.global_position.x, player.position.z - object.global_position.z).length()
		if str(object.get_meta("kind", "")) == "equipment":
			if _can_use_equipment() and _equipment_target_visible(object) and distance < worksite_distance:
				worksite = object
				worksite_distance = distance
			continue
		if str(object.get_meta("kind", "")).begins_with("continuation_") and not _continuation_target_visible(object):
			continue
		if str(object.get_meta("kind", "")).begins_with("commerce_") and not _commerce_target_visible(object):
			continue
		if str(object.get_meta("kind", "")) == "inspect":
			if distance < inspection_distance and _can_inspect() and _interaction_visible(object):
				inspection_distance = distance
				inspection = object
			continue
		if str(object.get_meta("kind", "")) in ["survivor", "beacon", "rappel", "evidence", "supply", "refuge", "observation"] and not _legacy_interaction_reachable(object):
			continue
		if distance < best:
			best = distance
			nearest = object
	# A deliberately aimed worksite takes priority over nearby supplies/readings.
	# Immediate rescue and traversal controls retain their existing close-range priority.
	var close_rescue_control: bool = is_instance_valid(nearest) and best < 1.5 and str(nearest.get_meta("kind", "")) in ["survivor", "beacon", "rappel", "refuge", "continuation_escort"]
	if is_instance_valid(worksite) and not close_rescue_control:
		nearest = worksite
		return
	# Rescue controls retain their close-range priority; optional reading requires aim.
	if is_instance_valid(inspection) and best >= 1.5:
		nearest = inspection

func _legacy_interaction_focus(object: Node3D) -> Vector3:
	var kind: String = str(object.get_meta("kind", ""))
	var height: float = 0.7 if kind == "supply" else (1.4 if kind == "beacon" else 1.1)
	return object.global_position + Vector3(0, height, 0)

func _legacy_interaction_reachable(object: Node3D) -> bool:
	# The original rescue/supply actions obey the same physical reach as the
	# later equipment sites. Revalidate at E, not just when the prompt was drawn.
	if not started or paused or completed or arrival_playing or boot_playing or epilogue_playing or player.on_rope or not player.is_at_landing():
		return false
	if not is_instance_valid(object) or not object.is_visible_in_tree() or object.get_meta("used", false) or object not in world_data.get("interactables", []):
		return false
	if int(object.get_meta("floor", 0)) != player.nearest_floor():
		return false
	var distance: float = Vector2(player.global_position.x - object.global_position.x, player.global_position.z - object.global_position.z).length()
	if distance > 3.0:
		return false
	var origin: Vector3 = player.camera.global_position
	var focus: Vector3 = _legacy_interaction_focus(object)
	var toward: Vector3 = focus - origin
	var nearby_control: bool = str(object.get_meta("kind", "")) in ["rappel", "beacon"] and distance <= 1.5
	if not nearby_control and toward.length_squared() > 0.001 and (-player.camera.global_basis.z).dot(toward.normalized()) < 0.55:
		return false
	var query: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(origin, focus)
	query.exclude = [player.get_rid()]
	var hit: Dictionary = get_world_3d().direct_space_state.intersect_ray(query)
	if hit.is_empty():
		return true
	var collider: Node = hit.get("collider")
	return is_instance_valid(collider) and (collider == object or object.is_ancestor_of(collider))

func _can_inspect() -> bool:
	return started and not paused and not completed and not arrival_playing and not player.on_rope and not incident.is_active() and not is_instance_valid(carried) and not is_instance_valid(hoisting)

func _interaction_visible(object: Node3D) -> bool:
	if not is_instance_valid(object) or not object.is_visible_in_tree():
		return false
	if int(object.get_meta("floor", 0)) != player.nearest_floor():
		return false
	var distance: float = Vector2(player.global_position.x - object.global_position.x, player.global_position.z - object.global_position.z).length()
	if distance > float(object.get_meta("range", 2.4)):
		return false
	var focus: Vector3 = object.global_position + (object.get_meta("focus_offset", Vector3(0,0.8,0)) as Vector3)
	var origin: Vector3 = player.camera.global_position
	var toward: Vector3 = focus - origin
	if toward.length_squared() < 0.001 or (-player.camera.global_basis.z).dot(toward.normalized()) < 0.82:
		return false
	var query: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(origin,focus)
	query.exclude = [player.get_rid()]
	return get_world_3d().direct_space_state.intersect_ray(query).is_empty()

func _open_inspection(object: Node3D) -> void:
	if not _can_inspect() or not _interaction_visible(object) or str(object.get_meta("kind", "")) != "inspect":
		return
	var entry: Dictionary = FieldProps.read(str(object.get_meta("id", "")), {"incident_state":incident.phase, "rescued":rescued, "supplies_used":supplies_used})
	if entry.is_empty():
		return
	_pause(false)
	hud.show_inspection(entry)

func _key(object: Node3D) -> String:
	if str(object.get_meta("kind", "")) in ["inspect", "equipment"] or str(object.get_meta("kind", "")).begins_with("continuation_") or str(object.get_meta("kind", "")).begins_with("commerce_"):
		return str(object.get_meta("id", ""))
	return "%s_%d" % [str(object.get_meta("kind", "unknown")), int(object.get_meta("floor", 0))]

func _interact() -> void:
	if player.on_rope:
		if player.can_cancel_rope_transfer():
			player.cancel_rope_transfer()
		elif player.can_exit_rope():
			player.leave_rope(int(player.rope_snapshot().get("exit_floor", 0)))
		else:
			_notify("Arrêtez-vous au palier et recentrez la longe avant de sortir · Espace verrouille le descendeur")
		return
	if is_instance_valid(nearest):
		_interact_node(nearest)

func _interact_node(object: Node3D) -> void:
	if not is_instance_valid(object) or object.get_meta("used", false):
		return
	var kind: String = object.get_meta("kind", "")
	if kind in ["survivor", "beacon", "rappel", "evidence", "supply", "refuge", "observation"] and not _legacy_interaction_reachable(object):
		return
	var floor_number: int = int(object.get_meta("floor", 0))
	if incident.is_active() and kind == "survivor":
		_notify("La secousse continue. Restez près du rescapé ; le portage reprend dès la stabilisation.")
		return
	match kind:
		"equipment":
			_begin_equipment(object)
		"inspect":
			_open_inspection(object)
		"observation":
			if incident.is_active():
				_notify("Éloignez-vous des vitres. Rejoignez le noyau intérieur ; la ligne de rappel tient.")
			elif incident.phase == "aftermath":
				_say("ALEX  /  CONSTAT", "Hespérie repose contre notre façade. Bravo ne répond toujours pas. Le passage intérieur reste praticable.", 8)
			elif not "survivor_30" in rescued:
				_say("BRAVO  /  HESPÉRIE", "On vous voit. Secourez d’abord Ana au restaurant 30 ; on garde le contact depuis notre tour.", 8)
			elif elapsed < 36.0:
				_notify("Les hélicoptères dégagent les toits. Bravo vous rejoint à la fenêtre.")
			else:
				_start_incident()
		"beacon":
			if is_instance_valid(carried):
				if hoisting != null:
					_notify("Le treuil est déjà en mouvement.")
					return
				if int(carried.get_meta("floor", 0)) != floor_number:
					_notify("Ramenez %s à la balise de l’étage %d." % [str(carried.get_meta("title", "le rescapé")), int(carried.get_meta("floor", 0))])
					return
				_start_hoist(carried, floor_number)
			elif is_instance_valid(hoisting):
				_notify("Attendez que le treuil ait déposé le rescapé au toit.")
			else:
				_notify("Balise orange : évacuation des rescapés. Pour descendre, suivez les repères bleus ou l’escalier signalé.")
		"rappel":
			if continuation.phase == "active" and continuation.duo_briefed and continuation.escort_state != "received":
				_notify("Le groupe vous suit à pied. Accompagnez-le au refuge 25 avant d’engager le rappel.")
			elif is_instance_valid(carried):
				_notify("Évacuez d’abord le rescapé à la balise orange de son étage. Le rappel personnel reste libre.")
			elif is_instance_valid(hoisting):
				_notify("Attendez la réception du rescapé avant d’engager une nouvelle liaison.")
			elif incident.is_active():
				_notify("Attendez la fin de la secousse sur le palier avant de vous engager.")
			elif player.engage_rope(floor_number, str(object.get_meta("route_id", ""))):
				_notify("Longe engagée · S descendre · Z/W remonter · Espace verrouiller · E sortir au palier")
			else:
				_notify("Rejoignez le repère bleu de cette ouverture depuis un appui stable.")
		"survivor":
			if continuation.phase == "active" and continuation.duo_briefed and continuation.escort_state != "received":
				_notify("Accompagnez d’abord Léa et Idris au refuge avant d’engager un autre portage.")
				return
			if is_instance_valid(carried) or is_instance_valid(hoisting):
				_notify("Une personne à la fois. Rejoignez d’abord la balise orange.")
				return
			carried = object
			object.set_meta("used", true)
			object.hide()
			player.carrying = true
			rescue_visuals.set_carried(object)
			_notify("%s sécurisé·e au harnais. Retournez à la balise orange du puits." % object.get_meta("title", "Rescapé"))
			_say("VARGA  /  POSTE DU TOIT", "Harnais reçu. Revenez au point orange du même étage : nous préparons le treuil.", 7)
		"evidence":
			if not _key(object) in clues:
				clues.append(_key(object))
			object.set_meta("used", true)
			object.hide()
			_notify("Indice ajouté au journal : %s  ·  J pour le lire" % object.get_meta("title", "Document"))
			_say("NOTE D’INTERVENTION", str(object.get_meta("description", "")), 12)
		"supply":
			if _key(object) in supplies_used:
				return
			supplies_used.append(_key(object))
			object.set_meta("used", true)
			object.hide()
			oxygen = 100
			health = minf(100, health + 30)
			anchors = mini(8, anchors + 2)
			flares = mini(6, flares + 2)
			_notify("Réserve récupérée  ·  Air remplacé, soins, 2 ancrages et 2 fusées")
		"refuge":
			if commerce.phase == "active":
				if _save_checkpoint(25):
					_notify("Relais 25 enregistré. " + commerce.objective())
			elif continuation.phase == "active":
				if _save_checkpoint(25):
					_notify("Relais 25 enregistré. " + continuation.objective())
			elif rescued.size() >= 3 and incident.phase == "aftermath":
				_complete_game()
			elif rescued.size() >= 3:
				_save_checkpoint(25)
				_notify("Avant de clore l’intervention, établissez le contact visuel avec Bravo à la baie Est du 29.")
			else:
				_save_checkpoint(25)
				_notify("Refuge enregistré. %d personne(s) attendent encore votre aide aux étages 30, 28 ou 26." % (3 - rescued.size()))
		"continuation_escort":
			_interact_escort(object)
		"continuation_evidence":
			_collect_continuation_evidence(object)
		"continuation_finish":
			_complete_continuation(object)
		"commerce_action", "commerce_person", "commerce_clue", "commerce_finish":
			_interact_commerce(object)

func _start_hoist(survivor: Node3D, floor_number: int) -> void:
	if not is_instance_valid(survivor) or int(survivor.get_meta("floor", 0)) != floor_number:
		return
	hoisting = survivor
	hoist_floor = floor_number
	hoist_progress = 0
	# Keep the lift silhouette and cable legible. The HUD retains location and
	# rescue progress; restore the existing annotation preference on completion.
	hoist_labels_enabled = player.camera.get_cull_mask_value(2)
	player.camera.set_cull_mask_value(2, false)
	survivor.show()
	survivor.global_position = Vector3(1.8, (floor_number - 24) * 6 + 0.6, 0)
	carried = null
	player.carrying = false
	rescue_visuals.begin_hoist(survivor)
	_notify("Treuillage en cours. Gardez le puits dégagé jusqu’à la réception.")
	_say("VARGA  /  TREUIL", "Le harnais est verrouillé. On remonte votre rescapé au poste de secours. Gardez le puits dégagé.", 7)

func _process_hoist(delta: float) -> void:
	if not is_instance_valid(hoisting):
		return
	hoist_progress += maxf(delta, 0.0)
	rescue_visuals.sample_hoist(hoisting, hoist_progress, hoist_floor)
	if hoist_progress >= RescuePresentation.HOIST_DURATION:
		var key: String = _key(hoisting)
		if not key in rescued:
			rescued.append(key)
		hoisting.hide()
		hoisting = null
		player.camera.set_cull_mask_value(2, hoist_labels_enabled)
		_play_effect("rescue")
		stress = maxf(0, stress - 15)
		world.set_rescued_people(rescued)
		rescue_visuals.finish_hoist(key)
		var person_name: String = {"survivor_30": "Ana Rios", "survivor_28": "Samuel Breton", "survivor_26": "Nora Haddad"}.get(key, "Rescapé")
		_notify("%s : réception confirmée. Reprenez votre progression." % person_name)
		_say("VARGA  /  POSTE DU TOIT", "%s : réception confirmée au poste de secours. %d sur 3 à l’abri." % [person_name, rescued.size()], 8, true)
		_save_checkpoint(hoist_floor)

func _use_flare() -> void:
	if flares <= 0:
		_notify("Plus de fusées. Gardez la lampe allumée et rejoignez la corde.")
		return
	flares -= 1
	flare_time = 20
	flare_light.global_position = player.position + Vector3(0,1.3,0)
	stress = maxf(0, stress - 10)
	_notify("Fusée allumée  ·  20 secondes de lumière rouge")
	_play_effect("flare")

func _call_radio() -> void:
	if incident.is_active():
		_notify("Canal de secours prioritaire. Écoutez les consignes et éloignez-vous de la façade Est.")
		return
	if radio_cooldown > 0:
		return
	radio_cooldown = 8
	stress = maxf(0, stress - 5)
	# Operational requests take precedence over both ambient fiction and queued
	# normal messages. Received lines remain available in the journal.
	if commerce.phase == "active":
		_say("VARGA  /  SECOURS INFÉRIEURS", commerce.objective() + " Les groupes déjà reçus restent à l’abri au toit et au 25.", 11, true)
	elif continuation.phase == "active":
		_say("VARGA  /  RELAIS A25", continuation.objective() + " Les trois premières réceptions restent confirmées au toit. Bravo n’est toujours pas identifié.", 10, true)
	elif is_instance_valid(carried):
		_say("VARGA  /  POSTE DU TOIT", "Vous avez quelqu’un au harnais. Rejoignez la balise orange du même étage et confirmez le treuillage.", 8, true)
	elif is_instance_valid(hoisting):
		_say("VARGA  /  TREUIL", "Le treuil est en mouvement. Gardez le puits dégagé et attendez la confirmation de réception au toit.", 8, true)
	elif rescued.size() >= 3:
		if incident.phase == "intact":
			_say("VARGA  /  POSTE D’AUBE", "Les trois rescapés sont ici. Bravo attend votre contact visuel à la baie Est du 29 avant le rapport final.", 8, true)
		else:
			_say("VARGA  /  POSTE D’AUBE — SIGNAL DÉGRADÉ", "Les trois rescapés sont à l’abri. Rejoignez le refuge 25 et son relais ; il faut retrouver Bravo.", 8, true)
	elif player.nearest_floor() == 26 and clues.size() > 1:
		_say("CANAL SECOURS  /  SOURCE NON IDENTIFIÉE", "Ne remontez pas. Le toit est déjà sous l’eau. ... Alex ? Ne remontez pas.", 8)
		stress = minf(100, stress + 12)
	elif incident.phase == "aftermath":
		_say("VARGA  /  POSTE D’AUBE — SIGNAL DÉGRADÉ", "... Aube vous reçoit. Le treuil est opérationnel. Contournez les débris Est au 28 par le noyau. Bravo, ici Aube... répondez.", 9)
	elif "survivor_30" in rescued:
		_say("BRAVO  /  HESPÉRIE", "Bravo à Alpha. Ana est à l’abri ? On vous attend à la baie Est du 29. Regardez vers nos lumières.", 9)
	else:
		_say("VARGA  /  POSTE DU TOIT", "Signaux confirmés au restaurant 30, aux archives 28 et au spa 26. Les balises orange servent au treuil ; suivez les repères bleus et les escaliers pour progresser.", 9)

func _process_story_radio(quiet_delta: float) -> void:
	if not started or paused or completed or arrival_playing or incident.phase != "aftermath" or "survivor_28" not in rescued:
		radio_quiet_time = 0.0
		return
	if not player.is_at_landing() or is_instance_valid(carried) or is_instance_valid(hoisting) or radio.is_busy():
		radio_quiet_time = 0.0
		return
	var floor_number: int = player.nearest_floor()
	var awaiting_echo: bool = "bravo_echo" not in radio_events
	if (awaiting_echo and floor_number != 27) or (not awaiting_echo and ("bravo_verification" in radio_events or floor_number not in [27, 25, 31])):
		radio_quiet_time = 0.0
		return
	radio_quiet_time += maxf(0.0, quiet_delta)
	var required_silence: float = 6.0 if awaiting_echo else 2.0
	if radio_quiet_time < required_silence:
		return
	radio_quiet_time = 0.0
	if awaiting_echo:
		radio_events.append("bravo_echo")
		_say("BRAVO  /  ÉCHO NON VÉRIFIÉ", "Bravo à Aube. On vous voit à la baie Est... Notre toit tient. Vous nous recevez ?", 8)
	else:
		radio_events.append("bravo_verification")
		_say("VARGA  /  VÉRIFICATION DU SIGNAL", "J’ai reçu le même fragment. Aucun contact confirmé avec Bravo. Gardez les consignes du poste d’Aube ; nous vérifions la liaison.", 9)
	_save_checkpoint(floor_number)

func _update_hud() -> void:
	var floor_number: int = player.nearest_floor()
	var stair_route: Dictionary = player.stair_context()
	var rope_state: Dictionary = player.rope_snapshot() if player.on_rope else {}
	var spec: Dictionary = _floor_spec(floor_number)
	var display_names: Dictionary = {31:"Poste de commandement",30:"Restaurant panoramique",29:"Suites de Nacre",28:"Bureaux et archives",27:"Jardin des enfants",26:"Spa et piscine",25:"Refuge technique",24:"Centre de congrès",23:"Histoire de Nacre",22:"Galerie des Alizés",21:"Cuisines de service",20:"Refuge des équipes"}
	var name_text: String = display_names.get(floor_number, "Puits de rappel")
	hud.location_label.text = ("TOIT" if floor_number == 31 else "ÉTAGE %02d" % floor_number) + "  ·  " + name_text
	if not stair_route.is_empty():
		hud.location_label.text = "ESCALIER %d ↔ %d  ·  Liaison locale" % [int(stair_route["upper"]), int(stair_route["lower"])]
	var atmosphere: String = "LIAISON RADIO ACTIVE"
	if player.on_rope:
		atmosphere = "RAPPEL %d ↔ %d  /  %s" % [int(rope_state.get("upper", 0)), int(rope_state.get("lower", 0)), "DESCENDEUR VERROUILLÉ" if bool(rope_state.get("locked", false)) else "LIGNE LOCALE"]
	elif not stair_route.is_empty():
		atmosphere = "ESCALIER PRATICABLE  /  RETOUR POSSIBLE"
	elif spec.get("hazard", "none") == "smoke":
		atmosphere = "FUMÉES  /  AIR DE RÉSERVE ACTIF"
	elif spec.get("hazard", "none") == "water":
		atmosphere = "SOL INONDÉ  /  PROGRESSION RALENTIE"
	elif spec.get("hazard", "none") == "unstable":
		atmosphere = "DÉBRIS INSTABLES  /  PRUDENCE"
	elif floor_number == 25:
		atmosphere = "REFUGE SÉCURISÉ"
	if incident.is_active():
		atmosphere = "RÉPLIQUE EN COURS  /  RESTEZ PRÈS DU NOYAU"
	elif incident.phase == "aftermath" and floor_number != 25:
		atmosphere = "SIGNAL DÉGRADÉ  /  BRAVO SANS RÉPONSE"
	elif incident.phase == "intact" and floor_number in [29,28] and not player.on_rope:
		atmosphere = "DEUX ÉQUIPES EN INTERVENTION"
	if commerce.phase != "dormant" and not player.on_rope and stair_route.is_empty():
		if floor_number == 20: atmosphere = "REFUGE 20 · LIAISON ACTIVE" if commerce.has_action("relay") else "REFUGE 20 · RELAIS À RÉTABLIR"
		elif is_instance_valid(commerce_visuals) and commerce_visuals.smoke_exposure(player.global_position): atmosphere = "FUMÉE LOCALE · ISOLER PUIS CONTENIR LE FOYER"
	hud.depth_label.text = "ALT. %d m  ·  %s" % [int(player.position.y + 132), atmosphere]
	hud.health_bar.value = health
	hud.oxygen_bar.value = oxygen
	hud.stress_bar.value = stress
	hud.resources_label.text = "ANCRAGES %d  /  FUSÉES %d" % [anchors, flares]
	hud.equipment_label.text = "%s  ·  %s\n1 Hache  2 Extincteur  3 Halligan  4 Coupe-boulon" % [str(Equipment.TITLES[equipment.selected]).to_upper(), "réserve %d / 3" % equipment.charges_left() if equipment.selected == "extinguisher" else "outil prêt"]
	if not _can_use_equipment():
		hud.equipment_label.text = "MATÉRIEL RANGÉ · MAINS LIBRES POUR LE SECOURS"
	hud.status_label.text = "RESCAPÉS %d / 3    •    INDICES %d / 3" % [rescued.size(), clues.size()]
	if continuation.phase != "dormant":
		hud.status_label.text = "TOIT 3 / 3   •   REFUGE %d / 2   •   INDICES %d / 5" % [2 if continuation.escort_state == "received" else 0, clues.size()]
	if commerce.phase != "dormant":
		hud.status_label.text = "À L’ABRI %d / 8   •   REFUGE 20 : %d / 3   •   INDICES %d / 7" % [5 + commerce.received_count(), commerce.received_count(), clues.size()]
	if player.on_rope:
		rope_state["kind"] = "rope"
		hud.set_traversal_context(rope_state)
	elif not stair_route.is_empty():
		hud.set_traversal_context(stair_route)
	else:
		hud.set_traversal_context({})
	if arrival_playing:
		hud.mission_label.text = "Approche des deux tours  ·  Alpha sur Aube, Bravo sur Hespérie."
	elif incident.is_active():
		hud.mission_label.text = "Éloignez-vous des vitres. Le noyau et la ligne de rappel tiennent."
	elif commerce.phase == "active":
		hud.mission_label.text = commerce.objective()
	elif continuation.phase == "active":
		hud.mission_label.text = continuation.objective()
	elif is_instance_valid(carried):
		hud.mission_label.text = "Ramener %s à la balise orange du %d." % [str(carried.get_meta("title", "le rescapé")), int(carried.get_meta("floor", floor_number))]
	elif is_instance_valid(hoisting):
		var phase_text: String = "Verrouillage du harnais" if hoist_progress < 0.45 else ("Dépose au toit" if hoist_progress >= 4.2 else "Remontée vers le toit")
		hud.mission_label.text = "%s  ·  %d %%\nAttendre la réception confirmée." % [phase_text, int(clampf(hoist_progress / RescuePresentation.HOIST_DURATION, 0.0, 1.0) * 100)]
	elif incident.phase == "intact" and "survivor_30" in rescued:
		hud.mission_label.text = "Rejoindre la baie Est du 29 et regarder l’équipe Bravo."
	elif rescued.size() >= 3:
		hud.mission_label.text = "Activer le relais du refuge sécurisé à l’étage 25."
	else:
		hud.mission_label.text = "Secourir les personnes aux étages 30, 28 et 26."
	if arrival_playing:
		hud.prompt_label.text = "E  Passer l’approche et rejoindre l’équipe sur le toit"
	elif player.on_rope:
		var rope_exit: String = "E  Rejoindre le palier %d" % int(rope_state.get("exit_floor", 0)) if player.can_exit_rope() else "Freinez au palier et recentrez la longe pour sortir"
		if not str(rope_state.get("transfer", "")).is_empty():
			rope_exit = "Transfert assuré vers le puits" if str(rope_state["transfer"]) in ["attach", "cancel_exit"] else "Retour assuré sur le palier"
		if bool(rope_state.get("obstructed", false)):
			rope_exit = "E  Annuler le transfert et revenir assuré" if bool(rope_state.get("can_cancel_transfer", false)) else "Passage encombré · Maintien de la longe"
		hud.prompt_label.text = "S  Descendre  •  Z/W  Remonter  •  Q/D  Équilibrer\nCtrl  Précis  •  Maj  Rapide  •  Espace  Verrou  •  X  Ancrage\n" + rope_exit
	elif not stair_route.is_empty():
		hud.prompt_label.text = "Escalier %d ↔ %d · ZQSD / WASD pour progresser\nCette volée ne dessert que ces deux étages" % [int(stair_route["upper"]), int(stair_route["lower"])]
	elif is_instance_valid(nearest):
		var kind: String = nearest.get_meta("kind", "")
		if kind == "beacon":
			hud.prompt_label.text = "Treuillage en cours  ·  Attendre la réception" if is_instance_valid(hoisting) else ("E  Confirmer le treuillage du rescapé" if is_instance_valid(carried) else "Balise orange · Évacuation des rescapés uniquement")
		elif kind == "rappel":
			var route: Dictionary = Routes.for_id(str(nearest.get_meta("route_id", "")))
			hud.prompt_label.text = "E  Engager le rappel %d ↔ %d\nUne liaison locale · Sortie sur le palier opposé" % [int(route.get("upper", floor_number)), int(route.get("lower", floor_number - 1))]
		elif kind == "survivor":
			hud.prompt_label.text = "Attendez la fin de la secousse avant de déplacer le rescapé" if incident.is_active() else "E  Sécuriser %s au harnais" % nearest.get_meta("title", "le rescapé")
		elif kind == "refuge":
			hud.prompt_label.text = "E  Activer le relais du refuge et enregistrer"
		elif kind == "continuation_escort":
			hud.prompt_label.text = "Groupe reçu au refuge 25" if continuation.escort_state == "received" else ("E  Signe visible : attendez ici" if continuation.escort_state == "following" else "E  Signe visible : suivez-moi vers le refuge 25")
		elif kind == "continuation_evidence":
			hud.prompt_label.text = "E  Relever · " + str(nearest.get_meta("title", "Pièce d’exposition"))
		elif kind == "continuation_finish":
			hud.prompt_label.text = "E  Transmettre le compte rendu de reconnaissance"
		elif kind == "commerce_action":
			var action: String = str(nearest.get_meta("action_id", ""))
			hud.prompt_label.text = commerce.prompt(action, equipment.selected)
			if action == "resident" and (player.lamp_enabled or player.global_position.distance_to(nearest.global_position) < 2.0):
				hud.prompt_label.text = "Reculez à 2–3 m · F abaisse la lampe · Maintenir E pour parler"
		elif kind == "commerce_person":
			var person: String = str(nearest.get_meta("person_id", ""))
			hud.prompt_label.text = "E · Attendez ici" if commerce.person_state(person) == "following" else "E · Suivez-moi jusqu’au refuge 20"
			if person == "mina" and not commerce.has_action("shutter"): hud.prompt_label.text = "Dégagez d’abord le volet au Halligan"
			if person == "theo" and not commerce.has_action("blanket"): hud.prompt_label.text = "Isolez le réchauffeur puis déployez la couverture"
		elif kind == "commerce_clue":
			hud.prompt_label.text = "E · Consigner " + str(nearest.get_meta("title", "le constat"))
		elif kind == "commerce_finish":
			hud.prompt_label.text = "E · Transmettre le bilan du refuge 20"
		elif kind == "equipment":
			hud.prompt_label.text = equipment.prompt(_key(nearest))
		elif kind == "inspect":
			hud.prompt_label.text = "E  Examiner · " + str(nearest.get_meta("title", "Objet d’intervention"))
		elif kind == "observation":
			if incident.is_active():
				hud.prompt_label.text = "Éloignez-vous des vitres  ·  Rejoignez le noyau intérieur"
			else:
				hud.prompt_label.text = "E  Constater les dégâts" if incident.phase == "aftermath" else "E  Établir le contact visuel avec Bravo"
		else:
			hud.prompt_label.text = "E  " + str(nearest.get_meta("title", "Examiner"))
	else:
		hud.prompt_label.text = "Rescapé au harnais  ·  Rejoignez la balise orange" if is_instance_valid(carried) else ""
	hud.overlay.color.a = clampf((30 - health) / 160.0, 0, 0.16)
	var rows: PackedStringArray = []
	var map_floors: Array = [31,30,29,28,27,26,25,24,23] if continuation.phase != "dormant" else [31,30,29,28,27,26,25]
	if commerce.phase != "dormant": map_floors.append_array([22,21,20])
	for n: int in map_floors:
		var title: String = {31:"TOIT",30:"RESTAURANT",29:"SUITES",28:"ARCHIVES",27:"JARDIN",26:"SPA",25:"REFUGE",24:"CONGRÈS",23:"EXPOSITION",22:"GALERIE",21:"CUISINES",20:"REFUGE"}[n]
		rows.append(("▸ " if n == floor_number else "  ") + str(n) + "  " + title + ("  ✓" if "survivor_%d" % n in rescued else ""))
	hud.floor_map.text = "\n".join(rows)

func _journal_content() -> String:
	var text: String = "OPÉRATION ORPHÉE — GRAINE %d\n\n" % current_seed
	text += "Votre mission : secourir les personnes des étages 30, 28 et 26, puis rejoindre le refuge 25. Les treuils évacuent les rescapés au toit ; les hélicoptères attendent une accalmie.\n\n"
	text += "RESCAPÉS AU POSTE DE SECOURS : %d / 3\n" % rescued.size()
	for record: Array in [["survivor_30", "Ana Rios", 30], ["survivor_28", "Samuel Breton", 28], ["survivor_26", "Nora Haddad", 26]]:
		text += "%s — %s\n" % [record[1], "réception confirmée, à l’abri au toit" if record[0] in rescued else "à secourir, étage %d" % record[2]]
	text += "\n"
	if incident.phase == "aftermath":
		text += "SITUATION STRUCTURELLE\nUne réplique a fait basculer Hespérie contre la façade Est d’Aube. Bravo ne répond plus ; son sort n’est pas confirmé. Le noyau, le treuil et le poste d’Aube restent opérationnels. Le passage Est du 28 est condamné : suivre le détour intérieur. Les victimes déjà réceptionnées restent à l’abri.\n\n"
	else:
		text += "SITUATION STRUCTURELLE\nDeux tours debout à notre arrivée. Alpha intervient sur Aube ; Bravo vérifie des signaux dans Hespérie. Après le sauvetage d’Ana au 30, rejoindre la baie Est du 29 pour établir le contact visuel.\n\n"
	for spec: Dictionary in floor_specs:
		if "evidence_%d" % int(spec["number"]) in clues:
			text += "%s — ÉTAGE %d\n%s\n\n" % [spec["evidence_title"], spec["number"], spec["evidence_text"]]
	if clues.is_empty():
		text += "Aucun indice collecté. Les documents sont éclairés d’une lueur bleue.\n\n"
	text += "TRANSMISSIONS REÇUES\n"
	if radio.history.is_empty():
		text += "Aucune transmission enregistrée dans ce point de reprise.\n"
	for transmission: Dictionary in radio.history:
		var stamp: int = int(transmission["elapsed"])
		text += "[%02d:%02d] %s\n%s\n\n" % [stamp / 60, stamp % 60, transmission["speaker"], transmission["message"]]
	text += "\nMATÉRIEL\nLa lampe ne consomme pas de pile dans ce prototype. L’air diminue dans la fumée. Une fusée éclaire pendant 20 secondes et masque les manifestations. X stabilise le balancement sur une liaison locale. Espace verrouille le descendeur ; reposez-vous assuré pour récupérer de l’endurance.\n\nPOINTS SÛRS\nUn rescapé reçu déclenche une tentative de point sûr. Si vous êtes encore sur une liaison, l’écriture attend le prochain palier stable. Le refuge 25 enregistre également votre progression."
	text += "\n\nOBSERVATIONS DE TERRAIN\nDouze objets peuvent être examinés du toit au refuge. Approchez-vous et regardez-les pour afficher E. Leur fiche distingue usage, constat et consigne, selon la situation actuelle. La lecture met l’intervention en pause ; Fermer ou Échap reprend le jeu. Ces observations restent facultatives et ne consomment aucun matériel."
	return text

func _dossier_snapshot() -> Dictionary:
	# Project only the records actually collected in this intervention. Unread
	# clue titles and texts never enter the journal panel's model.
	var records: Array[Dictionary] = []
	var active_route: Dictionary = player.rope_snapshot() if player.on_rope else player.stair_context()
	for spec: Dictionary in floor_specs:
		var id: String = "evidence_%d" % int(spec["number"])
		if id in clues:
			records.append({"id": id, "floor": int(spec["number"]),
				"title": str(spec["evidence_title"]), "text": str(spec["evidence_text"])})
	for id: String in Dossier.CONTINUATION_CLUES:
		if id in clues:
			var entry: Dictionary = Dossier.CONTINUATION_CLUES[id].duplicate(true)
			entry["id"] = id
			records.append(entry)
	for id: String in Commerce.CLUES:
		if id in clues:
			var entry: Dictionary = Commerce.CLUES[id].duplicate(true)
			entry["id"] = id
			records.append(entry)
	return {
		"seed": current_seed, "floor": player.nearest_floor() if player.is_at_landing() else last_floor, "checkpoint_floor": checkpoint_floor,
		"traversal_id": str(active_route.get("route_id", active_route.get("id", ""))),
		"rescued": rescued.duplicate(), "clues": clues.duplicate(), "clue_records": records,
		"supplies_used": supplies_used.duplicate(), "elapsed": elapsed,
		"health": health, "oxygen": oxygen, "stress": stress, "anchors": anchors, "flares": flares,
		"seen_floors": seen_floors.duplicate(), "completed": completed,
		"incident_state": incident.phase, "transmissions": radio.history_snapshot(),
		"carried_id": _key(carried) if is_instance_valid(carried) else "",
		"hoisting_id": _key(hoisting) if is_instance_valid(hoisting) else "",
		"continuation": continuation.snapshot(), "commerce": commerce.snapshot()
	}

func _complete_game(play_epilogue: bool = true) -> void:
	if continuation.phase != "dormant" or not started or incident.phase != "aftermath" or player.nearest_floor() != 25:
		return
	for id: String in ["survivor_30", "survivor_28", "survivor_26"]:
		if not id in rescued:
			return
	var first_completion: bool = not completed
	completed = true
	# The durable completion precedes its optional presentation. If the disk
	# write fails, keep the playable refuge and its visible error so the player
	# can retry; never show a successfully completed film for an unsaved ending.
	if first_completion and not _save_checkpoint(25):
		completed = false
		return
	rescue_visuals.finish_reception()
	if is_instance_valid(horror_visuals):
		horror_visuals.clear()
	if is_instance_valid(audio_horror):
		audio_horror.stop()
	for channel: AudioStreamPlayer in [audio_score,audio_rotors,audio_radio,audio_effect]:
		if is_instance_valid(channel):
			channel.stop()
	# Continuing or replaying a finished intervention never rewrites its save.
	player.active = false
	world.set_process(false)
	paused = false
	hud.set_paused(false)
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	if first_completion and play_epilogue:
		_start_epilogue()
	else:
		_finish_epilogue()

func _start_epilogue() -> void:
	if continuation.phase != "dormant" or not completed or paused or epilogue_playing:
		return
	for id: String in ["survivor_30", "survivor_28", "survivor_26"]:
		if id not in rescued:
			return
	epilogue.start()
	epilogue_playing = true
	epilogue_voice_key = ""
	player.active = false
	world.set_process(false)
	menu_camera.current = true
	hud.game.hide()
	hud.end_panel.hide()
	hud.journal_panel.hide()
	hud.pause_panel.hide()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	_render_epilogue()

func _process_epilogue(delta: float) -> void:
	if paused or not epilogue_playing:
		return
	epilogue.advance(delta)
	_render_epilogue()
	if not epilogue.active:
		_finish_epilogue()

func _render_epilogue() -> void:
	_apply_camera_sample(epilogue.camera_sample(reduced_motion))
	var frame: Dictionary = epilogue.presentation()
	hud.cinematic.set_frame(frame, "epilogue")
	var voice_key: String = str(frame.get("speaker", "")) + str(frame.get("message", ""))
	if not voice_key.is_empty() and voice_key != epilogue_voice_key:
		epilogue_voice_key = voice_key
		if sound_enabled and is_instance_valid(audio_radio):
			audio_radio.play()

func _finish_epilogue() -> void:
	if not completed or paused:
		return
	epilogue.finish()
	epilogue_playing = false
	epilogue_voice_key = ""
	if is_instance_valid(audio_radio):
		audio_radio.stop()
	hud.cinematic.hide()
	player.active = false
	world.set_process(false)
	menu_camera.current = true
	_apply_camera_sample(Epilogue.debrief_camera())
	hud.show_debrief(_dossier_snapshot())
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _replay_epilogue() -> void:
	# Only the visible debrief owns this action. Stale signals from another
	# modal cannot start a sequence behind a journal or a live intervention.
	if continuation.phase != "dormant" or not started or not completed or paused or epilogue_playing or not hud.end_panel.visible:
		return
	_start_epilogue()


func _continuation_context() -> Dictionary:
	return {"completed": completed, "floor": player.nearest_floor(), "at_landing": player.is_at_landing(),
		"rescued": rescued.duplicate(), "clues": clues.duplicate(), "incident_state": incident.stable_state(),
		"duo_arrived": is_instance_valid(continuation_visuals) and continuation_visuals.both_arrived()}


func _begin_continuation() -> void:
	if continuation.phase == "complete":
		_begin_commerce()
		return
	# Only the visible, settled first debrief owns this choice. Migration and
	# merely reading the ending never start a new chapter or replace its save.
	if not started or not completed or paused or epilogue_playing or boot_playing or arrival_playing or not hud.end_panel.visible or hud.journal_panel.visible:
		return
	var previous: Dictionary = continuation.snapshot()
	var previous_seen: Array = seen_floors.duplicate()
	if not continuation.begin(_continuation_context()):
		return
	if 25 not in seen_floors:
		seen_floors.append(25)
	completed = false
	if not _save_checkpoint(25):
		continuation.restore(previous)
		seen_floors = previous_seen
		completed = true
		hud.end_panel.subtitle_label.text = "Sauvegarde impossible. L’intervention précédente est conservée ; réessayez la poursuite."
		return
	# Rebuilding happens only after the durable choice. The original six floors,
	# receptions, resources, investigation ledger and incident are preserved.
	_restore(Save.load_data(save_path))
	_say("VARGA  /  RELAIS A25", "Le centre de congrès est accessible par l’escalier de service au nord. Vérifiez les personnes signalées dans les cabines. Je garde le refuge ouvert.", 10, true)
	_update_hud()


func _valid_continuation_interaction(object: Node3D) -> bool:
	if continuation.phase != "active" or not started or paused or completed or not is_instance_valid(object) or player.on_rope or not player.is_at_landing():
		return false
	if int(object.get_meta("floor", 0)) != player.nearest_floor() or not object.is_visible_in_tree():
		return false
	var distance: float = Vector2(player.position.x - object.global_position.x, player.position.z - object.global_position.z).length()
	return distance <= 3.0 and object in world_data.get("interactables", []) and _continuation_target_visible(object)


func _continuation_target_visible(object: Node3D) -> bool:
	var origin: Vector3 = player.camera.global_position
	var focus: Vector3 = object.global_position + Vector3(0, 1.2, 0)
	var toward: Vector3 = focus - origin
	if toward.length_squared() < 0.001 or (-player.camera.global_basis.z).dot(toward.normalized()) < 0.70:
		return false
	var query: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(origin, focus)
	query.exclude = [player.get_rid()]
	var hit: Dictionary = get_world_3d().direct_space_state.intersect_ray(query)
	if hit.is_empty():
		return true
	var collider: Node = hit.get("collider")
	return is_instance_valid(collider) and (collider == object or object.is_ancestor_of(collider) or (str(object.get_meta("kind", "")) == "continuation_escort" and collider == object.get_parent()))


func _interact_escort(object: Node3D) -> void:
	if not _valid_continuation_interaction(object) or continuation.escort_state == "received":
		return
	var first_contact: bool = not continuation.duo_briefed
	if continuation.escort_state == "following":
		continuation.pause_escort()
		_notify("SIGNE VISIBLE · Attendez ici. Revenez près du groupe puis E pour reprendre.")
	elif continuation.start_escort(_continuation_context()):
		_notify("SIGNE VISIBLE · Suivez-moi. Restez près du groupe et remontez l’escalier de service vers le 25.")
		_say("LÉA  /  CONSIGNE ACCOMPAGNÉE D’UN SIGNE", "D’accord. Je reste avec Idris. Avancez à notre rythme, nous attendrons si vous vous éloignez.", 10)
	world.set_continuation_state(continuation.snapshot())
	if first_contact and continuation.duo_briefed:
		_save_checkpoint(24)
	_update_hud()


func _collect_continuation_evidence(object: Node3D) -> void:
	if not _valid_continuation_interaction(object):
		return
	var id: String = _key(object)
	if not Dossier.CONTINUATION_CLUES.has(id) or id in clues:
		return
	clues.append(id)
	object.set_meta("used", true)
	# Keep the exhibition prop in its place. Only its reading prompt is consumed.
	var record: Dictionary = Dossier.CONTINUATION_CLUES[id]
	_say("ALEX  /  CONSTAT RELEVÉ", str(record["text"]), 12)
	if _save_checkpoint(23):
		_notify("Relevé ajouté au dossier : " + str(record["title"]))
	_update_hud()


func _process_continuation(delta: float) -> void:
	if continuation.phase != "active" or paused or not started or completed or not is_instance_valid(continuation_visuals):
		return
	var optional_cue: bool = player.is_at_landing() and not radio.is_busy() and not incident.is_active() and not is_instance_valid(carried) and not is_instance_valid(hoisting)
	continuation_visuals.advance(delta, player.global_position, not player.on_rope, optional_cue)
	if continuation.escort_state != "received" and continuation_visuals.both_arrived():
		if continuation.receive_escort(_continuation_context()):
			world.set_continuation_state(continuation.snapshot())
			_say("VARGA  /  RÉCEPTION AU REFUGE 25", "Léa Mercier et Idris Kaci sont reçus au refuge. Les deux personnes sont à l’abri. Vous pouvez reprendre la reconnaissance au 23.", 10, true)
			_save_checkpoint(25)


func _physics_process(delta: float) -> void:
	_process_continuation(delta)
	_process_commerce(delta)


func _complete_continuation(object: Node3D) -> void:
	if not _valid_continuation_interaction(object):
		return
	var previous: Dictionary = continuation.snapshot()
	if not continuation.complete(_continuation_context()):
		_notify("Compte rendu incomplet. Recevez Léa et Idris au refuge, puis relevez la maquette et la photographie au 23.")
		return
	completed = true
	if not _save_checkpoint(23):
		continuation.restore(previous)
		completed = false
		return
	_show_continuation_debrief()


func _show_continuation_debrief() -> void:
	player.active = false
	world.set_process(false)
	paused = false
	arrival_playing = false
	epilogue_playing = false
	hud.set_paused(false)
	menu_camera.current = true
	_apply_camera_sample(Cinematics.menu_camera({"id": "floor", "floor": 20 if commerce.phase == "complete" else 23, "incident": "aftermath"}, 0.0, true))
	hud.show_debrief(_dossier_snapshot())
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _fall_recovery() -> void:
	var data: Dictionary = Save.load_data(save_path)
	if not data.is_empty() and float(data.get("health", 0.0)) <= 0.0:
		_return_to_menu()
		return
	if data.is_empty():
		_start_new(current_seed)
	else:
		_restore(data)
	_say("VARGA  /  REPRISE AU POINT SÛR", "Intervention reprise au dernier point enregistré. Engagez la longe au repère bleu avant d’entrer dans une ouverture.", 10)

func _open_journal() -> void:
	if not started or arrival_playing or epilogue_playing or boot_playing:
		return
	_pause(false)
	hud.hide_inspection()
	# The ending is a later sibling modal and would otherwise cover the journal.
	hud.end_panel.hide()
	hud.show_journal(_dossier_snapshot())

func _pause(show_panel: bool = true) -> void:
	paused = true
	equipment.cancel()
	commerce.cancel()
	if is_instance_valid(equipment_visuals):
		equipment_visuals.sample(equipment.snapshot(), false, incident.phase == "aftermath", reduced_motion)
	for channel: AudioStreamPlayer in [audio_wind,audio_radio,audio_effect,audio_score,audio_rotors]:
		if is_instance_valid(channel):
			channel.stream_paused = true
	if is_instance_valid(audio_horror):
		# A short optional 3D cue can still be pending its first audio frame.
		# Stop it on pause so it cannot start behind a modal; the serial prevents
		# an automatic replay when the same visual frame resumes.
		audio_horror.stop()
		audio_horror.stream_paused = false
	player.active = false
	world.set_process(false)
	hud.pause_panel.visible = show_panel
	if arrival_playing or epilogue_playing:
		hud.cinematic.hide()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _resume() -> void:
	paused = false
	for channel: AudioStreamPlayer in [audio_wind,audio_radio,audio_effect,audio_score,audio_rotors]:
		if is_instance_valid(channel):
			channel.stream_paused = false
	if is_instance_valid(audio_horror):
		audio_horror.stream_paused = false
	player.active = not arrival_playing and not completed
	world.set_process(not completed)
	hud.hide_inspection()
	hud.set_paused(false)
	if epilogue_playing:
		_render_epilogue()
	elif completed:
		hud.show_debrief(_dossier_snapshot())
	elif arrival_playing:
		_render_cinematic()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE if completed or arrival_playing else Input.MOUSE_MODE_CAPTURED

func _return_to_menu() -> void:
	if is_instance_valid(audio_horror):
		audio_horror.stop()
		audio_horror.stream_paused = false
	for channel: AudioStreamPlayer in [audio_wind,audio_radio,audio_effect,audio_score,audio_rotors]:
		if is_instance_valid(channel):
			channel.stream_paused = false
	boot_playing = false
	cinematic.finish()
	radio.reset()
	radio_quiet_time = 0.0
	_prepare_menu()

func _notify(message: String) -> void:
	hud.notify_label.text = message
	notify_time = 6
	hud.notify_label.show()

func _say(speaker: String, message: String, seconds: float = 8.0, priority: bool = false) -> void:
	var before: Dictionary = radio.current.duplicate(true)
	var accepted: bool = radio.submit(speaker, message, seconds, elapsed, priority, incident.is_active() and not priority)
	if accepted:
		radio_quiet_time = 0.0
	_sync_radio(accepted and before != radio.current)

func _sync_radio(play_chirp: bool = false) -> void:
	radio_time = radio.remaining
	if radio.is_busy():
		hud.set_radio(str(radio.current["speaker"]), str(radio.current["message"]))
	else:
		hud.radio_panel.hide()
	if play_chirp and radio.is_busy() and sound_enabled and is_instance_valid(audio_radio):
		audio_radio.play()

func _setting_changed(setting: String, value: Variant) -> void:
	if not Preferences.valid_value(setting, value):
		return
	preferences[setting] = value
	reduced_motion = bool(preferences["reduced_motion"])
	flashes_enabled = bool(preferences["flashes"])
	sound_enabled = bool(preferences["audio"])
	if is_instance_valid(player):
		player.apply_comfort(preferences)
	if is_instance_valid(world):
		world.set_lightning_enabled(flashes_enabled)
		world.set_reduced_motion(reduced_motion)
	if is_instance_valid(horror_visuals):
		if started and not completed and not boot_playing and not arrival_playing and not epilogue_playing:
			horror_visuals.sample(horror.presentation(), reduced_motion)
		else:
			horror_visuals.clear()
	AudioServer.set_bus_mute(0,not sound_enabled)
	_apply_master_volume()
	if DisplayServer.get_name() != "headless" and sound_enabled and is_instance_valid(audio_wind) and not audio_wind.playing:
		audio_wind.play()
		audio_wind.stream_paused = paused
	if not sound_enabled:
		if is_instance_valid(audio_horror):
			audio_horror.stop()
		for channel: AudioStreamPlayer in [audio_wind,audio_radio,audio_effect,audio_score,audio_rotors]:
			if is_instance_valid(channel):
				channel.stop()
	hud.apply_settings(preferences)
	var error: Error = Preferences.save_settings(preferences,preferences_path)
	if error != OK:
		_notify("Réglages appliqués pour cette session, mais non enregistrés sur le disque.")

func _apply_master_volume() -> void:
	var volume: float = clampf(float(preferences.get("master_volume", 1.0)), 0.0, 1.0)
	AudioServer.set_bus_volume_db(0, -80.0 if volume <= 0.0 else linear_to_db(volume))

func _make_audio() -> void:
	audio_wind = AudioStreamPlayer.new()
	add_child(audio_wind)
	if ResourceLoader.exists("res://assets/audio/wind.wav"):
		var stream: AudioStreamWAV = load("res://assets/audio/wind.wav")
		stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
		stream.loop_end = stream.get_length() * stream.mix_rate
		audio_wind.stream = stream
		audio_wind.volume_db = -13
	audio_radio = AudioStreamPlayer.new()
	add_child(audio_radio)
	if ResourceLoader.exists("res://assets/audio/radio.wav"):
		audio_radio.stream = load("res://assets/audio/radio.wav")
		audio_radio.volume_db = -17
	audio_effect = AudioStreamPlayer.new()
	add_child(audio_effect)
	audio_effect.volume_db = -15
	audio_score = _make_loop("menu_theme",-26)
	audio_rotors = _make_loop("rotors",-29)
	audio_horror = AudioStreamPlayer3D.new()
	audio_horror.name = "UncertainFootsteps"
	add_child(audio_horror)
	audio_horror.stream = load("res://assets/audio/uncertain_steps.wav")
	audio_horror.volume_db = -20.0
	audio_horror.unit_size = 4.0
	audio_horror.max_distance = 18.0

func _make_loop(asset: String, volume: float) -> AudioStreamPlayer:
	var channel: AudioStreamPlayer = AudioStreamPlayer.new()
	add_child(channel)
	var path: String = "res://assets/audio/%s.wav" % asset
	if ResourceLoader.exists(path):
		var stream: AudioStreamWAV = load(path)
		stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
		stream.loop_end = int(stream.get_length() * stream.mix_rate)
		channel.stream = stream
	channel.volume_db = volume
	return channel

func _update_soundscape(delta: float) -> void:
	if DisplayServer.get_name() == "headless":
		return
	var score_on: bool = sound_enabled and (not started or arrival_playing)
	var rotors_on: bool = sound_enabled and (arrival_playing or (started and elapsed < 36.0 and incident.phase == "intact"))
	for record: Array in [[audio_score,score_on,-23.0 if arrival_playing else -26.0],[audio_rotors,rotors_on,-29.0]]:
		var channel: AudioStreamPlayer = record[0]
		if not is_instance_valid(channel) or channel.stream == null:
			continue
		var enabled: bool = record[1]
		var target: float = float(record[2]) if enabled else -60.0
		if enabled and not channel.playing:
			channel.volume_db = -60.0
			channel.play()
		channel.volume_db = move_toward(channel.volume_db,target,maxf(0.0,delta) * 28.0)
		if not enabled and channel.volume_db <= -59.9:
			channel.stop()

func _play_effect(effect: String) -> void:
	if sound_enabled and ResourceLoader.exists("res://assets/audio/%s.wav" % effect):
		audio_effect.stream = load("res://assets/audio/%s.wav" % effect)
		audio_effect.play()

func _exit_tree() -> void:
	if is_instance_valid(audio_horror):
		audio_horror.stop()
	for channel: AudioStreamPlayer in [audio_wind,audio_radio,audio_effect,audio_score,audio_rotors]:
		if is_instance_valid(channel):
			channel.stop()


func _can_use_equipment() -> bool:
	return _can_inspect() and player.is_at_landing() and not epilogue_playing and not boot_playing

func _equipment_target_visible(object: Node3D) -> bool:
	if not is_instance_valid(object) or not object.is_visible_in_tree() or str(object.get_meta("kind", "")) != "equipment":
		return false
	if object not in world_data.get("interactables", []) or int(object.get_meta("floor", 0)) != player.nearest_floor():
		return false
	var focus: Vector3 = object.global_position + (object.get_meta("focus_offset", Vector3(0, 0.85, 0)) as Vector3)
	var origin: Vector3 = player.camera.global_position
	var toward: Vector3 = focus - origin
	if toward.length() > 2.8 or toward.length_squared() < 0.001 or (-player.camera.global_basis.z).dot(toward.normalized()) < 0.86:
		return false
	var query: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(origin, focus)
	query.exclude = [player.get_rid()]
	var hit: Dictionary = get_world_3d().direct_space_state.intersect_ray(query)
	if hit.is_empty():
		return true
	var collider: Node = hit.get("collider")
	return is_instance_valid(collider) and (collider == object or object.is_ancestor_of(collider))

func _select_equipment(id: String) -> void:
	if not _can_use_equipment():
		_notify("Rejoignez un appui stable, les mains libres, pour sortir un outil.")
		return
	if equipment.select_tool(id):
		commerce.cancel()
		_notify(str(Equipment.TITLES[id]) + " en main. Visez un point d’intervention puis maintenez E.")
		equipment_visuals.sample(equipment.snapshot(), true, incident.phase == "aftermath", reduced_motion, elapsed)
		_update_hud()

func _begin_equipment(object: Node3D) -> void:
	if not _can_use_equipment() or not _equipment_target_visible(object) or incident.phase != "aftermath":
		return
	var id: String = _key(object)
	if not equipment.begin(id):
		_notify(equipment.prompt(id))
		return
	_update_hud()

func _process_equipment(delta: float, held_override: int = -1) -> void:
	if not is_instance_valid(equipment_visuals):
		return
	var available: bool = _can_use_equipment()
	var target: Node3D = equipment_visuals.targets.get(equipment.active_id)
	var valid: bool = available and is_instance_valid(target) and _equipment_target_visible(target) and incident.phase == "aftermath"
	var held: bool = Input.is_action_pressed("interact") if held_override < 0 else held_override == 1
	var result: Dictionary = equipment.advance(delta, valid, held)
	if not result.is_empty():
		var id: String = str(result["id"])
		if id not in supplies_used:
			supplies_used.append(id)
			match str(result["reward"]):
				"flare": flares = mini(6, flares + 1)
				"medical": health = minf(100.0, health + 20.0)
		_save_checkpoint(player.nearest_floor())
		_notify(str(result["message"]))
	equipment_visuals.sample(equipment.snapshot(), available and commerce.active_action.is_empty(), incident.phase == "aftermath", reduced_motion, elapsed)
	equipment_visuals.aim_spray(player.camera.to_global(Vector3(0.25, -0.22, -0.5)))


func _begin_commerce() -> void:
	if not started or not completed or paused or epilogue_playing or boot_playing or arrival_playing or not hud.end_panel.visible or hud.journal_panel.visible:
		return
	var previous: Dictionary = commerce.snapshot()
	var previous_seen: Array = seen_floors.duplicate()
	if not commerce.begin({"completed": completed, "floor": player.nearest_floor(), "at_landing": player.is_at_landing(), "continuation": continuation.snapshot()}):
		return
	if 23 not in seen_floors: seen_floors.append(23)
	completed = false
	if not _save_checkpoint(23):
		commerce.restore(previous)
		seen_floors = previous_seen
		completed = true
		hud.end_panel.subtitle_label.text = "Sauvegarde impossible. La reconnaissance au 23 reste conservée ; réessayez la poursuite."
		return
	_restore(Save.load_data(save_path))
	_say("VARGA  /  SUITE DE LA RECONNAISSANCE", "L’escalier sud du 23 rejoint la galerie. Trois nouveaux signaux sont à vérifier : Mina au 22, Théo au 21 et Sofia au 20. Gardez un chemin de retour ; les groupes reçus restent à l’abri.", 13, true)
	_update_hud()


func _commerce_target_visible(object: Node3D) -> bool:
	if commerce.phase != "active" or not _can_inspect() or not player.is_at_landing() or not is_instance_valid(object) or not object.is_visible_in_tree() or object.get_meta("used", false):
		return false
	if object not in world_data.get("interactables", []) or int(object.get_meta("floor", 0)) != player.nearest_floor():
		return false
	var origin: Vector3 = player.camera.global_position
	var focus: Vector3 = object.global_position + (object.get_meta("focus_offset", Vector3(0, 1.2, 0)) as Vector3)
	var toward: Vector3 = focus - origin
	if toward.length() > 3.15 or toward.length_squared() < 0.001 or (-player.camera.global_basis.z).dot(toward.normalized()) < 0.72:
		return false
	var query := PhysicsRayQueryParameters3D.create(origin, focus)
	query.exclude = [player.get_rid()]
	var hit: Dictionary = get_world_3d().direct_space_state.intersect_ray(query)
	if hit.is_empty(): return true
	var collider: Node = hit.get("collider")
	return is_instance_valid(collider) and (collider == object or object.is_ancestor_of(collider) or (str(object.get_meta("kind", "")) == "commerce_person" and collider == object.get_parent()))


func _commerce_action_context(object: Node3D) -> bool:
	if not _commerce_target_visible(object): return false
	if str(object.get_meta("action_id", "")) == "resident":
		return not player.lamp_enabled and player.global_position.distance_to(object.global_position) >= 2.0
	return true


func _interact_commerce(object: Node3D) -> void:
	if not _commerce_target_visible(object): return
	match str(object.get_meta("kind", "")):
		"commerce_action":
			var id: String = str(object.get_meta("action_id", ""))
			if not _commerce_action_context(object) or not commerce.begin_action(id, equipment.selected):
				_notify("Abaissez la lampe et gardez 2 à 3 mètres pour parler." if id == "resident" else commerce.prompt(id, equipment.selected))
			else:
				equipment.cancel()
		"commerce_person":
			var id: String = str(object.get_meta("person_id", ""))
			var first: bool = id not in commerce.state["contacted"]
			if commerce.toggle_person(id):
				commerce_visuals.apply_state(commerce.snapshot())
				if first: _save_checkpoint(player.nearest_floor())
				_notify(str(Commerce.PEOPLE[id]["name"]) + (" vous suit vers le refuge 20. Gardez moins de 5 mètres d’écart." if commerce.person_state(id) == "following" else " attend ici. Revenez et donnez le signal pour reprendre."))
			else:
				_notify("Le volet doit être dégagé." if id == "mina" else "Isolez le réchauffeur et contenez le foyer avant de déplacer Théo.")
		"commerce_clue":
			var id: String = _key(object)
			if Commerce.CLUES.has(id) and id not in clues:
				clues.append(id)
				object.set_meta("used", true)
				_say("ALEX  /  CONSTAT CONSIGNÉ", Commerce.CLUES[id]["text"], 12)
				_save_checkpoint(player.nearest_floor())
		"commerce_finish":
			var previous: Dictionary = commerce.snapshot()
			if not commerce.complete({"floor": player.nearest_floor(), "at_landing": player.is_at_landing(), "clues": clues}):
				_notify("Bilan incomplet : trois personnes reçues au 20, relais alimenté, registre du 22 et consigne du 21 à relever.")
				return
			completed = true
			if not _save_checkpoint(20):
				commerce.restore(previous)
				completed = false
				return
			commerce_visuals.apply_state(commerce.snapshot())
			_show_continuation_debrief()
	_update_hud()


func _process_commerce_action(delta: float, held_override: int = -1) -> void:
	if not is_instance_valid(commerce_visuals): return
	var target: Node3D = commerce_visuals.action_targets.get(commerce.active_action)
	var held: bool = Input.is_action_pressed("interact") if held_override < 0 else held_override == 1
	var result: Dictionary = commerce.advance_action(delta, _commerce_action_context(target), held, equipment.selected)
	if result.is_empty(): return
	commerce_visuals.apply_state(commerce.snapshot())
	_save_checkpoint(player.nearest_floor())
	_notify(str(result["message"]))
	_say("ALEX  /  INTERVENTION", str(result["message"]), 8)


func _process_commerce(delta: float) -> void:
	if commerce.phase != "active" or not started or paused or completed or arrival_playing or not is_instance_valid(commerce_visuals): return
	var running: bool = not player.on_rope and not incident.is_active()
	var allow_unease: bool = player.is_at_landing() and not radio.is_busy() and commerce.active_action.is_empty()
	commerce_visuals.advance(delta, player.global_position, running, allow_unease, player.lamp_enabled, reduced_motion)
	if not player.is_at_landing() or player.nearest_floor() != 20: return
	for id: String in Commerce.PERSON_IDS:
		if commerce.receive(id, player.nearest_floor(), commerce_visuals.physically_arrived(id)):
			commerce_visuals.apply_state(commerce.snapshot())
			_say("VARGA  /  RÉCEPTION AU REFUGE 20", "%s est reçu·e au refuge 20. %d sur 3 nouvelles personnes à l’abri." % [Commerce.PEOPLE[id]["name"], commerce.received_count()], 9, true)
			_save_checkpoint(20)
