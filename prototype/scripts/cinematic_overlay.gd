extends Control
class_name DescentCinematicOverlay

signal skip_requested

const TITLE_FONT = preload("res://assets/fonts/OpenSans-CondBold.ttf")
const BODY_FONT = preload("res://assets/fonts/OpenSans-Regular.ttf")
const LIGHT_FONT = preload("res://assets/fonts/OpenSans-Light.ttf")
var veil: ColorRect
var card: Control
var crest: TextureRect
var eyebrow: Label
var title: Label
var subtitle: Label
var radio_source: Label
var radio_text: Label
var skip_button: Button
var progress: ProgressBar

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	veil = ColorRect.new()
	veil.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	veil.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var material: ShaderMaterial = ShaderMaterial.new()
	material.shader = preload("res://shaders/cinematic_veil.gdshader")
	veil.material = material
	add_child(veil)
	for bottom: bool in [false,true]:
		var bar: ColorRect = ColorRect.new()
		bar.color = Color("05090c")
		bar.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE if bottom else Control.PRESET_TOP_WIDE)
		bar.offset_top = -76 if bottom else 0
		bar.offset_bottom = 0 if bottom else 76
		bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(bar)
	card = Control.new()
	card.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	card.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(card)
	crest = TextureRect.new()
	crest.texture = preload("res://assets/ui/studio_mark.svg")
	crest.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	crest.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	crest.position = Vector2(648,224)
	crest.size = Vector2(144,144)
	card.add_child(crest)
	eyebrow = _label(19,Color("c9a24a"),BODY_FONT)
	title = _label(65,Color("e8e7de"),TITLE_FONT)
	subtitle = _label(19,Color("adb9b9"),BODY_FONT)
	card.add_child(eyebrow)
	card.add_child(title)
	card.add_child(subtitle)
	radio_source = _label(15,Color("d2b582"),BODY_FONT)
	radio_source.position = Vector2(290,690)
	radio_source.size = Vector2(860,28)
	add_child(radio_source)
	radio_text = _label(21,Color("e8e7de"),BODY_FONT)
	radio_text.position = Vector2(230,724)
	radio_text.size = Vector2(980,74)
	radio_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	add_child(radio_text)
	skip_button = Button.new()
	skip_button.text = "PASSER  ·  E / ENTRÉE"
	skip_button.position = Vector2(1110,838)
	skip_button.size = Vector2(256,40)
	skip_button.flat = true
	skip_button.add_theme_font_override("font",BODY_FONT)
	skip_button.add_theme_font_size_override("font_size",14)
	skip_button.add_theme_color_override("font_color",Color("b7c0bd"))
	skip_button.pressed.connect(func(): skip_requested.emit())
	add_child(skip_button)
	progress = ProgressBar.new()
	progress.position = Vector2(80,855)
	progress.size = Vector2(220,2)
	progress.show_percentage = false
	var background: StyleBoxFlat = StyleBoxFlat.new()
	background.bg_color = Color("283a40")
	progress.add_theme_stylebox_override("background",background)
	var fill: StyleBoxFlat = StyleBoxFlat.new()
	fill.bg_color = Color("b89a67")
	progress.add_theme_stylebox_override("fill",fill)
	add_child(progress)
	hide()

func _label(font_size: int, color: Color, font: Font) -> Label:
	var label: Label = Label.new()
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_override("font",font)
	label.add_theme_font_size_override("font_size",font_size)
	label.add_theme_color_override("font_color",color)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return label

func set_frame(data: Dictionary, sequence: String) -> void:
	show()
	var kind: String = data.get("card","")
	var arrival: bool = sequence == "arrival"
	card.modulate.a = float(data.get("alpha",1.0))
	crest.visible = kind == "studio"
	eyebrow.text = data.get("eyebrow","")
	title.text = data.get("title","")
	subtitle.text = data.get("subtitle","")
	progress.value = float(data.get("progress",0)) * 100.0
	(veil.material as ShaderMaterial).set_shader_parameter("shade",0.09 if arrival else 0.43 if kind == "title" else 0.76)
	if arrival:
		eyebrow.position = Vector2(80,110)
		eyebrow.size = Vector2(700,28)
		title.position = Vector2(80,145)
		title.size = Vector2(900,70)
		subtitle.position = Vector2(82,214)
		subtitle.size = Vector2(900,30)
		title.add_theme_font_size_override("font_size",46)
		for label: Label in [eyebrow,title,subtitle]:
			label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	else:
		eyebrow.position = Vector2(200,380 if kind == "studio" else 328)
		eyebrow.size = Vector2(1040,36)
		title.position = Vector2(140,416 if kind == "studio" else 280 if kind == "title" else 376)
		title.size = Vector2(1160,260 if kind == "title" else 100)
		title.add_theme_font_size_override("font_size",105 if kind == "title" else 66)
		title.add_theme_constant_override("line_spacing",-16 if kind == "title" else 0)
		subtitle.position = Vector2(160,570 if kind == "title" else 524)
		subtitle.size = Vector2(1120,50)
		for label: Label in [eyebrow,title,subtitle]:
			label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		radio_source.text = ""
		radio_text.text = ""

func set_transmission(speaker: String, message: String) -> void:
	radio_source.text = speaker
	radio_text.text = message
