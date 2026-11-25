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

var rescue_visuals: Node3D
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
var shadow: Node3D
var shadow_time: float = 0
var damage_cooldown: float = 0
var flashes_enabled: bool = false
var sound_enabled: bool = true
var reduced_motion: bool = true
var audio_wind: AudioStreamPlayer
var audio_radio: AudioStreamPlayer
var audio_effect: AudioStreamPlayer
var audio_score: AudioStreamPlayer
var audio_rotors: AudioStreamPlayer
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
	hud.inspection_closed.connect(_resume)
	hud.apply_settings(preferences)
	_prepare_menu()
	if DisplayServer.get_name() != "headless" and bool(preferences["startup_intro"]):
		_start_studio_intro()

func _prepare_menu() -> void:
	# A menu is a preview of the last validated checkpoint, never a new save.
	menu_snapshot = Save.load_data(save_path)
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
			target.hide()
			target.set_meta("used",true)
	if not menu_snapshot.is_empty():
		_position_helicopters(float(menu_snapshot.get("elapsed",0)))
	_show_menu_camera()
	_apply_camera_sample(Cinematics.menu_camera(menu_context,menu_time,reduced_motion))
	hud.show_menu()
	hud.set_menu_context(menu_context,not menu_snapshot.is_empty(),current_seed)
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
		"radio": [KEY_R], "journal": [KEY_J], "anchor": [KEY_X], "pause_game": [KEY_ESCAPE]
	}
	for action in keys:
		if not InputMap.has_action(action):
			InputMap.add_action(action)
		for key in keys[action]:
			var event: InputEventKey = InputEventKey.new()
			event.keycode = key
			InputMap.action_add_event(action, event)

func _build_world(seed_value: int) -> void:
	epilogue_playing = false
	epilogue.finish()
	epilogue_voice_key = ""
	rescue_visuals = null
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
	shadow = null
	current_seed = seed_value
	floor_specs = Generator.generate(seed_value)
	world = World.new()
	add_child(world)
	world_data = world.build(seed_value, floor_specs)
	world_data["interactables"].append_array(FieldProps.new().build(world))
	world.set_rescued_people(rescued)
	world.apply_incident(incident.phase, incident.phase_elapsed)
	world.set_lightning_enabled(flashes_enabled)
	world.set_reduced_motion(reduced_motion)
	player = Player.new()
	add_child(player)
	player.position = world_data.get("roof_spawn", Vector3(7,42.2,7))
	player.rotation.y = 0.75
	player.apply_comfort(preferences)
	rescue_visuals = RescuePresentation.new()
	world.add_child(rescue_visuals)
	rescue_visuals.build(world, player.camera)
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
	# A new attempt does not erase the previous checkpoint until a new one is valid.
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
	shadow_time = 0
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
	_restore(data)
	if not completed:
		_say("VARGA  /  POSTE DU TOIT", "Point sûr rétabli. Votre compte rendu est à jour. Vérifiez votre matériel avant de continuer.", 8)

func _restore(data: Dictionary) -> void:
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
	shadow_time = 0
	flare_time = 0
	for target: Node3D in world_data.get("interactables", []):
		var key: String = _key(target)
		if key in rescued or key in clues or key in supplies_used:
			target.hide()
			target.set_meta("used", true)
	_begin_game()
	player.teleport_to_floor(checkpoint_floor)
	_process_departure()
	if completed:
		_complete_game(false)

