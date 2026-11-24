extends Control
class_name DescentFrontend

signal start_requested(seed_value: int)
signal continue_requested
signal replay_requested
signal help_requested
signal setting_changed(setting: String, enabled: bool)

const TITLE_FONT = preload("res://assets/fonts/OpenSans-CondBold.ttf")
const BODY_FONT = preload("res://assets/fonts/OpenSans-Regular.ttf")
const LIGHT_FONT = preload("res://assets/fonts/OpenSans-Light.ttf")
const GOLD: Color = Color("d2b582")
const WHITE: Color = Color("e7e6dd")
const MUTED: Color = Color("97a8ad")
const TEAL: Color = Color("7caeb5")

var start_button: Button
var continue_button: Button
var seed_input: SpinBox
var options: Control
var dossier: Control
var new_panel: Control
var context_title: Label
var context_detail: Label
var progress_label: Label
var mission_text: RichTextLabel
var replacement_note: Label
var toggles: Dictionary = {}
var modal_stack: Array[Control] = []
var has_save: bool = false
var reduced_motion: bool = true
var clock: float = 0.0
var enter_time: float = 0.0
var title_group: Control
var context: Dictionary = {}

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_PASS
	var theme: Theme = Theme.new()
	theme.default_font = BODY_FONT
	theme.default_font_size = 18
	theme.set_color("font_color","Label",WHITE)
	theme.set_color("font_color","CheckButton",WHITE)
	self.theme = theme
	_build_background()
	_build_main()
	_build_new()
	_build_options()
	_build_dossier()
	set_context({},false,271104)

func _label(value: String, font_size: int, color: Color = WHITE, font: Font = BODY_FONT) -> Label:
	var item: Label = Label.new()
	item.text = value
	item.add_theme_font_override("font",font)
	item.add_theme_font_size_override("font_size",font_size)
	item.add_theme_color_override("font_color",color)
	return item

func _place(item: Control, position_value: Vector2, extent: Vector2, parent: Node = null) -> void:
	item.position = position_value
	item.size = extent
	(parent if parent != null else self).add_child(item)

func _flat(color: Color, border: Color = Color(0,0,0,0), width: int = 0) -> StyleBoxFlat:
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = color
	style.border_color = border
	style.border_width_left = width
	style.content_margin_left = 17
	style.content_margin_right = 17
	style.content_margin_top = 9
	style.content_margin_bottom = 9
	return style

func _button(value: String, callback: Callable, primary: bool = false) -> Button:
	var item: Button = Button.new()
	item.text = value
	item.alignment = HORIZONTAL_ALIGNMENT_LEFT
	item.custom_minimum_size = Vector2(500,46)
	item.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	item.add_theme_font_override("font",TITLE_FONT)
	item.add_theme_font_size_override("font_size",24)
	item.add_theme_color_override("font_color",GOLD if primary else WHITE)
	item.add_theme_color_override("font_hover_color",Color.WHITE)
	item.add_theme_color_override("font_disabled_color",Color(0.5,0.57,0.58,0.5))
	item.add_theme_stylebox_override("normal",_flat(Color(0.1,0.17,0.19,0.24) if primary else Color(0,0,0,0),GOLD if primary else Color(0,0,0,0),2 if primary else 0))
	item.add_theme_stylebox_override("hover",_flat(Color(0.20,0.29,0.31,0.58),GOLD,3))
	item.add_theme_stylebox_override("pressed",_flat(Color(0.27,0.33,0.32,0.8),GOLD,3))
	item.add_theme_stylebox_override("focus",_flat(Color(0.16,0.25,0.28,0.4),GOLD,2))
	item.pressed.connect(callback)
	return item

