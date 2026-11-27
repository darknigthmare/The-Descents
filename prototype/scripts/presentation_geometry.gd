extends RefCounted
class_name DescentPresentationGeometry

## Native, collision-free presentation geometry. No imported models or textures.
## The world builder owns the gameplay sockets and collision envelopes.

static func aircraft(w: Node3D, parent: Node3D, pos: Vector3, aircraft_name: String) -> Dictionary:
	var h: Node3D = Node3D.new()
	h.name = aircraft_name
	parent.add_child(h)
	h.position = pos
	h.set_meta("presentation_model", "rescue_aircraft_v05")
	var m: Dictionary = w.materials
	var skid_y: float = 42.11 - pos.y
	# Separate keel, cabin and roof leave a genuine opening behind the sliding doors.
	_sphere(h, Vector3(0,-0.20,-0.1), Vector3(1.25,0.29,2.15), m["orange"])
	_sphere(h, Vector3(0,1.67,0.0), Vector3(1.23,0.32,1.88), m["orange"])
	w._box(h,Vector3(0,0.02,0.25),Vector3(2.15,0.12,3.05),m["black_metal"])
	w._box(h,Vector3(0,0.85,1.55),Vector3(2.18,1.6,0.18),m["orange"])
	_sphere(h,Vector3(0,0.99,-1.63),Vector3(1.13,0.88,1.13),m["window"])
	_beam(w,h,Vector3(0,0.35,-2.59),Vector3(0,1.58,-2.24),0.055,m["orange"])
	_beam(w,h,Vector3(-0.91,0.72,-2.15),Vector3(-0.73,1.65,-1.91),0.06,m["orange"])
	_beam(w,h,Vector3(0.91,0.72,-2.15),Vector3(0.73,1.65,-1.91),0.06,m["orange"])
	for side in [-1.0,1.0]:
		for z: float in [-0.67,1.45]:
			w._box(h,Vector3(side*1.19,0.89,z),Vector3(0.09,1.6,0.08),m["metal"])
		w._box(h,Vector3(side*1.24,0.02,0.38),Vector3(0.15,0.13,2.3),m["metal"])
		w._box(h,Vector3(side*1.30,-0.63,0.35),Vector3(0.5,0.12,1.6),m["black_metal"])
		# The two existing aircraft origins differ by five centimetres. Each skid
		# is authored to touch the same y=42 roof, rather than floating above it.
		var skid: MeshInstance3D = _beam(w,h,Vector3(side*1.44,skid_y,-2.0),Vector3(side*1.44,skid_y,2.0),0.11,m["metal"])
		skid.name = "SkidLeft" if side < 0 else "SkidRight"
		_beam(w,h,Vector3(side*1.44,skid_y,-2.0),Vector3(side*1.44,skid_y+0.31,-2.38),0.11,m["metal"])
		for z: float in [-0.9,1.0]:
			_beam(w,h,Vector3(side*0.74,-0.05,z),Vector3(side*1.44,-1.20,z),0.075,m["metal"])
		var door: Node3D = Node3D.new()
		door.name = "DoorLeft" if side < 0 else "DoorRight"
		h.add_child(door)
		door.position = Vector3(side*1.24,0.86,0.39)
		door.set_meta("closed_position",door.position)
		w._box(door,Vector3.ZERO,Vector3(0.09,1.53,1.9),m["orange"])
		w._box(door,Vector3(side*0.052,0.22,0.0),Vector3(0.02,0.67,1.46),m["window"])
		for z: float in [-0.8,0.8]:
			w._box(door,Vector3(side*0.067,0.23,z),Vector3(0.025,0.78,0.045),m["metal"])
		w._box(door,Vector3(side*0.07,-0.43,0.02),Vector3(0.025,0.13,1.72),m["white"])
		w._box(door,Vector3(side*0.08,-0.10,-0.65),Vector3(0.055,0.07,0.25),m["black_metal"])
		var lettering: Label3D = w._label(door,Vector3(side*0.09,-0.47,0),"SECOURS",34,Color("152c33"),0.006,false)
		lettering.rotation.y = side*PI/2.0
		# Cabin benches, harnesses and cockpit crew are visible through the open door.
		for z: float in [-0.15,0.8]:
			w._box(h,Vector3(side*0.7,0.35,z),Vector3(0.45,0.12,0.54),m["dark"])
			w._box(h,Vector3(side*0.89,0.69,z),Vector3(0.12,0.7,0.53),m["blue"])
			w._box(h,Vector3(side*0.81,0.72,z),Vector3(0.04,0.6,0.065),m["yellow"])
		_sphere(h,Vector3(side*0.44,1.08,-1.47),Vector3(0.19,0.22,0.2),m["white"])
		w._box(h,Vector3(side*0.44,0.70,-1.4),Vector3(0.38,0.45,0.31),m["blue"])
		_sphere(h,Vector3(side*1.3,1.63,0.95),Vector3(0.07,0.07,0.09),m["lit_red"] if side < 0 else m["lit_green"])
	# Twin power plants and tapered tail establish a recognisable rescue silhouette.
	for side in [-1.0,1.0]:
		_sphere(h,Vector3(side*0.47,1.98,0.57),Vector3(0.35,0.30,1.04),m["cream"])
		var exhaust: MeshInstance3D = w._cylinder(h,Vector3(side*0.47,1.98,1.43),0.19,0.44,m["black_metal"])
		exhaust.rotation.x = PI/2.0
		for slot in range(5):
			w._box(h,Vector3(side*0.71,2.02,0.15+slot*0.19),Vector3(0.06,0.18,0.055),m["dark"])
	_beam(w,h,Vector3(0,0.72,1.5),Vector3(0,1.39,6.65),0.35,m["orange"],0.12)
	w._box(h,Vector3(0,1.38,5.69),Vector3(3.1,0.11,0.66),m["white"])
	var fin: MeshInstance3D = w._box(h,Vector3(0,2.0,6.37),Vector3(0.13,1.59,1.02),m["orange"])
	fin.rotation.x = -0.34
	w._box(h,Vector3(0.075,2.06,6.32),Vector3(0.035,0.22,0.88),m["white"])
	w._cylinder(h,Vector3(0,2.24,0),0.12,0.85,m["metal"])
	var rotor: Node3D = Node3D.new()
	rotor.name = "Rotor"
	h.add_child(rotor)
	rotor.position.y = 2.65
	_sphere(rotor,Vector3.ZERO,Vector3(0.34,0.16,0.34),m["metal"])
	for index in range(4):
		var blade: Node3D = Node3D.new()
		rotor.add_child(blade)
		blade.rotation.y = index*PI/2.0
		w._box(blade,Vector3(0,0,3.0),Vector3(0.24,0.06,5.25),m["dark"])
		w._box(blade,Vector3(0,0.005,5.46),Vector3(0.25,0.075,0.23),m["yellow"])
		_beam(w,blade,Vector3(0,-0.15,0),Vector3(0,0,0.95),0.04,m["metal"])
	var tail: Node3D = Node3D.new()
	tail.name = "TailRotor"
	h.add_child(tail)
	tail.position = Vector3(0.23,1.62,6.53)
	w._box(tail,Vector3.ZERO,Vector3(0.09,1.76,0.15),m["dark"])
	w._box(tail,Vector3.ZERO,Vector3(0.09,0.15,1.76),m["dark"])
	_sphere(tail,Vector3.ZERO,Vector3(0.15,0.15,0.15),m["metal"])
	_beam(w,h,Vector3(0,2.1,-1.0),Vector3(0,2.5,-1.28),0.022,m["black_metal"])
	_sphere(h,Vector3(0,2.82,6.1),Vector3(0.075,0.075,0.075),m["lit_red"])
	var lamp: MeshInstance3D = _sphere(h,Vector3(0,-0.13,-2.04),Vector3(0.19,0.16,0.17),m["lit_blue"])
	lamp.name = "SearchlightLens"
	w._light(h,Vector3(0,-0.4,-1.75),Color("d3e9e6"),1.6,10)
	return {"helicopter":h,"rotor":rotor}

