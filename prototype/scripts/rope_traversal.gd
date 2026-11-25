extends RefCounted
class_name DescentRopeTraversal
## Local belayed travel between two adjacent floors. No scene, IO, wall clock
## or random generator: the player owns the capsule and reconciles collisions.

const DESCENT_SPEED: float = 2.8
const ASCENT_SPEED: float = 1.6
const PRECISION_SPEED: float = 0.75
const FAST_DESCENT_SPEED: float = 4.2
const ACCELERATION: float = 7.5
const BRAKE_DECELERATION: float = 16.0
const ASCENT_COST: float = 10.0
const PRECISE_ASCENT_COST: float = 5.0
const FAST_DESCENT_COST: float = 8.0
const REST_RECOVERY: float = 12.0
const RESUME_STAMINA: float = 20.0
const SECURED_DURATION: float = 16.0
const EXIT_HEIGHT_TOLERANCE: float = 0.45
const EXIT_SWAY_TOLERANCE: float = 0.25
const EXIT_SPEED_TOLERANCE: float = 0.05
const HARNESS_HEIGHT: float = 0.8
const MAX_STEP: float = 1.0 / 120.0
const MAX_ADVANCE: float = 120.0

var active: bool = false
var _route: Dictionary = {}
var _position: Vector3 = Vector3.ZERO
var _velocity: float = 0.0 # Positive downward; snapshot exposes world-Y velocity.
var _sway: float = 0.0
var _sway_speed: float = 0.0
var _secured_time: float = 0.0
var _locked: bool = false
var _stamina: float = 100.0
var _resting: bool = false
var _elapsed: float = 0.0
var _mode: String = "detached"

func reset() -> void:
	active = false
	_route.clear()
	_position = Vector3.ZERO
	_velocity = 0.0
	_sway = 0.0
	_sway_speed = 0.0
	_secured_time = 0.0
	_locked = false
	_stamina = 100.0
	_resting = false
	_elapsed = 0.0
	_mode = "detached"

func attach(route: Dictionary, start_floor: int, stamina: float = 100.0) -> bool:
	# Invalid requests are transactional: an existing belay is never discarded.
	if not _valid_route(route) or not is_finite(stamina) or stamina < 0.0 or stamina > 100.0:
		return false
	if start_floor != int(route["upper"]) and start_floor != int(route["lower"]):
		return false
	reset()
	_route = route.duplicate(true)
	active = true
	_position = _route["rope_top"] if start_floor == int(_route["upper"]) else _route["rope_bottom"]
	_stamina = stamina
	_resting = stamina <= 0.0
	_mode = "rest" if _resting else "hold"
	return true

func advance(delta: float, controls: Dictionary = {}) -> Dictionary:
	# Pausing preserves every field, including wind, inertia and anchor duration.
	if not active or not _valid_controls(controls) or not bool(controls.get("running", true)):
		return snapshot()
	if not is_finite(delta) or delta <= 0.0 or delta > MAX_ADVANCE:
		return snapshot()
	var vertical: float = float(controls.get("vertical", 0.0))
	var lateral: float = float(controls.get("lateral", 0.0))
	var precision: bool = bool(controls.get("precision", false))
	var fast: bool = bool(controls.get("fast", false))
	var wind_strength: float = float(controls.get("wind_strength", 0.35))
	# Fixed maximum steps bound the spring and keep large-frame brakes reliable.
	var steps: int = maxi(1, ceili(delta / MAX_STEP))
	var dt: float = delta / float(steps)
	for _index in range(steps):
		_advance_step(dt, vertical, lateral, precision, fast, wind_strength)
	return snapshot()

