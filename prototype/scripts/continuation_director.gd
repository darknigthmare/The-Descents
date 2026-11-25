extends RefCounted
class_name DescentContinuationDirector
## Pure mission progression after the first refuge debrief. Positions, collision,
## dialogue playback and saving remain owned by the mission/world. No clocks or I/O.
## A following escort is transient: checkpoint_snapshot() and restore() return
## the duo to their authored waiting place; a confirmed reception stays durable.

const RESCUE_IDS: Array[String] = ["survivor_30", "survivor_28", "survivor_26"]
const PROOF_IDS: Array[String] = ["continuation_model_23", "continuation_photo_23"]
const STATE_KEYS: Array[String] = ["phase", "started_at_refuge", "duo_briefed", "escort_state"]
var state: Dictionary = dormant_state()
var phase: String:
	get:
		return state["phase"]
var escort_state: String:
	get:
		return state["escort_state"]
var duo_briefed: bool:
	get:
		return state["duo_briefed"]


static func dormant_state() -> Dictionary:
	return {"phase": "dormant", "started_at_refuge": false, "duo_briefed": false, "escort_state": "waiting"}


static func normalize(value: Variant, stable_only: bool = false) -> Dictionary:
	if not value is Dictionary or value.size() != STATE_KEYS.size() or not value.has_all(STATE_KEYS):
		return {}
	if typeof(value["phase"]) != TYPE_STRING or value["phase"] not in ["dormant", "active", "complete"]:
		return {}
	if typeof(value["started_at_refuge"]) != TYPE_BOOL or typeof(value["duo_briefed"]) != TYPE_BOOL:
		return {}
	if typeof(value["escort_state"]) != TYPE_STRING or value["escort_state"] not in ["waiting", "following", "received"]:
		return {}
	if stable_only and value["escort_state"] == "following":
		return {}
	if value["phase"] == "dormant":
		return dormant_state() if value == dormant_state() else {}
	if not value["started_at_refuge"]:
		return {}
	if value["escort_state"] != "waiting" and not value["duo_briefed"]:
		return {}
	if value["phase"] == "complete" and (not value["duo_briefed"] or value["escort_state"] != "received"):
		return {}
	return value.duplicate(true)


static func has_rescues(context: Dictionary) -> bool:
	var people: Variant = context.get("rescued", [])
	if not people is Array:
		return false
	for id: String in RESCUE_IDS:
		if id not in people:
			return false
	return true


static func has_proofs(context: Dictionary) -> bool:
	var clues: Variant = context.get("clues", [])
	if not clues is Array:
		return false
	for id: String in PROOF_IDS:
		if id not in clues:
			return false
	return true


static func checkpoint_consistent(context: Dictionary, continuation_value: Dictionary, commerce_active: bool = false) -> bool:
	var normalized: Dictionary = normalize(continuation_value, true)
	if normalized.is_empty():
		return false
	var phase: String = normalized["phase"]
	var floor_number: int = int(context.get("floor", 31))
	var completed: bool = bool(context.get("completed", false))
	if phase == "dormant":
		if floor_number < 25:
			return false
		for level: Variant in context.get("seen_floors", []):
			if int(level) < 25:
				return false
		for clue: String in PROOF_IDS:
			if clue in context.get("clues", []):
				return false
		return not completed or (floor_number == 25 and has_rescues(context) and context.get("incident_state") == "aftermath")
	if not has_rescues(context) or context.get("incident_state") != "aftermath":
		return false
	if 25 not in context.get("seen_floors", []):
		return false
	if phase == "complete":
		if commerce_active:
			return has_proofs(context)
		return completed and floor_number == 23 and has_proofs(context)
	return not completed


func reset() -> void:
	state = dormant_state()


func restore(value: Variant) -> bool:
	var restored: Dictionary = normalize(value)
	if restored.is_empty():
		return false
	if restored["escort_state"] == "following":
		restored["escort_state"] = "waiting"
	state = restored
	return true


func snapshot() -> Dictionary:
	return state.duplicate(true)


func checkpoint_snapshot() -> Dictionary:
	var checkpoint: Dictionary = snapshot()
	if checkpoint["escort_state"] == "following":
		checkpoint["escort_state"] = "waiting"
	return checkpoint


func is_active() -> bool:
	return state["phase"] == "active"


func begin(context: Dictionary) -> bool:
	if state["phase"] != "dormant" or not _supported(context, 25):
		return false
	if not _flag(context, "completed") or context.get("incident_state") != "aftermath" or not has_rescues(context):
		return false
	state = {"phase": "active", "started_at_refuge": true, "duo_briefed": false, "escort_state": "waiting"}
	return true


func start_escort(context: Dictionary) -> bool:
	var at_rendezvous: bool = _supported(context, 24) or (state["duo_briefed"] and _supported(context, 25))
	if not is_active() or state["escort_state"] != "waiting" or not at_rendezvous:
		return false
	state["duo_briefed"] = true
	state["escort_state"] = "following"
	return true


func pause_escort() -> bool:
	if not is_active() or state["escort_state"] != "following":
		return false
	state["escort_state"] = "waiting"
	return true


func receive_escort(context: Dictionary) -> bool:
	if not is_active() or state["escort_state"] != "following" or not _supported(context, 25):
		return false
	if not _flag(context, "duo_arrived"):
		return false
	state["escort_state"] = "received"
	return true


func can_complete(context: Dictionary) -> bool:
	return is_active() and state["escort_state"] == "received" and _supported(context, 23) and has_proofs(context) and has_rescues(context) and context.get("incident_state") == "aftermath"


func complete(context: Dictionary) -> bool:
	if not can_complete(context):
		return false
	state["phase"] = "complete"
	return true


func objective() -> String:
	if state["phase"] == "dormant":
		return "Terminer les secours et consulter le bilan au refuge 25."
	if state["phase"] == "complete":
		return "Reconnaissance achevée : Léa et Idris sont au refuge, les deux preuves sont consignées."
	match state["escort_state"]:
		"following":
			return "Accompagner Léa Mercier et Idris Kaci par l’escalier jusqu’au refuge 25."
		"received":
			return "Explorer le Salon des maquettes au 23 ; examiner la maquette et la photographie."
		_:
			return "Rejoindre Léa Mercier et Idris Kaci au 24 et préparer leur remontée au refuge."


static func _supported(context: Dictionary, floor_number: int) -> bool:
	return typeof(context.get("floor")) == TYPE_INT and context.get("floor") == floor_number and _flag(context, "at_landing")


static func _flag(context: Dictionary, key: String) -> bool:
	return typeof(context.get(key)) == TYPE_BOOL and bool(context[key])
