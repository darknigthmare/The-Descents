extends CanvasLayer
class_name DescentHUD

signal start_requested(seed_value: int)
signal continue_requested
signal resume_requested
signal return_requested
signal setting_changed(setting: String, enabled: bool)

const INK: Color = Color(0.035, 0.065, 0.08, 0.94)
const PALE: Color = Color(0.86, 0.92, 0.92)
const MUTED: Color = Color(0.55, 0.69, 0.72)
const AMBER: Color = Color(1.0, 0.65, 0.29)
const TEAL: Color = Color(0.35, 0.86, 0.83)

var root: Control
var menu: Control
var game: Control
var pause_panel: Control
var journal_panel: Control
var end_panel: Control
var help_panel: Control
var start_button: Button
var continue_button: Button
var seed_input: SpinBox
var location_label: Label
var status_label: Label
var mission_label: Label
var resources_label: Label
var prompt_label: Label
var radio_label: Label
var radio_source: Label
var radio_panel: Control
var journal_text: RichTextLabel
var completion_text: RichTextLabel
var notify_label: Label
var depth_label: Label
var health_bar: ProgressBar
var oxygen_bar: ProgressBar
var stress_bar: ProgressBar
var overlay: ColorRect
var floor_map: Label
var audio_toggle: CheckButton

func _ready() -> void:
	layer = 10
	root = Control.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(root)
	var theme: Theme = Theme.new()
	theme.default_font_size = 18
	theme.set_color("font_color", "Label", PALE)
	root.theme = theme
	_build_menu()
	_build_game()
	_build_pause()
	_build_journal()
	_build_end()
	_build_help()
	game.hide()
	pause_panel.hide()
	journal_panel.hide()
	end_panel.hide()
	help_panel.hide()

func _box(color: Color = INK, border: Color = Color(0.18, 0.29, 0.32)) -> StyleBoxFlat:
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = color
	style.border_color = border
	style.set_border_width_all(1)
	style.set_corner_radius_all(3)
	style.content_margin_left = 20
	style.content_margin_right = 20
	style.content_margin_top = 16
	style.content_margin_bottom = 16
	return style

func _label(text: String, size: int = 18, color: Color = PALE) -> Label:
	var label: Label = Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", size)
	label.add_theme_color_override("font_color", color)
	return label

func _button(text: String, action: Callable, highlighted: bool = false) -> Button:
	var b: Button = Button.new()
	b.text = text
	b.custom_minimum_size = Vector2(0, 49)
	b.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	b.add_theme_font_size_override("font_size", 18)
	b.add_theme_color_override("font_color", Color(0.03,0.08,0.1) if highlighted else PALE)
	b.add_theme_stylebox_override("normal", _box(TEAL if highlighted else Color(0.06,0.12,0.15,0.97)))
	b.add_theme_stylebox_override("hover", _box(Color(0.55,0.95,0.91) if highlighted else Color(0.12,0.24,0.28)))
	b.add_theme_stylebox_override("pressed", _box(Color(0.3,0.64,0.65)))
	b.add_theme_stylebox_override("focus", _box(Color(0,0,0,0), AMBER))
	b.pressed.connect(action)
	return b

func _full_control() -> Control:
	var control: Control = Control.new()
	control.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	control.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(control)
	return control

