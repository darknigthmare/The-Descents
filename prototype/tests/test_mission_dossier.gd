extends SceneTree
## Pure factual projection, spoiler boundaries and keyboard-driven reading UI.

const Dossier = preload("res://scripts/mission_dossier.gd")
const DossierPanel = preload("res://scripts/mission_dossier_panel.gd")
const HUD = preload("res://scripts/hud.gd")
var checks: int = 0
var failures: Array[String] = []
var actions: Array[String] = []


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	_test_projection()
	_test_clue_disclosure()
	_test_history()
	_test_boundaries()
	await _test_panels(Vector2i(1440, 900))
	await _test_panels(Vector2i(960, 600))
	await _test_hud()
	if failures.is_empty():
		print("PASS mission dossier: %d checks; factual rescue states, unrecovered-clue protection, received history, keyboard tabs/scroll, debrief actions and 1440x900/960x600 bounds." % checks)
		quit(0)
	else:
		for failure: String in failures:
			push_error(failure)
		print("FAIL mission dossier: %d failures / %d checks." % [failures.size(), checks])
		quit(1)


func _test_projection() -> void:
	var source: Dictionary = _fixture()
	source["rescued"] = ["survivor_30", "survivor_30", "not_a_person", 28]
	source["carried_id"] = "survivor_28"
	source["hoisting_id"] = "survivor_26"
	var before: Dictionary = source.duplicate(true)
	var model: Dictionary = Dossier.build(source)
	_check(source == before, "Building a dossier mutated mission input.")
	_check(model["rescued_count"] == 1 and model["survivors"].size() == 3, "Unknown or duplicate IDs counted as rescues.")
	_check(model["survivors"][0]["name"] == "Ana Rios" and model["survivors"][0]["confirmed"], "Confirmed Ana is missing from the roster.")
	_check(model["survivors"][1]["status"] == "AU HARNAIS" and not model["survivors"][1]["confirmed"], "Carrying Samuel confirmed him before receipt.")
	_check(model["survivors"][2]["status"] == "AU TREUIL" and not model["survivors"][2]["confirmed"], "Hoisting Nora confirmed her before receipt.")
	for name_value: String in ["Ana Rios", "Samuel Breton", "Nora Haddad"]:
		_check(str(model["pages"]["situation"]).contains(name_value), "Situation omits %s." % name_value)
	_check(str(model["pages"]["situation"]).contains("réception confirmée"), "The situation omits the confirmed rooftop receipt.")
	_check(str(model["pages"]["situation"]).contains("TRANSMISSIONS REÇUES"), "The initial page does not expose the received-radio excerpt.")
	_check(model["duration"] == "03:00" and model["floor"] == 29 and model["checkpoint_floor"] == 30, "The dossier confused current location, elapsed or safe checkpoint.")
	_check(model["route"].size() == 7 and model["route"][2]["current"] and not model["route"][6]["seen"], "The descent axis invents visits or loses current location.")
	model["survivors"][0]["name"] = "Changed copy"
	_check(Dossier.build(source)["survivors"][0]["name"] == "Ana Rios", "A returned roster exposes shared mutable model constants.")
	source["completed"] = true
	source["rescued"] = []
	_check(Dossier.build(source)["rescued_count"] == 0, "The completed flag fabricated three rescue confirmations.")
	_check(not Dossier.build(source)["replay_available"], "A final flag without three receipts enabled the three-person epilogue.")
	source["incident_state"] = "aftermath"
	var after: Dictionary = Dossier.build(source)
	_check(str(after["structure_text"]).contains("condamné") and str(after["structure_text"]).contains("sort n’est pas confirmé"), "The aftermath omits the changed route or asserts Bravo's fate.")
	_check(str(after["relay_title"]).contains("NON CONFIRMÉE") and str(after["relay_text"]).contains("l’heure"), "The relay fragment claims confirmed origin or chronology.")
	_check(after["transmissions"].size() == source["transmissions"].size(), "The final relay was inserted into actually received radio history.")
	for phase: String in ["warning", "quake", "collapse", "impact"]:
		source["incident_state"] = phase
		_check(Dossier.build(source)["structure_title"] == "RÉPLIQUE EN COURS", "Active phase %s appeared as a resolved structure." % phase)
	_check(not str(Dossier.build(_fixture())["structure_text"]).contains("condamné"), "An intact situation reveals the future blocked route.")


