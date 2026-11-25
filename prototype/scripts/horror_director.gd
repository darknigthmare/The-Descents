extends RefCounted
class_name DescentHorrorDirector
## Early-floor uncertainty, not an enemy controller. No IO, random draw or mission mutation.
## Clocks advance only during an eligible, quiet, on-foot intervention.

const SUITES_POSITION: Vector3 = Vector3(-5.25, 30.0, -2.8)
const TRACE_POSITION: Vector3 = Vector3(-6.0, 24.018, 2.6)
const SPA_POSITION: Vector3 = Vector3(-7.0, 12.0, 1.0)
const SUITES_QUIET: float = 2.6
const SUITES_DURATION: float = 3.4
const TRACE_QUIET: float = 3.0
const TRACE_DURATION: float = 5.5
const SPA_QUIET: float = 4.0
const SPA_DURATION: float = 6.0
const SPA_RETURN_WAIT: float = 20.0
const SPA_LOOK_AWAY: float = 1.0
const MAX_SPA_OCCURRENCES: int = 2

var active_id: String = ""
var elapsed: float = 0.0
var cue_serial: int = 0
var _cue_id: String = ""
var _cue_position: Vector3 = Vector3.ZERO
var _last_floor: int = 31
var _suites_quiet: float = 0.0
var _suites_time: float = -1.0
var _suites_gaze: float = 0.0
var _suites_consumed: bool = false
var _trace_quiet: float = 0.0
var _trace_time: float = -1.0
var _trace_restored: bool = false
var _spa_quiet: float = 0.0
var _spa_time: float = -1.0
var _spa_wait: float = 0.0
var _spa_away: float = 0.0
var _spa_occurrences: int = 0
var _frame: Dictionary = {}

func _init() -> void:
	reset()

func reset(visited_floors: Array = []) -> void:
	active_id = ""
	elapsed = 0.0
	cue_serial = 0
	_cue_id = ""
	_cue_position = Vector3.ZERO
	_last_floor = 31
	_suites_quiet = 0.0
	_suites_time = -1.0
	_suites_gaze = 0.0
	_suites_consumed = 29 in visited_floors
	_trace_quiet = 0.0
	_trace_time = -1.0
	_trace_restored = 28 in visited_floors
	_spa_quiet = 0.0
	_spa_time = -1.0
	_spa_wait = 0.0
	_spa_away = 0.0
	_spa_occurrences = MAX_SPA_OCCURRENCES if 26 in visited_floors else 0
	_frame = _empty_frame()

func presentation() -> Dictionary:
	return _frame.duplicate(true)

func advance(delta: float, context: Dictionary) -> Dictionary:
	var dt: float = delta if is_finite(delta) and delta > 0.0 else 0.0
	var floor_number: int = int(context.get("floor", 31))
	var running: bool = bool(context.get("running", false))
	_frame = _empty_frame()
	active_id = ""
	if not running:
		return presentation()
	if floor_number != _last_floor:
		# Leaving a glimpse never keeps a half-faded body waiting at a later visit.
		if _last_floor == 29 and _suites_time >= 0.0:
			_suites_consumed = true
			_suites_time = -1.0
		if _last_floor == 26 and _spa_time >= 0.0:
			_spa_time = -1.0
			_spa_wait = 0.0
		_suites_quiet = 0.0
		_spa_quiet = 0.0
		_last_floor = floor_number
	var aftermath: bool = str(context.get("incident_state", "intact")) == "aftermath"
	if floor_number == 28 and aftermath:
		_render_trace()
	var blocked: bool = bool(context.get("on_rope", false)) or bool(context.get("carrying", false)) or bool(context.get("hoisting", false)) or bool(context.get("incident_active", false)) or bool(context.get("radio_busy", false))
	if blocked or floor_number not in [29, 28, 26]:
		# Existing damp traces remain physical dressing during a rescue. New
		# manifestations and their clocks yield to all operational priorities.
		_suites_quiet = 0.0
		_spa_quiet = 0.0
		_trace_quiet = 0.0
		return presentation()
	elapsed += dt
	if floor_number == 29:
		_advance_suites(dt, context)
	elif floor_number == 28 and aftermath:
		_advance_trace(dt, context)
	elif floor_number == 26:
		_advance_spa(dt, context)
	_frame["cue_serial"] = cue_serial
	_frame["cue_id"] = _cue_id
	_frame["cue_position"] = _cue_position
	_frame["id"] = active_id
	return presentation()

func _advance_suites(dt: float, context: Dictionary) -> void:
	if _suites_consumed:
		return
	var facing: float = _facing(context, SUITES_POSITION + Vector3(0, 1.15, 0))
	var nearby: bool = _nearby(context, SUITES_POSITION, 3.2, 12.0)
	var line_of_sight: bool = bool(context.get("line_of_sight", true))
	var peripheral: bool = facing >= 0.56 and facing <= 0.94
	if bool(context.get("flare_active", false)):
		_suites_quiet = 0.0
		return
	if _suites_time < 0.0:
		if not nearby or not peripheral or not line_of_sight:
			_suites_quiet = 0.0
			return
		_suites_quiet += dt
		if _suites_quiet < SUITES_QUIET or dt <= 0.0:
			return
		_suites_time = _suites_quiet - SUITES_QUIET
		_cue("distant_steps", SUITES_POSITION)
	else:
		_suites_time += dt
		if facing > 0.94 or facing < 0.05 or not nearby or not line_of_sight:
			_suites_gaze += dt
	if _suites_time >= SUITES_DURATION or _suites_gaze >= 0.6:
		_suites_consumed = true
		_suites_time = -1.0
		return
	active_id = "peripheral_29"
	_frame["phase"] = "glimpse"
	var envelope: float = minf(clampf(_suites_time / 0.65, 0.0, 1.0), clampf((SUITES_DURATION - _suites_time) / 0.8, 0.0, 1.0))
	var gaze_fade: float = 1.0 - clampf(_suites_gaze / 0.6, 0.0, 1.0)
	_frame["suites_alpha"] = envelope * gaze_fade * 0.72

