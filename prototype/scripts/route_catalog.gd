extends RefCounted
class_name DescentRouteCatalog
## Authored, reversible links between adjacent floors. This catalogue has no
## RNG and never changes floor generation, rescue sockets or save data.

const ROUTE_IDS: Array[String] = ["R31_30", "S30_29", "R29_28", "S28_27", "R27_26", "S26_25"]
const ROPE_X: float = -1.3
const ROPE_MAX_SWAY: float = 0.65
const STAIR_FRONT: float = 5.8
const STAIR_BACK: float = 10.2
const STAIR_TURN: float = 10.8
const STAIR_SIDE: float = 1.3


static func floor_height(number: int) -> float:
	return float(number - 24) * 6.0


static func all_routes() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for upper: int in [31, 30, 29, 28, 27, 26]:
		result.append(_make_route(upper))
	return result


static func for_id(route_id: String) -> Dictionary:
	for route: Dictionary in all_routes():
		if str(route["id"]) == route_id:
			return route
	return {}


static func routes_at_floor(number: int) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for route: Dictionary in all_routes():
		if number == int(route["upper"]) or number == int(route["lower"]):
			result.append(route)
	return result


static func stair_at_position(position_value: Vector3) -> Dictionary:
	if not position_value.is_finite():
		return {}
	for route: Dictionary in all_routes():
		if route["kind"] == "stairs" and (route["bounds"] as AABB).has_point(position_value):
			return route
	return {}


static func _make_route(upper: int) -> Dictionary:
	var lower: int = upper - 1
	var top_y: float = floor_height(upper)
	var bottom_y: float = floor_height(lower)
	var rope: bool = upper % 2 == 1
	var route: Dictionary = {
		"id": ("R" if rope else "S") + "%d_%d" % [upper, lower],
		"kind": "rope" if rope else "stairs",
		"upper": upper,
		"lower": lower,
		"title": ("Rappel" if rope else "Escalier") + " %s ↔ %d" % ["toit" if upper == 31 else str(upper), lower],
		"top_entry": Vector3(-3.8, top_y + 0.06, 0.0) if rope else Vector3(-STAIR_SIDE, top_y + 0.06, 5.0),
		"bottom_entry": Vector3(-3.8, bottom_y + 0.06, 0.0) if rope else Vector3(STAIR_SIDE, bottom_y + 0.06, 5.0),
		"rope_top": Vector3(ROPE_X, top_y + 0.04, 0.0),
		"rope_bottom": Vector3(ROPE_X, bottom_y + 0.04, 0.0),
		"anchor": Vector3(ROPE_X, top_y + 2.6, 0.0),
		"max_sway": ROPE_MAX_SWAY if rope else 0.0,
		"path_points": []
	}
	if rope:
		route["bounds"] = AABB(Vector3(-2.4, bottom_y - 0.1, -1.2), Vector3(2.2, 6.5, 2.4))
	else:
		# Entries are on a full slab, outside this stair volume. A halfway
		# landing is never mistaken for arrival at a numbered floor.
		route["bounds"] = AABB(Vector3(-2.5, bottom_y - 0.1, 5.5), Vector3(5.0, 6.5, 6.0))
		route["path_points"] = [
			route["top_entry"],
			Vector3(-STAIR_SIDE, top_y + 0.06, STAIR_FRONT),
			Vector3(-STAIR_SIDE, bottom_y + 3.06, STAIR_BACK),
			Vector3(-STAIR_SIDE, bottom_y + 3.06, STAIR_TURN),
			Vector3(STAIR_SIDE, bottom_y + 3.06, STAIR_TURN),
			Vector3(STAIR_SIDE, bottom_y + 3.06, STAIR_BACK),
			Vector3(STAIR_SIDE, bottom_y + 0.06, STAIR_FRONT),
			route["bottom_entry"]
		]
	return route


static func validate(routes: Array) -> Array[String]:
	var errors: Array[String] = []
	if routes.size() != ROUTE_IDS.size():
		errors.append("Six local traversal links are required.")
		return errors
	var required: Dictionary = {
		"id": TYPE_STRING, "kind": TYPE_STRING, "upper": TYPE_INT, "lower": TYPE_INT,
		"title": TYPE_STRING, "top_entry": TYPE_VECTOR3, "bottom_entry": TYPE_VECTOR3,
		"rope_top": TYPE_VECTOR3, "rope_bottom": TYPE_VECTOR3, "anchor": TYPE_VECTOR3,
		"max_sway": TYPE_FLOAT, "path_points": TYPE_ARRAY, "bounds": TYPE_AABB
	}
	for index in range(routes.size()):
		if not routes[index] is Dictionary:
			errors.append("Route %d is not a dictionary." % index)
			continue
		var route: Dictionary = routes[index]
		var valid: bool = true
		for key: String in required:
			if not route.has(key) or typeof(route[key]) != required[key]:
				errors.append("Route %d lacks a valid %s." % [index, key])
				valid = false
		if not valid:
			continue
		var expected: Dictionary = _make_route(31 - index)
		for key: String in required:
			if route[key] != expected[key]:
				errors.append("Route %s changed the protected %s contract." % [str(route["id"]), key])
	return errors