static func human(w: Node3D, parent: Node3D, pos: Vector3, clothing: Material, helmet: bool) -> Node3D:
	var p: Node3D = Node3D.new()
	p.name = "RescueFigure" if helmet else "CivilianFigure"
	parent.add_child(p)
	p.position = pos
	p.set_meta("presentation_model","articulated_human_v05")
	var m: Dictionary = w.materials
	_capsule(p,Vector3(0,1.17,0),0.265,0.67,clothing,Vector3(1,1,0.67))
	w._box(p,Vector3(0,0.89,-0.005),Vector3(0.49,0.08,0.33),m["black_metal"])
	for side in [-1.0,1.0]:
		var leg: Node3D = Node3D.new()
		leg.name = "LeftLeg" if side < 0 else "RightLeg"
		p.add_child(leg)
		leg.position = Vector3(side*0.145,0.88,0)
		_capsule(leg,Vector3(0,-0.22,0),0.105,0.46,m["dark"])
		_capsule(leg,Vector3(0,-0.58,0),0.09,0.42,m["dark"])
		_sphere(leg,Vector3(0,-0.44,-0.075),Vector3(0.10,0.12,0.055),m["black_metal"])
		_sphere(leg,Vector3(0,-0.79,-0.07),Vector3(0.115,0.10,0.21),m["black_metal"])
		w._box(leg,Vector3(0,-0.85,-0.075),Vector3(0.22,0.04,0.36),m["dark"])
		var arm: Node3D = Node3D.new()
		arm.name = "LeftArm" if side < 0 else "RightArm"
		p.add_child(arm)
		arm.position = Vector3(side*0.29,1.41,0)
		arm.rotation.z = side*0.09
		arm.set_meta("rest_rotation",arm.rotation)
		_capsule(arm,Vector3(side*0.025,-0.20,0),0.09,0.41,clothing)
		_capsule(arm,Vector3(side*0.045,-0.48,-0.035),0.075,0.32,clothing)
		_sphere(arm,Vector3(side*0.05,-0.68,-0.045),Vector3(0.075,0.11,0.08),m["black_metal"] if helmet else m["skin"])
		if helmet:
			w._box(arm,Vector3(side*0.028,-0.31,-0.079),Vector3(0.15,0.065,0.015),m["yellow"])
	w._cylinder(p,Vector3(0,1.52,0),0.065,0.14,m["skin"])
	_sphere(p,Vector3(0,1.69,-0.015),Vector3(0.165,0.205,0.17),m["skin"])
	_sphere(p,Vector3(0,1.68,-0.18),Vector3(0.035,0.055,0.045),m["skin"])
	if helmet:
		_sphere(p,Vector3(0,1.84,0.005),Vector3(0.21,0.135,0.23),m["white"])
		w._box(p,Vector3(0,1.76,-0.177),Vector3(0.32,0.09,0.055),m["window"])
		_sphere(p,Vector3(0,1.86,-0.22),Vector3(0.045,0.035,0.04),m["lit_blue"])
		for side in [-1.0,1.0]:
			w._box(p,Vector3(side*0.16,1.2,-0.177),Vector3(0.055,0.48,0.045),m["black_metal"])
			w._box(p,Vector3(side*0.20,1.03,-0.20),Vector3(0.115,0.15,0.09),m["black_metal"])
		w._box(p,Vector3(0,1.14,-0.205),Vector3(0.45,0.065,0.025),m["yellow"])
		_capsule(p,Vector3(0,1.23,0.27),0.21,0.63,m["orange"],Vector3(1,1,0.65))
		w._box(p,Vector3(0,1.25,0.42),Vector3(0.36,0.08,0.025),m["yellow"])
		w._box(p,Vector3(-0.16,1.36,-0.22),Vector3(0.09,0.16,0.065),m["dark"])
		_beam(w,p,Vector3(-0.16,1.42,-0.22),Vector3(-0.16,1.59,-0.22),0.009,m["black_metal"])
	else:
		_sphere(p,Vector3(0,1.82,0.045),Vector3(0.172,0.095,0.18),m["wood"])
	return p

