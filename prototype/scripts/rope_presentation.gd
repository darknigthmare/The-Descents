extends Node3D
class_name DescentRopePresentation
## Camera-space descender and gloved hands. Sampling has no gameplay effects.

var lever: Node3D
var left_hand: Node3D
var right_hand: Node3D
var indicator: MeshInstance3D
var metal: StandardMaterial3D
var glove: StandardMaterial3D
var orange: StandardMaterial3D
var safe: StandardMaterial3D

func _ready() -> void:
	name = "RopeHandsAndDescender"
	metal = _material(Color("6e898c"), 0.65)
	glove = _material(Color("233d45"), 0.0)
	orange = _material(Color("e1a15d"), 0.0)
	safe = _material(Color("65d1ba"), 0.15)
	var jacket: StandardMaterial3D = _material(Color("dfad55"), 0.0)
	# The descending strand crosses the device, separate from the rescue hoist.
	_beam(self, Vector3(0.08, -0.04, -0.51), Vector3(0.08, -0.53, -0.51), 0.012, orange)
	_box(self, Vector3(0.08, -0.33, -0.51), Vector3(0.105, 0.14, 0.045), metal)
	_box(self, Vector3(0.08, -0.33, -0.48), Vector3(0.065, 0.08, 0.014), glove)
	lever = Node3D.new()
	lever.position = Vector3(0.12, -0.31, -0.46)
	add_child(lever)
	_box(lever, Vector3(0.035, -0.055, 0), Vector3(0.025, 0.14, 0.035), orange)
	indicator = _box(self, Vector3(0.065, -0.29, -0.465), Vector3(0.025, 0.014, 0.008), safe)
	# A rectangular carabiner with an open centre, sized to the descender.
	for x: float in [0.045, 0.115]:
		_beam(self, Vector3(x, -0.40, -0.50), Vector3(x, -0.48, -0.50), 0.009, metal)
	for y: float in [-0.40, -0.48]:
		_beam(self, Vector3(0.045, y, -0.50), Vector3(0.115, y, -0.50), 0.009, metal)
	left_hand = _hand(Vector3(-0.03, -0.17, -0.51), -1.0, jacket)
	right_hand = _hand(Vector3(0.22, -0.39, -0.47), 1.0, jacket)
	hide()

func _material(color: Color, metallic_value: float) -> StandardMaterial3D:
	var result := StandardMaterial3D.new()
	result.albedo_color = color
	result.metallic = metallic_value
	result.roughness = 0.72
	return result

func _hand(point: Vector3, side: float, sleeve: Material) -> Node3D:
	var hand := Node3D.new()
	hand.position = point
	add_child(hand)
	_box(hand, Vector3.ZERO, Vector3(0.11, 0.075, 0.08), glove)
	for index in range(4):
		_box(hand, Vector3(-side * 0.052, 0.025 - index * 0.017, -0.025), Vector3(0.045, 0.013, 0.045), glove)
	_box(hand, Vector3(side * 0.005, -0.04, 0.015), Vector3(0.065, 0.025, 0.045), glove)
	_beam(hand, Vector3(side * 0.06, -0.015, 0.015), Vector3(side * 0.19, -0.13, 0.23), 0.065, sleeve)
	return hand

func _box(parent: Node3D, point: Vector3, size_value: Vector3, material: Material) -> MeshInstance3D:
	var instance := MeshInstance3D.new()
	var shape := BoxMesh.new()
	shape.size = size_value
	instance.mesh = shape
	instance.material_override = material
	instance.position = point
	instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	parent.add_child(instance)
	return instance

func _beam(parent: Node3D, a: Vector3, b: Vector3, radius: float, material: Material) -> void:
	var instance := MeshInstance3D.new()
	var shape := CylinderMesh.new()
	shape.top_radius = radius
	shape.bottom_radius = radius
	shape.height = a.distance_to(b)
	shape.radial_segments = 10
	instance.mesh = shape
	instance.material_override = material
	instance.position = (a + b) * 0.5
	instance.quaternion = Quaternion(Vector3.UP, (b - a).normalized())
	instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	parent.add_child(instance)

func sample(state: Dictionary, reduced_motion: bool) -> void:
	visible = bool(state.get("active", false))
	if not visible or not is_instance_valid(lever):
		return
	var locked: bool = bool(state.get("locked", false))
	var speed_value: float = clampf(float(state.get("speed", 0.0)), 0.0, 4.2)
	lever.rotation.z = 0.0 if locked else speed_value * 0.10
	indicator.material_override = safe if locked or speed_value < 0.08 else orange
	var motion: float = 0.0 if reduced_motion else sin(float(state.get("deployed", 0.0)) * 5.0) * 0.012 * minf(speed_value, 1.0)
	left_hand.position.y = -0.17 + motion
	right_hand.position.y = -0.39 - motion * 0.5