func _build_background() -> void:
	var shade: ColorRect = ColorRect.new()
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var shader: Shader = Shader.new()
	shader.code = "shader_type canvas_item; void fragment(){float a=mix(0.96,0.08,smoothstep(0.05,0.83,UV.x)); float low=smoothstep(0.57,1.0,UV.y)*0.38; COLOR=vec4(0.014,0.027,0.036,max(a,low));}"
	var material: ShaderMaterial = ShaderMaterial.new()
	material.shader = shader
	shade.material = material
	add_child(shade)
	var veil: ColorRect = ColorRect.new()
	veil.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	veil.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var veil_material: ShaderMaterial = ShaderMaterial.new()
	veil_material.shader = preload("res://shaders/cinematic_veil.gdshader")
	veil_material.set_shader_parameter("shade",0.02)
	veil_material.set_shader_parameter("edge_strength",0.28)
	veil.material = veil_material
	add_child(veil)

func _build_main() -> void:
	var mark: TextureRect = TextureRect.new()
	mark.texture = preload("res://assets/ui/studio_mark.svg")
	mark.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	mark.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_place(mark,Vector2(84,34),Vector2(31,31))
	_place(_label("DARKNIGTHMARE KINGDOMS GAMES PRODUCTIONS",12,MUTED),Vector2(128,41),Vector2(510,25))
	_place(_label("NACRE  /  OPÉRATION ORPHÉE",15,TEAL),Vector2(88,130),Vector2(510,28))
	title_group = Control.new()
	_place(title_group,Vector2(82,168),Vector2(570,205))
	_place(_label("THE TOWER",63,WHITE,TITLE_FONT),Vector2(0,0),Vector2(540,80),title_group)
	_place(_label("DESCENT",111,WHITE,TITLE_FONT),Vector2(-2,60),Vector2(570,140),title_group)
	_place(_label("Chaque vie compte.",23,GOLD,LIGHT_FONT),Vector2(89,374),Vector2(500,38))
	_place(_label("Chaque étage vous éloigne du ciel.",17,MUTED),Vector2(89,411),Vector2(530,30))
	var actions: VBoxContainer = VBoxContainer.new()
	actions.add_theme_constant_override("separation",8)
	_place(actions,Vector2(72,472),Vector2(520,320))
	continue_button = _button("REPRENDRE L’INTERVENTION",func(): continue_requested.emit(),true)
	actions.add_child(continue_button)
	start_button = _button("NOUVELLE INTERVENTION",func(): _open_modal(new_panel),true)
	actions.add_child(start_button)
	actions.add_child(_button("DOSSIER DE MISSION",func(): _open_modal(dossier)))
	actions.add_child(_button("OPTIONS",func(): _open_modal(options)))
	actions.add_child(_button("REVOIR L’INTRODUCTION",func(): replay_requested.emit()))
	if not OS.has_feature("web"):
		actions.add_child(_button("QUITTER",func(): get_tree().quit()))
	var coordinates: Label = _label("ARCHIPEL DE NACRE\n04:17  /  MER MONTANTE",14,MUTED)
	coordinates.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	coordinates.add_theme_constant_override("line_spacing",7)
	_place(coordinates,Vector2(1040,46),Vector2(320,65))
	progress_label = _label("",15,GOLD)
	progress_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_place(progress_label,Vector2(855,722),Vector2(505,28))
	context_title = _label("",30,WHITE,TITLE_FONT)
	context_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_place(context_title,Vector2(720,756),Vector2(640,48))
	context_detail = _label("",16,MUTED)
	context_detail.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_place(context_detail,Vector2(700,808),Vector2(660,32))
	_place(_label("THE TOWER DESCENT  /  0.4",12,MUTED),Vector2(89,860),Vector2(400,24))
	var bottom: Label = _label("↑ ↓  NAVIGUER     ENTRÉE  SÉLECTIONNER",12,MUTED)
	bottom.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_place(bottom,Vector2(950,862),Vector2(410,24))

