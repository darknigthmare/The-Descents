extends Control
class_name DescentMissionDossierPanel
## Shared read-only presentation for the journal and the final mission report.
## All values come from an explicit snapshot; opening or replaying cannot save.

signal close_requested
signal journal_requested
signal replay_requested
signal menu_requested
signal descent_requested

const Dossier = preload("res://scripts/mission_dossier.gd")
const TITLE_FONT: Font = preload("res://assets/fonts/OpenSans-CondBold.ttf")
const BODY_FONT: Font = preload("res://assets/fonts/OpenSans-Regular.ttf")
const LIGHT_FONT: Font = preload("res://assets/fonts/OpenSans-Light.ttf")
const WHITE: Color = Color("e7e6dd")
const GOLD: Color = Color("d2b582")
const MUTED: Color = Color("97a8ad")
const TEAL: Color = Color("7caeb5")
const SURFACE: Color = Color("0b141c")

var mode: String = "journal"
var selected_tab: String = "situation"
var model: Dictionary = {}
var tab_buttons: Dictionary = {}
var journal_text: RichTextLabel
var completion_text: RichTextLabel
var journal_button: Button
var replay_button: Button
var return_button: Button
var descent_button: Button
var close_button: Button
var title_label: Label
var subtitle_label: Label
var content_title: Label
var margin: MarginContainer
var body_row: HBoxContainer
var footer: HBoxContainer
var footer_note: Label
var side_column: VBoxContainer
var route_box: VBoxContainer
var route_rows: Array[Label] = []
var metric_values: Array[Label] = []
var survivor_names: Array[Label] = []
var survivor_statuses: Array[Label] = []
var survivor_details: Array[Label] = []
var _compact: bool = false
var _card_styles: Array[StyleBoxFlat] = []
var _layout: VBoxContainer


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	var dossier_theme: Theme = Theme.new()
	dossier_theme.default_font = BODY_FONT
	dossier_theme.default_font_size = 18
	dossier_theme.set_color("font_color", "Label", WHITE)
	theme = dossier_theme
	_build_shell()
	if mode == "debrief":
		_build_debrief()
	else:
		_build_journal()
	resized.connect(_adapt_layout)
	if model.is_empty():
		model = Dossier.build({})
	_refresh()
	_adapt_layout()
	hide()


func present(snapshot: Dictionary) -> void:
	model = Dossier.build(snapshot)
	selected_tab = "situation"
	if is_node_ready():
		_refresh()
	show()
	_focus_initial.call_deferred()


func select_tab(tab_id: String, focus_tab: bool = false) -> void:
	if mode != "journal" or tab_id not in Dossier.TABS:
		return
	selected_tab = tab_id
	if not is_node_ready():
		return
	content_title.text = Dossier.TAB_TITLES[tab_id]
	journal_text.text = model.get("pages", {}).get(tab_id, "")
	journal_text.get_v_scroll_bar().value = 0
	journal_text.scroll_to_line(0)
	for id_value: String in tab_buttons:
		tab_buttons[id_value].set_pressed_no_signal(id_value == selected_tab)
	if focus_tab:
		tab_buttons[tab_id].grab_focus()


func _build_shell() -> void:
	var shade: ColorRect = ColorRect.new()
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	shade.color = Color(0.027, 0.051, 0.075, 0.80 if mode == "debrief" else 0.88)
	shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(shade)
	var rule: ColorRect = ColorRect.new()
	rule.color = GOLD
	rule.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	rule.offset_bottom = 3
	rule.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(rule)
	margin = MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(margin)
	_layout = VBoxContainer.new()
	_layout.add_theme_constant_override("separation", 18)
	margin.add_child(_layout)
	var header: VBoxContainer = VBoxContainer.new()
	header.add_theme_constant_override("separation", 2)
	_layout.add_child(header)
	header.add_child(_label("THE TOWER DESCENT   /   SECOURS · TOUR AUBE", 13, GOLD))
	title_label = _label("LE REFUGE 25" if mode == "debrief" else "JOURNAL D’INTERVENTION", 62, WHITE)
	title_label.add_theme_font_override("font", TITLE_FONT)
	header.add_child(title_label)
	subtitle_label = _label("", 17, MUTED)
	subtitle_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	header.add_child(subtitle_label)
	var metrics: HBoxContainer = HBoxContainer.new()
	metrics.add_theme_constant_override("separation", 10)
	_layout.add_child(metrics)
	for metric_title: String in ["PERSONNES À L’ABRI", "INDICES RÉCUPÉRÉS", "TEMPS DE MISSION", "POSITION"]:
		var card: PanelContainer = _card()
		card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		metrics.add_child(card)
		var stack: VBoxContainer = VBoxContainer.new()
		stack.add_theme_constant_override("separation", 3)
		card.add_child(stack)
		var label: Label = _label(metric_title, 11, MUTED)
		label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
		stack.add_child(label)
		var value: Label = _label("—", 29, WHITE)
		value.add_theme_font_override("font", TITLE_FONT)
		stack.add_child(value)
		metric_values.append(value)
	body_row = HBoxContainer.new()
	body_row.add_theme_constant_override("separation", 24)
	body_row.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_layout.add_child(body_row)
	footer = HBoxContainer.new()
	footer.add_theme_constant_override("separation", 12)
	_layout.add_child(footer)


