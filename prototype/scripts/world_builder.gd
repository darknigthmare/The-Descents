extends Node3D
class_name DescentWorld

const Presentation = preload("res://scripts/presentation_geometry.gd")

## Self-contained, modular 3D greybox. Metres are the world unit.
## All gameplay corridors and interaction sockets remain outside prop jitter.

var materials: Dictionary = {}
var interactables: Array[Node3D] = []
var floor_heights: Dictionary = {}
var rng: RandomNumberGenerator = RandomNumberGenerator.new()
var rain: MultiMeshInstance3D
var rain_origin: Vector3 = Vector3.ZERO
var elapsed: float = 0.0
var specs_by_floor: Dictionary = {}
var lightning_enabled: bool = false
# The incident is sampled from a persistent director, never advanced by a Tween.
var incident_stage: String = "intact"
var incident_player_position: Vector3 = Vector3.INF
var twin_tower: Node3D
var hesperie_sign: Label3D
var twin_origin: Vector3 = Vector3(46, -144, -6)
var helicopters: Array[Node3D] = []
var rotors: Array[Node3D] = []
var helicopter_origins: Array[Vector3] = []
var alpha_roof_members: Array[Node3D] = []
var alpha_roof_origins: Array[Vector3] = []
var arrival_wash: Array[MeshInstance3D] = []
var incident_damage: Array[Node3D] = []
var breakable_glass: Array[MeshInstance3D] = []
var crack_group: Node3D
var impact_fragments: Array[MeshInstance3D] = []
var fragment_origins: Array[Vector3] = []
var dust_group: Node3D
# Cosmetic settling is independent of the stable persistent incident clock.
var aftermath_dust_elapsed: float = 10.0
const AFTERMATH_DUST_DURATION: float = 10.0
var emergency_group: Node3D
var broken_connection: Node3D
var bravo_gallery: Node3D
var bravo_members: Array[Node3D] = []
var bravo_member_origins: Array[Vector3] = []
var bravo_roof_team: Node3D
var bravo_roof_members: Array[Node3D] = []
var bravo_roof_origins: Array[Vector3] = []
var roof_rescued_people: Dictionary = {}
var roof_medical_group: Node3D
var roof_medical_sign: Label3D
var route_obstacle: MeshInstance3D
var route_obstacle_body: StaticBody3D
var route_obstacle_activated: bool = false
var route_markers: Node3D
var affected_lights: Array[OmniLight3D] = []
var observation_position: Vector3 = Vector3(9.8, 30.06, 0)
var twin_view_target: Vector3 = Vector3(34.1, 33.0, -2.5)
const FINAL_LEAN: float = 7.2
const FINAL_SETTLEMENT: Vector3 = Vector3(-0.8, -1.8, 0.2)

func build(seed_value: int, floor_specs: Array) -> Dictionary:
	rng.seed = seed_value
	_make_materials()
	_build_environment()
	_build_city()
	_build_twin_tower()
	_build_lower_shell()
	for item in floor_specs:
		if item is Dictionary:
			var number: int = int(item.get("number", item.get("floor", 0)))
			specs_by_floor[number] = item
	for number in [30, 29, 28, 27, 26, 25]:
		floor_heights[number] = float(number - 24) * 6.0
		_build_floor(number, specs_by_floor.get(number, {}))
	var roof: Dictionary = _build_roof()
	_build_arrival_wash()
	_build_rain()
	_build_incident_effects()
	apply_incident("intact", 0.0)
	set_rescued_people([])
	return {
		"interactables": interactables,
		"helicopter": roof["helicopter"],
		"rotor": roof["rotor"],
		"helicopters": helicopters,
		"rotors": rotors,
		"helicopter_origins": helicopter_origins,
		"observation_position": observation_position,
		"twin_view_target": twin_view_target,
		"twin_tower": twin_tower,
		"route_obstacle": route_obstacle,
		"detour_waypoints": [Vector3(4.7, 24.06, -2), Vector3(4.7, 24.06, -5.2), Vector3(7, 24.06, -6)],
		"rope_top": Vector3(0, 45, 0),
		"roof_spawn": Vector3(7, 42.2, 7),
		"floor_y": floor_heights,
		"sea_level": -132.0,
		"specs": specs_by_floor
	}

func _process(delta: float) -> void:
	elapsed += delta
	if incident_stage == "aftermath" and aftermath_dust_elapsed < AFTERMATH_DUST_DURATION:
		aftermath_dust_elapsed = minf(AFTERMATH_DUST_DURATION, aftermath_dust_elapsed + maxf(delta, 0.0))
		_update_incident_dust("aftermath", 0.0)
	if is_instance_valid(rain):
		rain.position = rain_origin + Vector3(fmod(elapsed * 1.4, 1.0), -fmod(elapsed * 14.0, 18.0), 0)
	var moon: DirectionalLight3D = get_node_or_null("StormLight")
	if is_instance_valid(moon):
		var phase: float = fmod(elapsed, 24.0)
		var pulse: float = sin(phase * PI / 0.9) * 0.8 if lightning_enabled and phase < 0.9 else 0.0
		moon.light_energy = 0.60 + pulse

func set_lightning_enabled(enabled: bool) -> void:
	lightning_enabled = enabled

func _make_materials() -> void:
	var concrete: ShaderMaterial = ShaderMaterial.new()
	concrete.shader = load("res://shaders/weathered_surface.gdshader")
	concrete.set_shader_parameter("surface_color", Color("37454b"))
	concrete.set_shader_parameter("surface_roughness", 0.94)
	materials["concrete"] = concrete
	materials["edge"] = _mat(Color("687273"), 0.85)
	materials["dark"] = _mat(Color("121d25"), 0.75)
	materials["metal"] = _mat(Color("597580"), 0.34, 0.65)
	materials["black_metal"] = _mat(Color("10232e"), 0.45, 0.65)
	materials["gold"] = _mat(Color("9c7650"), 0.4, 0.7)
	materials["cream"] = _mat(Color("b5b9aa"), 0.82)
	materials["wood"] = _mat(Color("463d38"), 0.85)
	materials["orange"] = _mat(Color("e08343"), 0.65)
	materials["yellow"] = _mat(Color("cfb85a"), 0.72)
	materials["red"] = _mat(Color("924b48"), 0.78)
	materials["blue"] = _mat(Color("3d687e"), 0.8)
	materials["green"] = _mat(Color("476c5a"), 0.85)
	materials["skin"] = _mat(Color("ad8f7b"), 0.9)
	materials["white"] = _mat(Color("cad5cf"), 0.85)
	materials["lit_amber"] = _mat(Color("f6b76b"), 0.35, 0.0, 2.2)
	materials["lit_green"] = _mat(Color("68d8b5"), 0.35, 0.0, 1.6)
	materials["lit_blue"] = _mat(Color("84b7cd"), 0.4, 0.0, 1.0)
	materials["lit_red"] = _mat(Color("ef7959"), 0.35, 0.0, 2.0)
	materials["screen"] = _mat(Color("478f9c"), 0.4, 0.0, 0.7)
	materials["window"] = _mat(Color("233b48"), 0.18, 0.45)
	var clear_glass: StandardMaterial3D = _mat(Color(0.44, 0.65, 0.72, 0.11), 0.08, 0.12)
	clear_glass.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	clear_glass.cull_mode = BaseMaterial3D.CULL_DISABLED
	materials["clear_glass"] = clear_glass
	var dust_material: StandardMaterial3D = _mat(Color(0.63, 0.64, 0.60, 0.09), 1.0)
	dust_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	dust_material.cull_mode = BaseMaterial3D.CULL_DISABLED
	materials["dust"] = dust_material
	materials["pool"] = _mat(Color("1a6a78"), 0.15, 0.4)
	var haze: StandardMaterial3D = _mat(Color(0.48, 0.56, 0.59, 0.07), 1.0)
	haze.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	haze.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	haze.cull_mode = BaseMaterial3D.CULL_DISABLED
	materials["haze"] = haze
	var rain_mat: StandardMaterial3D = _mat(Color(0.5, 0.65, 0.7, 0.16), 1.0)
	rain_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	rain_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	materials["rain"] = rain_mat

func _mat(color: Color, roughness: float = 0.8, metallic: float = 0.0, emission: float = 0.0) -> StandardMaterial3D:
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = roughness
	material.metallic = metallic
	if emission > 0.0:
		material.emission_enabled = true
		material.emission = color
		material.emission_energy_multiplier = emission
	return material