func _advance_trace(dt: float, context: Dictionary) -> void:
	if _trace_restored:
		_render_trace()
		return
	if _trace_time < 0.0:
		if not _nearby(context, TRACE_POSITION, 0.0, 12.0):
			_trace_quiet = 0.0
			return
		_trace_quiet += dt
		if _trace_quiet < TRACE_QUIET or dt <= 0.0:
			return
		_trace_time = _trace_quiet - TRACE_QUIET
		_cue("water_step", TRACE_POSITION)
	else:
		_trace_time = minf(TRACE_DURATION, _trace_time + dt)
	_render_trace()

func _render_trace() -> void:
	var progress: float = 1.0 if _trace_restored else clampf(_trace_time / TRACE_DURATION, 0.0, 1.0)
	_frame["trace_progress"] = progress
	_frame["trace_alpha"] = 0.78 if progress > 0.0 else 0.0
	if progress > 0.0:
		active_id = "damp_trace_28"
		_frame["id"] = active_id
		_frame["phase"] = "settled" if progress >= 1.0 else "forming"

func _advance_spa(dt: float, context: Dictionary) -> void:
	var facing: float = _facing(context, SPA_POSITION + Vector3(0, 1.2, 0))
	var nearby: bool = _nearby(context, SPA_POSITION, 3.1, 13.0)
	var line_of_sight: bool = bool(context.get("line_of_sight", true))
	if bool(context.get("flare_active", false)):
		_spa_quiet = 0.0
		return
	if _spa_time < 0.0:
		if _spa_occurrences >= MAX_SPA_OCCURRENCES:
			return
		if _spa_occurrences == 0:
			if not nearby or facing < 0.55 or facing > 0.96 or not line_of_sight:
				_spa_quiet = 0.0
				return
			_spa_quiet += dt
			if _spa_quiet < SPA_QUIET or dt <= 0.0:
				return
			_spa_time = _spa_quiet - SPA_QUIET
		else:
			_spa_wait = minf(SPA_RETURN_WAIT, _spa_wait + dt)
			if facing < 0.2:
				_spa_away = minf(SPA_LOOK_AWAY, _spa_away + dt)
			if _spa_wait < SPA_RETURN_WAIT or _spa_away < SPA_LOOK_AWAY or not nearby or facing < 0.55 or not line_of_sight or dt <= 0.0:
				return
			_spa_time = 0.0
		_spa_occurrences += 1
		_cue("cloth_shift", SPA_POSITION)
	else:
		_spa_time += dt
	if _spa_time >= SPA_DURATION or not nearby:
		_spa_time = -1.0
		_spa_wait = 0.0
		_spa_away = 0.0
		return
	if not line_of_sight:
		return
	active_id = "presence_26"
	_frame["phase"] = "returning" if _spa_occurrences == 2 else "lingering"
	_frame["recurrence"] = _spa_occurrences
	# A constant physical pose, without approach, tracking, eye glow or damage.
	var envelope: float = minf(clampf(_spa_time / 1.1, 0.0, 1.0), clampf((SPA_DURATION - _spa_time) / 1.2, 0.0, 1.0))
	_frame["spa_alpha"] = envelope * (0.76 if _spa_occurrences == 2 else 0.64)

func _nearby(context: Dictionary, target: Vector3, minimum: float, maximum: float) -> bool:
	var position_value: Variant = context.get("player_position", Vector3.INF)
	if not position_value is Vector3 or not position_value.is_finite():
		return false
	var distance: float = Vector2(position_value.x - target.x, position_value.z - target.z).length()
	return absf(position_value.y - target.y) < 3.0 and distance >= minimum and distance <= maximum

func _facing(context: Dictionary, target: Vector3) -> float:
	var position_value: Variant = context.get("camera_position", Vector3.INF)
	var forward: Variant = context.get("camera_forward", Vector3.ZERO)
	if not position_value is Vector3 or not forward is Vector3 or not position_value.is_finite() or not forward.is_finite() or forward.length_squared() < 0.0001:
		return -1.0
	var direction: Vector3 = target - position_value
	if direction.length_squared() < 0.0001:
		return 1.0
	return clampf(forward.normalized().dot(direction.normalized()), -1.0, 1.0)

func _cue(id_value: String, position_value: Vector3) -> void:
	cue_serial += 1
	_cue_id = id_value
	_cue_position = position_value

func _empty_frame() -> Dictionary:
	return {"id": "", "phase": "quiet", "recurrence": 0, "suites_alpha": 0.0, "trace_alpha": 0.0, "trace_progress": 0.0, "spa_alpha": 0.0, "cue_serial": cue_serial, "cue_id": _cue_id, "cue_position": _cue_position}