func _build_journal() -> void:
	side_column = VBoxContainer.new()
	side_column.custom_minimum_size.x = 236
	side_column.add_theme_constant_override("separation", 8)
	body_row.add_child(side_column)
	var names: Array[String] = ["Situation", "Rescapés", "Indices", "Transmissions"]
	for index in range(Dossier.TABS.size()):
		var id_value: String = Dossier.TABS[index]
		var button: Button = _button("%02d   %s" % [index + 1, names[index]])
		button.toggle_mode = true
		button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		button.pressed.connect(select_tab.bind(id_value, true))
		button.gui_input.connect(_tab_input.bind(index))
		tab_buttons[id_value] = button
		side_column.add_child(button)
	var spacer: Control = Control.new()
	spacer.custom_minimum_size.y = 12
	side_column.add_child(spacer)
	route_box = VBoxContainer.new()
	route_box.add_theme_constant_override("separation", 5)
	var route_scroll := ScrollContainer.new()
	route_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	route_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	side_column.add_child(route_scroll)
	route_scroll.add_child(route_box)
	route_box.add_child(_label("AXE DE DESCENTE", 12, GOLD))
	for index in range(12):
		var row: Label = _label("", 15, MUTED)
		route_box.add_child(row)
		route_rows.append(row)
	var body_card: PanelContainer = _card()
	body_card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	body_row.add_child(body_card)
	var body: VBoxContainer = VBoxContainer.new()
	body.add_theme_constant_override("separation", 14)
	body_card.add_child(body)
	content_title = _label("SITUATION", 22, GOLD)
	content_title.add_theme_font_override("font", TITLE_FONT)
	body.add_child(content_title)
	journal_text = _reader()
	body.add_child(journal_text)
	footer_note = _label("↑ ↓  Onglets    ·    Tab  Navigation    ·    Page ↑↓ / molette  Lecture", 14, MUTED)
	footer_note.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	footer.add_child(footer_note)
	close_button = _button("Fermer le journal", true)
	close_button.custom_minimum_size.x = 238
	close_button.pressed.connect(func(): close_requested.emit())
	footer.add_child(close_button)
	_wire_journal_focus()


