extends CharacterBody3D
class_name DescentPlayer

signal lost_footing

const Preferences = preload("res://scripts/preferences_store.gd")

var active: bool = false
var on_rope: bool = false
var reduced_motion: bool = true
var carrying: bool = false
var lamp_enabled: bool = true
var sensitivity: float = 0.0024
var invert_y: bool = false
var field_of_view: float = 77.0
var rope_anchor: Vector3 = Vector3(0, 45, 0)
var sway: float = 0.0
var sway_speed: float = 0.0
var secured_time: float = 0.0
var walk_time: float = 0.0
var camera: Camera3D
var head: Node3D
var flashlight: SpotLight3D
var rope_mesh: MeshInstance3D
var rope_line: ImmediateMesh
var rope_material: StandardMaterial3D
var stamina: float = 100.0
var environment_speed: float = 1.0
var disaster_intensity: float = 0.0
var disaster_time: float = 0.0

func _ready() -> void:
	name = "Rescuer"
	var capsule: CapsuleShape3D = CapsuleShape3D.new()
	capsule.radius = 0.34
	capsule.height = 1.72
	var shape: CollisionShape3D = CollisionShape3D.new()
	shape.shape = capsule
	shape.position.y = 0.87
	add_child(shape)
	floor_snap_length = 0.22
	head = Node3D.new()
	head.position.y = 1.62
	add_child(head)
	camera = Camera3D.new()
	camera.fov = field_of_view
	camera.near = 0.07
	camera.far = 1300
	head.add_child(camera)
	camera.current = true
	flashlight = SpotLight3D.new()
	flashlight.light_color = Color(1.0, 0.88, 0.66)
	flashlight.light_energy = 1.35
	flashlight.spot_range = 27.0
	flashlight.spot_angle = 32.0
	flashlight.spot_attenuation = 1.4
	flashlight.position = Vector3(0.24, -0.18, -0.08)
	camera.add_child(flashlight)
	# A small, diegetic torch instead of an oversized weapon.
	var torch: MeshInstance3D = MeshInstance3D.new()
	var tube: CylinderMesh = CylinderMesh.new()
	tube.top_radius = 0.045
	tube.bottom_radius = 0.04
	tube.height = 0.32
	torch.mesh = tube
	torch.rotation.x = PI / 2
	torch.position = Vector3(0.27, -0.29, -0.47)
	var mat: StandardMaterial3D = StandardMaterial3D.new()
	mat.albedo_color = Color(0.1, 0.16, 0.17)
	mat.metallic = 0.6
	torch.material_override = mat
	camera.add_child(torch)
	rope_line = ImmediateMesh.new()
	rope_mesh = MeshInstance3D.new()
	rope_mesh.mesh = rope_line
	rope_mesh.top_level = true
	rope_material = StandardMaterial3D.new()
	rope_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	rope_material.albedo_color = Color(1.0, 0.57, 0.19)
	rope_mesh.material_override = rope_material
	add_child(rope_mesh)

func apply_comfort(settings: Dictionary) -> void:
	var clean: Dictionary = Preferences.normalize(settings)
	reduced_motion = bool(clean["reduced_motion"])
	sensitivity = 0.0024 * float(clean["mouse_sensitivity"])
	invert_y = bool(clean["invert_y"])
	field_of_view = float(clean["field_of_view"])
	if is_instance_valid(camera):
		camera.fov = field_of_view

func _unhandled_input(event: InputEvent) -> void:
	if not active:
		return
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		_apply_mouse_look(event.relative)

func _apply_mouse_look(relative: Vector2) -> void:
	rotate_y(-relative.x * sensitivity)
	head.rotation.x = clampf(head.rotation.x - relative.y * sensitivity * (-1.0 if invert_y else 1.0), -1.35, 1.35)

func _physics_process(delta: float) -> void:
	if not active:
		return
	var look_x: float = Input.get_axis("look_left", "look_right")
	var look_y: float = Input.get_axis("look_up", "look_down")
	rotate_y(-look_x * delta * 1.5)
	head.rotation.x = clampf(head.rotation.x - look_y * delta * 1.2 * (-1.0 if invert_y else 1.0), -1.35, 1.35)
	if on_rope:
		_process_rope(delta)
	else:
		_process_walk(delta)
	_apply_disaster_motion()
	flashlight.visible = lamp_enabled
	if position.y < 2.0:
		active = false
		lost_footing.emit()