func _modal(title: String) -> Array:
	var panel: Control = Control.new()
	panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	panel.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(panel)
	var shade: ColorRect = ColorRect.new()
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	shade.color = Color(0.018,0.032,0.045,0.98)
	panel.add_child(shade)
	var center: CenterContainer = CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	panel.add_child(center)
	var col: VBoxContainer = VBoxContainer.new()
	col.custom_minimum_size.x = 780
	col.add_theme_constant_override("separation",17)
	center.add_child(col)
	col.add_child(_label("OPÉRATION ORPHÉE",14,TEAL))
	col.add_child(_label(title,48,WHITE,TITLE_FONT))
	panel.hide()
	modal_stack.append(panel)
	return [panel,col]

func _build_new() -> void:
	var built: Array = _modal("NOUVELLE INTERVENTION")
	new_panel = built[0]
	var col: VBoxContainer = built[1]
	var brief: Label = _label("Alpha se déploie sur Aube. Bravo prend Hespérie.\nRetrouvez Ana au 30, Samuel au 28 et Nora au 26.\nLes hélicoptères repartiront dès la dépose terminée.",20,MUTED)
	brief.add_theme_constant_override("line_spacing",8)
	col.add_child(brief)
	var row: HBoxContainer = HBoxContainer.new()
	row.add_theme_constant_override("separation",24)
	row.add_child(_label("Disposition de l’intervention",18,WHITE))
	seed_input = SpinBox.new()
	seed_input.min_value = 1
	seed_input.max_value = 999999
	seed_input.value = 271104
	seed_input.custom_minimum_size = Vector2(190,45)
	row.add_child(seed_input)
	col.add_child(row)
	col.add_child(_label("Changer ce nombre fait varier les pièces, les ressources et les dangers.",16,MUTED))
	replacement_note = _label("Une nouvelle intervention remplacera votre dernier point sûr.\nVos réglages de confort seront conservés.",18,GOLD)
	col.add_child(replacement_note)
	col.add_child(_button("DÉPLOYER ALPHA",func(): start_requested.emit(int(seed_input.value)),true))
	col.add_child(_button("RETOUR",close_modals))

func _build_options() -> void:
	var built: Array = _modal("OPTIONS ET CONFORT")
	options = built[0]
	var col: VBoxContainer = built[1]
	var settings: Array = [["audio","Ambiance sonore"],["reduced_motion","Réduire les mouvements de caméra"],["flashes","Activer les éclairs lumineux"],["startup_intro","Afficher l’introduction au lancement"]]
	for record: Array in settings:
		var toggle: CheckButton = CheckButton.new()
		toggle.text = record[1]
		toggle.custom_minimum_size.y = 46
		toggle.add_theme_font_size_override("font_size",20)
		var key: String = record[0]
		toggle.toggled.connect(func(value: bool): setting_changed.emit(key,value))
		col.add_child(toggle)
		toggles[key] = toggle
	var detail: Label = _label("Les sous-titres sont toujours affichés. Toutes les séquences peuvent être passées.\nLa caméra réduite utilise des plans fixes et des fondus.\nLes éclairs sont facultatifs et désactivés par défaut.",17,MUTED)
	detail.add_theme_constant_override("line_spacing",8)
	col.add_child(detail)
	col.add_child(_button("COMMANDES",func(): help_requested.emit()))
	col.add_child(_button("RETOUR",close_modals,true))

func _build_dossier() -> void:
	var built: Array = _modal("DOSSIER DE MISSION")
	dossier = built[0]
	var col: VBoxContainer = built[1]
	mission_text = RichTextLabel.new()
	mission_text.custom_minimum_size = Vector2(780,385)
	mission_text.add_theme_font_size_override("normal_font_size",20)
	mission_text.add_theme_color_override("default_color",WHITE)
	col.add_child(mission_text)
	col.add_child(_button("COMMANDES ET MATÉRIEL",func(): help_requested.emit()))
	col.add_child(_button("RETOUR",close_modals,true))

