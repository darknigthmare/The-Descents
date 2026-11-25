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


static func all_routes(include_continuation: bool = false) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for upper: int in [31, 30, 29, 28, 27, 26]:
		result.append(_make_route(upper))
	if include_continuation:
		result.append(_make_route(25, "stairs", true))
		result.append(_make_route(24, "rope"))
	return result


static func for_id(route_id: String) -> Dictionary:
	for route: Dictionary in all_routes(true):
		if str(route["id"]) == route_id:
			return route
	return {}


static func routes_at_floor(number: int, include_continuation: bool = false) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for route: Dictionary in all_routes(include_continuation):
		if number == int(route["upper"]) or number == int(route["lower"]):
			result.append(route)
	return result


static func stair_at_position(position_value: Vector3, include_continuation: bool = false) -> Dictionary:
	if not position_value.is_finite():
		return {}
	for route: Dictionary in all_routes(include_continuation):
		if route["kind"] == "stairs" and (route["bounds"] as AABB).has_point(position_value):
			return route
	return {}


static func _make_route(upper: int, authored_kind: String = "", north: bool = false) -> Dictionary:
	var lower: int = upper - 1
	var top_y: float = floor_height(upper)
	var bottom_y: float = floor_height(lower)
	var rope: bool = upper % 2 == 1 if authored_kind.is_empty() else authored_kind == "rope"
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
		if north:
			# A separate northern stair bay prevents the new 25–24 link from
			# turning the southern 26–25 staircase into an open multistorey cage.
			for key: String in ["top_entry", "bottom_entry"]:
				var point: Vector3 = route[key]
				route[key] = Vector3(-point.x, point.y, -point.z)
			var points: Array = []
			for point: Vector3 in route["path_points"]:
				points.append(Vector3(-point.x, point.y, -point.z))
			route["path_points"] = points
			route["bounds"] = AABB(Vector3(-2.5, bottom_y - 0.1, -11.5), Vector3(5.0, 6.5, 6.0))
			route["north"] = true
	return route


static func validate(routes: Array, include_continuation: bool = false) -> Array[String]:
	var errors: Array[String] = []
	var authored: Array[Dictionary] = all_routes(include_continuation)
	if routes.size() != authored.size():
		errors.append("The selected chapter requires its exact adjacent-floor traversal links.")
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
		var expected: Dictionary = authored[index]
		if route.get("north", false) != expected.get("north", false):
			errors.append("Route %s changed its protected stair orientation." % str(route["id"]))
		for key: String in required:
			if route[key] != expected[key]:
				errors.append("Route %s changed the protected %s contract." % [str(route["id"]), key])
	return errors