func _build_debrief() -> void:
	side_column = VBoxContainer.new()
	side_column.custom_minimum_size.x = 340
	side_column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	side_column.size_flags_stretch_ratio = 0.9
	side_column.add_theme_constant_override("separation", 10)
	body_row.add_child(side_column)
	for index in range(3):
		var card: PanelContainer = _card()
		card.size_flags_vertical = Control.SIZE_EXPAND_FILL
		side_column.add_child(card)
		var stack: VBoxContainer = VBoxContainer.new()
		stack.add_theme_constant_override("separation", 4)
		card.add_child(stack)
		var name_label: Label = _label("", 26, WHITE)
		name_label.add_theme_font_override("font", TITLE_FONT)
		stack.add_child(name_label)
		survivor_names.append(name_label)
		var state_label: Label = _label("", 13, TEAL)
		stack.add_child(state_label)
		survivor_statuses.append(state_label)
		var detail_label: Label = _label("", 15, MUTED)
		detail_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		stack.add_child(detail_label)
		survivor_details.append(detail_label)
	var relay_card: PanelContainer = _card()
	relay_card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	relay_card.size_flags_stretch_ratio = 1.8
	body_row.add_child(relay_card)
	var relay: VBoxContainer = VBoxContainer.new()
	relay.add_theme_constant_override("separation", 14)
	relay_card.add_child(relay)
	content_title = _label("EXTRAIT DU RELAIS", 22, GOLD)
	content_title.add_theme_font_override("font", TITLE_FONT)
	relay.add_child(content_title)
	completion_text = _reader()
	relay.add_child(completion_text)
	journal_button = _button("Compte rendu")
	journal_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	journal_button.pressed.connect(func(): journal_requested.emit())
	footer.add_child(journal_button)
	replay_button = _button("Revoir la séquence")
	replay_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	replay_button.pressed.connect(func(): replay_requested.emit())
	footer.add_child(replay_button)
	return_button = _button("Revenir à l’accueil", true)
	return_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	return_button.pressed.connect(func(): menu_requested.emit())
	footer.add_child(return_button)
	descent_button = _button("Poursuivre au congrès", true)
	descent_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	descent_button.pressed.connect(func(): descent_requested.emit())
	footer.add_child(descent_button)
	var focus_chain: Array[Control] = [journal_button, replay_button, return_button, descent_button, completion_text]
	_wire_focus_chain(focus_chain)


func _refresh() -> void:
	subtitle_label.text = "TRANCHE JOUABLE TERMINÉE   ·   Le signal reste à vérifier." if mode == "debrief" and model["completed"] else "DOSSIER %06d   ·   %s   ·   Lecture au temps de mission %s" % [model["seed"], model["location"], model["duration"]]
	metric_values[0].text = "%d / %d" % [model["total_received"], model["roster_total"]]
	metric_values[1].text = "%d / %d" % [model["clue_count"], model["evidence_total"]]
	metric_values[2].text = model["duration"]
	metric_values[3].text = "TOIT" if model["floor"] == 31 else "ÉTAGE %d" % model["floor"]
	if mode == "debrief":
		var extended: bool = model.get("continuation_phase", "dormant") != "dormant"
		var lower: bool = model.get("commerce_phase", "dormant") != "dormant"
		title_label.text = "SOUS LES PLANS DE NACRE" if extended else "LE REFUGE 25"
		subtitle_label.text = "RECONNAISSANCE A24–A23 TERMINÉE · Cinq personnes à l’abri, deux constats à approfondir." if extended else "INTERVENTION SUPÉRIEURE TERMINÉE · Le refuge ouvre la suite de la descente."
		# Three cards remain readable on compact displays. The extension uses
		# two named arrivals plus the preserved roof reception summary.
		var cards: Array = model["survivors"].slice(3, 5) if extended else model["survivors"]
		if extended:
			cards.append({"name": "Ana · Samuel · Nora", "status": "AU POSTE DU TOIT", "floor": 31, "confirmed": true, "detail": "Les trois réceptions initiales restent confirmées. Aucun secours n’a été rejoué."})
		if lower:
			title_label.text = "LE REFUGE DES ÉQUIPES"
			subtitle_label.text = "SECOURS A22–A20 TERMINÉS · Huit personnes à l’abri, sept pièces possibles au dossier."
			cards = model["survivors"].slice(5, 8)
		for index in range(mini(cards.size(), survivor_names.size())):
			var row: Dictionary = cards[index]
			survivor_names[index].text = row["name"]
			survivor_statuses[index].text = str(row["status"]) if extended else "%s · ÉTAGE %d" % [row["status"], row["floor"]]
			survivor_statuses[index].add_theme_color_override("font_color", TEAL if row["confirmed"] else GOLD)
			survivor_details[index].text = row["detail"]
		completion_text.text = "%s\n\n%s\n\n%s\n%s\n\nRESSOURCES AU REFUGE\nÉtat physique %d %% · Air %d %% · Tension %d %%\nAncrages %d · Fusées %d · Réserves ouvertes %d / 2\n\nCette intervention s’arrête au refuge 25. Le sort de Bravo et la suite de la descente restent ouverts." % [model["relay_title"], model["relay_text"], model["structure_title"], model["structure_text"], roundi(model["health"]), roundi(model["oxygen"]), roundi(model["stress"]), model["anchors"], model["flares"], model["supplies_count"]]
		completion_text.scroll_to_line(0)
		if extended:
			completion_text.text = str(model["relay_title"]) + "\n\n" + str(model["relay_text"]) + "\n\nPOINT SÛR\nÉtage 23 · Compte rendu conservé. Le dossier permet de relire les cinq personnes prises en charge et les pièces effectivement recueillies."
		else:
			completion_text.text = completion_text.text.replace("Cette intervention s’arrête au refuge 25. Le sort de Bravo et la suite de la descente restent ouverts.", "Le bilan des secours supérieurs est acquis. Poursuivre au congrès ouvre l’escalier vers le 24 après enregistrement du nouveau point sûr. Le sort de Bravo reste inconnu.")
		replay_button.disabled = not model["replay_available"]
		if lower:
			completion_text.text = str(model["relay_title"]) + "\n\n" + str(model["relay_text"]) + "\n\nPOINT SÛR\nRefuge 20 · Les réceptions et interventions sont conservées. Le journal distingue les faits recueillis de leur interprétation."
		replay_button.visible = not extended
		descent_button.visible = model.get("continuation_available", false) or model.get("commerce_available", false)
		descent_button.text = "Poursuivre vers les commerces" if model.get("commerce_available", false) else "Poursuivre au congrès"
		var focus_chain: Array[Control] = [journal_button]
		if replay_button.visible:
			focus_chain.append(replay_button)
		focus_chain.append(return_button)
		if descent_button.visible:
			focus_chain.append(descent_button)
		focus_chain.append(completion_text)
		_wire_focus_chain(focus_chain)
	else:
		for row_label: Label in route_rows:
			row_label.hide()
		for index in range(model["route"].size()):
			var row: Dictionary = model["route"][index]
			var suffix: String = "  ·  ÉVAC." if row["confirmed"] else ""
			route_rows[index].text = "%s  %02d  %s%s" % ["›" if row["current"] else "·", row["floor"], row["title"], suffix]
			route_rows[index].add_theme_color_override("font_color", GOLD if row["current"] else (WHITE if row["seen"] else MUTED))
			route_rows[index].show()
		select_tab(selected_tab)


