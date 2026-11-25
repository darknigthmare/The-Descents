extends CharacterBody3D
class_name DescentPlayer

signal lost_footing
signal traversal_notice(message: String)

const Preferences = preload("res://scripts/preferences_store.gd")
const Routes = preload("res://scripts/route_catalog.gd")
const Rope = preload("res://scripts/rope_traversal.gd")
const RopePresentation = preload("res://scripts/rope_presentation.gd")

const TRANSFER_DURATION: float = 0.85
const FLOOR_TOLERANCE: float = 0.35

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
var rope = Rope.new()
var rope_presentation: Node3D
var rope_transfer: String = ""
var rope_transfer_origin: Vector3 = Vector3.ZERO
var rope_transfer_target: Vector3 = Vector3.ZERO
var rope_transfer_elapsed: float = 0.0
var rope_transfer_floor: int = 0
var rope_obstructed: bool = false
var last_ground_height: float = 42.0

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
	rope_mesh.hide()
	rope_presentation = RopePresentation.new()
	camera.add_child(rope_presentation)

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
	if position.y < 2.0 or (not on_rope and position.y < last_ground_height - 3.5):
		active = false
		lost_footing.emit()

func _process_walk(delta: float) -> void:
	if is_on_floor():
		last_ground_height = position.y
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
	if not active or not is_finite(delta) or delta <= 0.0:
		return
	if not rope_transfer.is_empty():
		_process_rope_transfer(delta)
		return
	var state: Dictionary = rope.advance(delta, {
		"vertical": Input.get_axis("move_forward", "move_back"),
		"lateral": Input.get_axis("move_left", "move_right"),
		"precision": Input.is_action_pressed("crouch"),
		"fast": Input.is_action_pressed("sprint"),
		"running": active,
		"wind_strength": clampf(0.35 + disaster_intensity * 0.65, 0.0, 1.0),
	})
	if not bool(state.get("active", false)):
		return
	# Keep the capsule in the physical world. A newly blocked shaft stops the
	# descender; it never lets the prescribed rope position pass through a wall.
	var collision: KinematicCollision3D = move_and_collide(Vector3(state["position"]) - global_position)
	rope_obstructed = collision != null
	if rope_obstructed:
		rope.sync_position(global_position)
		state = rope.snapshot()
	_apply_rope_state(state)
	velocity = Vector3.ZERO
	head.position.y = 1.62
	camera.position.y = 0
	camera.rotation.z = 0 if reduced_motion else -sway * 0.025
	_draw_rope()
	rope_presentation.sample(state, reduced_motion)

func _apply_rope_state(state: Dictionary) -> void:
	sway = float(state.get("sway", 0.0))
	sway_speed = float(state.get("sway_speed", 0.0))
	secured_time = float(state.get("secured_time", 0.0))
	stamina = float(state.get("stamina", stamina))
	rope_anchor = state.get("anchor", rope_anchor)

func _process_rope_transfer(delta: float) -> void:
	if not active:
		return
	var next_elapsed: float = minf(TRANSFER_DURATION, rope_transfer_elapsed + delta)
	var ratio: float = smoothstep(0.0, 1.0, next_elapsed / TRANSFER_DURATION)
	var target: Vector3 = rope_transfer_origin.lerp(rope_transfer_target, ratio)
	var collision: KinematicCollision3D = move_and_collide(target - global_position)
	velocity = Vector3.ZERO
	if collision != null and global_position.distance_to(target) > 0.015:
		if not rope_obstructed:
			traversal_notice.emit("Passage encombré. La longe reste attachée ; dégagez le palier.")
		rope_obstructed = true
		_draw_rope()
		return
	rope_obstructed = false
	rope_transfer_elapsed = next_elapsed
	_draw_rope()
	rope_presentation.sample(rope_snapshot(), reduced_motion)
	if next_elapsed < TRANSFER_DURATION:
		return
	if rope_transfer == "exit":
		_finish_dismount()
	else:
		rope.sync_position(global_position)
		rope_transfer = ""

func _begin_transfer(kind: String, target: Vector3, floor_number: int) -> void:
	rope_transfer = kind
	rope_transfer_origin = global_position
	rope_transfer_target = target
	rope_transfer_elapsed = 0.0
	rope_transfer_floor = floor_number
	rope_obstructed = false
	velocity = Vector3.ZERO