func _advance_step(delta: float, vertical: float, lateral: float, precision: bool, fast: bool, wind_strength: float) -> void:
	_elapsed += delta
	_secured_time = maxf(0.0, _secured_time - delta)
	if _resting and _stamina >= RESUME_STAMINA:
		_resting = false
	var target: float = 0.0
	var effort: float = 0.0
	_mode = "hold"
	if _locked:
		_mode = "locked"
	elif _resting:
		_mode = "rest"
	elif absf(vertical) >= 0.02:
		if precision:
			target = signf(vertical) * PRECISION_SPEED * absf(vertical)
			effort = PRECISE_ASCENT_COST if vertical < 0.0 else 0.0
			_mode = "precision"
		elif vertical < 0.0:
			target = -ASCENT_SPEED * absf(vertical)
			effort = ASCENT_COST
			_mode = "ascend"
		elif fast:
			target = FAST_DESCENT_SPEED * vertical
			effort = FAST_DESCENT_COST
			_mode = "rapid"
		else:
			target = DESCENT_SPEED * vertical
			_mode = "descend"
	# A direction reversal brakes to zero before accelerating the other way.
	var braking: bool = is_zero_approx(target) or (_velocity * target < 0.0)
	var requested: float = 0.0 if _velocity * target < 0.0 else target
	_velocity = move_toward(_velocity, requested, (BRAKE_DECELERATION if braking else ACCELERATION) * delta)
	var old_y: float = _position.y
	_position.y = clampf(_position.y - _velocity * delta, _route["rope_bottom"].y, _route["rope_top"].y)
	var distance: float = absf(_position.y - old_y)
	if (is_equal_approx(_position.y, _route["rope_bottom"].y) and _velocity > 0.0) or (is_equal_approx(_position.y, _route["rope_top"].y) and _velocity < 0.0):
		_velocity = 0.0
		if not _locked and not _resting:
			_mode = "hold"
	if distance > 0.000001 and effort > 0.0:
		var movement_fraction: float = minf(1.0, distance / maxf(absf(target) * delta, 0.000001))
		_stamina = maxf(0.0, _stamina - effort * delta * movement_fraction)
	elif absf(_velocity) <= EXIT_SPEED_TOLERANCE and distance < 0.000001:
		_stamina = minf(100.0, _stamina + REST_RECOVERY * delta)
	if _stamina <= 0.0:
		# The descender holds safely. Exhaustion never creates a fall or damage.
		_resting = true
		_velocity = 0.0
		_mode = "locked" if _locked else "rest"
	var stabilization: float = 0.14 if _secured_time > 0.0 else 1.0
	var wind: float = (sin(_elapsed * 1.3) + sin(_elapsed * 0.43) * 0.25) * 0.55 * wind_strength * stabilization
	var lateral_control: float = 0.0 if _locked or _resting else lateral
	_sway_speed += (lateral_control * 4.5 * stabilization + wind - _sway * 4.8 - _sway_speed * 3.4) * delta
	var limit: float = float(_route["max_sway"])
	_sway = clampf(_sway + _sway_speed * delta, -limit, limit)
	if (is_equal_approx(_sway, limit) and _sway_speed > 0.0) or (is_equal_approx(_sway, -limit) and _sway_speed < 0.0):
		_sway_speed = 0.0
	_position.x = _route["rope_top"].x
	_position.z = _route["rope_top"].z + _sway

func toggle_lock() -> bool:
	if not active:
		return false
	_locked = not _locked
	if _locked:
		_velocity = 0.0
		_sway_speed = 0.0
	_mode = "locked" if _locked else ("rest" if _resting else "hold")
	return true

func secure() -> bool:
	if not active or _secured_time > 0.0:
		return false
	_secured_time = SECURED_DURATION
	_sway = 0.0
	_sway_speed = 0.0
	_position.z = _route["rope_top"].z
	return true

func sync_position(actual_position: Vector3) -> void:
	if not active or not actual_position.is_finite():
		return
	var corrected: Vector3 = Vector3(
		_route["rope_top"].x,
		clampf(actual_position.y, _route["rope_bottom"].y, _route["rope_top"].y),
		clampf(actual_position.z, _route["rope_top"].z - float(_route["max_sway"]), _route["rope_top"].z + float(_route["max_sway"]))
	)
	if corrected.distance_squared_to(_position) > 0.00000001 or actual_position.distance_squared_to(corrected) > 0.00000001:
		_velocity = 0.0
		_sway_speed = 0.0
		_mode = "locked" if _locked else ("rest" if _resting else "hold")
	_position = corrected
	_sway = _position.z - _route["rope_top"].z

func can_exit() -> bool:
	return active and _aligned_floor() != 0 and absf(_velocity) <= EXIT_SPEED_TOLERANCE and absf(_sway) <= EXIT_SWAY_TOLERANCE

func exit_floor() -> int:
	return _aligned_floor() if can_exit() else 0

func landing() -> Vector3:
	var floor_number: int = exit_floor()
	if floor_number == 0:
		return Vector3.INF
	return _route["top_entry"] if floor_number == int(_route["upper"]) else _route["bottom_entry"]

func detach() -> void:
	var retained_stamina: float = _stamina
	reset()
	_stamina = retained_stamina

