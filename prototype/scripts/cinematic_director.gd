extends RefCounted
class_name DescentCinematicDirector

## A sampled timeline. No Tween owns mission state or saves a transient camera.
const BOOT_DURATION: float = 15.0
const ARRIVAL_DURATION: float = 28.0
const STUDIO: String = "Darknigthmare Kingdoms Games Productions"
const ARRIVAL_CUES: Array = [
	{"at": 0.6, "speaker": "HÉLIX 2  /  APPROCHE NACRE", "message": "Nacre en vue. La ville est sous les eaux. Les deux tours sont toujours debout.", "duration": 6.4},
	{"at": 7.2, "speaker": "VARGA  /  OPÉRATION ORPHÉE", "message": "Alpha sur Aube, Bravo sur Hespérie. On vérifie chaque signal. Aucun étage n’est déclaré sûr.", "duration": 6.4},
	{"at": 14.2, "speaker": "BRAVO  /  ÉQUIPE HESPÉRIE", "message": "Bravo posé. Nous voyons votre équipe de l’autre côté. On reste en contact.", "duration": 6.0},
	{"at": 21.0, "speaker": "VARGA  /  POSTE D’AUBE", "message": "Alex, le repère bleu à l’ouest engage le rappel vers le 30. Ana Rios vous attend au restaurant.", "duration": 7.0}
]

var mode: String = ""
var elapsed: float = 0.0
var active: bool = false
var cue_cursor: int = 0

func start(sequence: String) -> void:
	mode = sequence if sequence in ["boot", "arrival"] else ""
	elapsed = 0.0
	cue_cursor = 0
	active = not mode.is_empty()

func duration() -> float:
	return BOOT_DURATION if mode == "boot" else ARRIVAL_DURATION if mode == "arrival" else 0.0

func advance(delta: float) -> Array[Dictionary]:
	var events: Array[Dictionary] = []
	if not active:
		return events
	elapsed = minf(duration(), elapsed + maxf(0.0, delta))
	if mode == "arrival":
		while cue_cursor < ARRIVAL_CUES.size() and float(ARRIVAL_CUES[cue_cursor]["at"]) <= elapsed:
			events.append(ARRIVAL_CUES[cue_cursor].duplicate(true))
			cue_cursor += 1
	active = elapsed < duration()
	return events

func finish() -> void:
	elapsed = duration()
	active = false
	cue_cursor = ARRIVAL_CUES.size()

static func _card_alpha(time: float, begin: float, end: float) -> float:
	return clampf(minf((time - begin) / 0.65, (end - time) / 0.65), 0.0, 1.0)

func presentation() -> Dictionary:
	if mode == "boot":
		if elapsed < 3.6:
			return {"card": "studio", "eyebrow": "DARKNIGTHMARE", "title": "KINGDOMS GAMES", "subtitle": "P R O D U C T I O N S", "alpha": _card_alpha(elapsed, 0.0, 3.6), "progress": elapsed / BOOT_DURATION}
		if elapsed < 5.6:
			return {"card": "presents", "eyebrow": "", "title": "présente", "subtitle": "", "alpha": _card_alpha(elapsed, 3.6, 5.6), "progress": elapsed / BOOT_DURATION}
		if elapsed < 8.0:
			return {"card": "author", "eyebrow": "UN JEU DE", "title": "Darknigthmare", "subtitle": "", "alpha": _card_alpha(elapsed, 5.6, 8.0), "progress": elapsed / BOOT_DURATION}
		return {"card": "title", "eyebrow": "", "title": "THE TOWER\nDESCENT", "subtitle": "Chaque vie compte. Chaque étage vous éloigne du ciel.", "alpha": _card_alpha(elapsed, 8.0, BOOT_DURATION), "progress": elapsed / BOOT_DURATION}
	var shot: int = mini(3, int(elapsed / 7.0))
	var titles: Array[String] = ["ÎLE DE NACRE", "LES TOURS ORPHÉE", "DEUX ÉQUIPES", "VOTRE LIGNE TIENT"]
	var subtitles: Array[String] = ["04:17  /  PREMIÈRE ROTATION DE SECOURS", "AUBE  /  HESPÉRIE", "ALPHA SUR AUBE  /  BRAVO SUR HESPÉRIE", "AUBE  /  POSTE DE COMMANDEMENT"]
	return {"card": "arrival", "eyebrow": "OPÉRATION ORPHÉE", "title": titles[shot], "subtitle": subtitles[shot], "alpha": _card_alpha(elapsed, shot * 7.0, shot * 7.0 + 7.0), "progress": elapsed / ARRIVAL_DURATION, "shot": shot}