func _build_environment() -> void:
	var environment_node: WorldEnvironment = WorldEnvironment.new()
	environment_node.name = "environment"
	var environment: Environment = Environment.new()
	environment.background_mode = Environment.BG_SKY
	var sky: Sky = Sky.new()
	var sky_material: ProceduralSkyMaterial = ProceduralSkyMaterial.new()
	sky_material.sky_top_color = Color("0c1c2d")
	sky_material.sky_horizon_color = Color("3d5c67")
	sky_material.ground_bottom_color = Color("07141c")
	sky_material.ground_horizon_color = Color("3d5c67")
	sky_material.sky_curve = 0.22
	sky.sky_material = sky_material
	environment.sky = sky
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = Color("88a0ac")
	environment.ambient_light_energy = 0.40
	environment.fog_enabled = true
	environment.fog_light_color = Color("3c5965")
	environment.fog_light_energy = 0.62
	environment.fog_density = 0.0026
	environment.fog_sky_affect = 0.4
	environment.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	environment_node.environment = environment
	add_child(environment_node)
	var moon: DirectionalLight3D = DirectionalLight3D.new()
	moon.name = "StormLight"
	moon.rotation_degrees = Vector3(-38, -28, 0)
	moon.light_color = Color("b9c8d5")
	moon.light_energy = 0.60
	moon.shadow_enabled = true
	moon.directional_shadow_max_distance = 80.0
	add_child(moon)
	var sea_mesh: PlaneMesh = PlaneMesh.new()
	# Keep the finite water boundary beyond the aerial shots and their fog horizon.
	sea_mesh.size = Vector2(6400, 6400)
	sea_mesh.subdivide_width = 100
	sea_mesh.subdivide_depth = 100
	var sea: MeshInstance3D = MeshInstance3D.new()
	sea.name = "water"
	sea.mesh = sea_mesh
	sea.position.y = -132.0
	var water_material: ShaderMaterial = ShaderMaterial.new()
	water_material.shader = load("res://shaders/water.gdshader")
	sea.material_override = water_material
	add_child(sea)

func _build_city() -> void:
	var city: Node3D = Node3D.new()
	city.name = "NacreSubmergedCity"
	add_child(city)
	for index in range(42):
		var angle: float = rng.randf_range(0, TAU)
		var radius: float = rng.randf_range(60, 360)
		var height: float = rng.randf_range(4, 42)
		var width: float = rng.randf_range(7, 19)
		var center: Vector3 = Vector3(cos(angle) * radius, -132 + height * 0.5 - 2, sin(angle) * radius)
		var building: MeshInstance3D = _box(city, center, Vector3(width, height, width * 0.8), materials["dark"])
		building.rotation.z = rng.randf_range(-0.11, 0.11)
		_box(city, center + Vector3(0, height * 0.5, 0), Vector3(width + 0.4, 0.5, width * 0.8 + 0.4), materials["edge"])
		if index % 3 == 0:
			_box(city, center + Vector3(0, height * 0.5 + 1, 0), Vector3(width * 0.5, 2, width * 0.3), materials["metal"])
		for row in range(2):
			_box(city, center + Vector3(0, height * 0.2 - row * 5, width * 0.4 + 0.05), Vector3(width * 0.8, 1.1, 0.1), materials["window"])
	# Marina fragments and a collapsed skybridge barely clear the water.
	_box(city, Vector3(-45, -131, 35), Vector3(25, 0.6, 6), materials["wood"])
	var bridge: MeshInstance3D = _box(city, Vector3(44, -128, 22), Vector3(46, 2, 7), materials["concrete"])
	bridge.rotation.z = -0.22
	Presentation.city_landmarks(self, city)

func _build_twin_tower() -> void:
	twin_tower = Node3D.new()
	twin_tower.name = "HesperieTower"
	add_child(twin_tower)
	twin_tower.position = twin_origin
	# Full-height, upright facade at insertion. The visible contact is authored,
	# while the rescue shaft and all victims stay outside the moving geometry.
	_box(twin_tower, Vector3(0, 93, 0), Vector3(23.8, 186, 23.8), materials["window"])
	for level in range(32):
		var yy: float = level * 6.0
		_box(twin_tower, Vector3(0, yy, 0), Vector3(24.4, 0.5, 24.4), materials["edge"])
		if level < 31:
			for side in [-1, 1]:
				for offset in [-8.0, 0.0, 8.0]:
					_box(twin_tower, Vector3(side * 12.02, yy + 2.8, offset), Vector3(0.2, 5.5, 0.18), materials["metal"])
					_box(twin_tower, Vector3(offset, yy + 2.8, side * 12.02), Vector3(0.18, 5.5, 0.2), materials["metal"])
			if level % 3 == 0:
				_box(twin_tower, Vector3(-12.04, yy + 3, 0), Vector3(0.08, 0.45, 17), materials["lit_amber"])
	# A helipad with a small service core leaves the two teams legible from Aube.
	_box(twin_tower, Vector3(6.5, 188, -6.5), Vector3(6.5, 4, 6.5), materials["dark"])
	for xx in [-7.2, -3.6]:
		_box(twin_tower, Vector3(xx, 186.04, 1.5), Vector3(0.23, 0.05, 4.5), materials["white"])
	_box(twin_tower, Vector3(-5.4, 186.04, 1.5), Vector3(3.8, 0.05, 0.23), materials["white"])
	hesperie_sign = _label(twin_tower, Vector3(-12.08, 177, 0), "HESPÉRIE", 86, Color("e4cc9c"), 0.019, true)
	bravo_roof_team = Node3D.new()
	bravo_roof_team.name = "BravoRoofTeam"
	twin_tower.add_child(bravo_roof_team)
	for origin in [Vector3(-8.5, 186, 7), Vector3(-6.5, 186, 8.5), Vector3(-3.5, 186, 8)]:
		var member: Node3D = _human(bravo_roof_team, origin, materials["orange"] if bravo_roof_members.size() < 2 else materials["blue"], true)
		member.name = "BravoRoofMember%d" % bravo_roof_members.size()
		bravo_roof_members.append(member)
		bravo_roof_origins.append(origin)
	_label(bravo_roof_team, Vector3(-7.5, 189.2, 7.5), "BRAVO / TOIT", 39, Color("f4c389"), 0.017)
	_light(bravo_roof_team, Vector3(-8, 190, 7), Color("ffca8d"), 1.8, 15)
	# A separate pair is already surveying the 29th-floor balcony as Alpha descends.
	bravo_gallery = Node3D.new()
	bravo_gallery.name = "BravoObservationGallery"
	twin_tower.add_child(bravo_gallery)
	bravo_gallery.position = Vector3(-12.9, 174, 2)
	_box(bravo_gallery, Vector3(-0.35, -0.12, 0), Vector3(2.5, 0.24, 7), materials["edge"])
	for zz in [-2.0, 2.0]:
		var member: Node3D = _human(bravo_gallery, Vector3(-0.4, 0, zz), materials["orange"], true)
		member.name = "BravoGalleryMember%d" % bravo_members.size()
		member.rotation.y = -PI / 2
		bravo_members.append(member)
		bravo_member_origins.append(member.position)
	# A visible doorway gives the retreat a readable destination. All parts are
	# cosmetic: the opposite tower is not a playable navigation surface.
	_box(bravo_gallery, Vector3(0.93, 1.35, 0), Vector3(0.08, 2.7, 2.2), materials["dark"])
	for zz in [-1.15, 1.15]:
		_box(bravo_gallery, Vector3(0.87, 1.4, zz), Vector3(0.12, 2.8, 0.12), materials["metal"])
	_box(bravo_gallery, Vector3(0.87, 2.8, 0), Vector3(0.12, 0.12, 2.4), materials["lit_green"])
	_box(bravo_gallery, Vector3(-1.5, 0.95, 0), Vector3(0.08, 0.1, 7), materials["metal"])
	_light(bravo_gallery, Vector3(-1.5, 3.5, 0), Color("9de9d6"), 1.7, 10)
	_label(bravo_gallery, Vector3(-1, 3.8, 0), "BRAVO / 29", 34, Color("a8e9d7"), 0.015)
	# The aircraft uses the world root, so a later tower transform cannot move it.
	var bravo_heli: Dictionary = _make_helicopter(self, twin_origin + Vector3(-5.4, 187.3, 1.5), "HelixBravo")
	helicopters.append(bravo_heli["helicopter"])
	rotors.append(bravo_heli["rotor"])
	helicopter_origins.append(bravo_heli["helicopter"].global_position)

func _build_lower_shell() -> void:
	var shell: Node3D = Node3D.new()
	shell.name = "UnplayableLowerTowerFacade"
	add_child(shell)
	# The unplayable floors reach the level-25 slab at y=6, not y=0.
	_box(shell, Vector3(0, -66, 0), Vector3(23.8, 144, 23.8), materials["window"])
	for level in range(25):
		var yy: float = -138.0 + float(level) * 6
		_box(shell, Vector3(0, yy, 0), Vector3(24.5, 0.4, 24.5), materials["edge"])
	for xx in [-11.8, -6.0, 0.0, 6.0, 11.8]:
		_box(shell, Vector3(xx, -66, 12), Vector3(0.15, 144, 0.25), materials["metal"])
		_box(shell, Vector3(xx, -66, -12), Vector3(0.15, 144, 0.25), materials["metal"])

