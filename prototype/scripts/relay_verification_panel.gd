extends Control
## Diegetic routing check. Only explicit player input arms the held emission.
signal submitted(destination: String, reference: String)
signal cancelled
var destination_input: LineEdit
var reference_input: LineEdit
var error_label: Label

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	var shade := ColorRect.new()
	shade.color = Color(0.015, 0.028, 0.037, 0.94)
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(shade)
	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(center)
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(580, 0)
	var style := StyleBoxFlat.new()
	style.bg_color = Color("12242d")
	style.border_color = Color("3d7478")
	style.set_border_width_all(1)
	style.set_content_margin_all(28)
	style.set_corner_radius_all(10)
	panel.add_theme_stylebox_override("panel", style)
	center.add_child(panel)
	var stack := VBoxContainer.new()
	stack.add_theme_constant_override("separation", 14)
	panel.add_child(stack)
	var title := Label.new()
	title.text = "RELAIS 17 · VÉRIFIER L’ÉMISSION"
	title.add_theme_font_size_override("font_size", 25)
	stack.add_child(title)
	var instructions := Label.new()
	instructions.text = "Comparez les deux champs à la plaque de routage.\nUne voix connue ne confirme pas sa destination."
	instructions.add_theme_font_size_override("font_size", 17)
	stack.add_child(instructions)
	for caption: String in ["Destination", "Référence de circuit"]:
		var label := Label.new()
		label.text = caption
		stack.add_child(label)
		var field := LineEdit.new()
		field.max_length = 32
		field.custom_minimum_size.y = 44
		field.placeholder_text = "Recopier la plaque du local"
		stack.add_child(field)
		if caption == "Destination": destination_input = field
		else: reference_input = field
	error_label = Label.new()
	error_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	error_label.custom_minimum_size = Vector2(520, 52)
	error_label.add_theme_color_override("font_color", Color("f0ba80"))
	stack.add_child(error_label)
	var buttons := HBoxContainer.new()
	buttons.add_theme_constant_override("separation", 12)
	stack.add_child(buttons)
	var back := Button.new()
	back.text = "Revenir à la plaque"
	back.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	back.custom_minimum_size.y = 44
	back.pressed.connect(func(): cancelled.emit())
	buttons.add_child(back)
	var submit := Button.new()
	submit.text = "Vérifier le routage"
	submit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	submit.custom_minimum_size.y = 44
	submit.pressed.connect(_submit)
	buttons.add_child(submit)
	reference_input.text_submitted.connect(func(_value: String): _submit())
	destination_input.text_submitted.connect(func(_value: String): reference_input.grab_focus())
	hide()

func open_panel() -> void:
	error_label.text = "Le temps de l’intervention est suspendu pendant cette vérification."
	show()
	destination_input.grab_focus()

func show_error(message: String) -> void:
	error_label.text = message

func _submit() -> void:
	submitted.emit(destination_input.text.strip_edges().to_upper(), reference_input.text.strip_edges().to_upper())