func _build_menu() -> void:
	menu = _full_control()
	var shade: ColorRect = ColorRect.new()
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var shader: Shader = Shader.new()
	shader.code = "shader_type canvas_item; void fragment(){float a=mix(0.97,0.12,smoothstep(0.12,0.95,UV.x)); COLOR=vec4(0.018,0.04,0.055,a);}"
	var material: ShaderMaterial = ShaderMaterial.new()
	material.shader = shader
	shade.material = material
	menu.add_child(shade)
	var column: VBoxContainer = VBoxContainer.new()
	column.position = Vector2(82, 95)
	column.size = Vector2(510, 670)
	column.add_theme_constant_override("separation", 15)
	menu.add_child(column)
	column.add_child(_label("OPÉRATION SILLAGE  /  ÎLE DE NACRE", 16, TEAL))
	var title: Label = _label("THE TOWER\nDESCENT", 68)
	title.add_theme_constant_override("line_spacing", -12)
	column.add_child(title)
	column.add_child(_label("Le dernier refuge est au-dessus de vous.", 21, AMBER))
	var intro: Label = _label("Deux tours debout. Deux équipes de secours.\nDescendez, retrouvez les survivants et remontez-les\nau treuil. La structure ne tiendra pas toujours.", 18, MUTED)
	intro.add_theme_constant_override("line_spacing", 8)
	column.add_child(intro)
	var spacer: Control = Control.new()
	spacer.custom_minimum_size.y = 12
	column.add_child(spacer)
	var seed_row: HBoxContainer = HBoxContainer.new()
	seed_row.add_theme_constant_override("separation", 18)
	seed_row.add_child(_label("Graine de l’intervention", 17, MUTED))
	seed_input = SpinBox.new()
	seed_input.min_value = 1
	seed_input.max_value = 999999
	seed_input.value = 271104
	seed_input.custom_minimum_size.x = 155
	seed_row.add_child(seed_input)
	column.add_child(seed_row)
	start_button = _button("Commencer l’intervention", func(): start_requested.emit(int(seed_input.value)), true)
	column.add_child(start_button)
	continue_button = _button("Reprendre le dernier point sûr", func(): continue_requested.emit())
	continue_button.disabled = not FileAccess.file_exists("user://save_v1.json")
	column.add_child(continue_button)
	column.add_child(_button("Commandes et mission", func(): help_panel.show()))
	var footer: Label = _label("PROTOTYPE 0.2     •     SOLO     •     6 ÉTAGES EXPLORABLES", 14, MUTED)
	footer.position = Vector2(82, 846)
	menu.add_child(footer)
	var coord: Label = _label("NACRE\nTOURS ORPHÉE\n04:17  /  MER MONTANTE", 16, PALE)
	coord.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	coord.position = Vector2(1010, 72)
	coord.size.x = 350
	menu.add_child(coord)