static func roof_dressing(w: Node3D, roof: Node3D) -> void:
	var group: Node3D = Node3D.new()
	group.name = "RoofRescueEquipment"
	roof.add_child(group)
	var m: Dictionary = w.materials
	# The canopy is behind the medical roster and well outside all approach routes.
	for x: float in [5.5,11.1]:
		for z: float in [-11.1,-8.2]:
			_beam(w,group,Vector3(x,42,z),Vector3(x,44.65,z),0.045,m["metal"])
		_beam(w,group,Vector3(x,44.65,-11.1),Vector3(x,45.2,-9.65),0.045,m["metal"])
		_beam(w,group,Vector3(x,45.2,-9.65),Vector3(x,44.65,-8.2),0.045,m["metal"])
	for side in [-1.0,1.0]:
		var canvas: MeshInstance3D = w._box(group,Vector3(8.3,44.92,-9.65+side*0.73),Vector3(5.8,0.035,1.63),m["green"])
		canvas.rotation.x = side*0.36
	for x: float in [5.9,6.3]:
		w._cylinder(group,Vector3(x,42.57,-10.65),0.16,1.14,m["blue"])
		w._cylinder(group,Vector3(x,43.18,-10.65),0.055,0.14,m["metal"])
	w._box(group,Vector3(10.55,42.38,-10.3),Vector3(0.8,0.75,0.7),m["white"])
	w._box(group,Vector3(10.55,42.52,-9.94),Vector3(0.36,0.095,0.025),m["red"])
	w._box(group,Vector3(10.55,42.52,-9.94),Vector3(0.095,0.36,0.025),m["red"])
	# A practical winding drum and marked rope cases explain the support team.
	for x: float in [3.8,4.6]:
		_beam(w,group,Vector3(x,42,-7.2),Vector3(x,42.68,-7.2),0.055,m["metal"])
	var drum: MeshInstance3D = w._cylinder(group,Vector3(4.2,42.65,-7.2),0.35,0.72,m["orange"])
	drum.rotation.z = PI/2.0
	for x: float in [3.8,4.6]:
		var rim: MeshInstance3D = w._cylinder(group,Vector3(x,42.65,-7.2),0.42,0.055,m["black_metal"])
		rim.rotation.z = PI/2.0
	for n in range(9):
		var coil: MeshInstance3D = w._cylinder(group,Vector3(3.9+n*0.075,42.65,-7.2),0.36,0.024,m["cream"])
		coil.rotation.z = PI/2.0
	# Insets on the existing console add instruments without changing its collider.
	for index in range(3):
		w._box(group,Vector3(6.9+index*1.0,43.95,8.7),Vector3(0.76,0.035,0.55),m["black_metal"])
		w._box(group,Vector3(6.9+index*1.0,43.973,8.7),Vector3(0.61,0.012,0.39),m["screen"])
		for tick in range(4):
			w._box(group,Vector3(6.66+index*1.0+tick*0.15,43.983,8.71),Vector3(0.035,0.006,0.12+tick*0.035),m["lit_green"])
	for index in range(5):
		w._cylinder(group,Vector3(6.5+index*0.3,44.01,9.35),0.045,0.07,m["black_metal"])
	for z: float in [-11.0,-1.4]:
		for x: float in [-10.6,-1.4]:
			w._cylinder(group,Vector3(x,42.08,z),0.10,0.16,m["lit_blue"])