func _test_clue_disclosure() -> void:
	var source: Dictionary = _fixture()
	source["clue_records"] = [
		{"id": "evidence_29", "floor": 29, "title": "PRIVATE TITLE 29", "text": "PRIVATE TEXT 29"},
		{"id": "evidence_27", "floor": 27, "title": "PRIVATE TITLE 27", "text": "PRIVATE TEXT 27"},
		{"id": "evidence_26", "floor": 26, "title": "PRIVATE TITLE 26", "text": "PRIVATE TEXT 26"},
		{"id": "alien_id", "title": "PRIVATE INVALID", "text": "PRIVATE INVALID"}
	]
	var unopened: Dictionary = Dossier.build(source)
	_check(not JSON.stringify(unopened).contains("PRIVATE"), "An uncollected clue leaks through a page or another model field.")
	_check(unopened["clue_count"] == 0 and unopened["clues"].size() == 3, "Unrecovered clue count or slots are incorrect.")
	source["clues"] = ["evidence_27", "evidence_27", "alien_id"]
	var partial: Dictionary = Dossier.build(source)
	_check(partial["clue_count"] == 1 and partial["clues"][1]["collected"], "Duplicate or unknown clues corrupted the real registry.")
	_check(str(partial["pages"]["clues"]).contains("PRIVATE TEXT 27"), "The collected clue lost its actual supplied narrative.")
	_check(not JSON.stringify(partial).contains("PRIVATE TEXT 29") and not JSON.stringify(partial).contains("PRIVATE TITLE 26"), "A recovered clue revealed its unrelated neighbours.")
	source["clue_records"].append({"id": "evidence_27", "title": "REPLACEMENT", "text": "Duplicate replacement"})
	_check(not JSON.stringify(Dossier.build(source)).contains("REPLACEMENT"), "A duplicate clue row replaced the first collected record.")
	source["clue_records"] = []
	var missing: Dictionary = Dossier.build(source)
	_check(missing["clue_count"] == 1 and str(missing["clues"][1]["text"]).contains("pas disponible"), "A missing record either erased collection or fabricated its text.")
	_check(source["clues"].size() == 3, "Filtering a clue list mutated the source registry.")


func _test_history() -> void:
	var source: Dictionary = _fixture()
	var history: Array = []
	for index in range(40):
		history.append({"speaker": "VARGA", "message": "Message %02d [literal]" % index, "elapsed": float(index)})
	history.append({"speaker": "VARGA", "message": "Future invalid", "elapsed": -1})
	history.append({"speaker": "", "message": "Invalid empty", "elapsed": 40})
	history.append({"speaker": [], "message": "Invalid speaker", "elapsed": 40})
	history.append("Invalid row")
	source["transmissions"] = history
	var original: Dictionary = source.duplicate(true)
	var model: Dictionary = Dossier.build(source)
	_check(model["transmissions"].size() == 32, "The dossier does not preserve the last 32 valid received transmissions.")
	_check(model["transmissions"][0]["message"] == "Message 08 [literal]" and model["transmissions"][-1]["message"] == "Message 39 [literal]", "Radio order or retention window changed.")
	_check(str(model["pages"]["transmissions"]).contains("[00:39] VARGA\nMessage 39 [literal]"), "A received timestamp, speaker or literal radio message was rewritten.")
	_check(not str(model["pages"]["situation"]).contains("Message 36") and str(model["pages"]["situation"]).contains("Message 37"), "Situation does not display exactly the last three received exchanges.")
	_check(not JSON.stringify(model).contains("Invalid") and not JSON.stringify(model).contains("Future invalid"), "Invalid rows appeared in the received record.")
	_check(source == original, "Projecting received history mutated the radio queue.")
	model["transmissions"][0]["message"] = "Mutated copy"
	_check(source["transmissions"][8]["message"] != "Mutated copy", "A projected radio row aliases live history.")
	source["transmissions"] = []
	_check(str(Dossier.build(source)["pages"]["transmissions"]).contains("Aucune transmission enregistrée"), "An empty radio log invents an opening exchange.")


func _test_boundaries() -> void:
	var source: Dictionary = _fixture()
	source.merge({"elapsed": INF, "floor": -40, "checkpoint_floor": 900, "health": NAN, "oxygen": -5, "stress": 200, "anchors": 999, "flares": -2, "seed": true, "completed": "true", "supplies_used": ["supply_29", "supply_29", "foreign"]}, true)
	var model: Dictionary = Dossier.build(source)
	_check(model["duration"] == "00:00" and model["health"] == 100.0 and model["seed"] == 271104, "Non-finite or non-numeric mission values reached the presentation.")
	_check(model["floor"] == 25 and model["checkpoint_floor"] == 31 and model["oxygen"] == 0 and model["stress"] == 100, "Location or meter values escaped their bounds.")
	_check(model["anchors"] == 8 and model["flares"] == 0 and model["supplies_count"] == 1, "Resource caps or consumed crate registry are incorrect.")
	_check(not model["completed"] and not str(model["relay_text"]).contains("Nous sommes au 24"), "A malformed completion value disclosed the final relay.")
	_check(Dossier.format_time(3661.9) == "01:01:01" and Dossier.format_time(-5) == "00:00", "Mission duration wraps at one hour or accepts negative time.")
	_check(Dossier.build({})["pages"].size() == 4, "An empty snapshot cannot produce all four journal pages.")


