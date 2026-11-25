extends RefCounted
class_name DescentCommerceDirector
## Authored rescue chapter A22–A20. Stable receipts are saved; movement and
## held operations are deliberately transient. No timers advance behind UI.

const PERSON_IDS: Array[String] = ["mina", "theo", "sofia"]
const PEOPLE: Dictionary = {
	"mina": {"name": "Mina Bensaïd", "floor": 22, "role": "Commerçante de la galerie"},
	"theo": {"name": "Théo Lenoir", "floor": 21, "role": "Second de cuisine"},
	"sofia": {"name": "Sofia Renard", "floor": 20, "role": "Agente de maintenance"}
}
const CLUES: Dictionary = {
	"commerce_deliveries_22": {"floor": 22, "title": "Registre des livraisons de nuit", "text": "Les inventaires de la galerie mentionnent des caisses SILLAGE expédiées vers un quai technique absent du plan public. Les réceptions sont signées quatre jours avant le typhon. Une note demande de ne plus emprunter le monte-charge après 02 h 17. Aucun destinataire n’est nommé."},
	"commerce_maintenance_21": {"floor": 21, "title": "Consigne de maintenance antérieure au séisme", "text": "Le journal de la cuisine décrit des coups dans les gaines lorsque les ventilateurs sont arrêtés. Le technicien a consigné une réponse à trois frappes, puis barré le mot « réponse ». Le document est daté de la veille de l’alerte. Ces faits précèdent les dégâts ; leur cause reste inconnue."}
}
const ACTIONS: Dictionary = {
	"shutter": {"floor": 22, "tool": "halligan", "duration": 2.8, "title": "Relever le volet de la réserve", "message": "Volet calé. Mina peut quitter la réserve et emprunter l’escalier nord."},
	"isolation": {"floor": 21, "tool": "", "duration": 1.8, "title": "Isoler l’alimentation du réchauffeur", "message": "Alimentation isolée. La couverture coupe-feu peut maintenant contenir le foyer du réchauffeur."},
	"blanket": {"floor": 21, "tool": "", "duration": 2.5, "title": "Déployer la couverture coupe-feu", "message": "Foyer contenu. La fumée locale se dissipe ; Théo peut quitter l’office."},
	"resident": {"floor": 22, "tool": "", "duration": 2.2, "title": "Parler calmement, lampe abaissée", "message": "Le Retranché baisse les bras et laisse le passage. Il affirme avoir entendu la même voix avant le typhon."},
	"relay": {"floor": 20, "tool": "", "duration": 2.0, "title": "Rétablir le relais du refuge 20", "message": "Relais 20 alimenté. Le poste d’Aube reçoit à nouveau vos comptes rendus."}
}
var state: Dictionary = dormant_state()
var active_action: String = ""
var progress: float = 0.0
var phase: String:
	get: return state["phase"]

static func dormant_state() -> Dictionary:
	return {"phase": "dormant", "actions": [], "people": {"mina": "waiting", "theo": "waiting", "sofia": "waiting"}, "contacted": []}

static func normalize(value: Variant, stable_only: bool = false) -> Dictionary:
	if not value is Dictionary or value.size() != 4 or not value.has_all(["phase", "actions", "people", "contacted"]):
		return {}
	if typeof(value["phase"]) != TYPE_STRING or value["phase"] not in ["dormant", "active", "complete"]:
		return {}
	if not value["actions"] is Array or not value["contacted"] is Array or not value["people"] is Dictionary:
		return {}
	if value["people"].size() != 3 or not value["people"].has_all(PERSON_IDS):
		return {}
	var actions: Array = []
	for id: Variant in value["actions"]:
		if not id is String or not ACTIONS.has(id) or id in actions:
			return {}
		if id == "blanket" and "isolation" not in actions:
			return {}
		actions.append(id)
	var contacted: Array = []
	for id: Variant in value["contacted"]:
		if not id is String or id not in PERSON_IDS or id in contacted:
			return {}
		contacted.append(id)
	for id: String in PERSON_IDS:
		var status: Variant = value["people"][id]
		if not status is String or status not in ["waiting", "following", "received"] or (stable_only and status == "following"):
			return {}
		if status != "waiting" and id not in contacted:
			return {}
	if "mina" in contacted and "shutter" not in actions:
		return {}
	if "theo" in contacted and "blanket" not in actions:
		return {}
	if value["phase"] == "dormant":
		return dormant_state() if value == dormant_state() else {}
	if value["phase"] == "complete":
		if "relay" not in actions:
			return {}
		for id: String in PERSON_IDS:
			if value["people"][id] != "received":
				return {}
	return value.duplicate(true)

