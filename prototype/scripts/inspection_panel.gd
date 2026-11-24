extends Control
class_name DescentInspectionPanel
## Presentation only. The owner decides when play pauses and resumes.

signal close_requested

const PALE: Color = Color(0.88, 0.92, 0.91)
const MUTED: Color = Color(0.59, 0.70, 0.73)
const TEAL: Color = Color(0.38, 0.85, 0.79)
const AMBER: Color = Color(0.96, 0.69, 0.36)

var entry_id: String = ""
var title_label: Label
var category_label: Label
var status_label: Label
var usage_label: Label
var observation_label: Label
var action_label: Label
var team_label: Label
var close_button: Button
var scroll: ScrollContainer
var page_margin: MarginContainer

func _ready() -> void:
	name = "InspectionPanel"
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	var shade: ColorRect = ColorRect.new()
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	shade.color = Color(0.01, 0.025, 0.035, 0.84)
	shade.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(shade)
	page_margin = MarginContainer.new()
	page_margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(page_margin)
	var sheet: PanelContainer = PanelContainer.new()
	var sheet_style: StyleBoxFlat = _style(Color(0.035, 0.065, 0.078, 0.99), Color(0.22, 0.36, 0.38))
	sheet_style.content_margin_left = 34
	sheet_style.content_margin_right = 34
	sheet_style.content_margin_top = 26
	sheet_style.content_margin_bottom = 24
	sheet_style.border_width_top = 3
	sheet.add_theme_stylebox_override("panel", sheet_style)
	page_margin.add_child(sheet)
	var layout: VBoxContainer = VBoxContainer.new()
	layout.add_theme_constant_override("separation", 14)
	sheet.add_child(layout)
	var eyebrow: HBoxContainer = HBoxContainer.new()
	eyebrow.add_theme_constant_override("separation", 16)
	layout.add_child(eyebrow)
	var heading: Label = _label("LECTURE DU TERRAIN", 15, TEAL)
	heading.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	eyebrow.add_child(heading)
	status_label = _label("", 14, AMBER)
	status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	eyebrow.add_child(status_label)
	var identity: VBoxContainer = VBoxContainer.new()
	identity.add_theme_constant_override("separation", 4)
	layout.add_child(identity)
	title_label = _label("", 38, PALE)
	title_label.add_theme_font_override("font", preload("res://assets/fonts/OpenSans-CondBold.ttf"))
	title_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	identity.add_child(title_label)
	category_label = _label("", 15, MUTED)
	category_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	identity.add_child(category_label)
	layout.add_child(_rule())
	scroll = ScrollContainer.new()
	scroll.name = "ReadingScroll"
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	scroll.follow_focus = false
	layout.add_child(scroll)
	var reading_margin: MarginContainer = MarginContainer.new()
	reading_margin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	reading_margin.add_theme_constant_override("margin_right", 20)
	reading_margin.add_theme_constant_override("margin_top", 4)
	reading_margin.add_theme_constant_override("margin_bottom", 14)
	scroll.add_child(reading_margin)
	var reading: VBoxContainer = VBoxContainer.new()
	reading.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	reading.add_theme_constant_override("separation", 22)
	reading_margin.add_child(reading)
	usage_label = _section(reading, "FONCTION DE L’OBJET", PALE)
	observation_label = _section(reading, "CONSTAT SUR PLACE", PALE)
	action_label = _section(reading, "POUR LA SUITE", Color(0.74, 0.9, 0.86))
	team_label = _section(reading, "NOTE DE L’ÉQUIPE", MUTED, 18)
	layout.add_child(_rule())
	var footer: HBoxContainer = HBoxContainer.new()
	footer.add_theme_constant_override("separation", 24)
	layout.add_child(footer)
	var navigation: Label = _label("Molette / Page ↑↓  ·  Défiler\nÉchap  ·  Reprendre", 15, MUTED)
	navigation.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	navigation.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	footer.add_child(navigation)
	close_button = Button.new()
	close_button.name = "CloseInspection"
	close_button.text = "Fermer et reprendre"
	close_button.custom_minimum_size = Vector2(230, 52)
	close_button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	close_button.add_theme_font_size_override("font_size", 18)
	close_button.add_theme_color_override("font_color", Color(0.035, 0.085, 0.09))
	close_button.add_theme_color_override("font_hover_color", Color(0.035, 0.085, 0.09))
	close_button.add_theme_color_override("font_pressed_color", Color(0.035, 0.085, 0.09))
	close_button.add_theme_stylebox_override("normal", _style(TEAL, TEAL))
	close_button.add_theme_stylebox_override("hover", _style(Color(0.57, 0.95, 0.88), TEAL))
	close_button.add_theme_stylebox_override("pressed", _style(Color(0.29, 0.67, 0.64), TEAL))
	close_button.add_theme_stylebox_override("focus", _style(Color(0, 0, 0, 0), AMBER, 2))
	close_button.pressed.connect(func(): close_requested.emit())
	footer.add_child(close_button)
	resized.connect(_update_margins)
	_update_margins()
	hide()

