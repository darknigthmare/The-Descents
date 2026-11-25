extends Control
class_name DescentFrontend

signal start_requested(seed_value: int)
signal continue_requested
signal replay_requested
signal help_requested
signal setting_changed(setting: String, value: Variant)
signal settings_closed

const Preferences = preload("res://scripts/preferences_store.gd")
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
var sliders: Dictionary = {}
var value_labels: Dictionary = {}
var settings_scroll: ScrollContainer
var standalone_settings: bool = false
var help_overlay: Control
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
	_place(_label("THE TOWER DESCENT  /  %s" % ProjectSettings.get_setting("application/config/version", "0.5.0"),12,MUTED),Vector2(89,860),Vector2(400,24))
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
	col.custom_minimum_size.x = 900
	settings_scroll = ScrollContainer.new()
	settings_scroll.custom_minimum_size = Vector2(900, 438)
	settings_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	settings_scroll.follow_focus = true
	col.add_child(settings_scroll)
	var settings_col: VBoxContainer = VBoxContainer.new()
	settings_col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	settings_col.add_theme_constant_override("separation", 10)
	settings_scroll.add_child(settings_col)
	settings_col.add_child(_label("SON", 14, TEAL))
	_add_toggle(settings_col, "audio", "Activer le son")
	_add_slider(settings_col, "master_volume", "Volume général")
	settings_col.add_child(_label("REGARD", 14, TEAL))
	_add_slider(settings_col, "mouse_sensitivity", "Sensibilité de la souris")
	_add_slider(settings_col, "field_of_view", "Champ de vision en jeu")
	_add_toggle(settings_col, "invert_y", "Inverser le regard vertical")
	settings_col.add_child(_label("MISE EN SCÈNE", 14, TEAL))
	_add_toggle(settings_col, "reduced_motion", "Réduire les mouvements de caméra")
	_add_toggle(settings_col, "flashes", "Activer les éclairs lumineux")
	_add_toggle(settings_col, "startup_intro", "Afficher l’introduction au lancement")
	var detail: Label = _label("Les sous-titres restent affichés. Toutes les introductions peuvent être passées.\nLe champ de vision règle le regard en jeu et le dernier raccord mobile de l’arrivée.\nMouvements réduits : plans fixes et pluie en voile, sans traînées mobiles.\nLe regard inversé s’applique à la souris et aux flèches. Les éclairs sont facultatifs.", 16, MUTED)
	detail.add_theme_constant_override("line_spacing", 5)
	settings_col.add_child(detail)
	col.add_child(_label("Appliqué immédiatement  ·  Tab : parcourir  ·  ← → : ajuster  ·  Molette : défiler", 15, MUTED))
	var actions: HBoxContainer = HBoxContainer.new()
	actions.add_theme_constant_override("separation", 14)
	var commands: Button = _button("COMMANDES", func(): help_requested.emit())
	commands.custom_minimum_size.x = 0
	commands.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	actions.add_child(commands)
	var reset: Button = _button("RÉTABLIR LES VALEURS PAR DÉFAUT", _reset_settings)
	reset.custom_minimum_size.x = 0
	reset.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	reset.add_theme_font_size_override("font_size", 21)
	actions.add_child(reset)
	col.add_child(actions)
	col.add_child(_button("RETOUR", close_modals, true))

func _add_toggle(parent: VBoxContainer, key: String, title: String) -> void:
	var toggle: CheckButton = CheckButton.new()
	toggle.name = "Setting_" + key
	toggle.text = title
	toggle.custom_minimum_size.y = 42
	toggle.add_theme_font_size_override("font_size", 20)
	toggle.toggled.connect(func(value: bool): setting_changed.emit(key, value))
	parent.add_child(toggle)
	toggles[key] = toggle

func _add_slider(parent: VBoxContainer, key: String, title: String) -> void:
	var group: VBoxContainer = VBoxContainer.new()
	group.add_theme_constant_override("separation", 2)
	var header: HBoxContainer = HBoxContainer.new()
	var label: Label = _label(title, 19, WHITE)
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(label)
	var value: Label = _label("", 19, GOLD)
	value.custom_minimum_size.x = 110
	value.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	header.add_child(value)
	group.add_child(header)
	var slider: HSlider = HSlider.new()
	slider.name = "Setting_" + key
	var limits: Vector2 = Preferences.LIMITS[key]
	slider.min_value = limits.x
	slider.max_value = limits.y
	slider.step = 1.0 if key == "field_of_view" else 0.05
	slider.custom_minimum_size = Vector2(0, 30)
	slider.focus_mode = Control.FOCUS_ALL
	slider.scrollable = false
	slider.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	slider.tooltip_text = title + "  ·  Flèches gauche et droite pour ajuster"
	var track: StyleBoxFlat = StyleBoxFlat.new()
	track.bg_color = Color(0.15, 0.25, 0.28)
	track.set_corner_radius_all(3)
	track.content_margin_top = 3
	track.content_margin_bottom = 3
	slider.add_theme_stylebox_override("slider", track)
	var fill: StyleBoxFlat = track.duplicate()
	fill.bg_color = GOLD
	slider.add_theme_stylebox_override("grabber_area", fill)
	var highlight: StyleBoxFlat = fill.duplicate()
	highlight.bg_color = WHITE
	slider.add_theme_stylebox_override("grabber_area_highlight", highlight)
	var focus: StyleBoxFlat = StyleBoxFlat.new()
	focus.bg_color = Color(0, 0, 0, 0)
	focus.border_color = TEAL
	focus.set_border_width_all(1)
	focus.set_corner_radius_all(3)
	slider.add_theme_stylebox_override("focus", focus)
	slider.value_changed.connect(func(number: float):
		_update_value_label(key, number)
		setting_changed.emit(key, number)
	)
	group.add_child(slider)
	parent.add_child(group)
	sliders[key] = slider
	value_labels[key] = value