func _test_panels(viewport_size: Vector2i) -> void:
	var viewport: SubViewport = SubViewport.new()
	viewport.size = viewport_size
	root.add_child(viewport)
	var journal = DossierPanel.new()
	viewport.add_child(journal)
	var source: Dictionary = _fixture()
	for index in range(32):
		source["transmissions"].append({"speaker": "VARGA", "message": "Échange %d. Restez près du noyau ; les messages [non formatés] sont conservés tels qu’ils ont été reçus." % index, "elapsed": float(index)})
	var before: Dictionary = source.duplicate(true)
	journal.present(source)
	await _settle_layout()
	_check(journal.visible and journal.selected_tab == "situation" and viewport.gui_get_focus_owner() == journal.tab_buttons["situation"], "Opening journal did not focus Situation at %s." % viewport_size)
	_check(journal.journal_text is RichTextLabel and not journal.journal_text.bbcode_enabled, "The journal is not a real plain RichTextLabel.")
	for id_value: String in Dossier.TABS:
		journal.tab_buttons[id_value].grab_focus()
		await _key(viewport, KEY_ENTER)
		_check(journal.selected_tab == id_value and journal.journal_text.text == journal.model["pages"][id_value], "The real %s tab failed to select its page at %s." % [id_value, viewport_size])
	journal.select_tab("situation", true)
	await _key(viewport, KEY_DOWN)
	_check(journal.selected_tab == "survivors" and viewport.gui_get_focus_owner() == journal.tab_buttons["survivors"], "Arrow navigation failed to change the tab and its focus.")
	await _key(viewport, KEY_UP)
	_check(journal.selected_tab == "situation", "Reverse arrow navigation did not return to Situation.")
	journal.select_tab("transmissions", true)
	await _key(viewport, KEY_TAB)
	_check(viewport.gui_get_focus_owner() == journal.journal_text, "Tab does not move from the final tab to the scrollable reader.")
	await _settle_layout()
	await _key(viewport, KEY_PAGEDOWN)
	_check(journal.journal_text.get_v_scroll_bar().value > 0, "Page Down cannot scroll a long received history.")
	journal.select_tab("clues")
	await _settle_layout()
	_check(journal.journal_text.get_v_scroll_bar().value == 0, "Switching pages retained an unrelated reading offset.")
	journal.select_tab("unknown")
	_check(journal.selected_tab == "clues", "An unknown tab replaced a valid page.")
	_assert_inside(journal.title_label, viewport_size, "journal title")
	_assert_inside(journal.journal_text, viewport_size, "journal reader")
	_assert_inside(journal.footer, viewport_size, "journal footer")
	_check(journal.journal_text.size.y > 100 and journal.journal_text.size.x > 300, "The reduced viewport leaves no usable journal reading area.")
	_check(journal.body_row.get_global_rect().end.y <= journal.footer.get_global_rect().position.y, "Journal contents overlap its close controls.")
	journal.close_requested.connect(func(): actions.append("close"))
	journal.close_button.grab_focus()
	await _key(viewport, KEY_ENTER)
	_check(actions.has("close") and source == before, "Closing a journal fails to signal or mutates its source snapshot.")
	journal.hide()
	var debrief = DossierPanel.new()
	debrief.mode = "debrief"
	viewport.add_child(debrief)
	source["rescued"] = ["survivor_30", "survivor_28", "survivor_26"]
	source["completed"] = true
	source["incident_state"] = "aftermath"
	source["floor"] = 25
	debrief.present(source)
	await _settle_layout()
	_check(debrief.survivor_names.size() == 3 and debrief.survivor_names[1].text == "Samuel Breton", "Debrief lacks the three named people.")
	_check(str(debrief.completion_text.text).contains("ORIGINE NON CONFIRMÉE") and str(debrief.completion_text.text).contains("Ancrages 3"), "Debrief omitted relay uncertainty or actual remaining resources.")
	_check(not debrief.replay_button.disabled and viewport.gui_get_focus_owner() == debrief.journal_button, "A completed debrief cannot focus its report or replay the sequence.")
	_assert_inside(debrief.title_label, viewport_size, "debrief title")
	_assert_inside(debrief.completion_text, viewport_size, "debrief reader")
	_assert_inside(debrief.footer, viewport_size, "debrief footer")
	_check(debrief.body_row.get_global_rect().end.y <= debrief.footer.get_global_rect().position.y, "Debrief contents overlap its action row.")
	for row: Label in debrief.survivor_details:
		_assert_inside(row, viewport_size, "named rescue detail")
	actions.clear()
	debrief.journal_requested.connect(func(): actions.append("journal"))
	debrief.replay_requested.connect(func(): actions.append("replay"))
	debrief.menu_requested.connect(func(): actions.append("menu"))
	for button: Button in [debrief.journal_button, debrief.replay_button, debrief.return_button]:
		button.grab_focus()
		await _key(viewport, KEY_ENTER)
	_check(actions == ["journal", "replay", "menu"], "The three debrief keyboard actions were lost, reordered or duplicated.")
	source["completed"] = false
	debrief.present(source)
	_check(debrief.replay_button.disabled and not debrief.completion_text.text.contains("Nous sommes au 24"), "An unfinished report exposes a replay or the final relay.")
	viewport.queue_free()
	await process_frame
	await process_frame


