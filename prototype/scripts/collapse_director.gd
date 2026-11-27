class_name CollapseDirector
extends RefCounted
## A deterministic, one-shot incident clock. The caller owns player progression,
## pause, presentation and checkpoints; no wall-clock timer runs independently.

const DURATIONS: Dictionary = {
	"warning": 8.0,
	"quake": 6.0,
	"collapse": 7.0,
	"impact": 4.0
}
const NEXT_PHASE: Dictionary = {
	"warning": "quake", "quake": "collapse",
	"collapse": "impact", "impact": "aftermath"
}
const STABLE_STATES: Array[String] = ["intact", "aftermath"]

var phase: String = "intact"
var phase_elapsed: float = 0.0


func start() -> bool:
	if phase != "intact":
		return false
	phase = "warning"
	phase_elapsed = 0.0
	return true


func advance(delta: float) -> Array[String]:
	var entered: Array[String] = []
	if not is_active() or not is_finite(delta) or delta <= 0.0:
		return entered
	var remaining: float = delta
	while remaining > 0.0 and is_active():
		var time_left: float = float(DURATIONS[phase]) - phase_elapsed
		if remaining < time_left:
			phase_elapsed += remaining
			break
		remaining -= time_left
		phase = str(NEXT_PHASE[phase])
		phase_elapsed = 0.0
		entered.append(phase)
	return entered


func is_active() -> bool:
	return DURATIONS.has(phase)


func restore(saved_state: String) -> void:
	# Unsupported values are ignored: a corrupt call cannot rewind a completed
	# event. Persistent files are validated by DescentSave before this method.
	if not STABLE_STATES.has(saved_state):
		return
	phase = saved_state
	phase_elapsed = 0.0


func stable_state() -> String:
	# An interrupted sequence replays from its explicit pre-incident checkpoint.
	return "aftermath" if phase == "aftermath" else "intact"