func present(entry: Dictionary) -> void:
	entry_id = entry.get("id", "")
	title_label.text = entry.get("title", "Observation")
	category_label.text = "%s  /  %s" % [entry.get("floor_label", "AUBE"), entry.get("category", "TERRAIN")]
	status_label.text = entry.get("status_label", "")
	usage_label.text = entry.get("usage", "")
	observation_label.text = entry.get("observation", "")
	action_label.text = entry.get("action", "")
	team_label.text = entry.get("team_note", "")
	scroll.scroll_vertical = 0
	show()
	close_button.grab_focus.call_deferred()

func _unhandled_key_input(event: InputEvent) -> void:
	if not visible or not event is InputEventKey or not event.pressed:
		return
	var step: int = maxi(120, int(scroll.size.y * 0.75))
	match event.keycode:
		KEY_PAGEDOWN:
			scroll.scroll_vertical += step
		KEY_PAGEUP:
			scroll.scroll_vertical -= step
		KEY_HOME:
			scroll.scroll_vertical = 0
		KEY_END:
			scroll.scroll_vertical = int(scroll.get_v_scroll_bar().max_value)
		_:
			return
	get_viewport().set_input_as_handled()

func _update_margins() -> void:
	if not is_instance_valid(page_margin):
		return
	var horizontal: int = maxi(18, int((size.x - 1040.0) * 0.5))
	var vertical: int = int(clampf(size.y * 0.065, 18.0, 66.0))
	page_margin.add_theme_constant_override("margin_left", horizontal)
	page_margin.add_theme_constant_override("margin_right", horizontal)
	page_margin.add_theme_constant_override("margin_top", vertical)
	page_margin.add_theme_constant_override("margin_bottom", vertical)

func _section(parent: VBoxContainer, heading: String, color: Color, font_size: int = 20) -> Label:
	var section: VBoxContainer = VBoxContainer.new()
	section.add_theme_constant_override("separation", 7)
	parent.add_child(section)
	section.add_child(_label(heading, 14, TEAL))
	var content: Label = _label("", font_size, color)
	content.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content.add_theme_constant_override("line_spacing", 5)
	section.add_child(content)
	return content

func _rule() -> ColorRect:
	var rule: ColorRect = ColorRect.new()
	rule.color = Color(0.18, 0.29, 0.31)
	rule.custom_minimum_size.y = 1
	rule.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return rule

func _label(text: String, font_size: int, color: Color) -> Label:
	var label: Label = Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	return label

func _style(background: Color, border: Color, border_width: int = 1) -> StyleBoxFlat:
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = background
	style.border_color = border
	style.set_border_width_all(border_width)
	style.set_corner_radius_all(3)
	return style