func _build_game() -> void:
	game = _full_control()
	var head: PanelContainer = PanelContainer.new()
	head.position = Vector2(28, 26)
	head.size = Vector2(505, 105)
	head.add_theme_stylebox_override("panel", _box())
	game.add_child(head)
	var stack: VBoxContainer = VBoxContainer.new()
	head.add_child(stack)
	stack.add_child(_label("SECOURS  /  TOUR AUBE", 14, TEAL))
	location_label = _label("TOIT  ·  Poste de commandement", 24)
	stack.add_child(location_label)
	depth_label = _label("ALT. 174 m  ·  LIAISON RADIO ACTIVE", 14, MUTED)
	stack.add_child(depth_label)
	var mission: PanelContainer = PanelContainer.new()
	mission.position = Vector2(979, 26)
	mission.size = Vector2(430, 135)
	mission.add_theme_stylebox_override("panel", _box())
	game.add_child(mission)
	var mission_stack: VBoxContainer = VBoxContainer.new()
	mission.add_child(mission_stack)
	mission_stack.add_child(_label("ORDRE DE MISSION", 14, AMBER))
	mission_label = _label("Rejoindre le puits de rappel au centre du toit.", 17)
	mission_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	mission_label.custom_minimum_size.x = 390
	mission_stack.add_child(mission_label)
	status_label = _label("RESCAPÉS 0 / 3    •    INDICES 0 / 3", 15, TEAL)
	mission_stack.add_child(status_label)
	var resources: PanelContainer = PanelContainer.new()
	resources.position = Vector2(28, 655)
	resources.size = Vector2(320, 201)
	resources.add_theme_stylebox_override("panel", _box())
	game.add_child(resources)
	var meters: VBoxContainer = VBoxContainer.new()
	meters.add_theme_constant_override("separation", 7)
	resources.add_child(meters)
	health_bar = _meter(meters, "ÉTAT PHYSIQUE", AMBER)
	oxygen_bar = _meter(meters, "AIR DE RÉSERVE", TEAL)
	stress_bar = _meter(meters, "TENSION", Color(0.74, 0.68, 0.9))
	resources_label = _label("ANCRAGES 4  /  FUSÉES 3", 14, MUTED)
	meters.add_child(resources_label)
	prompt_label = _label("", 20, Color(1, 0.92, 0.75))
	prompt_label.position = Vector2(365, 620)
	prompt_label.size = Vector2(710, 68)
	prompt_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	prompt_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	game.add_child(prompt_label)
	var cross: Label = _label("·", 34, Color(0.9,1,1,0.75))
	cross.position = Vector2(710, 423)
	game.add_child(cross)
	notify_label = _label("", 18, TEAL)
	notify_label.position = Vector2(400, 140)
	notify_label.size = Vector2(640, 80)
	notify_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	notify_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	game.add_child(notify_label)
	radio_panel = PanelContainer.new()
	radio_panel.position = Vector2(398, 724)
	radio_panel.size = Vector2(644, 105)
	radio_panel.add_theme_stylebox_override("panel", _box(Color(0.025,0.05,0.065,0.95)))
	game.add_child(radio_panel)
	var radio_stack: VBoxContainer = VBoxContainer.new()
	radio_panel.add_child(radio_stack)
	radio_source = _label("CANAL SECOURS  /  VARGA", 14, AMBER)
	radio_stack.add_child(radio_source)
	radio_label = _label("", 18)
	radio_label.custom_minimum_size.x = 600
	radio_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	radio_stack.add_child(radio_label)
	radio_panel.hide()
	floor_map = _label("31 TOIT\n30 RESTAURANT\n29 SUITES\n28 ARCHIVES\n27 JARDIN\n26 SPA\n25 REFUGE", 14, MUTED)
	floor_map.position = Vector2(1245, 265)
	floor_map.add_theme_constant_override("line_spacing", 10)
	game.add_child(floor_map)
	var keys: Label = _label("ZQSD / WASD  Marcher     E  Interagir     F  Lampe     R  Radio     G  Fusée     J  Journal     ÉCHAP  Pause", 14, MUTED)
	keys.position = Vector2(382, 865)
	game.add_child(keys)
	overlay = ColorRect.new()
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	overlay.color = Color(0.7, 0.12, 0.04, 0)
	game.add_child(overlay)

func _meter(parent: VBoxContainer, title: String, color: Color) -> ProgressBar:
	parent.add_child(_label(title, 13, MUTED))
	var bar: ProgressBar = ProgressBar.new()
	bar.custom_minimum_size = Vector2(274, 10)
	bar.show_percentage = false
	bar.value = 100
	bar.add_theme_stylebox_override("background", _box(Color(0.10,0.18,0.2), Color(0,0,0,0)))
	bar.add_theme_stylebox_override("fill", _box(color, color))
	parent.add_child(bar)
	return bar

func _modal(title: String, width: float = 660) -> Array:
	var panel: Control = _full_control()
	panel.mouse_filter = Control.MOUSE_FILTER_STOP
	var shade: ColorRect = ColorRect.new()
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	shade.color = Color(0.015,0.035,0.05,0.93)
	panel.add_child(shade)
	var center: CenterContainer = CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	panel.add_child(center)
	var col: VBoxContainer = VBoxContainer.new()
	col.custom_minimum_size.x = width
	col.add_theme_constant_override("separation", 16)
	center.add_child(col)
	col.add_child(_label(title, 32))
	return [panel, col]

func _build_pause() -> void:
	var result: Array = _modal("INTERVENTION EN PAUSE")
	pause_panel = result[0]
	var col: VBoxContainer = result[1]
	col.add_child(_button("Reprendre", func(): resume_requested.emit(), true))
	col.add_child(_button("Commandes et mission", func(): help_panel.show()))
	var motion: CheckButton = CheckButton.new()
	motion.text = "Réduire les mouvements de caméra"
	motion.button_pressed = true
	motion.toggled.connect(func(v: bool): setting_changed.emit("reduced_motion", v))
	col.add_child(motion)
	var flashes: CheckButton = CheckButton.new()
	flashes.text = "Éclairs lumineux (désactivés par défaut)"
	flashes.toggled.connect(func(v: bool): setting_changed.emit("flashes", v))
	col.add_child(flashes)
	audio_toggle = CheckButton.new()
	audio_toggle.text = "Ambiance sonore"
	audio_toggle.button_pressed = true
	audio_toggle.toggled.connect(func(v: bool): setting_changed.emit("audio", v))
	col.add_child(audio_toggle)
	col.add_child(_label("Sauvegarde aux treuils, au refuge et avant/après l’effondrement.\nUne interruption pendant la secousse reprend avant celle-ci.", 17, MUTED))
	col.add_child(_button("Retour au menu", func(): return_requested.emit()))

