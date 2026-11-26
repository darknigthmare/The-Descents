extends RefCounted
class_name DescentResidentialDirector
## Authored A19–A17 rescue chapter. Durable receipts are separate from held
## work, radio-entry attempts and physical escort progress.

const PERSON_IDS: Array[String] = ["jeanne", "marc", "ines"]
const RELAY_DESTINATION: String = "AUBE-20"
const RELAY_REFERENCE: String = "NACRE-204"
const PEOPLE: Dictionary = {
	"jeanne": {"name": "Jeanne Morel", "floor": 19, "role": "Résidente des appartements hauts"},
	"marc": {"name": "Marc Morel", "floor": 18, "role": "Conjoint de Jeanne, retrouvé dans le duplex"},
	"ines": {"name": "Inès Vidal", "floor": 17, "role": "Technicienne du relais local"}
}
const CLUES: Dictionary = {
	"residential_visits_19": {"floor": 19, "title": "Message des visites nocturnes", "text": "Le carnet de Jeanne conserve un message du syndic : des techniciens entraient dans Hespérie après la fermeture des étages publics. La dernière visite est datée de trois jours avant le typhon. Jeanne distingue ces souvenirs des appels qu’elle entend maintenant ; ils n’établissent pas le sort de Bravo."},
	"residential_crack_18": {"floor": 18, "title": "Fissure signalée avant le séisme", "text": "Une feuille d’entretien du duplex décrit une fissure dans le noyau et un courant d’air chaud venant des gaines. Le défaut avait été signalé plusieurs semaines avant la catastrophe. Le dessin correspond à la ligne aujourd’hui rompue entre les deux appartements."},
	"residential_recordings_17": {"floor": 17, "title": "Deux messages, deux heures incompatibles", "text": "Inès a conservé deux enregistrements portant la même phrase : « Poste d’Aube, confirmez la destination. » Le premier est horodaté avant l’alerte ; le second après la coupure du réseau. La voix seule ne permet pas de les authentifier. La plaque de service donne une destination vérifiable : AUBE-20, référence NACRE-204."}
}
const ACTIONS: Dictionary = {
	"care": {"floor": 19, "tool": "", "duration": 2.0, "title": "Préparer le départ de Jeanne", "message": "Jeanne dispose de son nécessaire et peut marcher lentement avec vous. Le retour se fait par les escaliers, jamais par la corde du duplex."},
	"service_access": {"floor": 18, "tool": "halligan", "duration": 2.8, "title": "Dégager la porte de service du duplex", "message": "Retour de service ouvert. Marc et Inès peuvent rejoindre le refuge 20 par les escaliers ; le rappel reste une voie personnelle."},
	"power": {"floor": 17, "tool": "", "duration": 2.2, "title": "Alimenter le relais local", "message": "Relais alimenté. Relever la plaque de service et vérifier la destination avant d’émettre."},
	"reference": {"floor": 17, "tool": "", "duration": 1.2, "title": "Relever la destination et la référence", "message": "Plaque relevée : destination AUBE-20 ; référence NACRE-204. Ces données restent disponibles dans le journal de mission."},
	"relay": {"floor": 17, "tool": "", "duration": 2.0, "title": "Établir la liaison vérifiée avec Aube", "message": "Destination AUBE-20 et référence NACRE-204 confirmées. La liaison avec le refuge 20 est établie ; les deux enregistrements restent conservés comme constats."}
}

var state: Dictionary = dormant_state()
var active_action: String = ""
var progress: float = 0.0
var _relay_verified: bool = false
var _relay_waiting_for_hold: bool = false
var phase: String:
	get: return state["phase"]


static func dormant_state() -> Dictionary:
	return {"phase": "dormant", "actions": [], "people": {"jeanne": "waiting", "marc": "waiting", "ines": "waiting"}, "contacted": []}


