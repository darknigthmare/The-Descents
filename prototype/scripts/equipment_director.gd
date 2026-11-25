extends RefCounted
## Contextual rescue work persists in the existing supplies_used checkpoint ledger.
const TOOLS: Array[String] = ["fire_axe", "extinguisher", "halligan", "bolt_cutter"]
const TITLES: Dictionary = {"fire_axe": "Hache de secours", "extinguisher": "Extincteur", "halligan": "Outil Halligan", "bolt_cutter": "Coupe-boulon"}
const ACTIONS: Dictionary = {
	"equipment_boards_29": {"floor": 29, "tool": "fire_axe", "duration": 1.8, "title": "Dégager la réserve de balisage", "reward": "flare", "after_impact": true,
		"message": "Planches dégagées. Une fusée de balisage récupérée dans la réserve."},
	"equipment_fire_28": {"floor": 28, "tool": "extinguisher", "duration": 3.0, "title": "Éteindre le foyer de la corbeille", "reward": "none", "after_impact": true,
		"message": "Foyer éteint. La fumée locale se dissipe ; les autres zones enfumées restent à éviter."},
	"equipment_cabinet_25": {"floor": 25, "tool": "halligan", "duration": 2.2, "title": "Débloquer l’armoire de premiers secours", "reward": "medical", "after_impact": true,
		"message": "Armoire débloquée. Le matériel de soins permet de récupérer jusqu’à 20 points d’état physique."},
	"equipment_chain_24": {"floor": 24, "tool": "bolt_cutter", "duration": 1.6, "title": "Libérer le projecteur de secours", "reward": "worklight", "after_impact": true,
		"message": "Chaîne coupée. Le projecteur de secours éclaire maintenant le foyer du congrès."}
}
const EXTINGUISHER_CHARGES: int = 3
var selected: String = "fire_axe"
var completed: Array[String] = []
var active_id: String = ""
var progress: float = 0.0

func reset() -> void:
	selected = TOOLS[0]
	completed.clear()
	cancel()

func restore(ledger: Array) -> void:
	reset()
	for value: Variant in ledger:
		if value is String and ACTIONS.has(value) and value not in completed:
			completed.append(value)

func select_tool(id: String) -> bool:
	if id not in TOOLS:
		return false
	cancel()
	selected = id
	return true

func charges_left() -> int:
	var used: int = 0
	for id: String in completed:
		if str(ACTIONS[id]["tool"]) == "extinguisher":
			used += 1
	return maxi(0, EXTINGUISHER_CHARGES - used)

func can_begin(id: String) -> bool:
	return ACTIONS.has(id) and id not in completed and str(ACTIONS[id]["tool"]) == selected and (selected != "extinguisher" or charges_left() > 0)

func begin(id: String) -> bool:
	if not can_begin(id):
		return false
	if active_id != id:
		progress = 0.0
	active_id = id
	return true

func cancel() -> void:
	active_id = ""
	progress = 0.0

func advance(delta: float, valid_context: bool, held: bool) -> Dictionary:
	if active_id.is_empty():
		return {}
	if not valid_context or not held or not can_begin(active_id):
		cancel()
		return {}
	if not is_finite(delta) or delta <= 0.0:
		return {}
	# A suspended frame is not a completed action; pause and release cancel it.
	progress += minf(delta, 0.25)
	var action: Dictionary = ACTIONS[active_id]
	if progress + 0.00001 < float(action["duration"]):
		return {}
	var result: Dictionary = action.duplicate(true)
	result["id"] = active_id
	completed.append(active_id)
	cancel()
	return result

func snapshot() -> Dictionary:
	return {"selected": selected, "completed": completed.duplicate(), "active_id": active_id,
		"progress": progress, "ratio": progress / float(ACTIONS[active_id]["duration"]) if ACTIONS.has(active_id) else 0.0, "charges": charges_left()}

func prompt(id: String) -> String:
	if not ACTIONS.has(id) or id in completed:
		return ""
	var tool: String = str(ACTIONS[id]["tool"])
	if selected != tool:
		return "%d  %s · %s" % [TOOLS.find(tool) + 1, TITLES[tool], ACTIONS[id]["title"]]
	if active_id == id:
		return "Maintenir E · %s · %d %%" % [ACTIONS[id]["title"], roundi(float(snapshot()["ratio"]) * 100.0)]
	return "Maintenir E · %s" % ACTIONS[id]["title"]
