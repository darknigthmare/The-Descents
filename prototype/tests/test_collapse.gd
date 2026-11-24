extends SceneTree
## Run: godot --headless --path prototype --script tests/test_collapse.gd

const Director = preload("res://scripts/collapse_director.gd")
var failures: Array[String] = []
var checks: int = 0


func _initialize() -> void:
	var incident = Director.new()
	_check(incident.phase == "intact" and not incident.is_active(), "A new world must start intact and idle.")
	_check(incident.advance(1000.0).is_empty() and incident.phase == "intact", "Elapsed playtime triggered the event without progression.")
	_check(incident.start(), "An intact world could not start the incident.")
	_check(incident.phase == "warning" and incident.is_active(), "Starting did not give the player a warning period.")
	_check(not incident.start(), "A repeated trigger restarted the warning.")
	_check(incident.advance(7.5).is_empty(), "The warning ended too soon.")
	var elapsed_before_pause: float = incident.phase_elapsed
	_check(incident.advance(0.0).is_empty() and incident.phase_elapsed == elapsed_before_pause, "Zero elapsed time advanced a paused incident.")
	for invalid_delta in [-1.0, NAN, INF]:
		_check(incident.advance(invalid_delta).is_empty() and incident.phase_elapsed == elapsed_before_pause, "An invalid frame duration changed incident progress.")
	_check(incident.advance(0.5) == ["quake"], "The warning did not transition at the exact boundary.")
	_check(incident.phase_elapsed == 0.0, "A boundary transition retained the previous phase time.")
	_check(incident.advance(6.25) == ["collapse"], "The quake did not enter the falling phase.")
	_check(is_equal_approx(incident.phase_elapsed, 0.25), "Time remaining after a transition was lost.")
	_check(incident.stable_state() == "intact", "An interrupted fall was marked as a completed collapse.")
	_check(incident.advance(6.75) == ["impact"], "Impact did not occur after the full falling duration.")
	_check(incident.advance(4.0) == ["aftermath"], "Impact did not settle into aftermath.")
	_check(not incident.is_active() and incident.stable_state() == "aftermath", "The settled world did not persist its final state.")
	_check(not incident.start() and incident.advance(9999.0).is_empty(), "A settled collapse could replay without a checkpoint restore.")
	incident.restore("collapse")
	_check(incident.phase == "aftermath", "An unsupported restore state rewound a completed event.")
	incident.restore("intact")
	_check(incident.phase == "intact" and incident.phase_elapsed == 0.0, "A pre-incident checkpoint did not rewind cleanly.")
	_check(incident.start(), "A restored pre-incident checkpoint could not replay the sequence.")
	_check(incident.advance(100.0) == ["quake", "collapse", "impact", "aftermath"], "A large frame skipped or reordered a transition event.")
	_check(incident.phase_elapsed == 0.0 and incident.stable_state() == "aftermath", "Large-frame completion left an unstable saved state.")
	incident.restore("aftermath")
	_check(not incident.is_active() and not incident.start(), "A post-incident checkpoint replayed the event.")
	var fine_steps = Director.new()
	fine_steps.start()
	var transitions: Array[String] = []
	for frame in range(1600):
		transitions.append_array(fine_steps.advance(1.0 / 60.0))
	_check(transitions == ["quake", "collapse", "impact", "aftermath"], "Normal frame steps diverged from a large-frame timeline.")
	_check(fine_steps.stable_state() == incident.stable_state(), "Timeline partition changed the persistent result.")
	if failures.is_empty():
		print("PASS collapse director: %d checks; one-shot progression, timing, frame gaps, pause-safe ticking and stable restores passed." % checks)
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		print("FAIL collapse director: %d failures / %d checks." % [failures.size(), checks])
		quit(1)


func _check(condition: bool, message: String) -> void:
	checks += 1
	if not condition:
		failures.append(message)
