extends RefCounted
class_name DescentEpilogueDirector

## Read-only closing sequence. It samples the already completed intervention;
## mission completion, the received-radio ledger and saves stay owned by main.
const DURATION: float = 15.0
const SHOT_DURATION: float = 5.0
const FADE_DURATION: float = 0.35
const CUES: Array[Dictionary] = [
	{"from": 0.45, "until": 4.7, "speaker": "VARGA  /  POSTE MÉDICAL", "message": "Ana, Samuel et Nora sont au poste médical. Votre ligne tient."},
	{"from": 5.4, "until": 9.7, "speaker": "RELAIS 25  /  FRAGMENT BRAVO", "message": "Bravo à Aube. On vous voit à la baie Est…"},
	{"from": 10.4, "until": 14.7, "speaker": "RELAIS 25  /  ORIGINE NON CONFIRMÉE", "message": "Nous sommes au 24. Il y a de la lumière dessous."}
]

var elapsed: float = 0.0
var active: bool = false

func start() -> void:
	elapsed = 0.0
	active = true

func duration() -> float:
	return DURATION

func advance(delta: float) -> void:
	# Ignore invalid deltas rather than poisoning every subsequent camera sample.
	if not active or not is_finite(delta) or delta <= 0.0:
		return
	elapsed = minf(DURATION, _sample_time(elapsed) + delta)
	active = elapsed < DURATION

func finish() -> void:
	elapsed = DURATION
	active = false

static func _sample_time(value: float) -> float:
	return clampf(value, 0.0, DURATION) if not is_nan(value) else 0.0

func presentation() -> Dictionary:
	var time: float = _sample_time(elapsed)
	var shot: int = mini(2, int(time / SHOT_DURATION))
	var local: float = time - shot * SHOT_DURATION
	var titles: Array[String] = ["TROIS VIES À L’ABRI", "LE RELAIS RÉPOND", "SOUS NOS PIEDS"]
	var places: Array[String] = [
		"AUBE  /  POSTE MÉDICAL DU TOIT",
		"REFUGE 25  /  LIAISON SÉCURISÉE",
		"HESPÉRIE  /  ORIGINE DU SIGNAL INCERTAINE"
	]
	var dialogue: Dictionary = transmission()
	return {
		"card": "epilogue", "eyebrow": "OPÉRATION ORPHÉE  /  SIGNAL DU RELAIS",
		"title": titles[shot], "subtitle": places[shot], "shot": shot,
		"alpha": clampf(minf(local / 0.65, (SHOT_DURATION - local) / 0.65), 0.0, 1.0),
		"fade": 1.0 - clampf(minf(local / FADE_DURATION, (SHOT_DURATION - local) / FADE_DURATION), 0.0, 1.0),
		"progress": time / DURATION,
		"speaker": dialogue.get("speaker", ""), "message": dialogue.get("message", "")
	}

func transmission() -> Dictionary:
	# This is a displayed excerpt, never an event queue. Sampling/replaying cannot
	# invent a received mission transmission or duplicate an entry in radio.history.
	var time: float = _sample_time(elapsed)
	for cue: Dictionary in CUES:
		if time >= float(cue["from"]) and time < float(cue["until"]):
			return {"speaker": str(cue["speaker"]), "message": str(cue["message"])}
	return {"speaker": "", "message": ""}

func camera_sample(reduced_motion: bool = false) -> Dictionary:
	var time: float = _sample_time(elapsed)
	var shot: int = mini(2, int(time / SHOT_DURATION))
	var local: float = clampf((time - shot * SHOT_DURATION) / SHOT_DURATION, 0.0, 1.0)
	var blend: float = 0.5 if reduced_motion else smoothstep(0.0, 1.0, local)
	match shot:
		0:
			# Below the canopy roof, inside its open front, facing the real medical
			# registry. No figure is created or repositioned for this shot.
			return {"position": Vector3(7.6, 44.1, -5.0).lerp(Vector3(7.9, 44.05, -5.4), blend),
				"target": Vector3(8.15, 43.0, -9.15), "fov": 62.0}
		1:
			# The actual refuge terminal is at (7, 6, 6), with its lit front at
			# z=6.49. This protected south-side pocket is independent of room variants.
			return {"position": Vector3(10.25, 8.25, 9.6).lerp(Vector3(9.65, 8.05, 9.0), blend),
				"target": Vector3(7.0, 7.15, 6.1), "fov": 51.0}
		_:
			# Both towers and their settled contact remain visible. The camera does
			# not enter Hespérie or suggest that the unbuilt 24th floor is playable.
			return {"position": Vector3(75, 42, 91).lerp(Vector3(72, 40, 87), blend),
				"target": Vector3(16, 17, -5), "fov": 56.0}

static func debrief_camera() -> Dictionary:
	# Fixed contextual refuge framing for the dossier after the closing sequence.
	return {"position": Vector3(10.2, 8.3, 8.9), "target": Vector3(-5.0, 7.8, -4.5), "fov": 68.0}
