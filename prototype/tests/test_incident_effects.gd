extends SceneTree
## Regression coverage for dust settling, pause and restoration after the impact.
## Run: godot --headless --path prototype --script tests/test_incident_effects.gd
const MainScene = preload("res://scenes/main.tscn")
var checks: int = 0
var failures: Array[String] = []

func _initialize() -> void:
	_run.call_deferred()

func _run() -> void:
	var mission: Node3D = MainScene.instantiate()
	mission.save_path = "user://qa_cosmetic_settling_unused.json"
	mission.sound_enabled = false
	root.add_child(mission)
	mission.set_process(false)
	mission.player.set_physics_process(false)
	var world: Node3D = mission.world
	world.set_process(false)
	_check(not world.dust_group.visible, "Initial dust must be absent.")
	_check(world.hesperie_sign.visible, "The intact sign must remain visible.")
	world.apply_incident("impact", 1.2)
	_check(world.dust_group.visible, "Impact must create dust.")
	_check(not world.hesperie_sign.visible, "The sign must be removed at impact.")
	world.apply_incident("aftermath", 0.0)
	_check(world.dust_group.visible and is_zero_approx(world.aftermath_dust_elapsed), "A witnessed impact must start its settling tail.")
	var pose: Transform3D = world.twin_tower.transform
	world._process(4.0)
	_check(is_equal_approx(world.aftermath_dust_elapsed, 4.0) and world.dust_group.scale.x < 1.15, "Cosmetic dust must advance and shrink.")
	world.apply_incident("aftermath", 0.0)
	_check(is_equal_approx(world.aftermath_dust_elapsed, 4.0), "Stable director samples must not reset the cosmetic timer.")
	_check(world.twin_tower.transform.is_equal_approx(pose), "Cosmetic settling changed tower geometry.")
	mission._pause()
	_check(not world.is_processing(), "Pause must disable the world cosmetic clock.")
	var paused_size: Vector3 = world.dust_group.scale
	for index in range(3):
		await process_frame
	_check(is_equal_approx(world.aftermath_dust_elapsed, 4.0) and world.dust_group.scale.is_equal_approx(paused_size), "Dust advanced through a real paused frame.")
	mission._resume()
	_check(world.is_processing(), "Resume must restore cosmetic processing.")
	await process_frame
	await process_frame
	_check(world.aftermath_dust_elapsed > 4.0, "The actual resumed world process did not advance dust.")
	world.set_process(false)
	world._process(10.0)
	_check(is_equal_approx(world.aftermath_dust_elapsed, 10.0) and not world.dust_group.visible, "Dust must disappear after ten active seconds.")
	world.apply_incident("aftermath", 0.0)
	_check(not world.dust_group.visible and world.twin_tower.transform.is_equal_approx(pose), "Settled sampling regenerated dust or changed geometry.")
	world.apply_incident("intact", 0.0)
	_check(world.hesperie_sign.visible and not world.dust_group.visible, "Reset to intact did not restore sign/dust state.")
	world.apply_incident("aftermath", 0.0)
	_check(not world.dust_group.visible and is_equal_approx(world.aftermath_dust_elapsed, 10.0), "A direct aftermath restore must have no fresh dust cloud.")
	_check(not world.hesperie_sign.visible and world.twin_tower.transform.is_equal_approx(pose), "Restored aftermath sign or geometry differs from the stable state.")
	mission.free()
	if failures.is_empty():
		print("PASS cosmetic settling: %d checks; witnessed impact, stable sampling, real pause/resume frames, ten-second decay, direct restoration and removed sign." % checks)
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		quit(1)

func _check(condition: bool, message: String) -> void:
	checks += 1
	if not condition:
		failures.append(message)