func set_context(value: Dictionary, valid_save: bool, seed_value: int = 271104) -> void:
	context = value.duplicate(true)
	has_save = valid_save
	continue_button.visible = valid_save
	continue_button.disabled = not valid_save
	continue_button.text = "CONSULTER L’INTERVENTION TERMINÉE" if value.get("id") == "refuge" else "REPRENDRE L’INTERVENTION"
	start_button.text = "NOUVELLE INTERVENTION" if valid_save else "COMMENCER L’INTERVENTION"
	seed_input.value = seed_value
	replacement_note.visible = valid_save
	context_title.text = str(value.get("title","AVANT L’INTERVENTION"))
	context_detail.text = str(value.get("detail","Deux tours debout. Des vies à retrouver."))
	var floor_number: int = int(value.get("floor",31))
	var rescued_count: int = int(value.get("rescued",0))
	var seconds: int = int(value.get("elapsed",0))
	progress_label.text = "DERNIER POINT SÛR  /  %s  /  %d VIES SAUVÉES  /  %02d:%02d" % ["TOIT" if floor_number == 31 else "ÉTAGE %d" % floor_number,rescued_count,seconds / 60,seconds % 60] if valid_save else "PREMIÈRE ROTATION  /  ALPHA + BRAVO"
	var situation: String = "Aube et Hespérie sont debout. Deux équipes sont déposées sur les toits. Le typhon se reforme : les appareils attendront une accalmie pour revenir."
	if value.get("incident") == "aftermath":
		situation = "Une réplique a fait basculer Hespérie contre Aube. Le noyau et le treuil tiennent. Le passage Est du 28 est condamné ; passez par le noyau. Bravo ne répond plus."
	mission_text.text = "SITUATION\n" + situation + "\n\nVOTRE ÉQUIPE\nVarga coordonne le poste d’Aube. Alpha tient la ligne de rappel et réceptionne les rescapés. Bravo intervient sur Hespérie.\n\nVOTRE PARCOURS\n30 · Restaurant : Ana Rios\n29 · Suites : liaison visuelle vers Hespérie\n28 · Archives : Samuel Breton\n27 · Jardin des enfants\n26 · Spa : Nora Haddad\n25 · Refuge : relais et compte rendu\n\nMÉTHODE\nDescendez par la ligne centrale. Sécurisez chaque personne et rapportez-la à la balise de son étage. Attendez la confirmation du treuil. Vous pouvez remonter au poste de secours."
	if is_visible_in_tree():
		focus_primary()

func apply_settings(settings: Dictionary) -> void:
	for key: String in toggles:
		toggles[key].set_pressed_no_signal(bool(settings.get(key,false)))
	reduced_motion = bool(settings.get("reduced_motion",true))

func _open_modal(panel: Control) -> void:
	close_modals(false)
	panel.show()
	var buttons: Array[Node] = panel.find_children("*","Button",true,false)
	if not buttons.is_empty():
		buttons[0].grab_focus()

func close_modals(focus: bool = true) -> void:
	for panel: Control in modal_stack:
		panel.hide()
	if focus:
		focus_primary()

func focus_primary() -> void:
	if has_save:
		continue_button.grab_focus()
	else:
		start_button.grab_focus()

func reveal() -> void:
	enter_time = 0.0
	show()
	close_modals()

func has_modal() -> bool:
	for panel: Control in modal_stack:
		if panel.visible:
			return true
	return false

func _unhandled_key_input(event: InputEvent) -> void:
	if not is_visible_in_tree():
		return
	if event.is_action_pressed("ui_cancel") and has_modal():
		close_modals()
		get_viewport().set_input_as_handled()

func _process(delta: float) -> void:
	if not is_visible_in_tree():
		return
	clock += delta
	enter_time += delta
	modulate.a = clampf(enter_time / 0.65,0,1)
	if not reduced_motion:
		title_group.position.y = 168 + sin(clock * 0.22) * 1.6
	else:
		title_group.position.y = 168