func _update_value_label(key: String, value: float) -> void:
	match key:
		"master_volume":
			value_labels[key].text = "%d %%" % roundi(value * 100.0)
		"mouse_sensitivity":
			value_labels[key].text = "× %.2f" % value
		"field_of_view":
			value_labels[key].text = "%d°" % roundi(value)

func _reset_settings() -> void:
	for key: String in Preferences.DEFAULTS:
		setting_changed.emit(key, Preferences.DEFAULTS[key])
	apply_settings(Preferences.DEFAULTS)

func open_settings_from_pause() -> void:
	close_modals(false)
	standalone_settings = true
	z_index = 20
	enter_time = 1.0
	modulate.a = 1.0
	show()
	options.show()
	settings_scroll.scroll_vertical = 0
	toggles["audio"].grab_focus()

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
	if value.get("id") in ["recon", "recon_debrief"]:
		continue_button.text = "CONSULTER LA RECONNAISSANCE" if value.get("id") == "recon_debrief" else "REPRENDRE LA RECONNAISSANCE"
	start_button.text = "NOUVELLE INTERVENTION" if valid_save else "COMMENCER L’INTERVENTION"
	seed_input.value = seed_value
	replacement_note.visible = valid_save
	context_title.text = str(value.get("title","AVANT L’INTERVENTION"))
	context_detail.text = str(value.get("detail","Deux tours debout. Des vies à retrouver."))
	var floor_number: int = int(value.get("floor",31))
	var rescued_count: int = int(value.get("rescued",0))
	var seconds: int = int(value.get("elapsed",0))
	var rescue_label: String = "%d VIE SAUVÉE" % rescued_count if rescued_count == 1 else "%d VIES SAUVÉES" % rescued_count
	progress_label.text = "DERNIER POINT SÛR  /  %s  /  %s  /  %02d:%02d" % ["TOIT" if floor_number == 31 else "ÉTAGE %d" % floor_number,rescue_label,seconds / 60,seconds % 60] if valid_save else "PREMIÈRE ROTATION  /  ALPHA + BRAVO"
	var situation: String = "Aube et Hespérie sont debout. Deux équipes sont déposées sur les toits. Le typhon se reforme : les appareils attendront une accalmie pour revenir."
	if value.get("incident") == "aftermath":
		situation = "Une réplique a fait basculer Hespérie contre Aube. Le noyau et le treuil tiennent. Le passage Est du 28 est condamné ; passez par le noyau. Bravo ne répond plus."
	mission_text.text = "SITUATION\n" + situation + "\n\nVOTRE ÉQUIPE\nVarga coordonne le poste d’Aube. Alpha tient la ligne de rappel et réceptionne les rescapés. Bravo intervient sur Hespérie.\n\nVOTRE PARCOURS\n30 · Restaurant : Ana Rios\n29 · Suites : liaison visuelle vers Hespérie\n28 · Archives : Samuel Breton\n27 · Jardin des enfants\n26 · Spa : Nora Haddad\n25 · Refuge : relais et compte rendu\n\nMÉTHODE\nDescendez par la ligne centrale. Sécurisez chaque personne et rapportez-la à la balise de son étage. Attendez la confirmation du treuil. Vous pouvez remonter au poste de secours."
	mission_text.text += "\n\nPOURSUIVRE DEPUIS LE BILAN DU 25\n24 · Centre de congrès : Léa Mercier et Idris Kaci, accompagnement par l’escalier de service nord.\n23 · Exposition Histoire de Nacre : maquette et photographie, accès par rappel personnel.\nLes trois premiers secours restent acquis. Les consignes d’escorte sont visibles et le groupe attend quand vous vous éloignez.\n\nPOURSUIVRE DEPUIS LE BILAN DU 23\n22 · Galerie des Alizés : Mina, volet bloqué et personne retranchée.\n21 · Cuisines : isoler le réchauffeur puis contenir le foyer ; secourir Théo.\n20 · Refuge des équipes : accompagner Sofia, recevoir les trois personnes et remettre le relais en service.\nDes escaliers dans des cages distinctes relient ces étages ; un rappel facultatif dessert le 22–21."
	if is_visible_in_tree():
		focus_primary()

func apply_settings(settings: Dictionary) -> void:
	var clean: Dictionary = Preferences.normalize(settings)
	for key: String in toggles:
		toggles[key].set_pressed_no_signal(bool(clean[key]))
	for key: String in sliders:
		sliders[key].set_value_no_signal(float(clean[key]))
		_update_value_label(key, float(clean[key]))
	reduced_motion = bool(clean["reduced_motion"])

func _open_modal(panel: Control) -> void:
	close_modals(false)
	panel.show()
	if panel == options:
		settings_scroll.scroll_vertical = 0
		toggles["audio"].grab_focus()
		return
	var buttons: Array[Node] = panel.find_children("*", "Button", true, false)
	if not buttons.is_empty():
		buttons[0].grab_focus()

func close_modals(focus: bool = true) -> void:
	for panel: Control in modal_stack:
		panel.hide()
	if standalone_settings:
		standalone_settings = false
		z_index = 0
		hide()
		if focus:
			settings_closed.emit()
		return
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
	# The help overlay is a higher modal layer owned by the HUD.
	# Let its handler consume Escape before closing these underlying options.
	if is_instance_valid(help_overlay) and help_overlay.visible:
		return
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