func _floor_surface(parent: Node3D, y: float, floor_material: Material, enclosed: bool = true) -> void:
	# Four slabs make the 5.4 m square shaft genuinely open at every level.
	_box(parent, Vector3(-7.35, y - 0.3, 0), Vector3(9.3, 0.6, 24), floor_material, true)
	_box(parent, Vector3(7.35, y - 0.3, 0), Vector3(9.3, 0.6, 24), floor_material, true)
	_box(parent, Vector3(0, y - 0.3, -7.35), Vector3(5.4, 0.6, 9.3), floor_material, true)
	_box(parent, Vector3(0, y - 0.3, 7.35), Vector3(5.4, 0.6, 9.3), floor_material, true)
	# A fixed amber strip identifies the entry lip; it remains clear of collisions.
	_box(parent, Vector3(2.76, y + 0.015, 0), Vector3(0.16, 0.025, 3.6), materials["lit_amber"])
	for xx in [-12.0, 12.0]:
		_box(parent, Vector3(xx, y + 0.55, 0), Vector3(0.28, 1.1, 24), materials["concrete"], true)
	for zz in [-12.0, 12.0]:
		_box(parent, Vector3(0, y + 0.55, zz), Vector3(24, 1.1, 0.28), materials["concrete"], true)
	if not enclosed:
		return
	for xx in [-11.6, 11.6]:
		for zz in [-11.6, -4.2, 4.2, 11.6]:
			_box(parent, Vector3(xx, y + 2.8, zz), Vector3(0.65, 5.6, 0.65), materials["edge"], true)
	for zz in [-11.6, 11.6]:
		for xx in [-4.2, 4.2]:
			_box(parent, Vector3(xx, y + 2.8, zz), Vector3(0.65, 5.6, 0.65), materials["edge"], true)
	# Each bay has transparent interior glass and an outward-facing opaque coat.
	# The exterior reads as a complete curtain wall during the approach, while
	# back-face culling preserves the player's view through the observation bay.
	# East panes on 29/28 shatter only when Hesperie reaches Aube.
	for zz in [-11.9, 11.9]:
		for xx in [-8.0, 0.0, 8.0]:
			_glazed_pane(parent, Vector3(xx, y + 3.2, zz), Vector3(7.25, 4.25, 0.06), Vector3(0, 0, signf(zz)))
	for xx in [-11.9, 11.9]:
		for zz in [-8.0, 0.0, 8.0]:
			var pane: MeshInstance3D = _glazed_pane(parent, Vector3(xx, y + 3.2, zz), Vector3(0.06, 4.25, 7.25), Vector3(signf(xx), 0, 0))
			if xx > 0 and (is_equal_approx(y, 30.0) or is_equal_approx(y, 24.0)):
				breakable_glass.append(pane)

func _glazed_pane(parent: Node3D, position_value: Vector3, size: Vector3, outward: Vector3) -> MeshInstance3D:
	var pane: MeshInstance3D = _box(parent, position_value, size, materials["clear_glass"])
	var exterior: MeshInstance3D = MeshInstance3D.new()
	exterior.name = "ExteriorGlazing"
	var surface: QuadMesh = QuadMesh.new()
	surface.size = Vector2(7.75, 4.4)
	exterior.mesh = surface
	exterior.material_override = materials["window"]
	exterior.position = outward * 0.04
	exterior.rotation.y = atan2(outward.x, outward.z)
	exterior.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	pane.add_child(exterior)
	return pane

