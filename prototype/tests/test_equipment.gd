extends SceneTree
const Equipment = preload("res://scripts/equipment_director.gd")
var checks: int = 0
var failures: Array[String] = []

func _initialize() -> void:
	var tools = Equipment.new()
	_check(tools.charges_left() == 3 and tools.selected == "fire_axe", "Incorrect new kit defaults.")
	_check(not tools.select_tool("unknown") and not tools.begin("unknown"), "Unknown tool or site accepted.")
	_check(not tools.begin("equipment_fire_28"), "Wrong tool activated the fire action.")
	_check(tools.begin("equipment_boards_29"), "Axe cannot begin its site.")
	tools.advance(0.25, true, true)
	var before: Dictionary = tools.snapshot()
	_check(tools.begin("equipment_boards_29") and tools.snapshot() == before, "Repeated begin reset progress.")
	_check(tools.advance(NAN, true, true).is_empty() and tools.snapshot() == before, "Non-finite delta advanced work.")
	_check(tools.advance(-1.0, true, true).is_empty() and tools.snapshot() == before, "Negative delta advanced work.")
	tools.advance(100.0, true, true)
	_check(is_equal_approx(tools.progress, 0.5), "A stalled frame completed the action.")
	tools.advance(0.1, true, false)
	_check(tools.active_id.is_empty() and tools.progress == 0.0 and tools.completed.is_empty(), "Release consumed or retained progress.")
	tools.begin("equipment_boards_29")
	tools.advance(0.25, false, true)
	_check(tools.active_id.is_empty() and tools.completed.is_empty(), "Invalid context continued work.")
	tools.begin("equipment_boards_29")
	tools.select_tool("halligan")
	_check(tools.active_id.is_empty() and tools.progress == 0.0, "Switching retained progress.")
	for id: String in Equipment.ACTIONS:
		var action: Dictionary = Equipment.ACTIONS[id]
		tools.select_tool(str(action["tool"]))
		_check(tools.begin(id), "Valid work failed: " + id)
		var event: Dictionary = {}
		for tick: int in range(30):
			var result: Dictionary = tools.advance(0.125, true, true)
			if not result.is_empty():
				_check(event.is_empty(), "Duplicate reward: " + id)
				event = result
		_check(event.get("id") == id and event.get("reward") == action["reward"], "Missing work receipt: " + id)
		_check(not tools.begin(id) and tools.advance(1.0, true, true).is_empty(), "Completed work repeated: " + id)
	_check(tools.charges_left() == 2 and tools.completed.size() == 4, "Fire did not cost exactly one charge.")
	var detached: Dictionary = tools.snapshot()
	detached["completed"].clear()
	_check(tools.completed.size() == 4, "Mutable snapshot aliases live state.")
	var ledger: Array = ["supply_29", "equipment_fire_28", "equipment_fire_28", "equipment_cabinet_25", "unknown", 44]
	tools.restore(ledger)
	_check(tools.completed == ["equipment_fire_28", "equipment_cabinet_25"] and tools.charges_left() == 2, "Restore accepted unrelated or duplicate receipts.")
	_check(tools.active_id.is_empty() and tools.selected == "fire_axe", "Restore revived an unfinished action.")
	_check(ledger.size() == 6, "Restore mutated its input.")
	tools.reset()
	_check(tools.completed.is_empty() and tools.charges_left() == 3, "New game retained spent resources.")
	if failures.is_empty():
		print("PASS equipment: %d checks" % checks)
		quit(0)
	else:
		for message: String in failures: push_error(message)
		quit(1)

func _check(ok: bool, message: String) -> void:
	checks += 1
	if not ok: failures.append(message)