func _process_walk(delta: float) -> void:
	var axis: Vector2 = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var direction: Vector3 = (transform.basis * Vector3(axis.x, 0, axis.y)).normalized()
	var crouched: bool = Input.is_action_pressed("crouch")
	var sprinting: bool = Input.is_action_pressed("sprint") and stamina > 5 and not carrying and not crouched
	var speed: float = 3.7
	if sprinting:
		speed = 6.0
	if carrying:
		speed = 2.4
	if crouched:
		speed = 1.8
	speed *= environment_speed
	if sprinting and axis.length() > 0.1:
		stamina = maxf(0.0, stamina - delta * 14)
	else:
		stamina = minf(100.0, stamina + delta * 11)
	velocity.x = move_toward(velocity.x, direction.x * speed, delta * 25)
	velocity.z = move_toward(velocity.z, direction.z * speed, delta * 25)
	if not is_on_floor():
		velocity.y -= 16.0 * delta
	elif Input.is_action_just_pressed("jump") and not carrying:
		velocity.y = 5.6
	else:
		velocity.y = 0.0
	move_and_slide()
	head.position.y = lerpf(head.position.y, 1.12 if crouched else 1.62, delta * 10)
	if not reduced_motion:
		walk_time += delta * velocity.length() * 1.8
		camera.position.y = sin(walk_time) * 0.025 if is_on_floor() else 0
	else:
		camera.position.y = 0

func _process_rope(delta: float) -> void:
	var descent: float = Input.get_axis("move_forward", "move_back")
	var lateral: float = Input.get_axis("move_left", "move_right")
	secured_time = maxf(0.0, secured_time - delta)
	var wind: float = sin(Time.get_ticks_msec() * 0.0013) * (0.14 if secured_time > 0 else 0.5)
	sway_speed += (lateral * 3.0 + wind - sway * 3.5 - sway_speed * 2.3) * delta
	sway = clampf(sway + sway_speed * delta, -1.8, 1.8)
	position.x = sway
	position.z = 0.0
	position.y = clampf(position.y - descent * delta * 2.8, 6.04, 42.04)
	velocity = Vector3.ZERO
	head.position.y = 1.62
	camera.position.y = 0
	camera.rotation.z = 0 if reduced_motion else -sway * 0.025
	stamina = minf(100.0, stamina + delta * 8)
	_draw_rope()

func _apply_disaster_motion() -> void:
	# Camera comfort never changes scene timing, visibility or control.
	if reduced_motion:
		camera.position = Vector3.ZERO
		camera.rotation.z = 0
		return
	var strength: float = clampf(disaster_intensity, 0, 1)
	camera.position.x = sin(disaster_time * 29.0) * 0.025 * strength
	camera.position.y += sin(disaster_time * 37.0) * 0.018 * strength
	camera.rotation.z = (-sway * 0.025 if on_rope else 0.0) + sin(disaster_time * 21.0) * 0.009 * strength

func engage_rope(floor_number: int) -> void:
	on_rope = true
	position = Vector3(0, (floor_number - 24) * 6 + 0.04, 0)
	sway = 0
	sway_speed = 0
	velocity = Vector3.ZERO
	rope_mesh.visible = true
	rope_anchor = Vector3(0, 45, 0)
	_draw_rope()

func leave_rope(floor_number: int) -> void:
	on_rope = false
	position = Vector3(4.2, (floor_number - 24) * 6 + 0.06, 0.55)
	velocity = Vector3.ZERO
	camera.rotation.z = 0
	rope_mesh.visible = false

func secure_anchor() -> void:
	secured_time = 16.0
	sway_speed = 0
	sway = 0
	rope_anchor = Vector3(2.55, position.y + 3.0, 0)
	_draw_rope()

func _draw_rope() -> void:
	rope_line.clear_surfaces()
	rope_line.surface_begin(Mesh.PRIMITIVE_LINES)
	rope_line.surface_add_vertex(rope_anchor)
	rope_line.surface_add_vertex(position + Vector3(0.12, 0.8, -0.45))
	rope_line.surface_end()

func nearest_floor() -> int:
	return clampi(roundi((position.y - 0.04) / 6.0) + 24, 25, 31)

func can_exit_rope() -> bool:
	return absf(position.y - (nearest_floor() - 24) * 6) < 0.8

func teleport_to_floor(floor_number: int) -> void:
	leave_rope(floor_number)
	rotation = Vector3.ZERO
	head.rotation = Vector3.ZERO