func _has_landing_support(point: Vector3) -> bool:
	if not is_inside_tree():
		return false
	var query := PhysicsRayQueryParameters3D.create(point + Vector3(0, 0.16, 0), point - Vector3(0, 0.40, 0))
	query.exclude = [get_rid()]
	var result: Dictionary = get_world_3d().direct_space_state.intersect_ray(query)
	return not result.is_empty() and Vector3(result.get("normal", Vector3.ZERO)).y >= 0.7

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

func engage_rope(floor_number: int, route_id: String = "") -> bool:
	if on_rope or carrying or not is_at_landing() or nearest_floor() != floor_number:
		return false
	var route: Dictionary = Routes.for_id(route_id)
	if route_id.is_empty():
		for candidate: Dictionary in Routes.routes_at_floor(floor_number):
			if str(candidate.get("kind", "")) == "rope":
				route = candidate
				break
	if route.is_empty() or str(route.get("kind", "")) != "rope":
		return false
	var upper: int = int(route.get("upper", 0))
	var lower: int = int(route.get("lower", 0))
	if floor_number != upper and floor_number != lower:
		return false
	var entry: Vector3 = route["top_entry"] if floor_number == upper else route["bottom_entry"]
	var target: Vector3 = route["rope_top"] if floor_number == upper else route["rope_bottom"]
	if global_position.distance_to(entry) > 2.7 or not _has_landing_support(global_position):
		return false
	if test_move(global_transform, target - global_position):
		traversal_notice.emit("Accès au rappel obstrué. Rejoignez le repère bleu au bord de l’ouverture.")
		return false
	if not rope.attach(route, floor_number, stamina):
		return false
	on_rope = true
	sway = 0.0
	sway_speed = 0.0
	_apply_rope_state(rope.snapshot())
	rope_mesh.show()
	_begin_transfer("attach", target, floor_number)
	_draw_rope()
	return true

func leave_rope(floor_number: int) -> bool:
	if not can_exit_rope() or floor_number != rope.exit_floor():
		return false
	var landing: Vector3 = rope.landing()
	if not _has_landing_support(landing) or test_move(global_transform, landing - global_position):
		traversal_notice.emit("Palier encombré. Restez assuré et libérez la zone de sortie.")
		return false
	_begin_transfer("exit", landing, floor_number)
	return true

func _finish_dismount() -> void:
	on_rope = false
	rope.detach()
	rope_transfer = ""
	rope_obstructed = false
	sway = 0.0
	sway_speed = 0.0
	secured_time = 0.0
	velocity = Vector3.ZERO
	last_ground_height = position.y
	camera.rotation.z = 0.0
	rope_mesh.hide()
	rope_presentation.hide()

func secure_anchor() -> bool:
	if not on_rope or not rope_transfer.is_empty() or not rope.secure():
		return false
	_apply_rope_state(rope.snapshot())
	_draw_rope()
	return true

func toggle_rope_lock() -> bool:
	if not on_rope or not rope_transfer.is_empty():
		return false
	return rope.toggle_lock()

func rope_snapshot() -> Dictionary:
	var state: Dictionary = rope.snapshot()
	state["transfer"] = rope_transfer
	state["obstructed"] = rope_obstructed
	if not rope_transfer.is_empty():
		state["mode"] = "attach" if rope_transfer == "attach" else "exit"
		state["can_exit"] = false
		state["speed"] = 0.0
	return state

func stair_context() -> Dictionary:
	return {} if on_rope else Routes.stair_at_position(global_position)

func is_at_landing() -> bool:
	return not on_rope and stair_context().is_empty() and absf(velocity.y) <= 0.15 and absf(position.y - Routes.floor_height(nearest_floor())) <= FLOOR_TOLERANCE and _has_landing_support(global_position)

func _draw_rope() -> void:
	rope_line.clear_surfaces()
	rope_line.surface_begin(Mesh.PRIMITIVE_LINES)
	rope_line.surface_add_vertex(rope_anchor)
	rope_line.surface_add_vertex(position + Vector3(0.12, 0.8, -0.45))
	rope_line.surface_end()

func nearest_floor() -> int:
	return clampi(roundi((position.y - 0.04) / 6.0) + 24, 25, 31)

func can_exit_rope() -> bool:
	return on_rope and rope_transfer.is_empty() and not rope_obstructed and rope.can_exit()

func teleport_to_floor(floor_number: int) -> void:
	# Save restoration is always a stable landing. Transient suspension and
	# transfers are deliberately absent from the schema-3 checkpoint.
	_finish_dismount()
	position = Vector3(4.2, (floor_number - 24) * 6 + 0.06, 0.55)
	last_ground_height = position.y
	rotation = Vector3.ZERO
	head.rotation = Vector3.ZERO
