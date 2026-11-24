extends Node3D

const Generator = preload("res://scripts/floor_generator.gd")
const World = preload("res://scripts/world_builder.gd")
const Player = preload("res://scripts/player_controller.gd")
const HUD = preload("res://scripts/hud.gd")
const Save = preload("res://scripts/save_store.gd")
const Incident = preload("res://scripts/collapse_director.gd")

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
var flare_light: OmniLight3D
var intro_stage: int = 0
var helicopter_origin: Vector3
var menu_time: float = 0
var save_path: String = "user://save_v1.json"
var incident = Incident.new()
var observation_hold: float = 0.0
var arrival_playing: bool = false
var arrival_time: float = 0.0
const ARRIVAL_DURATION: float = 6.0

func _ready() -> void:
	_bind_inputs()
	_make_audio()
	hud = HUD.new()
	add_child(hud)
	hud.start_requested.connect(_start_new)
	hud.continue_requested.connect(_continue_game)
	hud.resume_requested.connect(_resume)
	hud.return_requested.connect(_return_to_menu)
	hud.setting_changed.connect(_setting_changed)
	_build_world(current_seed)
	_show_menu_camera()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

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
	if is_instance_valid(world):
		world.free()
	if is_instance_valid(player):
		player.free()
	if is_instance_valid(menu_camera):
		menu_camera.free()
	carried = null
	hoisting = null
	nearest = null
	shadow = null
	current_seed = seed_value
	floor_specs = Generator.generate(seed_value)
	world = World.new()
	add_child(world)
	world_data = world.build(seed_value, floor_specs)
	world.apply_incident(incident.phase, incident.phase_elapsed)
	world.set_lightning_enabled(flashes_enabled)
	player = Player.new()
	add_child(player)
	player.position = world_data.get("roof_spawn", Vector3(7,42.2,7))
	player.rotation.y = 0.75
	player.reduced_motion = reduced_motion
	player.lost_footing.connect(_fall_recovery)
	menu_camera = Camera3D.new()
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
	player.active = false
	menu_camera.current = true
	_process_arrival(0.0)
	_say("VARGA  /  APPROCHE ORPHÉE", "Les deux tours sont debout. Alpha sur Aube, Bravo sur Hespérie : des personnels techniques y sont signalés. Alex, votre première victime est au 30.", 11)

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
	intro_stage = 3 if elapsed >= 36.0 or incident.phase == "aftermath" else 0
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
		_complete_game()