func _test_hud() -> void:
	var hud = HUD.new()
	root.add_child(hud)
	var source: Dictionary = _fixture()
	hud.show_game()
	hud.show_journal(source)
	await _settle_layout()
	_check(hud.journal_panel.visible and hud.journal_text == hud.journal_panel.journal_text and not hud.end_panel.visible, "HUD journal entry point lost its legacy live control handle or exclusivity.")
	_check(not hud.game.visible, "The game HUD bleeds through the translucent journal.")
	hud.set_paused(false)
	_check(hud.game.visible and not hud.journal_panel.visible, "Closing an in-game journal did not restore its prior HUD visibility.")
	source["completed"] = true
	source["rescued"] = ["survivor_30", "survivor_28", "survivor_26"]
	hud.show_debrief(source)
	await _settle_layout()
	_check(hud.end_panel.visible and not hud.journal_panel.visible and hud.completion_text == hud.end_panel.completion_text and hud.end_journal_button == hud.end_panel.journal_button, "HUD debrief entry point lost its named controls or modal exclusivity.")
	actions.clear()
	hud.journal_requested.connect(func(): actions.append("journal"))
	hud.epilogue_replay_requested.connect(func(): actions.append("replay"))
	hud.return_requested.connect(func(): actions.append("menu"))
	hud.end_journal_button.pressed.emit()
	hud.end_panel.replay_button.pressed.emit()
	hud.end_panel.return_button.pressed.emit()
	_check(actions == ["journal", "replay", "menu"], "HUD failed to forward debrief actions to the mission controller.")
	hud.queue_free()
	await process_frame
	await process_frame


func _key(viewport: Viewport, keycode: Key) -> void:
	var event: InputEventKey = InputEventKey.new()
	event.keycode = keycode
	event.pressed = true
	viewport.push_input(event)
	await process_frame
	event = InputEventKey.new()
	event.keycode = keycode
	event.pressed = false
	viewport.push_input(event)
	await process_frame


func _settle_layout() -> void:
	for frame in range(4):
		await process_frame


func _assert_inside(control: Control, viewport_size: Vector2i, label: String) -> void:
	var bounds: Rect2 = control.get_global_rect()
	_check(bounds.position.x >= -0.5 and bounds.position.y >= -0.5 and bounds.end.x <= viewport_size.x + 0.5 and bounds.end.y <= viewport_size.y + 0.5, "%s escapes %s: %s" % [label, viewport_size, bounds])


func _fixture() -> Dictionary:
	return {"seed": 271104, "floor": 29, "checkpoint_floor": 30, "rescued": [], "clues": [], "clue_records": [], "supplies_used": ["supply_29"], "elapsed": 180.5, "health": 84.0, "oxygen": 73.0, "stress": 28.0, "anchors": 3, "flares": 2, "seen_floors": [31, 30, 29], "completed": false, "incident_state": "intact", "transmissions": [{"speaker": "VARGA", "message": "La ligne principale tient.", "elapsed": 170.0}], "carried_id": "", "hoisting_id": ""}


func _check(condition: bool, message: String) -> void:
	checks += 1
	if not condition:
		failures.append(message)