static func checkpoint_consistent(context: Dictionary, value: Dictionary) -> bool:
	var checked: Dictionary = normalize(value, true)
	if checked.is_empty(): return false
	if checked["phase"] == "dormant":
		if int(context.get("floor", 31)) < 23: return false
		for level: Variant in context.get("seen_floors", []):
			if int(level) < 23: return false
		for id: String in CLUES:
			if id in context.get("clues", []): return false
		return true
	var previous: Dictionary = context.get("continuation", {})
	if previous.get("phase") != "complete" or previous.get("escort_state") != "received" or context.get("incident_state") != "aftermath" or 23 not in context.get("seen_floors", []):
		return false
	if checked["phase"] == "active": return not bool(context.get("completed", true))
	if not bool(context.get("completed", false)) or int(context.get("floor", 0)) != 20: return false
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

func snapshot() -> Dictionary:
	return state.duplicate(true)

func checkpoint_snapshot() -> Dictionary:
	var result: Dictionary = snapshot()
	for id: String in PERSON_IDS:
		if result["people"][id] == "following": result["people"][id] = "waiting"
	return result

func begin(context: Dictionary) -> bool:
	if phase != "dormant" or not bool(context.get("completed", false)) or context.get("floor") != 23 or not bool(context.get("at_landing", false)) or context.get("continuation", {}).get("phase") != "complete":
		return false
	state["phase"] = "active"
	return true

func has_action(id: String) -> bool:
	return id in state["actions"]

func can_action(id: String, tool: String) -> bool:
	if phase != "active" or not ACTIONS.has(id) or has_action(id): return false
	if id == "blanket" and not has_action("isolation"): return false
	return str(ACTIONS[id]["tool"]).is_empty() or ACTIONS[id]["tool"] == tool

func begin_action(id: String, tool: String) -> bool:
	if not can_action(id, tool): return false
	if active_action != id: progress = 0.0
	active_action = id
	return true

func cancel() -> void:
	active_action = ""
	progress = 0.0

func advance_action(delta: float, valid_context: bool, held: bool, tool: String) -> Dictionary:
	if active_action.is_empty(): return {}
	if not valid_context or not held or not can_action(active_action, tool):
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
	if (id == "mina" and not has_action("shutter")) or (id == "theo" and not has_action("blanket")): return false
	if id not in state["contacted"]: state["contacted"].append(id)
	state["people"][id] = "waiting" if person_state(id) == "following" else "following"
	return true

func receive(id: String, floor_number: int, physically_arrived: bool) -> bool:
	if phase != "active" or id not in PERSON_IDS or person_state(id) != "following" or floor_number != 20 or not physically_arrived:
		return false
	state["people"][id] = "received"
	return true

func received_count() -> int:
	var count: int = 0
	for id: String in PERSON_IDS:
		if person_state(id) == "received": count += 1
	return count

func complete(context: Dictionary) -> bool:
	if phase != "active" or context.get("floor") != 20 or not bool(context.get("at_landing", false)) or received_count() != 3 or not has_action("relay"):
		return false
	for id: String in CLUES:
		if id not in context.get("clues", []): return false
	state["phase"] = "complete"
	return true

func objective() -> String:
	if phase == "complete": return "Refuge 20 établi : Mina, Théo et Sofia sont reçus. Deux nouveaux constats sont consignés."
	if not has_action("shutter"): return "Au 22, dégager le volet au Halligan et établir le contact avec Mina."
	if not has_action("isolation"): return "Au 21, isoler le réchauffeur avant de traiter le foyer local."
	if not has_action("blanket"): return "Au 21, déployer la couverture coupe-feu pour permettre la sortie de Théo."
	if received_count() < 3: return "Accompagner Mina, Théo et Sofia aux trois repères du refuge 20 · %d / 3 reçus." % received_count()
	if not has_action("relay"): return "Au refuge 20, remettre le relais en service."
	return "Relever le registre du 22 et la consigne du 21, puis transmettre le bilan au refuge 20."

func prompt(id: String, tool: String) -> String:
	if not ACTIONS.has(id): return ""
	if has_action(id): return "Intervention terminée"
	if id == "blanket" and not has_action("isolation"): return "Isoler d’abord l’alimentation du réchauffeur"
	if str(ACTIONS[id]["tool"]) != "" and ACTIONS[id]["tool"] != tool: return "3  Halligan requis · Relever le volet"
	var suffix: String = " · %d %%" % roundi(progress / float(ACTIONS[id]["duration"]) * 100.0) if active_action == id else ""
	return "Maintenir E · " + str(ACTIONS[id]["title"]) + suffix