func camera_sample(reduced_motion: bool = false, landing: Vector3 = Vector3(7,43.85,7), facing: Vector3 = Vector3(-0.6816,0,-0.7317), gameplay_fov: float = 76.0) -> Dictionary:
	if mode == "boot":
		var t: float = 0.5 if reduced_motion else smoothstep(0.0, 1.0, elapsed / BOOT_DURATION)
		return {"position": Vector3(115,73,145).lerp(Vector3(84,64,105), t), "target": Vector3(16,-10,-4), "fov": 53.0}
	var shot: int = mini(3, int(elapsed / 7.0))
	var local: float = clampf((elapsed - shot * 7.0) / 7.0, 0.0, 1.0)
	var p: float = 0.5 if reduced_motion else smoothstep(0.0, 1.0, local)
	match shot:
		0:
			return {"position": Vector3(128,78,152).lerp(Vector3(98,70,118), p), "target": Vector3(12,1,0), "fov": 56.0}
		1:
			return {"position": Vector3(80,62,54).lerp(Vector3(40,54,46), p), "target": Vector3(16,45,0), "fov": 53.0}
		2:
			return {"position": Vector3(34,53,30).lerp(Vector3(27,51,30), p), "target": Vector3(16,43,-5), "fov": 64.0}
		_:
			if reduced_motion:
				return {"position": Vector3(6,48,16), "target": Vector3(5,43.7,0), "fov": 62.0}
			# Only the final moving bridge matches the player’s chosen lens.
			# Other shots and reduced-motion fixed framing keep their authored FOV.
			var handoff_fov: float = clampf(gameplay_fov, 65.0, 100.0) if is_finite(gameplay_fov) else 76.0
			return {"position": Vector3(6,49,18).lerp(landing, p), "target": Vector3(4,43.7,0).lerp(landing + facing * 10.0, p), "fov": lerpf(62.0, handoff_fov, p)}

static func staging_sample(time: float) -> Dictionary:
	# Absolute poses make pausing, large frames and skipping converge on one state.
	# Flights remain above the roof until the final vertical descent; Bravo lands first.
	var t: float = clampf(time, 0.0, ARRIVAL_DURATION)
	var aircraft: Array[Dictionary] = []
	for index in range(2):
		var touchdown: float = 13.4 if index == 0 else 10.8
		var approach_end: float = 8.0 if index == 0 else 6.5
		var start: Vector3 = Vector3(-34,28,110) if index == 0 else Vector3(65,36,130)
		var hover: Vector3 = Vector3(0,5.6,8.0)
		var cruise: float = smoothstep(0.0, approach_end, t)
		var descent: float = smoothstep(approach_end, touchdown, t)
		var offset: Vector3 = start.lerp(hover, cruise) if t < approach_end else hover.lerp(Vector3.ZERO, descent)
		var banking: float = sin(cruise * PI) * (1.0 - descent)
		var rotation: Vector3 = Vector3(-0.075 * (1.0 - descent), 0.12 * banking * (-1.0 if index == 0 else 1.0), 0.06 * banking)
		var door_open: float = smoothstep(touchdown + 0.4, touchdown + 2.6, t)
		var door_close: float = smoothstep(24.0, 26.0, t)
		var wash: float = smoothstep(approach_end - 1.0, touchdown, t) * (1.0 - smoothstep(23.0, 28.0, t))
		aircraft.append({"offset":offset, "rotation":rotation, "door":door_open * (1.0 - door_close), "wash":wash})
	return {"aircraft":aircraft, "crew":smoothstep(16.0,23.0,t), "time":t}

static func menu_context(data: Dictionary) -> Dictionary:
	if data.is_empty():
		return {"id":"approach", "floor":31, "title":"AVANT L’INTERVENTION", "detail":"Deux tours debout. Des vies à retrouver.", "incident":"intact", "rescued":0, "elapsed":0.0}
	var floor_number: int = int(data.get("floor",31))
	var after: bool = str(data.get("incident_state","intact")) == "aftermath"
	var complete: bool = bool(data.get("completed",false))
	var names: Dictionary = {31:"POSTE DU TOIT",30:"RESTAURANT PANORAMIQUE",29:"SUITES DE NACRE",28:"ARCHIVES D’AUBE",27:"JARDIN DES ENFANTS",26:"SPA DE NACRE",25:"REFUGE TECHNIQUE"}
	return {"id":"refuge" if complete else "roof" if floor_number == 31 else "floor", "floor":floor_number, "title": "INTERVENTION TERMINÉE" if complete else names.get(floor_number,"POINT SÛR"), "detail":"Le relais tient. La suite vous attend." if complete else "Signal dégradé. Les secours continuent." if after else "Alpha et Bravo sont en liaison.", "incident":"aftermath" if after else "intact", "rescued":data.get("rescued",[]).size(), "elapsed":float(data.get("elapsed",0.0))}

static func menu_camera(context: Dictionary, time: float, reduced_motion: bool) -> Dictionary:
	var position: Vector3 = Vector3(91,64,113)
	var target: Vector3 = Vector3(19,-7,-3)
	var fov: float = 52.0
	var floor_number: int = int(context.get("floor",31))
	match str(context.get("id","approach")):
		"roof":
			position = Vector3(21,52,21)
			target = Vector3(1,43.5,-5)
			fov = 59.0
		"floor", "refuge":
			var y: float = float(floor_number - 24) * 6.0
			position = Vector3(10.2,y+2.3,8.9)
			target = Vector3(-5.0,y+1.8,-4.5)
			fov = 68.0
			if floor_number == 29 and context.get("incident") == "aftermath":
				position = Vector3(7.4,y+2.0,3.1)
				target = Vector3(42,31,-6)
				fov = 64.0
	if not reduced_motion:
		position += Vector3(sin(time * 0.075) * 0.75, sin(time * 0.045) * 0.18, cos(time * 0.075) * 0.35)
	return {"position":position, "target":target, "fov":fov}