static func city_landmarks(w: Node3D, city: Node3D) -> void:
	var m: Dictionary = w.materials
	var landmarks: Node3D = Node3D.new()
	landmarks.name = "CoastalLandmarks"
	city.add_child(landmarks)
	# Distant coastal landmarks remain intact enough to orient the player.
	w._cylinder(landmarks,Vector3(-155,-119,-78),4.4,26,m["cream"])
	for y: float in [-126,-117,-108]:
		w._cylinder(landmarks,Vector3(-155,y,-78),4.52,1.6,m["red"])
	w._cylinder(landmarks,Vector3(-155,-104.9,-78),5.2,1.2,m["edge"])
	w._cylinder(landmarks,Vector3(-155,-102.9,-78),3.2,2.7,m["window"])
	_sphere(landmarks,Vector3(-155,-102.8,-78),Vector3(0.65,1.0,0.65),m["lit_amber"])
	for step in range(3):
		w._box(landmarks,Vector3(119,-129+step*5.5,108),Vector3(36-step*8,5.5,23-step*5),m["cream"])
	_sphere(landmarks,Vector3(119,-112.5,108),Vector3(7.3,4.5,7.3),m["green"])
	w._cylinder(landmarks,Vector3(119,-107.5,108),0.3,2.6,m["gold"])
	for side in [-1.0,1.0]:
		for index in range(3):
			var hull: Node3D = Node3D.new()
			landmarks.add_child(hull)
			hull.position = Vector3(-70+index*12,-131.6,39+side*9)
			hull.rotation = Vector3(0.03*index,side*0.25,side*0.12)
			_sphere(hull,Vector3.ZERO,Vector3(2.5,0.9,6.0),m["white"])
			w._box(hull,Vector3(0,0.8,0.7),Vector3(3.6,1.4,3.8),m["cream"])
			w._box(hull,Vector3(0,1.05,-1.24),Vector3(3.1,0.7,0.035),m["window"])
			_beam(w,hull,Vector3(0,1.5,0.5),Vector3(0,4.5,0.5),0.045,m["metal"])
	# A dark exposed ridge gives the skyline an island silhouette beyond the city.
	for index in range(7):
		_sphere(landmarks,Vector3(-310+index*35,-139+sin(index)*3,-220-index*9),Vector3(41,22+index*1.7,24),m["concrete"])

