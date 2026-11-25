extends CanvasLayer
class_name DescentHUD

signal start_requested(seed_value: int)
signal continue_requested
signal resume_requested
signal return_requested
signal journal_requested
signal replay_intro_requested
signal epilogue_replay_requested
signal descent_requested
signal cinematic_skip_requested
signal inspection_closed
signal setting_changed(setting: String, value: Variant)

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
var help_close_button: Button
var help_return_focus: Control
var start_button: Button
var continue_button: Button
var seed_input: SpinBox
var location_label: Label
var status_label: Label
var mission_label: Label
var resources_label: Label
var equipment_label: Label
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
var end_journal_button: Button
var cinematic: Control
var inspection_panel: Control
var pause_toggles: Dictionary = {}
var _journal_game_was_visible: bool = false
var traversal_panel: PanelContainer
var traversal_title: Label
var traversal_state: Label
var traversal_metrics: Label
var traversal_stamina_title: Label
var traversal_stamina: ProgressBar

func _ready() -> void:
	layer = 10
	root = Control.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(root)
	var theme: Theme = Theme.new()
	theme.default_font_size = 18
	theme.default_font = preload("res://assets/fonts/OpenSans-Regular.ttf")
	theme.set_color("font_color", "Label", PALE)
	root.theme = theme
	_build_menu()
	_build_game()
	_build_pause()
	_build_journal()
	_build_end()
	_build_help()
	_build_cinematic()
	_build_inspection()
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
	menu = preload("res://scripts/frontend_menu.gd").new()
	root.add_child(menu)
	menu.start_requested.connect(func(seed_value: int): start_requested.emit(seed_value))
	menu.continue_requested.connect(func(): continue_requested.emit())
	menu.replay_requested.connect(func(): replay_intro_requested.emit())
	menu.help_requested.connect(show_help)
	menu.setting_changed.connect(func(key: String, value: Variant): setting_changed.emit(key,value))
	menu.settings_closed.connect(_comfort_settings_closed)
	start_button = menu.start_button
	continue_button = menu.continue_button
	seed_input = menu.seed_input

func _build_cinematic() -> void:
	cinematic = preload("res://scripts/cinematic_overlay.gd").new()
	root.add_child(cinematic)
	cinematic.skip_requested.connect(func(): cinematic_skip_requested.emit())

func _build_inspection() -> void:
	inspection_panel = preload("res://scripts/inspection_panel.gd").new()
	root.add_child(inspection_panel)
	inspection_panel.close_requested.connect(func(): inspection_closed.emit())

func show_inspection(entry: Dictionary) -> void:
	pause_panel.hide()
	journal_panel.hide()
	help_panel.hide()
	inspection_panel.present(entry)

func hide_inspection() -> void:
	inspection_panel.hide()

func set_menu_context(context: Dictionary, valid_save: bool, seed_value: int) -> void:
	menu.set_context(context,valid_save,seed_value)

func apply_settings(settings: Dictionary) -> void:
	menu.apply_settings(settings)
	for key: String in pause_toggles:
		pause_toggles[key].set_pressed_no_signal(bool(settings.get(key,false)))

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
	prompt_label = _label("", 18, Color(1, 0.92, 0.75))
	prompt_label.add_theme_color_override("font_outline_color", Color(0.025, 0.055, 0.07, 0.95))
	prompt_label.add_theme_constant_override("outline_size", 3)
	prompt_label.position = Vector2(365, 596)
	prompt_label.size = Vector2(710, 106)
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
	equipment_label = _label("", 14, PALE)
	equipment_label.position = Vector2(880, 652)
	equipment_label.size = Vector2(520, 52)
	equipment_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	equipment_label.add_theme_color_override("font_outline_color", Color(0.025, 0.055, 0.07, 1.0))
	equipment_label.add_theme_constant_override("outline_size", 3)
	game.add_child(equipment_label)
	_build_traversal_panel()
	var keys: Label = _label("ZQSD / WASD  Marcher     E  Interagir     F  Lampe     R  Radio     G  Fusée     J  Journal     ÉCHAP  Pause", 14, MUTED)
	keys.position = Vector2(382, 865)
	game.add_child(keys)
	overlay = ColorRect.new()
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	overlay.color = Color(0.7, 0.12, 0.04, 0)
	game.add_child(overlay)