static func normalize(value: Variant, stable_only: bool = false) -> Dictionary:
	if not value is Dictionary or value.size() != 4 or not value.has_all(["phase", "actions", "people", "contacted"]): return {}
	if typeof(value["phase"]) != TYPE_STRING or value["phase"] not in ["dormant", "active", "complete"]: return {}
	if not value["actions"] is Array or not value["contacted"] is Array or not value["people"] is Dictionary: return {}
	if value["people"].size() != 3 or not value["people"].has_all(PERSON_IDS): return {}
	var actions: Array = []
	for id: Variant in value["actions"]:
		if not id is String or not ACTIONS.has(id) or id in actions: return {}
		if id == "relay" and ("power" not in actions or "reference" not in actions): return {}
		actions.append(id)
	var contacted: Array = []
	for id: Variant in value["contacted"]:
		if not id is String or id not in PERSON_IDS or id in contacted: return {}
		contacted.append(id)
	for id: String in PERSON_IDS:
		var status: Variant = value["people"][id]
		if not status is String or status not in ["waiting", "following", "received"] or (stable_only and status == "following"): return {}
		if status != "waiting" and id not in contacted: return {}
	if "jeanne" in contacted and "care" not in actions: return {}
	if ("marc" in contacted or "ines" in contacted) and "service_access" not in actions: return {}
	if value["phase"] == "dormant": return dormant_state() if value == dormant_state() else {}
	if value["phase"] == "complete":
		if "relay" not in actions: return {}
		for id: String in PERSON_IDS:
			if value["people"][id] != "received": return {}
	return value.duplicate(true)


static func checkpoint_consistent(context: Dictionary, value: Dictionary) -> bool:
	var checked: Dictionary = normalize(value, true)
	if checked.is_empty(): return false
	if checked["phase"] == "dormant":
		if int(context.get("floor", 31)) < 20: return false
		for level: Variant in context.get("seen_floors", []):
			if int(level) < 20: return false
		for id: String in CLUES:
			if id in context.get("clues", []): return false
		return true
	var commerce: Dictionary = context.get("commerce", {})
	if commerce.get("phase") != "complete" or context.get("incident_state") != "aftermath" or 20 not in context.get("seen_floors", []): return false
	for id: String in ["mina", "theo", "sofia"]:
		if commerce.get("people", {}).get(id) != "received": return false
	if checked["phase"] == "active": return not bool(context.get("completed", true))
	if not bool(context.get("completed", false)) or int(context.get("floor", 0)) != 17: return false
	for id: String in CLUES:
		if id not in context.get("clues", []): return false
	return true


func reset() -> void:
	state = dormant_state()
	cancel()


func restore(value: Variant) -> bool:
	var checked: Dictionary = normalize(value)
	if checked.is_empty(): return false
	for id: String in PERSON_IDS:
		if checked["people"][id] == "following": checked["people"][id] = "waiting"
	state = checked
	cancel()
	return true


func restore_runtime(value: Variant) -> bool:
	# Failed persistence rolls back durable data without resetting live escorts.
	# Presentation paths/cursors remain owned by the physical scene.
	var checked: Dictionary = normalize(value)
	if checked.is_empty(): return false
	state = checked
	cancel()
	return true


func snapshot() -> Dictionary:
	return state.duplicate(true)


func checkpoint_snapshot() -> Dictionary:
	var result: Dictionary = snapshot()
	for id: String in PERSON_IDS:
		if result["people"][id] == "following": result["people"][id] = "waiting"
	return result


func begin(context: Dictionary) -> bool:
	if phase != "dormant" or not bool(context.get("completed", false)) or context.get("floor") != 20 or not bool(context.get("at_landing", false)) or context.get("commerce", {}).get("phase") != "complete": return false
	state["phase"] = "active"
	return true


func has_action(id: String) -> bool:
	return id in state["actions"]


func can_action(id: String, tool: String) -> bool:
	if phase != "active" or not ACTIONS.has(id) or has_action(id): return false
	if id == "relay" and (not has_action("power") or not has_action("reference") or not _relay_verified): return false
	return str(ACTIONS[id]["tool"]).is_empty() or ACTIONS[id]["tool"] == tool


func begin_action(id: String, tool: String) -> bool:
	if not can_action(id, tool): return false
	if id != "relay":
		_relay_verified = false
		_relay_waiting_for_hold = false
	if active_action != id: progress = 0.0
	active_action = id
	return true


func validate_relay(destination: String, reference: String) -> bool:
	return phase == "active" and not has_action("relay") and has_action("power") and has_action("reference") and destination.strip_edges().to_upper() == RELAY_DESTINATION and reference.strip_edges().to_upper() == RELAY_REFERENCE