static func _capsule(parent: Node3D, pos: Vector3, radius: float, height: float, material: Material, scale_value: Vector3 = Vector3.ONE) -> MeshInstance3D:
	var mesh: CapsuleMesh = CapsuleMesh.new()
	mesh.radius = radius
	mesh.height = height
	mesh.radial_segments = 12
	mesh.rings = 4
	var node: MeshInstance3D = MeshInstance3D.new()
	node.mesh = mesh
	node.material_override = material
	parent.add_child(node)
	node.position = pos
	node.scale = scale_value
	return node

static func _sphere(parent: Node3D, pos: Vector3, scale_value: Vector3, material: Material) -> MeshInstance3D:
	var mesh: SphereMesh = SphereMesh.new()
	mesh.radius = 1.0
	mesh.height = 2.0
	mesh.radial_segments = 20
	mesh.rings = 10
	var node: MeshInstance3D = MeshInstance3D.new()
	node.mesh = mesh
	node.material_override = material
	parent.add_child(node)
	node.position = pos
	node.scale = scale_value
	return node

static func _beam(w: Node3D, parent: Node3D, a: Vector3, b: Vector3, radius: float, material: Material, end_radius: float = -1.0) -> MeshInstance3D:
	var beam: MeshInstance3D = w._cylinder(parent,(a+b)*0.5,radius,a.distance_to(b),material)
	beam.quaternion = Quaternion(Vector3.UP,(b-a).normalized())
	if end_radius >= 0:
		(beam.mesh as CylinderMesh).top_radius = end_radius
	return beam