func _build_traversal_panel() -> void:
	traversal_panel = PanelContainer.new()
	traversal_panel.position = Vector2(28, 170)
	traversal_panel.size = Vector2(320, 210)
	traversal_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	traversal_panel.add_theme_stylebox_override("panel", _box())
	game.add_child(traversal_panel)
	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation", 9)
	traversal_panel.add_child(content)
	traversal_title = _label("LIAISON LOCALE", 16, TEAL)
	content.add_child(traversal_title)
	traversal_state = _label("", 18, AMBER)
	traversal_state.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	traversal_state.custom_minimum_size.x = 280
	content.add_child(traversal_state)
	traversal_metrics = _label("", 14, PALE)
	traversal_metrics.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	content.add_child(traversal_metrics)
	traversal_stamina_title = _label("ENDURANCE", 13, MUTED)
	content.add_child(traversal_stamina_title)
	traversal_stamina = ProgressBar.new()
	traversal_stamina.custom_minimum_size = Vector2(274, 10)
	traversal_stamina.show_percentage = false
	traversal_stamina.add_theme_stylebox_override("background", _box(Color(0.10, 0.18, 0.2), Color.TRANSPARENT))
	traversal_stamina.add_theme_stylebox_override("fill", _box(TEAL, TEAL))
	content.add_child(traversal_stamina)
	traversal_panel.hide()

func set_traversal_context(data: Dictionary) -> void:
	if data.is_empty():
		traversal_panel.hide()
		return
	var is_rope: bool = str(data.get("kind", "")) == "rope"
	traversal_panel.show()
	traversal_title.text = "%s %d ↔ %d" % ["RAPPEL" if is_rope else "ESCALIER", int(data.get("upper", 0)), int(data.get("lower", 0))]
	traversal_stamina_title.visible = is_rope
	traversal_stamina.visible = is_rope
	if not is_rope:
		traversal_state.text = "DEUX ÉTAGES SEULEMENT"
		traversal_metrics.text = "Deux volées et un palier intermédiaire.\nRetour possible par le même passage.\nLe prochain tronçon se rejoint à pied."
		return
	var names := {"attach": "ENGAGEMENT ASSURÉ", "exit": "SORTIE SUR PALIER", "cancel_attach": "RETOUR VERS L’APPUI", "cancel_exit": "RETOUR VERS LA LIGNE", "hold": "FREIN AUTOMATIQUE", "locked": "DESCENDEUR VERROUILLÉ", "descend": "DESCENTE CONTRÔLÉE", "ascend": "REMONTÉE", "precision": "PROGRESSION PRÉCISE", "rapid": "DESCENTE RAPIDE", "rest": "REPOS ASSURÉ"}
	traversal_state.text = str(names.get(str(data.get("mode", "hold")), "LIGNE ASSURÉE"))
	if bool(data.get("obstructed", false)):
		traversal_state.text = "PASSAGE ENCOMBRÉ"
	var distance: float = float(data.get("distance_remaining", 0.0))
	traversal_metrics.text = "%.1f m/s · %.1f m vers le palier bas\nCorde : %.1f / %.1f m\n%s" % [float(data.get("speed", 0.0)), distance, float(data.get("deployed", 0.0)), float(data.get("rope_length", 0.0)), "Stabilisation : %.0f s" % float(data.get("secured_time", 0.0)) if float(data.get("secured_time", 0.0)) > 0.0 else "Relâchez les touches pour freiner"]
	traversal_stamina.value = float(data.get("stamina", 100.0))
	traversal_stamina_title.text = "ENDURANCE  %d %%" % roundi(traversal_stamina.value)

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
	col.add_child(_button("Commandes et mission", show_help))
	col.add_child(_button("Options et confort", show_comfort_settings))
	var motion: CheckButton = CheckButton.new()
	motion.text = "Réduire les mouvements de caméra"
	motion.button_pressed = true
	motion.toggled.connect(func(v: bool): setting_changed.emit("reduced_motion", v))
	col.add_child(motion)
	pause_toggles["reduced_motion"] = motion
	var flashes: CheckButton = CheckButton.new()
	flashes.text = "Éclairs lumineux (désactivés par défaut)"
	flashes.toggled.connect(func(v: bool): setting_changed.emit("flashes", v))
	col.add_child(flashes)
	pause_toggles["flashes"] = flashes
	audio_toggle = CheckButton.new()
	audio_toggle.text = "Ambiance sonore"
	audio_toggle.button_pressed = true
	audio_toggle.toggled.connect(func(v: bool): setting_changed.emit("audio", v))
	col.add_child(audio_toggle)
	pause_toggles["audio"] = audio_toggle
	col.add_child(_label("Sauvegarde aux treuils, au refuge et avant/après l’effondrement.\nUne interruption pendant la secousse reprend avant celle-ci.", 17, MUTED))
	col.add_child(_button("Retour au menu", func(): return_requested.emit()))