func snapshot() -> Dictionary:
	var frame: Dictionary = {
		"active": active, "route_id": str(_route.get("id", "")), "title": str(_route.get("title", "")),
		"upper": int(_route.get("upper", 0)), "lower": int(_route.get("lower", 0)),
		"position": _position, "anchor": _route.get("anchor", Vector3.ZERO),
		"floor": _nearest_floor(), "speed": absf(_velocity), "vertical_speed": -_velocity,
		"sway": _sway, "sway_speed": _sway_speed, "secured_time": _secured_time,
		"locked": _locked, "stamina": _stamina, "exhausted": _resting, "elapsed": _elapsed,
		"rope_length": 0.0, "deployed": 0.0, "remaining": 0.0,
		"segment_length": 0.0, "travelled": 0.0, "distance_remaining": 0.0,
		"can_exit": can_exit(), "exit_floor": exit_floor(), "landing": landing(), "mode": _mode
	}
	if active:
		var anchor: Vector3 = _route["anchor"]
		var end: Vector3 = _route["rope_bottom"] + Vector3(0.0, HARNESS_HEIGHT, 0.0)
		# Maximum lateral excursion fits the available belay; no short-rope snap.
		var far_z: float = absf(anchor.z - end.z) + float(_route["max_sway"])
		frame["rope_length"] = Vector3(anchor.x - end.x, anchor.y - end.y, far_z).length()
		frame["deployed"] = anchor.distance_to(_position + Vector3(0.0, HARNESS_HEIGHT, 0.0))
		frame["remaining"] = maxf(0.0, float(frame["rope_length"]) - float(frame["deployed"]))
		frame["segment_length"] = _route["rope_top"].y - _route["rope_bottom"].y
		frame["travelled"] = _route["rope_top"].y - _position.y
		frame["distance_remaining"] = _position.y - _route["rope_bottom"].y
	return frame

func _nearest_floor() -> int:
	if not active:
		return 0
	return int(_route["upper"]) if absf(_position.y - _route["rope_top"].y) <= absf(_position.y - _route["rope_bottom"].y) else int(_route["lower"])

func _aligned_floor() -> int:
	if not active:
		return 0
	if absf(_position.y - _route["rope_top"].y) <= EXIT_HEIGHT_TOLERANCE:
		return int(_route["upper"])
	if absf(_position.y - _route["rope_bottom"].y) <= EXIT_HEIGHT_TOLERANCE:
		return int(_route["lower"])
	return 0

static func _valid_controls(controls: Dictionary) -> bool:
	for key: String in ["running", "precision", "fast"]:
		if controls.has(key) and typeof(controls[key]) != TYPE_BOOL:
			return false
	for key: String in ["vertical", "lateral", "wind_strength"]:
		if not controls.has(key):
			continue
		var value: Variant = controls[key]
		if not _finite_number(value):
			return false
		var lower: float = 0.0 if key == "wind_strength" else -1.0
		if float(value) < lower or float(value) > 1.0:
			return false
	return true

static func _valid_route(route: Dictionary) -> bool:
	if not route.has_all(["id", "kind", "upper", "lower", "top_entry", "bottom_entry", "rope_top", "rope_bottom", "anchor", "max_sway"]):
		return false
	if typeof(route["id"]) != TYPE_STRING or str(route["id"]).strip_edges().is_empty() or route["kind"] != "rope":
		return false
	if typeof(route["upper"]) != TYPE_INT or typeof(route["lower"]) != TYPE_INT:
		return false
	var upper: int = int(route["upper"])
	var lower: int = int(route["lower"])
	if upper != lower + 1 or lower < 23 or upper > 31:
		return false
	for key: String in ["top_entry", "bottom_entry", "rope_top", "rope_bottom", "anchor"]:
		if typeof(route[key]) != TYPE_VECTOR3 or not route[key].is_finite():
			return false
	if not _finite_number(route["max_sway"]) or float(route["max_sway"]) <= 0.0 or float(route["max_sway"]) > 0.65:
		return false
	var top: Vector3 = route["rope_top"]
	var bottom: Vector3 = route["rope_bottom"]
	if not is_equal_approx(top.x, bottom.x) or not is_equal_approx(top.z, bottom.z):
		return false
	if absf(top.y - (upper - 24) * 6.0 - 0.04) > 0.001 or absf(bottom.y - (lower - 24) * 6.0 - 0.04) > 0.001:
		return false
	if absf(route["top_entry"].y - (upper - 24) * 6.0 - 0.06) > 0.001 or absf(route["bottom_entry"].y - (lower - 24) * 6.0 - 0.06) > 0.001:
		return false
	return route["anchor"].y > top.y + HARNESS_HEIGHT

static func _finite_number(value: Variant) -> bool:
	return (typeof(value) == TYPE_FLOAT or typeof(value) == TYPE_INT) and is_finite(float(value))
