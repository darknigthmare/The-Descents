extends RefCounted
## Scenario placement for tests/captures that exercise an interaction's outcome.
## Route suites remain responsible for proving travel between those positions.

static func face(mission: Node3D, target: Node3D) -> void:
	if not is_instance_valid(target):
		push_error("An interaction fixture has no target.")
		return
	var number: int = int(target.get_meta("floor", 31))
	mission.player.teleport_to_floor(number)
	var rappel: bool = str(target.get_meta("kind", "")) == "rappel"
	mission.player.global_position = target.global_position + Vector3(0, 0.06, 0.0 if rappel else 1.3)
	mission.player.velocity = Vector3.ZERO
	mission.player.camera.look_at(target.global_position + Vector3(1, 1.1, 0) if rappel else mission._legacy_interaction_focus(target))
	mission.last_floor = number