func _build_floor(number: int, spec: Dictionary) -> void:
	var floor_node: Node3D = Node3D.new()
	floor_node.name = "Floor%d" % number
	add_child(floor_node)
	var y: float = floor_heights[number]
	var floor_material: Material = materials["concrete"] if number <= 26 else materials["cream"]
	_floor_surface(floor_node, y, floor_material)
	var default_names: Dictionary = {30:"RESTAURANT PANORAMIQUE", 29:"SUITES DE L'AUBE", 28:"BUREAUX PELAGOS", 27:"JARDIN DES ENFANTS", 26:"SPA ET BASSIN", 25:"REFUGE TECHNIQUE"}
	var title: String = str(spec.get("name", default_names[number])).to_upper()
	_label(floor_node, Vector3(4.6, y + 3.8, -2.9), "%02d / %s" % [number, title], 40, Color("d7ded8"), 0.009, true)
	_label(floor_node, Vector3(-2.64, y + 1.7, 0), "%02d" % number, 92, Color("e8a15f"), 0.014, true)
	# Ceiling structural beams and soft indirect lights establish each volume.
	for zz in [-10.5, 10.5]:
		_box(floor_node, Vector3(0, y + 5.45, zz), Vector3(24, 0.3, 0.38), materials["metal"])
	for xx in [-7.3, 7.3]:
		_box(floor_node, Vector3(xx, y + 5.35, 0), Vector3(0.7, 0.12, 20), materials["dark"])
		_box(floor_node, Vector3(xx, y + 5.25, 0), Vector3(0.3, 0.08, 7), materials["lit_amber"] if number in [30,29] else materials["lit_blue"])
		var floor_light: OmniLight3D = _light(floor_node, Vector3(xx, y + 3.8, 0), Color("ecb778") if number in [30,29] else Color("6da1b3"), 0.95, 11)
		if number in [29, 28]:
			affected_lights.append(floor_light)
	match number:
		30: _restaurant(floor_node, y)
		29: _hotel(floor_node, y)
		28: _offices(floor_node, y)
		27: _children(floor_node, y)
		26: _spa(floor_node, y)
		25: _maintenance(floor_node, y)
	_variant_module(floor_node, y, int(spec.get("layout_variant", 0)))
	var damaged_dressing: Node3D = Node3D.new()
	damaged_dressing.name = "AfterImpactDressing"
	floor_node.add_child(damaged_dressing)
	incident_damage.append(damaged_dressing)
	var prop_rng: RandomNumberGenerator = RandomNumberGenerator.new()
	prop_rng.seed = int(spec.get("prop_seed", rng.randi()))
	for index in range(12):
		# Debris is small and never occupies the central cross or a rescue socket.
		var xx: float = prop_rng.randf_range(-10.5, 10.5)
		var zz: float = prop_rng.randf_range(-10.5, 10.5)
		if abs(xx) < 4.3 or abs(zz) < 3.0 or (xx > 4.5 and abs(abs(zz) - 6.0) < 2.0):
			continue
		var debris: MeshInstance3D = _box(damaged_dressing, Vector3(xx, y + 0.09, zz), Vector3(prop_rng.randf_range(0.3, 0.9), 0.16, prop_rng.randf_range(0.2, 0.6)), materials["edge"])
		debris.rotation.y = prop_rng.randf_range(-PI, PI)
	var hazard: String = str(spec.get("hazard", "none"))
	floor_node.set_meta("hazard", hazard)
	if hazard == "smoke":
		for index in range(4):
			_sphere(damaged_dressing, Vector3(-7 + index * 2.5, y + 3.4, -7), Vector3(5.0, 1.2, 4.0), materials["haze"])
		_light(damaged_dressing, Vector3(-8, y + 1.4, -9), Color("ff8052"), 0.8, 5)
	if hazard == "water":
		_box(damaged_dressing, Vector3(7, y + 0.025, 5), Vector3(7, 0.015, 9), materials["pool"])
	_make_beacon(floor_node, number, y)
	if bool(spec.get("survivor", number in [30,28,26])):
		var survivor_name: String = str(spec.get("survivor_name", {30:"Ana Rios",28:"Samuel Breton",26:"Nora Haddad"}.get(number,"Rescapé")))
		var survivor: Node3D = _interaction(floor_node, Vector3(7, y, -6), "survivor", "survivor_%d" % number, number, survivor_name, "Personne isolée. Stabilisez-la puis conduisez-la à la balise de treuil.")
		_human(survivor, Vector3.ZERO, materials["blue"] if number == 28 else materials["cream"], false)
		_label(survivor, Vector3(0, 2.25, 0), survivor_name, 30, Color("a9e5d6"), 0.008)
	if bool(spec.get("evidence", number in [29,27,26])):
		var evidence: Node3D = _interaction(floor_node, Vector3(7, y, 6), "evidence", "evidence_%d" % number, number, str(spec.get("evidence_title", "Archive SILLAGE")), str(spec.get("evidence_text", "Un enregistrement antérieur à la catastrophe mentionne des voix venant des fondations.")))
		_box(evidence, Vector3(0, 0.5, 0), Vector3(1.1, 1.0, 0.7), materials["dark"], true)
		_box(evidence, Vector3(0, 1.05, 0), Vector3(0.7, 0.07, 0.48), materials["lit_blue"])
		_label(evidence, Vector3(0, 1.65, 0), "ARCHIVE", 26, Color("a6d2e4"), 0.008)
	if bool(spec.get("supplies", number in [29,25])):
		var supply: Node3D = _interaction(floor_node, Vector3(-7, y, 6), "supply", "supply_%d" % number, number, "Caisse de secours", "Réserve de balises, ancrages et bouteilles d'air.")
		_supply_crate(supply, Vector3.ZERO)
	if number == 29:
		var observation: Node3D = _interaction(floor_node, Vector3(9.8, y, 0), "observation", "observation_29", 29, "Baie Est — équipe Bravo", "Confirmer visuellement la position de Bravo dans la tour Hespérie.")
		_label(observation, Vector3(0, 2.8, 0), "BAIE EST
VISUEL BRAVO", 30, Color("a8e9d7"), 0.010)
		for xx in [5.4, 6.6, 7.8, 9.0]:
			_box(floor_node, Vector3(xx, y + 0.02, 0), Vector3(0.55, 0.035, 0.14), materials["lit_green"])
	if number == 25:
		var refuge: Node3D = _interaction(floor_node, Vector3(7, y, 6), "refuge", "refuge_25", number, "Refuge 25", "Liaison sécurisée avec le toit. Sauvegarde et fin de la tranche de prototype.")
		_box(refuge, Vector3(0, 0.85, 0), Vector3(1.7, 1.7, 0.9), materials["metal"], true)
		_box(refuge, Vector3(0, 1.2, 0.49), Vector3(1.25, 0.55, 0.05), materials["lit_green"])
		_label(refuge, Vector3(0, 2.5, 0), "REFUGE 25\nLIAISON SÉCURISÉE", 36, Color("98efc9"), 0.01)
		_light(refuge, Vector3(0, 2.7, 0), Color("6eddb3"), 1.4, 9)

func _restaurant(parent: Node3D, y: float) -> void:
	for pos in [Vector3(-7,y,-7), Vector3(-7,y,7), Vector3(7,y,8)]:
		_cylinder(parent, pos + Vector3(0,1.0,0), 1.4, 0.12, materials["cream"], true)
		_cylinder(parent, pos + Vector3(0,0.5,0), 0.15, 0.9, materials["gold"])
		for offset in [Vector3(1.8,0,0), Vector3(-1.8,0,0)]:
			_chair(parent, pos + offset, 0, materials["red"])
		_cylinder(parent, pos + Vector3(0,1.2,0), 0.06, 0.3, materials["lit_amber"])
	_box(parent, Vector3(-7,y+0.7,-10.5), Vector3(8,1.4,1.5), materials["wood"], true)
	_box(parent, Vector3(-7,y+1.45,-10.5), Vector3(8.4,0.1,1.7), materials["gold"])
	for index in range(8):
		_cylinder(parent, Vector3(-10 + index * 0.8,y+1.7,-10.5), 0.1, 0.43, materials["green"])
	_label(parent, Vector3(-7,y+3.5,-11.5), "LE BELVÉDÈRE", 74, Color("e3bd83"), 0.017, false)
	_planter(parent, Vector3(10,y,-9))
	_planter(parent, Vector3(10,y,9))

func _hotel(parent: Node3D, y: float) -> void:
	for pos in [Vector3(-7,y,-7),Vector3(8,y,-8)]:
		_box(parent, pos + Vector3(0,0.35,0), Vector3(3.2,0.7,3.9), materials["wood"], true)
		_box(parent, pos + Vector3(0,0.8,0), Vector3(3.1,0.28,3.8), materials["cream"])
		_box(parent, pos + Vector3(0,1.0,-1.3), Vector3(2.5,0.22,0.6), materials["white"])
		_box(parent, pos + Vector3(0,1.15,0.7), Vector3(3.2,0.1,1.4), materials["blue"])
		_box(parent, pos + Vector3(0,1.2,-2), Vector3(3.4,1.8,0.25), materials["wood"], true)
	_box(parent, Vector3(-4.2,y+1.8,-7.5), Vector3(0.25,3.6,7), materials["wood"], true)
	# Two partition pieces leave a two-metre doorway to the west supply room.
	_box(parent, Vector3(-9.5,y+1.8,3.7), Vector3(3,3.6,0.25), materials["wood"], true)
	_box(parent, Vector3(-5,y+1.8,3.7), Vector3(2,3.6,0.25), materials["wood"], true)
	_label(parent, Vector3(6,y+3.0,-10.8), "SUITE 2908", 48, Color("d3bc91"), 0.01, false)
	_box(parent, Vector3(10,y+0.35,4), Vector3(1.1,0.7,0.8), materials["red"], true)

func _offices(parent: Node3D, y: float) -> void:
	for pos in [Vector3(-8,y,-8),Vector3(-5,y,-8),Vector3(-8,y,7),Vector3(8,y,8)]:
		_box(parent, pos + Vector3(0,0.83,0), Vector3(2.3,0.15,1.5), materials["wood"], true)
		for offset in [-0.9,0.9]:
			_box(parent, pos + Vector3(offset,0.4,0), Vector3(0.12,0.8,1.2), materials["metal"])
		_box(parent, pos + Vector3(0,1.3,-0.35), Vector3(1.0,0.65,0.08), materials["dark"])
		_box(parent, pos + Vector3(0,1.3,-0.29), Vector3(0.9,0.55,0.04), materials["screen"])
		_chair(parent, pos + Vector3(0,0,1.3), 0, materials["dark"])
	for xx in [-10.7,-9.4,-8.1]:
		_box(parent, Vector3(xx,y+1.3,10.6), Vector3(1.15,2.6,0.8), materials["metal"], true)
		for yy in [0.5,1.2,1.9]:
			_box(parent, Vector3(xx,y+yy,11.03), Vector3(0.8,0.05,0.06), materials["gold"])
	_label(parent, Vector3(4.2,y+3.4,-10.8), "PELAGOS\nDivision des fondations", 48, Color("b5d2d4"), 0.012, false)

func _children(parent: Node3D, y: float) -> void:
	for index in range(6):
		var xx: float = -10.1 + index * 1.05
		var color_mat: Material = [materials["red"],materials["yellow"],materials["blue"]][index % 3]
		_box(parent, Vector3(xx,y+0.8,-10), Vector3(0.95,1.6,0.7), color_mat, true)
		_box(parent, Vector3(xx,y+1.1,-9.6), Vector3(0.65,0.55,0.06), materials["dark"])
	for pos in [Vector3(-7,y,-6),Vector3(-7,y,7)]:
		_cylinder(parent, pos + Vector3(0,0.55,0), 1.3, 0.15, materials["yellow"], true)
		for offset in [Vector3(1.6,0,0),Vector3(-1.6,0,0)]:
			_box(parent, pos + offset + Vector3(0,0.3,0), Vector3(0.7,0.6,0.7), materials["blue"], true)
	for index in range(7):
		var toy: MeshInstance3D = _box(parent, Vector3(8 + rng.randf_range(-1,1),y+0.2,-8 + rng.randf_range(-1,1)), Vector3(0.4,0.4,0.4), materials["red"] if index % 2 else materials["blue"])
		toy.rotation.y = rng.randf_range(0,PI)
	_label(parent, Vector3(-7,y+3.3,-11.4), "LE JARDIN DES MARÉES", 50, Color("dcc88d"), 0.012, false)
	_box(parent, Vector3(10.9,y+2.0,6), Vector3(0.05,1.6,3.6), materials["cream"])
	# Child-made drawn towers as code-native geometry on the notice board.
	for zz in [5.4,6.4]:
		_box(parent, Vector3(10.86,y+2.0,zz), Vector3(0.04,1.2,0.45), materials["blue"])

func _spa(parent: Node3D, y: float) -> void:
	_box(parent, Vector3(-7,y+0.15,-6.8), Vector3(7,0.3,6.5), materials["edge"], true)
	_box(parent, Vector3(-7,y+0.32,-6.8), Vector3(6.6,0.04,6.1), materials["pool"])
	for pos in [Vector3(-8,y,7),Vector3(-5,y,7),Vector3(9,y,-9)]:
		_box(parent, pos + Vector3(0,0.45,0), Vector3(1.6,0.3,3.4), materials["cream"], true)
		var back: MeshInstance3D = _box(parent, pos + Vector3(0,0.9,-1.3), Vector3(1.6,1.2,0.22), materials["wood"])
		back.rotation.x = -0.3
	for xx in [-10.8,-10.1]:
		_cylinder(parent, Vector3(xx,y+2.4,2), 0.15, 4.8, materials["metal"])
	_label(parent, Vector3(-7,y+3.6,-11.5), "LES BAINS SUSPENDUS", 62, Color("a5d8d6"), 0.015, false)
	_light(parent, Vector3(-7,y+0.8,-6.8), Color("28a7a6"), 1.6, 7)

func _maintenance(parent: Node3D, y: float) -> void:
	for xx in [-10.7,-9.6,-8.5]:
		_box(parent, Vector3(xx,y+1.2,-9.5), Vector3(0.85,2.4,1.4), materials["metal"], true)
		_box(parent, Vector3(xx,y+1.7,-8.76), Vector3(0.4,0.4,0.05), materials["screen"])
	for xx in [-9,-7,-5]:
		_cylinder(parent, Vector3(xx,y+0.9,8), 0.25, 1.7, materials["orange"])
	_box(parent, Vector3(8,y+0.45,-8), Vector3(4.4,0.35,1.7), materials["green"], true)
	_box(parent, Vector3(8,y+0.72,-8), Vector3(4.2,0.2,1.5), materials["cream"])
	for zz in [-10.7,10.7]:
		var pipe: MeshInstance3D = _cylinder(parent, Vector3(0,y+4.6,zz), 0.19, 23, materials["yellow"])
		pipe.rotation.z = PI * 0.5
	_label(parent, Vector3(0,y+3.5,-11.5), "REFUGE 25\nSECTEUR SÉCURISÉ", 66, Color("b1e6c4"), 0.016, false)
	_human(parent, Vector3(9,y,2.5), materials["orange"], true)
	for xx in range(-11,12):
		_box(parent, Vector3(xx,y+0.015,3.3), Vector3(0.45,0.03,0.12), materials["yellow"])

func _make_beacon(parent: Node3D, number: int, y: float) -> void:
	var beacon: Node3D = _interaction(parent, Vector3(3.6,y,0), "beacon", "beacon_%d" % number, number, "Balise de treuil", "Point de raccordement au rappel et d'évacuation des rescapés vers le toit.")
	_cylinder(beacon, Vector3(0,0.18,0), 0.34, 0.36, materials["metal"])
	_cylinder(beacon, Vector3(0,0.9,0), 0.06, 1.3, materials["orange"])
	_sphere(beacon, Vector3(0,1.6,0), Vector3(0.18,0.18,0.18), materials["lit_green"])
	_label(beacon, Vector3(0,2.2,0), "TREUIL", 26, Color("99e6cc"), 0.007)

func _variant_module(parent: Node3D, y: float, variant: int) -> void:
	# A bounded west-side pocket changes layout without moving protected sockets.
	var module: Node3D = Node3D.new()
	module.name = "LayoutVariant%d" % variant
	parent.add_child(module)
	module.position = Vector3(-10.3,y,0)
	match variant:
		0:
			_box(module,Vector3(0,0.45,0),Vector3(1.0,0.9,2.7),materials["wood"],true)
			_box(module,Vector3(-0.4,1.05,0),Vector3(0.2,1.1,2.7),materials["cream"],true)
		1:
			for zz in [-1.0,1.0]:
				_cylinder(module,Vector3(0,0.75,zz),0.45,1.5,materials["edge"],true)
				_sphere(module,Vector3(0,1.8,zz),Vector3(0.4,0.5,0.4),materials["gold"])
		2:
			var panel: MeshInstance3D = _box(module,Vector3(0,0.4,0),Vector3(1.0,0.2,2.4),materials["metal"],true)
			panel.rotation_degrees.z = 0.0
			_box(module,Vector3(0,1.5,-1.5),Vector3(0.25,3.0,0.3),materials["metal"])

func _build_roof() -> Dictionary:
	var roof: Node3D = Node3D.new()
	roof.name = "RoofCommandPost"
	add_child(roof)
	_floor_surface(roof,42,materials["concrete"],false)
	# Heliport markings are physical painted strips, not a flat menu background.
	for xx in [-7.8,-4.2]:
		_box(roof,Vector3(xx,42.025,-6),Vector3(0.25,0.03,4.5),materials["white"])
	_box(roof,Vector3(-6,42.025,-6),Vector3(3.7,0.03,0.25),materials["white"])
	for xx in [-10.4,-1.6]:
		_box(roof,Vector3(xx,42.03,-6),Vector3(0.12,0.04,9.0),materials["yellow"])
	for zz in [-10.4,-1.6]:
		_box(roof,Vector3(-6,42.03,zz),Vector3(9.0,0.04,0.12),materials["yellow"])
	var aircraft: Dictionary = _make_helicopter(self, Vector3(-6,43.35,-6), "HelixAlpha")
	var helicopter: Node3D = aircraft["helicopter"]
	var rotor: Node3D = aircraft["rotor"]
	# Alpha occupies index 0 for callers that retain the original single-heli key.
	helicopters.push_front(helicopter)
	rotors.push_front(rotor)
	helicopter_origins.push_front(helicopter.global_position)
	for origin in [Vector3(6.6,42,-7), Vector3(9,42,-6), Vector3(7,42,4.7)]:
		var member: Node3D = _human(roof, origin, materials["blue"] if alpha_roof_members.size() == 1 else materials["orange"], true)
		member.name = "AlphaRoofMember%d" % alpha_roof_members.size()
		alpha_roof_members.append(member)
		alpha_roof_origins.append(origin)
	_build_roof_reception(roof)
	_label(roof,Vector3(7,44.3,4.7),"CPT. VARGA",30,Color("eab686"),0.004)
	_supply_crate(roof,Vector3(-7,42,7))
	_supply_crate(roof,Vector3(-9,42,7))
	_box(roof,Vector3(8,42.9,8.7),Vector3(4,1.8,1.8),materials["metal"],true)
	_box(roof,Vector3(8,43.9,8.7),Vector3(4.3,0.16,2.1),materials["dark"])
	_cylinder(roof,Vector3(10,45,10),0.08,6,materials["metal"])
	_box(roof,Vector3(10,47.4,10),Vector3(2.0,0.12,0.12),materials["metal"])
	_sphere(roof,Vector3(10,48.1,10),Vector3(0.15,0.15,0.15),materials["lit_red"])
	# The rope anchor crosses the opening 3 m above the roof.
	_box(roof,Vector3(0,45,0),Vector3(7.0,0.22,0.22),materials["metal"])
	for xx in [-3.4,3.4]:
		_box(roof,Vector3(xx,43.5,0),Vector3(0.18,3,0.18),materials["orange"])
	_make_beacon(roof,31,42)
	_label(roof,Vector3(4.2,44.6,-2.8),"AUBE / TOIT\nPOINT DE DESCENTE",45,Color("efd4ab"),0.010,true)
	_label(roof,Vector3(0,44.0,11.3),"ORPHÉE\nPOSTE DE SECOURS",66,Color("cedbd6"),0.014,false)
	for pos in [Vector3(8,45,-6),Vector3(-7,45,7)]:
		_light(roof,pos,Color("eabb83"),1.6,13)
	Presentation.roof_dressing(self, roof)
	return {"helicopter":helicopter,"rotor":rotor}

func _build_roof_reception(roof: Node3D) -> void:
	roof_medical_group = Node3D.new()
	roof_medical_group.name = "RoofMedicalReception"
	roof.add_child(roof_medical_group)
	var roster: Array = [
		["survivor_30", "ANA RIOS", Vector3(6, 42, -9.3)],
		["survivor_28", "SAMUEL BRETON", Vector3(8, 42, -9.3)],
		["survivor_26", "NORA HADDAD", Vector3(10, 42, -9.3)]
	]
	for index in range(roster.size()):
		var record: Array = roster[index]
		var reception: Node3D = Node3D.new()
		reception.name = "Reception_" + str(record[0])
		reception.set_meta("rescued_id", record[0])
		reception.position = record[2]
		roof_medical_group.add_child(reception)
		if index == 0:
			_box(reception, Vector3(0, 0.58, 0), Vector3(0.95, 0.13, 2.25), materials["green"])
			for xx in [-0.52, 0.52]:
				_box(reception, Vector3(xx, 0.55, 0), Vector3(0.07, 0.08, 2.6), materials["metal"])
			var patient: Node3D = _human(reception, Vector3(0, 0.79, -0.88), materials["cream"], false)
			patient.rotation.x = PI / 2
			_box(reception, Vector3(0, 0.9, -0.16), Vector3(0.69, 0.13, 1.12), materials["white"])
		else:
			var patient: Node3D = _human(reception, Vector3.ZERO, materials["blue"] if index == 1 else materials["cream"], false)
			if index == 2:
				patient.scale.y = 0.78
				_box(reception, Vector3(0, 0.34, 0.09), Vector3(0.85, 0.12, 0.7), materials["green"])
			_box(reception, Vector3(0, 0.88 if index == 1 else 0.68, 0.02), Vector3(0.78, 0.78, 0.43), materials["yellow"] if index == 1 else materials["white"])
		_label(reception, Vector3(0, 2.42, 0), "%s\nÀ L’ABRI" % str(record[1]), 25, Color("a8e9d7"), 0.007)
		roof_rescued_people[str(record[0])] = reception
	roof_medical_sign = _label(roof_medical_group, Vector3(8, 45.5, -9.6), "MÉDICAL\n0 SUR 3 À L’ABRI", 37, Color("a8e9d7"), 0.010)

func set_rescued_people(rescued: Array) -> void:
	# Projection of the saved registry, not another source of mission truth.
	# Prebuilt figures make repeat calls, restores and new-game resets idempotent.
	var confirmed: int = 0
	for id_value in roof_rescued_people:
		var person: Node3D = roof_rescued_people[id_value]
		person.visible = rescued.has(id_value)
		if person.visible:
			confirmed += 1
	if is_instance_valid(roof_medical_sign):
		roof_medical_sign.text = "MÉDICAL\n%d SUR 3 À L’ABRI" % confirmed

func _make_helicopter(parent: Node3D, pos: Vector3, aircraft_name: String) -> Dictionary:
	return Presentation.aircraft(self, parent, pos, aircraft_name)

func _build_arrival_wash() -> void:
	for index in range(helicopter_origins.size()):
		var wash: MeshInstance3D = MeshInstance3D.new()
		wash.name = "RotorWashAlpha" if index == 0 else "RotorWashBravo"
		var plane: PlaneMesh = PlaneMesh.new()
		plane.size = Vector2(14, 14)
		wash.mesh = plane
		var material: ShaderMaterial = ShaderMaterial.new()
		material.shader = load("res://shaders/rotor_wash.gdshader")
		wash.material_override = material
		wash.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		add_child(wash)
		wash.global_position = Vector3(helicopter_origins[index].x, 42.075, helicopter_origins[index].z)
		wash.visible = false
		arrival_wash.append(wash)

func apply_arrival_staging(sample: Dictionary) -> void:
	# Pure presentation of the director's clock. Absolute samples also support
	# scrubbing, skipping and resuming without adding a second mission state.
	if incident_stage != "intact":
		return
	var aircraft_samples: Array = sample.get("aircraft", [])
	var clock: float = float(sample.get("time", 0.0))
	for index in range(mini(helicopters.size(), aircraft_samples.size())):
		var pose: Dictionary = aircraft_samples[index]
		var helicopter: Node3D = helicopters[index]
		helicopter.global_position = helicopter_origins[index] + (pose.get("offset", Vector3.ZERO) as Vector3)
		helicopter.rotation = pose.get("rotation", Vector3.ZERO)
		helicopter.visible = true
		_set_aircraft_door(helicopter, clampf(float(pose.get("door", 0.0)), 0.0, 1.0))
		var strength: float = clampf(float(pose.get("wash", 0.0)), 0.0, 1.0)
		var wash: MeshInstance3D = arrival_wash[index]
		wash.visible = strength > 0.001
		(wash.material_override as ShaderMaterial).set_shader_parameter("strength", strength)
		(wash.material_override as ShaderMaterial).set_shader_parameter("clock", clock)
	var crew: float = clampf(float(sample.get("crew", 0.0)), 0.0, 1.0)
	for index in range(alpha_roof_members.size()):
		_pose_arrival_member(alpha_roof_members[index], alpha_roof_origins[index], 0, index, crew)
	for index in range(bravo_roof_members.size()):
		_pose_arrival_member(bravo_roof_members[index], bravo_roof_origins[index], 1, index, crew)
	# The already assigned gallery pair is revealed at handoff, independently of
	# the three roof members disembarking here. No figures are duplicated.
	for member: Node3D in bravo_members:
		member.visible = false

func restore_arrival_staging() -> void:
	for helicopter: Node3D in helicopters:
		_set_aircraft_door(helicopter, 0.0)
	for wash: MeshInstance3D in arrival_wash:
		wash.visible = false
		(wash.material_override as ShaderMaterial).set_shader_parameter("strength", 0.0)
		(wash.material_override as ShaderMaterial).set_shader_parameter("clock", 0.0)
	# A late call must never resurrect a sheltered Bravo or rewind a departure.
	if incident_stage != "intact":
		return
	for index in range(helicopters.size()):
		helicopters[index].global_position = helicopter_origins[index]
		helicopters[index].rotation = Vector3.ZERO
		helicopters[index].visible = true
	for index in range(alpha_roof_members.size()):
		var member: Node3D = alpha_roof_members[index]
		member.position = alpha_roof_origins[index]
		member.rotation = Vector3.ZERO
		member.visible = true
		_pose_human_walk(member, 0.0, 0.0)
	_sample_bravo_retreat("intact", 0.0)

func sample_aircraft_rotors(time: float) -> void:
	for index in range(helicopters.size()):
		rotors[index].rotation = Vector3(0, fposmod(time * 28.0 + index * 0.75, TAU), 0)
		var tail: Node3D = helicopters[index].get_node("TailRotor")
		tail.rotation = Vector3(fposmod(time * 41.0 + index * 0.5, TAU), 0, 0)

func _set_aircraft_door(helicopter: Node3D, openness: float) -> void:
	for name_value in ["DoorLeft", "DoorRight"]:
		var door: Node3D = helicopter.get_node(name_value)
		door.position = (door.get_meta("closed_position") as Vector3) + Vector3(0, 0, openness * 1.84)
		door.rotation = Vector3.ZERO

func _pose_arrival_member(member: Node3D, origin: Vector3, aircraft_index: int, member_index: int, crew: float) -> void:
	var phase: float = clampf((crew - member_index * 0.075) / (1.0 - member_index * 0.075), 0.0, 1.0)
	member.visible = phase > 0.0
	if phase >= 1.0:
		member.position = origin
		member.rotation = Vector3.ZERO
		_pose_human_walk(member, 0.0, 0.0)
		return
	var parent: Node3D = member.get_parent() as Node3D
	var helicopter: Node3D = helicopters[aircraft_index]
	var cabin: Vector3 = helicopter.to_global(Vector3(1.52, 0.09, 0.35))
	var step: Vector3 = helicopter.to_global(Vector3(1.62, -0.57, 0.35))
	var ground: Vector3 = helicopter_origins[aircraft_index] + Vector3(2.15, 0, 0.35)
	ground.y = 42.0
	var finish: Vector3 = parent.to_global(origin)
	# Alpha walks along the north edge before turning east of the shaft. The
	# route never cuts across the open descent hole or medical beds.
	var bend: Vector3 = Vector3(5.9, 42.0, -5.4) if aircraft_index == 0 else ground.lerp(finish, 0.48)
	var points: Array[Vector3] = [cabin, step, ground, bend, finish]
	var boundaries: Array[float] = [0.0, 0.08, 0.18, 0.68, 1.0]
	var segment: int = 0
	while segment < 3 and phase > boundaries[segment + 1]:
		segment += 1
	var fraction: float = inverse_lerp(boundaries[segment], boundaries[segment + 1], phase)
	var position_world: Vector3 = points[segment].lerp(points[segment + 1], fraction)
	var distance_walked: float = points[segment].distance_to(points[segment + 1]) * fraction
	for previous in range(segment):
		distance_walked += points[previous].distance_to(points[previous + 1])
	var stride_clock: float = distance_walked * TAU / 1.4 + member_index * 0.65
	var movement: float = smoothstep(0.0, 0.035, phase) * (1.0 - smoothstep(0.93, 1.0, phase))
	position_world.y += absf(sin(stride_clock)) * 0.027 * movement
	member.position = parent.to_local(position_world)
	var direction: Vector3 = parent.to_local(points[segment + 1]) - parent.to_local(points[segment])
	var yaw: float = atan2(-direction.x, -direction.z)
	if segment < 3:
		var next_direction: Vector3 = parent.to_local(points[segment + 2]) - parent.to_local(points[segment + 1])
		yaw = lerp_angle(yaw, atan2(-next_direction.x, -next_direction.z), smoothstep(0.72, 1.0, fraction))
	member.rotation = Vector3(0, lerp_angle(yaw, 0.0, smoothstep(0.91, 1.0, phase)), 0)
	_pose_human_walk(member, stride_clock, movement)

func _pose_human_walk(member: Node3D, clock: float, movement: float) -> void:
	var swing: float = sin(clock) * clampf(movement, 0.0, 1.0)
	var left_leg: Node3D = member.get_node("LeftLeg")
	var right_leg: Node3D = member.get_node("RightLeg")
	var left_arm: Node3D = member.get_node("LeftArm")
	var right_arm: Node3D = member.get_node("RightArm")
	left_leg.rotation = Vector3(swing * 0.58, 0, 0)
	right_leg.rotation = Vector3(-swing * 0.58, 0, 0)
	left_arm.rotation = (left_arm.get_meta("rest_rotation") as Vector3) + Vector3(-swing * 0.43, 0, 0)
	right_arm.rotation = (right_arm.get_meta("rest_rotation") as Vector3) + Vector3(swing * 0.43, 0, 0)

func _build_incident_effects() -> void:
	crack_group = Node3D.new()
	crack_group.name = "WindowStressCracks"
	add_child(crack_group)
	for index in range(8):
		var crack: MeshInstance3D = _box(crack_group, Vector3(11.85, 32.0 + sin(index * 1.1) * 1.2, -3.0 + index * 0.8), Vector3(0.035, 0.025, 1.1), materials["white"])
		crack.rotation.x = -0.65 + index * 0.18
	broken_connection = Node3D.new()
	broken_connection.name = "ImpactRupture"
	add_child(broken_connection)
	for index in range(9):
		var beam: MeshInstance3D = _box(broken_connection, Vector3(13.0 + index * 0.5, 27.0 - index * 0.45, -4.0 + index * 0.4), Vector3(0.25, 6.0, 0.3), materials["metal"])
		beam.rotation_degrees = Vector3(index * 5, 0, -28 + index * 8)
	for index in range(12):
		var chip: MeshInstance3D = _box(broken_connection, Vector3(11.25, 30.08, -3.1 + index * 0.5), Vector3(0.3, 0.08, 0.22), materials["clear_glass"])
		chip.rotation.y = index * 0.91
	dust_group = Node3D.new()
	dust_group.name = "ImpactDust"
	add_child(dust_group)
	dust_group.position = Vector3(13.8, 31.0, -2.0)
	for index in range(5):
		_sphere(dust_group, Vector3(index * 1.3, sin(index) * 2.0, index * 2.1 - 3.5), Vector3(2.5, 3.2, 2.6), materials["dust"])
	for index in range(30):
		var pos: Vector3 = Vector3(12.15 + (index % 3) * 0.25, 31.0 + (index % 5) * 0.7, -4.0 + (index % 11) * 0.7)
		var piece: MeshInstance3D = _box(self, pos, Vector3(0.05, 0.16 + (index % 3) * 0.12, 0.24 + (index % 4) * 0.08), materials["clear_glass"] if index % 3 else materials["edge"])
		piece.name = "ImpactFragment%02d" % index
		piece.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		impact_fragments.append(piece)
		fragment_origins.append(pos)
	emergency_group = Node3D.new()
	emergency_group.name = "AfterImpactEmergencyLights"
	add_child(emergency_group)
	for yy in [24.0, 30.0]:
		for zz in [-3.0, 3.0]:
			_box(emergency_group, Vector3(4.7, yy + 4.7, zz), Vector3(0.65, 0.12, 0.18), materials["lit_red"])
			_light(emergency_group, Vector3(5.8, yy + 3.8, zz), Color("ff9d66"), 0.6, 9)
	# This short east corridor is genuinely rerouted, but the central rescue
	# cross, survivor socket and observation bay are never obstructed.
	route_obstacle = _box(self, Vector3(8.55, 29.1, -3.7), Vector3(5.3, 2.8, 0.8), materials["edge"], true)
	route_obstacle.name = "FallenArchiveCeiling"
	route_obstacle_body = route_obstacle.get_child(0) as StaticBody3D
	route_obstacle_body.collision_layer = 0
	route_obstacle_body.collision_mask = 0
	route_markers = Node3D.new()
	route_markers.name = "ArchiveDetourMarkers"
	add_child(route_markers)
	_label(route_markers, Vector3(7.8, 26.8, -2.9), "PASSAGE EST COUPÉ
CONTOURNER PAR LE NOYAU ←", 29, Color("f4c389"), 0.008)
	for zz in [-2.2, -3.2, -4.2, -5.2]:
		_box(route_markers, Vector3(4.7, 24.025, zz), Vector3(0.15, 0.035, 0.5), materials["lit_green"])
	for xx in [5.6, 6.4]:
		_box(route_markers, Vector3(xx, 24.025, -5.2), Vector3(0.5, 0.035, 0.15), materials["lit_green"])

func set_incident_player_position(player_position: Vector3) -> void:
	incident_player_position = player_position

func apply_incident(stage: String, stage_time: float) -> void:
	# Sampling any state twice yields the same geometry; rewind/restore is safe.
	# Only a witnessed impact starts the cosmetic settling tail. A direct load
	# into the stable aftermath restores an already settled dust state.
	if stage == "aftermath" and incident_stage != "aftermath":
		aftermath_dust_elapsed = 0.0 if incident_stage == "impact" else AFTERMATH_DUST_DURATION
	elif stage == "intact":
		aftermath_dust_elapsed = AFTERMATH_DUST_DURATION
	incident_stage = stage
	var t: float = maxf(stage_time, 0.0)
	var after_contact: bool = stage == "impact" or stage == "aftermath"
	if is_instance_valid(hesperie_sign):
		# The sign is torn away at contact; it must not intrude into Aube's rooms.
		hesperie_sign.visible = not after_contact
	var collapse_fraction: float = 0.0
	if stage == "collapse":
		collapse_fraction = smoothstep(0.0, 7.0, t)
	elif after_contact:
		collapse_fraction = 1.0
	var quake_sway: float = 0.0
	if stage == "quake":
		# A bounded, slow structural oscillation remains readable without flashes.
		quake_sway = sin(t * 4.7) * sin(minf(t / 6.0, 1.0) * PI) * 0.18
	elif stage == "impact":
		quake_sway = sin(t * 9.0) * exp(-t * 1.8) * 0.12
	if is_instance_valid(twin_tower):
		twin_tower.position = twin_origin + FINAL_SETTLEMENT * collapse_fraction
		twin_tower.rotation_degrees = Vector3(0, 0, FINAL_LEAN * collapse_fraction + quake_sway)
	_sample_bravo_retreat(stage, t)
	for damage: Node3D in incident_damage:
		damage.visible = after_contact
	for pane: MeshInstance3D in breakable_glass:
		pane.visible = not after_contact
	if is_instance_valid(crack_group):
		crack_group.visible = stage == "quake" or stage == "collapse"
	if is_instance_valid(broken_connection):
		broken_connection.visible = after_contact
	if is_instance_valid(emergency_group):
		emergency_group.visible = after_contact
	for light: OmniLight3D in affected_lights:
		light.light_energy = 0.28 if after_contact else 0.95
	_update_incident_dust(stage, t)
	for index in range(impact_fragments.size()):
		var piece: MeshInstance3D = impact_fragments[index]
		var age: float = maxf(0, t - float(index % 6) * 0.055)
		piece.visible = stage == "impact" and age < 2.7
		# Fragments are cosmetic and fall outwards, not through the rescue path.
		piece.position = fragment_origins[index] + Vector3(0.4 + index % 4 * 0.35, 1.0 + index % 3 * 0.4, sin(index * 2.0) * 1.7) * age + Vector3(0, -4.8 * age * age, 0)
		piece.rotation = Vector3(age * (index % 3 + 1), age * 1.4, age * (index % 4 + 1))
	if is_instance_valid(route_obstacle):
		if stage == "intact":
			route_obstacle_activated = false
		var occupied: bool = _route_has_occupant()
		var fall_progress: float = clampf(t / 1.6, 0, 1) if stage == "impact" else 1.0
		route_obstacle.position.y = lerpf(29.1, 25.4, fall_progress * fall_progress)
		route_markers.visible = after_contact
		# The safety check applies only to the first landing. Once the barrier
		# has settled, approaching it must not make its collision disappear.
		if after_contact and fall_progress >= 1.0 and not occupied:
			route_obstacle_activated = true
		# Hide the opaque visual as well until an occupant leaves its envelope.
		route_obstacle.visible = after_contact and (route_obstacle_activated or not occupied)
		var should_block: bool = after_contact and fall_progress >= 1.0 and route_obstacle_activated
		var new_layer: int = 1 if should_block else 0
		if route_obstacle_body.collision_layer != new_layer:
			route_obstacle_body.set_deferred("collision_layer", new_layer)
			route_obstacle_body.set_deferred("collision_mask", new_layer)

func _sample_bravo_retreat(stage: String, sample_time: float) -> void:
	# A single continuous prepared action follows the incident clock. Loading a
	# phase directly yields the same pose; no Tween, pathfinding or collider is used.
	var retreat: float = 0.0
	var clock: float = 0.0
	match stage:
		"warning":
			clock = clampf(sample_time, 0.0, 8.0)
			retreat = smoothstep(1.0, 8.0, clock) * 0.08
		"quake":
			clock = 8.0 + clampf(sample_time, 0.0, 6.0)
			retreat = 0.08 + smoothstep(0.0, 6.0, sample_time) * 0.76
		"collapse":
			clock = 14.0 + clampf(sample_time, 0.0, 2.2)
			retreat = 0.84 + smoothstep(0.0, 2.2, sample_time) * 0.16
		"impact", "aftermath":
			clock = 16.2
			retreat = 1.0
	var turn: float = smoothstep(1.0, 4.0, clock)
	if is_instance_valid(bravo_gallery):
		bravo_gallery.visible = stage != "impact" and stage != "aftermath"
		for index in range(bravo_members.size()):
			_pose_retreat_member(bravo_members[index], bravo_member_origins[index], Vector3(3.2, 0, -0.35 + index * 0.7), -PI / 2, retreat, turn, clock, index)
	if is_instance_valid(bravo_roof_team):
		bravo_roof_team.visible = stage != "impact" and stage != "aftermath"
		for index in range(bravo_roof_members.size()):
			_pose_retreat_member(bravo_roof_members[index], bravo_roof_origins[index], Vector3(5.0 + index * 0.6, 186, -5.8), 0.0, retreat, turn, clock, index + 2)

func _pose_retreat_member(member: Node3D, origin: Vector3, shelter: Vector3, initial_yaw: float, retreat: float, turn: float, clock: float, index: int) -> void:
	var direction: Vector3 = shelter - origin
	var stride: float = sin(clock * 8.5 + index) * 0.025 * sin(retreat * PI)
	member.position = origin.lerp(shelter, retreat) + Vector3(0, absf(stride), 0)
	member.rotation = Vector3(0, lerp_angle(initial_yaw, atan2(-direction.x, -direction.z), turn), stride)
	# Disappearance happens inside the authored shelter and says nothing about fate.
	member.visible = retreat < 0.985
	_pose_human_walk(member, clock * 8.5 + index, sin(retreat * PI))

func _update_incident_dust(stage: String, sample_time: float) -> void:
	if not is_instance_valid(dust_group):
		return
	if stage == "impact":
		dust_group.visible = true
		dust_group.scale = Vector3.ONE * clampf(0.25 + sample_time * 0.35, 0.25, 1.15)
	elif stage == "aftermath":
		dust_group.visible = aftermath_dust_elapsed < AFTERMATH_DUST_DURATION
		dust_group.scale = Vector3.ONE * clampf(1.15 - aftermath_dust_elapsed * 0.09, 0.25, 1.15)
	else:
		dust_group.visible = false
		dust_group.scale = Vector3.ONE * 0.25

func _route_has_occupant() -> bool:
	var blocked_volume: AABB = AABB(Vector3(5.35, 22.0, -4.65), Vector3(6.4, 6.0, 1.9))
	return blocked_volume.has_point(incident_player_position)

func _build_rain() -> void:
	rain = MultiMeshInstance3D.new()
	rain.name = "Rain"
	var multi: MultiMesh = MultiMesh.new()
	multi.transform_format = MultiMesh.TRANSFORM_3D
	var mesh: BoxMesh = BoxMesh.new()
	mesh.size = Vector3(0.012,0.55,0.012)
	mesh.material = materials["rain"]
	multi.mesh = mesh
	multi.instance_count = 420
	for index in range(420):
		var transform: Transform3D = Transform3D(Basis(Vector3.FORWARD,0.18),Vector3(rng.randf_range(-36,36),rng.randf_range(0,62),rng.randf_range(-36,36)))
		multi.set_instance_transform(index,transform)
	rain.multimesh = multi
	rain.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(rain)
	rain_origin = Vector3(0,12,0)
	rain.position = rain_origin

func create_shadow(number: int) -> Node3D:
	var shadow: Node3D = Node3D.new()
	shadow.name = "SillageFigure%d" % number
	add_child(shadow)
	shadow.position = Vector3(-6,float(number-24)*6,-3.8)
	_human(shadow,Vector3.ZERO,materials["dark"],false)
	shadow.scale = Vector3(0.72,1.4,0.72)
	_sphere(shadow,Vector3(-0.09,1.65,-0.18),Vector3(0.025,0.025,0.025),materials["lit_amber"])
	_sphere(shadow,Vector3(0.09,1.65,-0.18),Vector3(0.025,0.025,0.025),materials["lit_amber"])
	shadow.visible = false
	return shadow

func _interaction(parent: Node3D, pos: Vector3, kind: String, id_value: String, number: int, title: String, description: String) -> Node3D:
	var node: Node3D = Node3D.new()
	node.name = id_value
	parent.add_child(node)
	node.position = pos
	node.set_meta("kind",kind)
	node.set_meta("id",id_value)
	node.set_meta("floor",number)
	node.set_meta("title",title)
	node.set_meta("description",description)
	interactables.append(node)
	return node

func _human(parent: Node3D, pos: Vector3, clothing: Material, helmet: bool) -> Node3D:
	return Presentation.human(self, parent, pos, clothing, helmet)

func _supply_crate(parent: Node3D, pos: Vector3) -> void:
	_box(parent,pos+Vector3(0,0.38,0),Vector3(1.5,0.76,1.0),materials["orange"],true)
	_box(parent,pos+Vector3(0,0.81,0),Vector3(1.6,0.1,1.1),materials["dark"])
	_box(parent,pos+Vector3(0,0.43,0.515),Vector3(0.12,0.43,0.02),materials["white"])
	_box(parent,pos+Vector3(0,0.43,0.52),Vector3(0.43,0.12,0.02),materials["white"])
	_label(parent,pos+Vector3(0,1.5,0),"SECOURS",26,Color("f3c184"),0.008)

func _chair(parent: Node3D, pos: Vector3, yaw: float, mat: Material) -> void:
	var chair: Node3D = Node3D.new()
	parent.add_child(chair)
	chair.position = pos
	chair.rotation.y = yaw
	_box(chair,Vector3(0,0.5,0),Vector3(0.75,0.15,0.8),mat,true)
	_box(chair,Vector3(0,0.95,0.34),Vector3(0.75,0.8,0.15),mat,true)
	for xx in [-0.27,0.27]:
		for zz in [-0.27,0.27]:
			_box(chair,Vector3(xx,0.25,zz),Vector3(0.07,0.5,0.07),materials["metal"])

func _planter(parent: Node3D, pos: Vector3) -> void:
	_cylinder(parent,pos+Vector3(0,0.35,0),0.5,0.7,materials["wood"],true)
	_cylinder(parent,pos+Vector3(0,1.2,0),0.08,1.6,materials["wood"])
	_sphere(parent,pos+Vector3(0,1.9,0),Vector3(0.85,1.0,0.85),materials["green"])

func _box(parent: Node3D, pos: Vector3, size_value: Vector3, material: Material, solid: bool = false) -> MeshInstance3D:
	var node: MeshInstance3D = MeshInstance3D.new()
	var mesh: BoxMesh = BoxMesh.new()
	mesh.size = size_value
	node.mesh = mesh
	node.material_override = material
	parent.add_child(node)
	node.position = pos
	if solid:
		var body: StaticBody3D = StaticBody3D.new()
		var collider: CollisionShape3D = CollisionShape3D.new()
		var shape: BoxShape3D = BoxShape3D.new()
		shape.size = size_value
		collider.shape = shape
		body.add_child(collider)
		node.add_child(body)
	return node

func _cylinder(parent: Node3D, pos: Vector3, radius: float, height: float, material: Material, solid: bool = false) -> MeshInstance3D:
	var node: MeshInstance3D = MeshInstance3D.new()
	var mesh: CylinderMesh = CylinderMesh.new()
	mesh.top_radius = radius
	mesh.bottom_radius = radius
	mesh.height = height
	mesh.radial_segments = 12
	node.mesh = mesh
	node.material_override = material
	parent.add_child(node)
	node.position = pos
	if solid:
		var body: StaticBody3D = StaticBody3D.new()
		var collider: CollisionShape3D = CollisionShape3D.new()
		var shape: CylinderShape3D = CylinderShape3D.new()
		shape.radius = radius
		shape.height = height
		collider.shape = shape
		body.add_child(collider)
		node.add_child(body)
	return node

func _sphere(parent: Node3D, pos: Vector3, scale_value: Vector3, material: Material) -> MeshInstance3D:
	var node: MeshInstance3D = MeshInstance3D.new()
	var mesh: SphereMesh = SphereMesh.new()
	mesh.radius = 1.0
	mesh.height = 2.0
	mesh.radial_segments = 12
	mesh.rings = 6
	node.mesh = mesh
	node.material_override = material
	parent.add_child(node)
	node.position = pos
	node.scale = scale_value
	return node

func _label(parent: Node3D, pos: Vector3, text_value: String, font_size: int, color: Color, pixel_size: float = 0.01, billboard: bool = true) -> Label3D:
	var label: Label3D = Label3D.new()
	label.text = text_value
	label.font_size = font_size
	label.pixel_size = pixel_size
	label.modulate = color
	label.outline_modulate = Color("0c1c24")
	label.outline_size = 6
	label.no_depth_test = false
	if billboard:
		label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		# Gameplay annotations stay visible to the player, but never overlay
		# the diegetic backgrounds used by the menu and cinematic camera.
		label.layers = 2
	parent.add_child(label)
	label.position = pos
	return label

func _light(parent: Node3D, pos: Vector3, color: Color, energy: float, light_range: float) -> OmniLight3D:
	var light: OmniLight3D = OmniLight3D.new()
	light.light_color = color
	light.light_energy = energy
	light.omni_range = light_range
	light.omni_attenuation = 1.3
	light.shadow_enabled = false
	parent.add_child(light)
	light.position = pos
	return light