func _adapt_layout() -> void:
	if not is_instance_valid(margin):
		return
	_compact = size.x < 1100 or size.y < 720
	_layout.add_theme_constant_override("separation", 12 if _compact else 18)
	for style: StyleBoxFlat in _card_styles:
		style.content_margin_top = 8 if _compact else 12
		style.content_margin_bottom = 8 if _compact else 12
	var inset: int = 24 if _compact else 52
	margin.add_theme_constant_override("margin_left", inset)
	margin.add_theme_constant_override("margin_right", inset)
	margin.add_theme_constant_override("margin_top", 20 if _compact else 32)
	margin.add_theme_constant_override("margin_bottom", 20 if _compact else 30)
	title_label.add_theme_font_size_override("font_size", 40 if _compact else 62)
	subtitle_label.add_theme_font_size_override("font_size", 14 if _compact else 17)
	body_row.add_theme_constant_override("separation", 14 if _compact else 24)
	content_title.add_theme_font_size_override("font_size", 19 if _compact else 22)
	for value: Label in metric_values:
		value.add_theme_font_size_override("font_size", 23 if _compact else 29)
	if mode == "debrief":
		side_column.custom_minimum_size.x = 260 if _compact else 340
		completion_text.add_theme_font_size_override("normal_font_size", 16 if _compact else 20)
		for label: Label in survivor_names:
			label.add_theme_font_size_override("font_size", 22 if _compact else 26)
		for label: Label in survivor_details:
			label.add_theme_font_size_override("font_size", 13 if _compact else 15)
		for button: Button in [journal_button, replay_button, return_button, descent_button]:
			button.add_theme_font_size_override("font_size", 15 if _compact else 18)
	else:
		side_column.custom_minimum_size.x = 194 if _compact else 236
		route_box.visible = size.y >= 740
		footer_note.visible = size.x >= 1100
		journal_text.add_theme_font_size_override("normal_font_size", 16 if _compact else 20)
		for id_value: String in tab_buttons:
			tab_buttons[id_value].add_theme_font_size_override("font_size", 16 if _compact else 18)