func show_comfort_settings() -> void:
	pause_panel.hide()
	menu.open_settings_from_pause()

func _comfort_settings_closed() -> void:
	pause_panel.show()
	var buttons: Array[Node] = pause_panel.find_children("*", "Button", true, false)
	if not buttons.is_empty():
		(buttons[0] as Button).grab_focus()

func _build_journal() -> void:
	journal_panel = preload("res://scripts/mission_dossier_panel.gd").new()
	journal_panel.mode = "journal"
	root.add_child(journal_panel)
	journal_text = journal_panel.journal_text
	journal_panel.close_requested.connect(func(): resume_requested.emit())

func _build_end() -> void:
	end_panel = preload("res://scripts/mission_dossier_panel.gd").new()
	end_panel.mode = "debrief"
	root.add_child(end_panel)
	completion_text = end_panel.completion_text
	end_journal_button = end_panel.journal_button
	end_panel.journal_requested.connect(func(): journal_requested.emit())
	end_panel.replay_requested.connect(func(): epilogue_replay_requested.emit())
	end_panel.menu_requested.connect(func(): return_requested.emit())
	end_panel.descent_requested.connect(func(): descent_requested.emit())

func show_journal(snapshot: Dictionary) -> void:
	if not journal_panel.visible:
		_journal_game_was_visible = game.visible
	game.hide()
	pause_panel.hide()
	end_panel.hide()
	help_panel.hide()
	hide_inspection()
	journal_panel.present(snapshot)

func show_debrief(snapshot: Dictionary) -> void:
	_journal_game_was_visible = false
	menu.close_modals(false)
	menu.hide()
	game.hide()
	pause_panel.hide()
	journal_panel.hide()
	help_panel.hide()
	cinematic.hide()
	hide_inspection()
	end_panel.present(snapshot)