func _build_journal() -> void:
	var result: Array = _modal("JOURNAL D’INTERVENTION", 880)
	journal_panel = result[0]
	var col: VBoxContainer = result[1]
	journal_text = RichTextLabel.new()
	journal_text.custom_minimum_size = Vector2(880, 510)
	journal_text.bbcode_enabled = false
	journal_text.add_theme_font_size_override("normal_font_size", 19)
	col.add_child(journal_text)
	col.add_child(_button("Fermer le journal", func(): resume_requested.emit(), true))

func _build_end() -> void:
	var result: Array = _modal("LE REFUGE 25", 800)
	end_panel = result[0]
	var col: VBoxContainer = result[1]
	col.add_child(_label("Les trois rescapés sont arrivés au poste de secours.", 22, TEAL))
	completion_text = RichTextLabel.new()
	completion_text.custom_minimum_size = Vector2(800, 280)
	completion_text.bbcode_enabled = false
	completion_text.add_theme_font_size_override("normal_font_size", 21)
	col.add_child(completion_text)
	col.add_child(_label("Fin du prototype jouable. La campagne continue dans la bible du jeu.", 17, MUTED))
	col.add_child(_button("Revenir au menu", func(): return_requested.emit(), true))

func _build_help() -> void:
	var result: Array = _modal("DESCENDRE. SECOURIR. REMONTER.", 900)
	help_panel = result[0]
	var col: VBoxContainer = result[1]
	var text: RichTextLabel = RichTextLabel.new()
	text.custom_minimum_size = Vector2(900, 485)
	text.add_theme_font_size_override("normal_font_size", 20)
	text.text = "MISSION\nRejoignez la balise orange près du puits central. E vous attache à la corde.\nRetrouvez les trois rescapés aux étages 30, 28 et 26. Sécurisez-les avec E,\npuis rapportez-les à la balise du même étage pour les évacuer au treuil.\nAprès les trois évacuations, rejoignez le refuge de l’étage 25.\n\nÀ PIED\nZQSD ou WASD : marcher   •   Souris : regarder   •   Flèches : regarder\nMaj : courir   •   Ctrl : s’accroupir   •   Espace : sauter   •   E : interagir\n\nSUR LA CORDE\nS : descendre   •   Z / W : remonter   •   Q / A et D : balancement\nE à hauteur d’un étage : se poser   •   X : ancrage secondaire (consommable)\n\nMATÉRIEL\nF : lampe   •   G : fusée lumineuse   •   R : appeler le commandement\nJ : indices et mission   •   Échap : pause et confort visuel\n\nL’air de réserve diminue seulement dans les zones enfumées.\nLa silhouette du spa recule devant une fusée. Le refuge reste sûr."
	col.add_child(text)
	col.add_child(_button("Compris", func(): help_panel.hide(), true))

func show_game() -> void:
	menu.hide()
	game.show()
	pause_panel.hide()
	journal_panel.hide()
	end_panel.hide()
	help_panel.hide()

func show_menu() -> void:
	menu.show()
	game.hide()
	pause_panel.hide()
	journal_panel.hide()
	end_panel.hide()
	help_panel.hide()
	continue_button.disabled = not FileAccess.file_exists("user://save_v1.json")

func set_paused(paused: bool) -> void:
	pause_panel.visible = paused
	if not paused:
		journal_panel.hide()
		help_panel.hide()

func set_radio(speaker: String, message: String) -> void:
	radio_source.text = speaker
	radio_label.text = message
	radio_panel.show()