func _focus_initial() -> void:
	if not is_visible_in_tree():
		return
	if mode == "debrief":
		journal_button.grab_focus()
	else:
		tab_buttons[selected_tab].grab_focus()


func _tab_input(event: InputEvent, index: int) -> void:
	if not event is InputEventKey or not event.pressed:
		return
	if event.keycode in [KEY_UP, KEY_LEFT, KEY_DOWN, KEY_RIGHT]:
		var direction: int = -1 if event.keycode in [KEY_UP, KEY_LEFT] else 1
		select_tab(Dossier.TABS[posmod(index + direction, Dossier.TABS.size())], true)
		get_viewport().set_input_as_handled()


func _reader_input(event: InputEvent, reader: RichTextLabel) -> void:
	if not event is InputEventKey or not event.pressed:
		return
	var scroll: VScrollBar = reader.get_v_scroll_bar()
	if event.keycode == KEY_PAGEDOWN:
		scroll.value += scroll.page * 0.85
	elif event.keycode == KEY_PAGEUP:
		scroll.value -= scroll.page * 0.85
	elif event.keycode == KEY_HOME:
		scroll.value = 0
	elif event.keycode == KEY_END:
		scroll.value = scroll.max_value
	else:
		return
	get_viewport().set_input_as_handled()


func _wire_journal_focus() -> void:
	var focus_chain: Array[Control] = []
	for id_value: String in Dossier.TABS:
		focus_chain.append(tab_buttons[id_value])
	focus_chain.append(journal_text)
	focus_chain.append(close_button)
	_wire_focus_chain(focus_chain)


func _wire_focus_chain(controls: Array[Control]) -> void:
	for index in range(controls.size()):
		controls[index].focus_next = controls[index].get_path_to(controls[(index + 1) % controls.size()])
		controls[index].focus_previous = controls[index].get_path_to(controls[posmod(index - 1, controls.size())])


func _reader() -> RichTextLabel:
	var reader: RichTextLabel = RichTextLabel.new()
	reader.bbcode_enabled = false
	reader.fit_content = false
	reader.scroll_active = true
	reader.selection_enabled = true
	reader.context_menu_enabled = false
	reader.focus_mode = Control.FOCUS_ALL
	reader.size_flags_vertical = Control.SIZE_EXPAND_FILL
	reader.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	reader.add_theme_color_override("default_color", WHITE)
	reader.add_theme_constant_override("line_separation", 5)
	reader.add_theme_font_override("normal_font", BODY_FONT)
	reader.add_theme_font_size_override("normal_font_size", 20)
	reader.gui_input.connect(_reader_input.bind(reader))
	return reader


func _label(text: String, font_size: int, color: Color) -> Label:
	var label: Label = Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	return label


func _card() -> PanelContainer:
	var card: PanelContainer = PanelContainer.new()
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = SURFACE
	style.border_color = Color("22313b")
	style.set_border_width_all(1)
	style.content_margin_left = 18
	style.content_margin_right = 18
	style.content_margin_top = 12
	style.content_margin_bottom = 12
	card.add_theme_stylebox_override("panel", style)
	_card_styles.append(style)
	return card


func _button(text: String, primary: bool = false) -> Button:
	var button: Button = Button.new()
	button.text = text
	button.custom_minimum_size.y = 49
	button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	button.add_theme_color_override("font_color", GOLD if primary else WHITE)
	button.add_theme_color_override("font_hover_color", WHITE)
	button.add_theme_color_override("font_pressed_color", GOLD)
	button.add_theme_color_override("font_disabled_color", Color("58656e"))
	button.add_theme_font_size_override("font_size", 18)
	for state: String in ["normal", "hover", "pressed", "disabled"]:
		var style: StyleBoxFlat = StyleBoxFlat.new()
		style.bg_color = Color("172733") if state in ["hover", "pressed"] else Color("0c1821")
		style.border_color = GOLD if state == "pressed" or primary else Color("34434b")
		style.border_width_left = 3
		style.content_margin_left = 16
		style.content_margin_right = 16
		button.add_theme_stylebox_override(state, style)
	var focus_style: StyleBoxFlat = StyleBoxFlat.new()
	focus_style.bg_color = Color.TRANSPARENT
	focus_style.border_color = GOLD
	focus_style.set_border_width_all(2)
	button.add_theme_stylebox_override("focus", focus_style)
	return button