func _build_help() -> void:
	var result: Array = _modal("DESCENDRE. SECOURIR. REMONTER.", 900)
	help_panel = result[0]
	help_panel.z_index = 30
	menu.help_overlay = help_panel
	var col: VBoxContainer = result[1]
	var text: RichTextLabel = RichTextLabel.new()
	text.custom_minimum_size = Vector2(900, 485)
	text.add_theme_font_size_override("normal_font_size", 20)
	text.focus_mode = Control.FOCUS_ALL
	text.selection_enabled = true
	text.text = "MISSION\nSecourez Ana au 30, Samuel au 28 et Nora au 26. E fixe leur harnais.\nRamenez chaque personne à la balise ORANGE de son étage pour le treuil.\nAprès les trois réceptions et l’incident, rejoignez le refuge 25.\n\nITINÉRAIRE LOCAL\nRappel toit–30 · Escalier 30–29 · Rappel 29–28 · Escalier 28–27\nRappel 27–26 · Escalier 26–25. Chaque passage permet aussi le retour.\n\nÀ PIED ET DANS LES ESCALIERS\nZQSD / WASD : marcher · Souris / flèches : regarder · Maj : courir\nCtrl : s’accroupir · Espace : sauter · E : interagir au repère BLEU du rappel\n\nSUR LA CORDE\nS : descendre · Z/W : remonter · Q/A et D : équilibrer le balancement\nCtrl : progression précise · Maj + S : descente rapide\nEspace : verrouiller / libérer le descendeur · Relâcher : frein automatique\nX : stabiliser 16 s (un ancrage) · E : sortir, arrêté et centré au palier\nRemontée et descente rapide demandent de l’endurance. Reposez-vous assuré.\nLe rappel personnel exige les mains libres ; évacuez d’abord votre rescapé.\n\nMATÉRIEL ET LECTURE\n1 : hache · 2 : extincteur · 3 : Halligan · 4 : coupe-boulon\nMaintenir E en visant le point d’intervention avec le bon outil.\nS’éloigner, relâcher E ou changer d’outil interrompt le travail.\nLes outils se rangent pendant le portage, le rappel et les secousses.\nF : lampe · G : fusée · R : radio · J : dossier · Échap : pause et options\nE devant un objet « Examiner » ouvre sa fiche et suspend l’intervention.\nMolette / Page ↑↓ : défiler. Fermer ou Échap : reprendre.\nL’air de réserve diminue dans les fumées. Le refuge reste sûr."
	text.text += "\n\nAPRÈS LE BILAN DU 25\nChoisissez Poursuivre au congrès pour ouvrir la reconnaissance.\nEscalier de service NORD 25–24 : voie de retour pour Léa et Idris.\nPlacez-vous devant le groupe et E : signe visible Suivez-moi / Attendez.\nAvancez près d’eux ; s’ils vous perdent, ils attendent sans se téléporter.\nLes deux personnes doivent atteindre les repères du refuge pour être reçues.\nAprès réception : rappel personnel 24–23, maquette et photographie à relever.\nLe terminal du 23 transmet le compte rendu. Choisissez ensuite Poursuivre vers les commerces.\nUne reprise remet une escorte inachevée à l’abri dans la cabine du 24.\n\nGALERIE, CUISINES ET REFUGE 20\nEscaliers locaux : sud 23–22, nord 22–21, sud 21–20.\nUn rappel facultatif 22–21 reste réservé au sauveteur.\n22 : Halligan au volet de Mina. 21 : isoler puis couvrir le réchauffeur.\nE devant Mina, Théo ou Sofia : suivre / attendre ; gardez moins de 5 m.\nChaque personne doit atteindre sa marque au refuge 20 pour être reçue.\nLe Retranché : distance de 2 à 3 m, lampe abaissée, E pour parler.\nDeux constats à relever au 22 et au 21, relais et bilan au 20.\nUne escorte inachevée reprend à son point initial ; les réceptions persistent."
	col.add_child(text)
	help_close_button = _button("Compris", close_help, true)
	col.add_child(help_close_button)

func show_help() -> void:
	help_return_focus = get_viewport().gui_get_focus_owner()
	help_panel.show()
	help_close_button.grab_focus()

func close_help() -> void:
	help_panel.hide()
	if is_instance_valid(help_return_focus) and help_return_focus.is_visible_in_tree():
		help_return_focus.grab_focus()
	help_return_focus = null

func _unhandled_key_input(event: InputEvent) -> void:
	if help_panel.visible and event.is_action_pressed("ui_cancel"):
		close_help()
		get_viewport().set_input_as_handled()

func show_game() -> void:
	menu.close_modals(false)
	menu.hide()
	cinematic.hide()
	game.show()
	pause_panel.hide()
	journal_panel.hide()
	end_panel.hide()
	help_panel.hide()
	hide_inspection()

func show_menu() -> void:
	_journal_game_was_visible = false
	menu.reveal()
	cinematic.hide()
	game.hide()
	pause_panel.hide()
	journal_panel.hide()
	end_panel.hide()
	help_panel.hide()
	hide_inspection()

func set_paused(paused: bool) -> void:
	if not paused and menu.standalone_settings:
		menu.close_modals(false)
	pause_panel.visible = paused
	if not paused:
		if journal_panel.visible:
			game.visible = _journal_game_was_visible
		journal_panel.hide()
		help_panel.hide()
		hide_inspection()

func set_radio(speaker: String, message: String) -> void:
	radio_source.text = speaker
	radio_label.text = message
	radio_panel.show()