func _save_checkpoint(floor_number: int) -> bool:
	# During the incident the preceding safe checkpoint remains authoritative.
	# Never persist a half-collapsed mesh or a transient collider configuration.
	if incident.is_active():
		_notify("La structure bouge. Le point sûr précédent est conservé jusqu’à la stabilisation.")
		return false
	var data: Dictionary = {
		"version": 3, "seed": current_seed, "floor": floor_number,
		"health": health, "oxygen": oxygen, "stress": stress,
		"anchors": anchors, "flares": flares, "rescued": rescued.duplicate(),
		"clues": clues.duplicate(), "supplies_used": supplies_used.duplicate(),
		"elapsed": elapsed, "seen_floors": seen_floors.duplicate(), "completed": completed,
		"incident_state": incident.stable_state(),
		"transmissions": radio.history_snapshot(), "radio_events": radio_events.duplicate()
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
	if event.is_action_pressed("interact"):
		_interact()
	elif event.is_action_pressed("flashlight"):
		player.lamp_enabled = not player.lamp_enabled
	elif event.is_action_pressed("flare"):
		_use_flare()
	elif event.is_action_pressed("anchor"):
		if player.on_rope and anchors > 0:
			anchors -= 1
			player.secure_anchor()
			_notify("Ancrage secondaire posé  ·  Balancement stabilisé pendant 16 secondes")
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
	if not player.on_rope and floor_number != last_floor:
		last_floor = floor_number
		_enter_floor(floor_number)
	_process_incident(delta)
	_process_hazards(delta, floor_number)
	_process_story_radio(quiet_radio_delta)
	_find_nearest()
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
	var spec: Dictionary = _floor_spec(number)
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
		if not is_instance_valid(shadow):
			shadow = world.create_shadow(26)
			shadow.visible = false
		shadow_time = 0
		if first:
			_say("NORA HADDAD  /  SPA", "Ne laissez pas la silhouette approcher. La lumière rouge l’a fait reculer. Il y a une fusée dans votre équipement.", 10)
	elif number == 25:
		_say("VARGA  /  REFUGE 25", "Votre signal est propre. Le local technique est sécurisé. Activez son relais pour terminer l’intervention.", 9)
	if first and spec.get("anomaly", "none") == "radio" and number != 26:
		stress = minf(100, stress + 9)

func _process_hazards(delta: float, floor_number: int) -> void:
	player.environment_speed = 1.0
	# The catastrophe is a witnessed event, not an unavoidable damage timer.
	if incident.is_active():
		if is_instance_valid(shadow):
			shadow.hide()
		return
	if player.on_rope:
		stress = minf(100, stress + delta * 0.025)
		if is_instance_valid(shadow):
			shadow.hide()
		return
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
	if is_instance_valid(shadow):
		if floor_number == 26:
			shadow_time += delta
			shadow.visible = shadow_time > 4 and flare_time <= 0
			if shadow.visible:
				var target: Vector3 = Vector3(player.position.x, 12, player.position.z)
				var speed: float = 0.72 if player.lamp_enabled else 1.1
				shadow.position = shadow.position.move_toward(target, delta * speed)
				stress = minf(100, stress + delta * 0.9)
				if shadow.position.distance_to(player.position) < 2.0 and damage_cooldown <= 0:
					health = maxf(0, health - 12)
					damage_cooldown = 3
					_notify("La silhouette vous atteint. Une fusée rouge la repousse. G")
					shadow.position = Vector3(-7,12,-7)
			elif flare_time > 0:
				shadow.position = Vector3(-8,12,-8)
		else:
			shadow.hide()

func _find_nearest() -> void:
	nearest = null
	if player.on_rope:
		return
	var best: float = 3.0
	var inspection: Node3D
	var inspection_distance: float = 2.4
	for object: Node3D in world_data.get("interactables", []):
		if not is_instance_valid(object) or object.get_meta("used", false) or not object.is_visible_in_tree():
			continue
		var floor_number: int = int(object.get_meta("floor", 0))
		if floor_number != player.nearest_floor():
			continue
		var distance: float = Vector2(player.position.x - object.global_position.x, player.position.z - object.global_position.z).length()
		if str(object.get_meta("kind", "")) == "inspect":
			if distance < inspection_distance and _can_inspect() and _interaction_visible(object):
				inspection_distance = distance
				inspection = object
			continue
		if distance < best:
			best = distance
			nearest = object
	# Rescue controls retain their close-range priority; optional reading requires aim.
	if is_instance_valid(inspection) and best >= 1.5:
		nearest = inspection

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
	if str(object.get_meta("kind", "")) == "inspect":
		return str(object.get_meta("id", ""))
	return "%s_%d" % [str(object.get_meta("kind", "unknown")), int(object.get_meta("floor", 0))]

func _interact() -> void:
	if player.on_rope:
		if player.can_exit_rope():
			player.leave_rope(player.nearest_floor())
		else:
			_notify("Alignez-vous sur une dalle avant de quitter la corde.")
		return
	if is_instance_valid(nearest):
		_interact_node(nearest)

func _interact_node(object: Node3D) -> void:
	if object.get_meta("used", false):
		return
	var kind: String = object.get_meta("kind", "")
	var floor_number: int = int(object.get_meta("floor", 0))
	if incident.is_active() and kind == "survivor":
		_notify("La secousse continue. Restez près du rescapé ; le portage reprend dès la stabilisation.")
		return
	match kind:
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
				_start_hoist(carried, floor_number)
			elif is_instance_valid(hoisting):
				_notify("Attendez que le treuil ait déposé le rescapé au toit.")
			else:
				player.engage_rope(floor_number)
				_notify("S : descendre  ·  Z/W : remonter  ·  E : se poser à hauteur d’un étage")
		"survivor":
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
			if rescued.size() >= 3 and incident.phase == "aftermath":
				_complete_game()
			elif rescued.size() >= 3:
				_save_checkpoint(25)
				_notify("Avant de clore l’intervention, établissez le contact visuel avec Bravo à la baie Est du 29.")
			else:
				_save_checkpoint(25)
				_notify("Refuge enregistré. %d personne(s) attendent encore votre aide aux étages 30, 28 ou 26." % (3 - rescued.size()))

func _start_hoist(survivor: Node3D, floor_number: int) -> void:
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
	if is_instance_valid(carried):
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
		_say("VARGA  /  POSTE DU TOIT", "Signaux confirmés au restaurant 30, aux archives 28 et au spa 26. La balise orange vous ramène à la corde.", 9)

func _process_story_radio(quiet_delta: float) -> void:
	if not started or paused or completed or arrival_playing or incident.phase != "aftermath" or "survivor_28" not in rescued:
		radio_quiet_time = 0.0
		return
	if player.on_rope or is_instance_valid(carried) or is_instance_valid(hoisting) or radio.is_busy():
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
	var spec: Dictionary = _floor_spec(floor_number)
	var display_names: Dictionary = {31:"Poste de commandement",30:"Restaurant panoramique",29:"Suites de Nacre",28:"Bureaux et archives",27:"Jardin des enfants",26:"Spa et piscine",25:"Refuge technique"}
	var name_text: String = display_names.get(floor_number, "Puits de rappel")
	hud.location_label.text = ("TOIT" if floor_number == 31 else "ÉTAGE %02d" % floor_number) + "  ·  " + name_text
	var atmosphere: String = "LIAISON RADIO ACTIVE"
	if player.on_rope:
		atmosphere = "RAPPEL  /  FREIN ENGAGÉ"
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
	hud.depth_label.text = "ALT. %d m  ·  %s" % [int(player.position.y + 132), atmosphere]
	hud.health_bar.value = health
	hud.oxygen_bar.value = oxygen
	hud.stress_bar.value = stress
	hud.resources_label.text = "ANCRAGES %d  /  FUSÉES %d" % [anchors, flares]
	hud.status_label.text = "RESCAPÉS %d / 3    •    INDICES %d / 3" % [rescued.size(), clues.size()]
	if arrival_playing:
		hud.mission_label.text = "Approche des deux tours  ·  Alpha sur Aube, Bravo sur Hespérie."
	elif incident.is_active():
		hud.mission_label.text = "Éloignez-vous des vitres. Le noyau et la ligne de rappel tiennent."
	elif is_instance_valid(carried):
		hud.mission_label.text = "Ramener %s à la balise orange de cet étage." % str(carried.get_meta("title", "le rescapé"))
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
		hud.prompt_label.text = "S  Descendre   •   Z/W  Remonter   •   X  Ancrage\n" + ("E  Se poser au " + ("toit" if floor_number == 31 else "niveau %d" % floor_number) if player.can_exit_rope() else "Alignez-vous sur un étage pour quitter la corde")
	elif is_instance_valid(nearest):
		var kind: String = nearest.get_meta("kind", "")
		if kind == "beacon":
			hud.prompt_label.text = "Treuillage en cours  ·  Attendre la réception" if is_instance_valid(hoisting) else ("E  Confirmer le treuillage du rescapé" if is_instance_valid(carried) else "E  S’attacher à la corde de rappel")
		elif kind == "survivor":
			hud.prompt_label.text = "Attendez la fin de la secousse avant de déplacer le rescapé" if incident.is_active() else "E  Sécuriser %s au harnais" % nearest.get_meta("title", "le rescapé")
		elif kind == "refuge":
			hud.prompt_label.text = "E  Activer le relais du refuge et enregistrer"
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
	for n: int in [31,30,29,28,27,26,25]:
		var title: String = {31:"TOIT",30:"RESTAURANT",29:"SUITES",28:"ARCHIVES",27:"JARDIN",26:"SPA",25:"REFUGE"}[n]
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
	text += "\nMATÉRIEL\nLa lampe ne consomme pas de pile dans ce prototype. L’air diminue dans la fumée. Une fusée éclaire et repousse la silhouette pendant 20 secondes. X stabilise le balancement sur corde sans couper votre ligne principale.\n\nPOINTS SÛRS\nUn rescapé treuillé crée un point de reprise. Le refuge 25 enregistre également votre progression."
	text += "\n\nOBSERVATIONS DE TERRAIN\nDouze objets peuvent être examinés du toit au refuge. Approchez-vous et regardez-les pour afficher E. Leur fiche distingue usage, constat et consigne, selon la situation actuelle. La lecture met l’intervention en pause ; Fermer ou Échap reprend le jeu. Ces observations restent facultatives et ne consomment aucun matériel."
	return text

func _dossier_snapshot() -> Dictionary:
	# Project only the records actually collected in this intervention. Unread
	# clue titles and texts never enter the journal panel's model.
	var records: Array[Dictionary] = []
	for spec: Dictionary in floor_specs:
		var id: String = "evidence_%d" % int(spec["number"])
		if id in clues:
			records.append({"id": id, "floor": int(spec["number"]),
				"title": str(spec["evidence_title"]), "text": str(spec["evidence_text"])})
	return {
		"seed": current_seed, "floor": player.nearest_floor(), "checkpoint_floor": checkpoint_floor,
		"rescued": rescued.duplicate(), "clues": clues.duplicate(), "clue_records": records,
		"supplies_used": supplies_used.duplicate(), "elapsed": elapsed,
		"health": health, "oxygen": oxygen, "stress": stress, "anchors": anchors, "flares": flares,
		"seen_floors": seen_floors.duplicate(), "completed": completed,
		"incident_state": incident.phase, "transmissions": radio.history_snapshot(),
		"carried_id": _key(carried) if is_instance_valid(carried) else "",
		"hoisting_id": _key(hoisting) if is_instance_valid(hoisting) else ""
	}

func _complete_game(play_epilogue: bool = true) -> void:
	if not started or incident.phase != "aftermath" or player.nearest_floor() != 25:
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
	if not completed or paused or epilogue_playing:
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
	if not started or not completed or paused or epilogue_playing or not hud.end_panel.visible:
		return
	_start_epilogue()

func _fall_recovery() -> void:
	var data: Dictionary = Save.load_data(save_path)
	if data.is_empty():
		_start_new(current_seed)
	else:
		_restore(data)
	_say("VARGA  /  REPRISE AU POINT SÛR", "Intervention reprise au dernier point enregistré. Attachez-vous à la balise avant d’entrer dans le puits.", 10)

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
	for channel: AudioStreamPlayer in [audio_wind,audio_radio,audio_effect,audio_score,audio_rotors]:
		if is_instance_valid(channel):
			channel.stream_paused = true
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
	AudioServer.set_bus_mute(0,not sound_enabled)
	_apply_master_volume()
	if DisplayServer.get_name() != "headless" and sound_enabled and is_instance_valid(audio_wind) and not audio_wind.playing:
		audio_wind.play()
		audio_wind.stream_paused = paused
	if not sound_enabled:
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
	for channel: AudioStreamPlayer in [audio_wind,audio_radio,audio_effect,audio_score,audio_rotors]:
		if is_instance_valid(channel):
			channel.stop()