func _save_checkpoint(floor_number: int) -> bool:
	# During the incident the preceding safe checkpoint remains authoritative.
	# Never persist a half-collapsed mesh or a transient collider configuration.
	if incident.is_active():
		_notify("La structure bouge. Le point sûr précédent est conservé jusqu’à la stabilisation.")
		return false
	var data: Dictionary = {
		"version": 2, "seed": current_seed, "floor": floor_number,
		"health": health, "oxygen": oxygen, "stress": stress,
		"anchors": anchors, "flares": flares, "rescued": rescued.duplicate(),
		"clues": clues.duplicate(), "supplies_used": supplies_used.duplicate(),
		"elapsed": elapsed, "seen_floors": seen_floors.duplicate(), "completed": completed,
		"incident_state": incident.stable_state()
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
	if not started or completed:
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
		if event.is_action_pressed("interact"):
			_finish_arrival()
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
		_pause(false)
		hud.journal_text.text = _journal_content()
		hud.journal_panel.show()

func _process(delta: float) -> void:
	if paused or completed:
		return
	menu_time += delta
	for rotor: Node3D in world_data.get("rotors", [world_data.get("rotor")]):
		if is_instance_valid(rotor):
			rotor.rotate_y(delta * 28)
	if not started:
		menu_camera.position.x = 95 + sin(menu_time * 0.05) * 5
		menu_camera.look_at(Vector3(6,-8,0))
		return
	elapsed += delta
	radio_time = maxf(0, radio_time - delta)
	notify_time = maxf(0, notify_time - delta)
	radio_cooldown = maxf(0, radio_cooldown - delta)
	damage_cooldown = maxf(0, damage_cooldown - delta)
	flare_time = maxf(0, flare_time - delta)
	hud.radio_panel.visible = radio_time > 0
	hud.notify_label.visible = notify_time > 0
	flare_light.visible = flare_time > 0
	_process_departure()
	if arrival_playing:
		_process_arrival(delta)
		_update_hud()
		return
	_process_hoist(delta)
	var floor_number: int = player.nearest_floor()
	if not player.on_rope and floor_number != last_floor:
		last_floor = floor_number
		_enter_floor(floor_number)
	_process_incident(delta)
	_process_hazards(delta, floor_number)
	_find_nearest()
	_update_hud()
	if health <= 0:
		_fall_recovery()

func _process_arrival(delta: float) -> void:
	arrival_time += delta
	var progress: float = clampf(arrival_time / ARRIVAL_DURATION, 0, 1)
	menu_camera.position = Vector3(77, 64, 68).lerp(Vector3(43, 57, 46), smoothstep(0, 1, progress))
	menu_camera.look_at(Vector3(20, 42, -3))
	if arrival_time >= ARRIVAL_DURATION:
		_finish_arrival()

func _finish_arrival() -> void:
	arrival_playing = false
	player.active = not paused and not completed
	player.camera.current = true
	_notify("AUBE  /  Équipe Alpha  ·  Secourez Ana au restaurant 30. Bravo se déploie sur Hespérie.")

func _process_departure() -> void:
	var helicopters: Array = world_data.get("helicopters", [world_data.get("helicopter")])
	var origins: Array = world_data.get("helicopter_origins", [helicopter_origin])
	for index in range(helicopters.size()):
		var heli: Node3D = helicopters[index]
		if not is_instance_valid(heli):
			continue
		var departure: float = clampf((elapsed - 10.0 - index * 3.0) / 23.0, 0, 1)
		var origin: Vector3 = origins[index]
		heli.global_position = origin + Vector3((100 + index * 20) * departure * departure, 25 * departure, -110 * departure)
		heli.visible = departure < 1 and incident.phase != "aftermath"
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
	for object: Node3D in world_data.get("interactables", []):
		if not is_instance_valid(object) or object.get_meta("used", false):
			continue
		var floor_number: int = int(object.get_meta("floor", 0))
		if floor_number != player.nearest_floor():
			continue
		var distance: float = Vector2(player.position.x - object.global_position.x, player.position.z - object.global_position.z).length()
		if distance < best:
			best = distance
			nearest = object

func _key(object: Node3D) -> String:
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
			_save_checkpoint(25)
			if rescued.size() >= 3 and incident.phase == "aftermath":
				_complete_game()
			elif rescued.size() >= 3:
				_notify("Avant de clore l’intervention, établissez le contact visuel avec Bravo à la baie Est du 29.")
			else:
				_notify("Refuge enregistré. %d personne(s) attendent encore votre aide aux étages 30, 28 ou 26." % (3 - rescued.size()))

func _start_hoist(survivor: Node3D, floor_number: int) -> void:
	hoisting = survivor
	hoist_floor = floor_number
	hoist_progress = 0
	survivor.show()
	survivor.global_position = Vector3(1.8, (floor_number - 24) * 6 + 0.6, 0)
	carried = null
	player.carrying = false
	_say("VARGA  /  TREUIL", "Le harnais est verrouillé. On remonte votre rescapé au poste de secours. Gardez le puits dégagé.", 7)

func _process_hoist(delta: float) -> void:
	if not is_instance_valid(hoisting):
		return
	hoist_progress += delta
	var initial_y: float = (hoist_floor - 24) * 6 + 0.6
	hoisting.position.y = lerpf(initial_y, 44.0, clampf(hoist_progress / 5.0, 0, 1))
	if hoist_progress >= 5:
		var key: String = _key(hoisting)
		if not key in rescued:
			rescued.append(key)
		hoisting.hide()
		hoisting = null
		_play_effect("rescue")
		stress = maxf(0, stress - 15)
		_save_checkpoint(hoist_floor)
		_say("VARGA  /  POSTE DU TOIT", "Rescapé réceptionné. Il est en sécurité avec nous. %d sur 3." % rescued.size(), 8)

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
	if player.nearest_floor() == 26 and clues.size() > 1:
		_say("CANAL SECOURS  /  SOURCE NON IDENTIFIÉE", "Ne remontez pas. Le toit est déjà sous l’eau. ... Alex ? Ne remontez pas.", 8)
		stress = minf(100, stress + 12)
	elif is_instance_valid(carried):
		_say("VARGA  /  POSTE DU TOIT", "Vous avez quelqu’un au harnais. Rejoignez la balise orange du même étage et confirmez le treuillage.", 8)
	elif rescued.size() >= 3:
		if incident.phase == "intact":
			_say("VARGA  /  POSTE D’AUBE", "Les trois rescapés sont ici. Bravo attend votre contact visuel à la baie Est du 29 avant le rapport final.", 8)
		else:
			_say("VARGA  /  POSTE D’AUBE — SIGNAL DÉGRADÉ", "Les trois rescapés sont à l’abri. Rejoignez le refuge 25 et son relais ; il faut retrouver Bravo.", 8)
	elif incident.phase == "aftermath":
		_say("VARGA  /  POSTE D’AUBE — SIGNAL DÉGRADÉ", "... Aube vous reçoit. Le treuil est opérationnel. Contournez les débris Est au 28 par le noyau. Bravo, ici Aube... répondez.", 9)
	elif "survivor_30" in rescued:
		_say("BRAVO  /  HESPÉRIE", "Bravo à Alpha. Ana est à l’abri ? On vous attend à la baie Est du 29. Regardez vers nos lumières.", 9)
	else:
		_say("VARGA  /  POSTE DU TOIT", "Signaux confirmés au restaurant 30, aux archives 28 et au spa 26. La balise orange vous ramène à la corde.", 9)

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
		hud.mission_label.text = "Ramener le rescapé à la balise orange de cet étage."
	elif is_instance_valid(hoisting):
		hud.mission_label.text = "Treuillage en cours. Attendre la confirmation du toit."
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
			hud.prompt_label.text = "E  Confirmer le treuillage du rescapé" if is_instance_valid(carried) else "E  S’attacher à la corde de rappel"
		elif kind == "survivor":
			hud.prompt_label.text = "Attendez la fin de la secousse avant de déplacer le rescapé" if incident.is_active() else "E  Sécuriser %s au harnais" % nearest.get_meta("title", "le rescapé")
		elif kind == "refuge":
			hud.prompt_label.text = "E  Activer le relais du refuge et enregistrer"
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
	var text: String = "OPÉRATION SILLAGE — GRAINE %d\n\n" % current_seed
	text += "Votre mission : secourir les personnes des étages 30, 28 et 26, puis rejoindre le refuge 25. Les treuils évacuent les rescapés au toit ; les hélicoptères attendent une accalmie.\n\n"
	text += "RESCAPÉS AU POSTE DE SECOURS : %d / 3\n\n" % rescued.size()
	if incident.phase == "aftermath":
		text += "SITUATION STRUCTURELLE\nUne réplique a fait basculer Hespérie contre la façade Est d’Aube. Bravo ne répond plus ; son sort n’est pas confirmé. Le noyau, le treuil et le poste d’Aube restent opérationnels. Le passage Est du 28 est condamné : suivre le détour intérieur. Les victimes déjà réceptionnées restent à l’abri.\n\n"
	else:
		text += "SITUATION STRUCTURELLE\nDeux tours debout à notre arrivée. Alpha intervient sur Aube ; Bravo vérifie des signaux dans Hespérie. Après le sauvetage d’Ana au 30, rejoindre la baie Est du 29 pour établir le contact visuel.\n\n"
	for spec: Dictionary in floor_specs:
		if "evidence_%d" % int(spec["number"]) in clues:
			text += "%s — ÉTAGE %d\n%s\n\n" % [spec["evidence_title"], spec["number"], spec["evidence_text"]]
	if clues.is_empty():
		text += "Aucun indice collecté. Les documents sont éclairés d’une lueur bleue.\n\n"
	text += "MATÉRIEL\nLa lampe ne consomme pas de pile dans ce prototype. L’air diminue dans la fumée. Une fusée éclaire et repousse la silhouette pendant 20 secondes. X stabilise le balancement sur corde sans couper votre ligne principale.\n\nPOINTS SÛRS\nUn rescapé treuillé crée un point de reprise. Le refuge25 enregistre également votre progression."
	return text

func _complete_game() -> void:
	completed = true
	_save_checkpoint(25)
	player.active = false
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	hud.end_panel.show()
	hud.completion_text.text = "Intervention terminée en %02d min %02d s.\nTrois vies sauvées. %d indices récupérés sur trois.\n\nHespérie reste appuyée contre Aube. Le relais accroche\nune voix disparue au moment de l’impact :\n« Bravo à Aube. On vous voit à la baie Est... »\nPuis : « Nous sommes au 24. Il y a de la lumière dessous. »\n\nLe message est-il en direct ? Un enfant appelle\nà son tour depuis Hespérie." % [int(elapsed) / 60, int(elapsed) % 60, clues.size()]

func _fall_recovery() -> void:
	var data: Dictionary = Save.load_data(save_path)
	if data.is_empty():
		_start_new(current_seed)
	else:
		_restore(data)
	_say("VARGA  /  REPRISE AU POINT SÛR", "Intervention reprise au dernier point enregistré. Attachez-vous à la balise avant d’entrer dans le puits.", 10)

func _pause(show_panel: bool = true) -> void:
	paused = true
	player.active = false
	world.set_process(false)
	hud.pause_panel.visible = show_panel
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _resume() -> void:
	paused = false
	player.active = not arrival_playing and not completed
	world.set_process(true)
	hud.set_paused(false)
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _return_to_menu() -> void:
	started = false
	paused = false
	completed = false
	arrival_playing = false
	incident.restore("intact")
	hud.show_menu()
	_build_world(current_seed)
	_show_menu_camera()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	if is_instance_valid(audio_wind):
		audio_wind.stop()

func _notify(message: String) -> void:
	hud.notify_label.text = message
	notify_time = 6
	hud.notify_label.show()

func _say(speaker: String, message: String, seconds: float = 8.0, priority: bool = false) -> void:
	if incident.is_active() and not priority:
		return
	hud.set_radio(speaker, message)
	radio_time = seconds
	if sound_enabled and is_instance_valid(audio_radio):
		audio_radio.play()

func _setting_changed(setting: String, enabled: bool) -> void:
	match setting:
		"reduced_motion":
			reduced_motion = enabled
			player.reduced_motion = enabled
		"flashes":
			flashes_enabled = enabled
			# World lightning is optional; no flashes are required for progression.
			if world.has_method("set_lightning_enabled"):
				world.set_lightning_enabled(enabled)
		"audio":
			sound_enabled = enabled
			AudioServer.set_bus_mute(0, not enabled)
			if enabled and started:
				audio_wind.play()

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

func _play_effect(effect: String) -> void:
	if sound_enabled and ResourceLoader.exists("res://assets/audio/%s.wav" % effect):
		audio_effect.stream = load("res://assets/audio/%s.wav" % effect)
		audio_effect.play()