func begin_relay(destination: String, reference: String, tool: String = "") -> bool:
	# A wrong entry is retryable and never touches people, receipts or chapter.
	if not validate_relay(destination, reference): return false
	_relay_verified = true
	if not begin_action("relay", tool):
		_relay_verified = false
		return false
	# The form closes before the player can move a finger to E. This verified
	# state waits for the first hold; it never advances or enters a checkpoint.
	_relay_waiting_for_hold = true
	return true


func cancel() -> void:
	active_action = ""
	progress = 0.0
	_relay_verified = false
	_relay_waiting_for_hold = false


func advance_action(delta: float, valid_context: bool, held: bool, tool: String) -> Dictionary:
	if active_action.is_empty(): return {}
	if not valid_context or not can_action(active_action, tool):
		cancel()
		return {}
	if active_action == "relay" and _relay_waiting_for_hold:
		if not held: return {}
		_relay_waiting_for_hold = false
	if not held:
		cancel()
		return {}
	if not is_finite(delta) or delta <= 0.0: return {}
	progress += minf(delta, 0.25)
	if progress + 0.00001 < float(ACTIONS[active_action]["duration"]): return {}
	var result: Dictionary = ACTIONS[active_action].duplicate(true)
	result["id"] = active_action
	state["actions"].append(active_action)
	cancel()
	return result


func person_state(id: String) -> String:
	return str(state["people"].get(id, "waiting"))


func toggle_person(id: String) -> bool:
	if phase != "active" or id not in PERSON_IDS or person_state(id) == "received": return false
	if (id == "jeanne" and not has_action("care")) or (id in ["marc", "ines"] and not has_action("service_access")): return false
	if id not in state["contacted"]: state["contacted"].append(id)
	state["people"][id] = "waiting" if person_state(id) == "following" else "following"
	return true


func receive(id: String, floor_number: int, physically_arrived: bool) -> bool:
	if phase != "active" or id not in PERSON_IDS or person_state(id) != "following" or floor_number != 20 or not physically_arrived: return false
	state["people"][id] = "received"
	return true


func received_count() -> int:
	var count: int = 0
	for id: String in PERSON_IDS:
		if person_state(id) == "received": count += 1
	return count


func complete(context: Dictionary) -> bool:
	if phase != "active" or context.get("floor") != 17 or not bool(context.get("at_landing", false)) or received_count() != 3 or not has_action("relay"): return false
	for id: String in CLUES:
		if id not in context.get("clues", []): return false
	state["phase"] = "complete"
	return true


func objective() -> String:
	if phase == "complete": return "Jeanne, Marc et Inès sont reçus au refuge 20. Le relais du 17 est vérifié ; trois constats sont conservés."
	if not has_action("care"): return "Au 19, préparer le départ de Jeanne et retrouver Marc dans le duplex du 18."
	if not has_action("service_access"): return "Au 18, dégager la porte de service au Halligan pour ouvrir un retour sûr vers le refuge 20."
	if received_count() < 3: return "Accompagner Jeanne, Marc et Inès par les escaliers jusqu’au refuge 20 · %d / 3 reçus." % received_count()
	if not has_action("power"): return "Au 17, alimenter le relais local."
	if not has_action("reference"): return "Au 17, relever la plaque de service donnant la destination et la référence."
	if not has_action("relay"): return "Vérifier l’émission : destination AUBE-20, référence NACRE-204."
	return "Relever les trois constats des résidences et du réseau, puis transmettre le bilan au relais du 17."


func prompt(id: String, tool: String) -> String:
	if not ACTIONS.has(id): return ""
	if has_action(id): return "Intervention terminée"
	if id == "relay":
		if not has_action("power"): return "Alimenter d’abord le relais local"
		if not has_action("reference"): return "Relever d’abord la plaque de destination et de référence"
		if not _relay_verified: return "E · Vérifier la destination et la référence avant émission"
		if _relay_waiting_for_hold: return "Destination vérifiée · Maintenir E pour émettre"
	if not str(ACTIONS[id]["tool"]).is_empty() and ACTIONS[id]["tool"] != tool: return "3 Halligan requis · Dégager la porte de service"
	var suffix: String = " · %d %%" % roundi(progress / float(ACTIONS[id]["duration"]) * 100.0) if active_action == id else ""
	return "Maintenir E · " + str(ACTIONS[id]["title"]) + suffix
