extends SceneTree
## Mission integration uses explicit placements to isolate state rules.
## Physical traversal remains the responsibility of the separate route suites.

const MainScene = preload("res://scenes/main.tscn")
const Store = preload("res://scripts/save_store.gd")
const TEST_PATH: String = "user://qa_v04_radio_integration.json"
const PREFS_PATH: String = "user://qa_v04_radio_preferences.json"
var mission: Node3D
var failures: Array[String] = []
var checks: int = 0


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	_cleanup()
	var timer: SceneTreeTimer = create_timer(30.0)
	timer.timeout.connect(func():
		push_error("Radio integration timed out.")
		_cleanup()
		quit(1)
	)
	mission = MainScene.instantiate()
	mission.save_path = TEST_PATH
	if _has_property(mission, "preferences_path"):
		mission.set("preferences_path", PREFS_PATH)
	mission.sound_enabled = false
	root.add_child(mission)
	mission.set_process(false)
	await process_frame
	_check(not mission.started and mission.hud.menu.visible, "Mission did not initialize into its accessible menu.")
	_check(mission.hud.has_signal("journal_requested"), "HUD omitted the final-journal signal.")
	mission._start_new(271104)
	mission._finish_arrival()
	_disable_ticks()
	mission.elapsed = 40.0
	mission.intro_stage = 3
	_check(mission.started and mission.player.active, "New mission or arrival skip left the player blocked.")
	_extract(30)
	_check(mission.world.roof_rescued_people["survivor_30"].visible, "Confirmed Ana did not appear at rooftop reception.")
	var first_save: Dictionary = Store.load_data(TEST_PATH)
	_check(first_save.get("version") == 4 and first_save.get("rescued") == ["survivor_30"], "The first confirmed rescue was not saved as schema 4.")
	_check(_history_has(first_save.get("transmissions", []), "Ana Rios : réception confirmée"), "Reception confirmation was saved before its received transmission existed.")

	_place(27)
	_silence()
	mission._process_story_radio(100.0)
	_check(mission.radio_events.is_empty(), "Bravo echo triggered before the structural incident and Samuel rescue.")
	mission.incident.restore("aftermath")
	mission.world.apply_incident("aftermath", 0.0)
	mission._process_story_radio(100.0)
	_check(mission.radio_events.is_empty(), "Bravo echo triggered without Samuel's confirmed reception.")
	_extract(28)
	_check(mission.world.roof_rescued_people["survivor_28"].visible, "Confirmed Samuel did not appear at reception.")
	_check(_history_has(Store.load_data(TEST_PATH).get("transmissions", []), "Samuel Breton : réception confirmée"), "Samuel's reception confirmation is absent from the checkpoint.")
	mission.incident.restore("intact")
	_place(27)
	_silence()
	mission._process_story_radio(100.0)
	_check(mission.radio_events.is_empty(), "Samuel's rescue alone triggered an echo before the incident.")
	mission.incident.restore("aftermath")
	for floor_number: int in [25, 26, 28, 29, 30, 31]:
		_place(floor_number)
		_silence()
		mission._process_story_radio(100.0)
		_check(mission.radio_events.is_empty(), "Optional Bravo echo triggered outside floor 27: %d." % floor_number)
	_place(27)
	mission.player.on_rope = true
	mission._process_story_radio(100.0)
	_check(mission.radio_events.is_empty(), "Bravo echo triggered during rope travel.")
	mission.player.on_rope = false
	var nora: Node3D = _find("survivor", 26)
	mission.carried = nora
	mission.player.carrying = true
	mission._process_story_radio(100.0)
	_check(mission.radio_events.is_empty(), "Bravo echo triggered while carrying a survivor.")
	mission.carried = null
	mission.player.carrying = false
	mission.hoisting = nora
	mission._process_story_radio(100.0)
	_check(mission.radio_events.is_empty(), "Bravo echo triggered during a live hoist.")
	mission.hoisting = null
	mission.arrival_playing = true
	mission._process_story_radio(100.0)
	_check(mission.radio_events.is_empty(), "Bravo echo triggered during arrival.")
	mission.arrival_playing = false
	_silence()
	mission._say("VARGA", "Lecture longue avant le silence", 20.0)
	mission._process(10.0)
	_check(mission.radio_events.is_empty() and mission.radio_quiet_time == 0.0, "Occupied subtitle time accumulated toward optional silence.")
	mission._process(15.0)
	_check(mission.radio_events.is_empty() and is_equal_approx(mission.radio_quiet_time, 5.0), "A long frame counted the occupied part of a subtitle as silence.")
	mission._process(0.9)
	_check(mission.radio_events.is_empty(), "Bravo echo fired before six quiet seconds.")
	mission._pause(false)
	var paused_elapsed: float = mission.elapsed
	var paused_silence: float = mission.radio_quiet_time
	mission._process(60.0)
	_check(mission.elapsed == paused_elapsed and mission.radio_quiet_time == paused_silence, "Pause advanced mission time or optional radio silence.")
	mission._resume()
	_disable_ticks()
	mission._process(0.11)
	_check(mission.radio_events == ["bravo_echo"] and str(mission.radio.current.get("speaker", "")).contains("BRAVO"), "Six quiet seconds after Samuel did not produce the optional echo.")
	var echo_save: Dictionary = Store.load_data(TEST_PATH)
	_check(echo_save.get("radio_events") == ["bravo_echo"] and echo_save.get("floor") == 27, "Echo receipt was not persisted at the safe garden checkpoint.")
	_check(_history_has(echo_save.get("transmissions", []), "Notre toit tient"), "The echo marker was saved without its received words.")
	mission._restore(echo_save)
	_disable_ticks()
	_check(not mission.radio.is_busy() and mission.radio.pending.is_empty(), "Loading replayed previously received subtitles.")
	_check(mission.world.roof_rescued_people["survivor_30"].visible and mission.world.roof_rescued_people["survivor_28"].visible, "Loading failed to reconstruct confirmed reception figures.")
	_place(26)
	mission._process_story_radio(100.0)
	_check(mission.radio_events == ["bravo_echo"], "Varga verification played in the unsafe spa.")
	_place(25)
	mission._process_story_radio(1.9)
	_check(mission.radio_events == ["bravo_echo"], "Varga verification ignored its two quiet seconds.")
	mission._process_story_radio(0.11)
	_check(mission.radio_events == ["bravo_echo", "bravo_verification"], "Varga verification failed at the safe refuge.")
	_check(str(mission.radio.current.get("speaker", "")).contains("VÉRIFICATION"), "Varga's verification did not appear as the current subtitle.")
	var verified_save: Dictionary = Store.load_data(TEST_PATH)
	_check(verified_save.get("radio_events") == mission.radio_events and _history_has(verified_save.get("transmissions", []), "Aucun contact confirmé"), "Verification flag and received words were not saved together.")
	mission._restore(echo_save)
	_disable_ticks()
	_place(31)
	mission._process_story_radio(2.01)
	_check("bravo_verification" in mission.radio_events, "Varga verification could not play at the rooftop safe area.")
	mission._restore(verified_save)
	_disable_ticks()
	_place(27)
	var received_count: int = mission.radio.history.size()
	mission._process_story_radio(100.0)
	_check(mission.radio.history.size() == received_count and not mission.radio.is_busy(), "Restoring both flags replayed the optional exchange.")

	_place(26)
	mission.clues = ["evidence_29", "evidence_27"]
	_queue_ordinary()
	mission.carried = _find("survivor", 26)
	mission.player.carrying = true
	mission.radio_cooldown = 0.0
	mission._call_radio()
	_check(str(mission.radio.current.get("message", "")).contains("balise orange") and str(mission.radio.current.get("message", "")).contains("harnais"), "R in the spa replaced carrying instructions with spooky fiction.")
	_check(mission.radio.pending.is_empty() and _history_has(mission.radio.history, "Message ordinaire en attente"), "Operational R guidance failed to interrupt pending normal words while retaining history.")
	mission.carried = null
	mission.player.carrying = false
	for phase: String in ["intact", "aftermath"]:
		mission.incident.restore(phase)
		mission.rescued = ["survivor_30", "survivor_28", "survivor_26"]
		_queue_ordinary()
		mission.radio_cooldown = 0.0
		mission._call_radio()
		var words: String = str(mission.radio.current.get("message", ""))
		_check(words.contains("baie Est du 29") if phase == "intact" else words.contains("refuge 25"), "R with three rescues omitted the remaining objective in %s." % phase)
		_check(mission.radio.pending.is_empty() and not words.contains("sous l’eau"), "Final objective instructions waited behind ambient radio at the spa.")
	mission.rescued = ["survivor_30", "survivor_28"]
	mission.incident.restore("intact")
	mission.incident.start()
	mission._say("VARGA", "ALERTE ACTIVE", 9.0, true)
	mission._say("NOTE", "Indice reçu pendant la secousse", 9.0)
	_check(mission.radio.current.get("message") == "ALERTE ACTIVE" and mission.radio.pending.is_empty(), "An ordinary incident message obscured the priority alert.")
	_check(_history_has(mission.radio.history, "Indice reçu pendant la secousse"), "Incident priority discarded a received clue instead of archiving it.")
	mission.incident.restore("aftermath")
	mission.world.apply_incident("aftermath", 0.0)
	_extract(26)
	_check(mission.world.roof_rescued_people["survivor_26"].visible and mission.rescued.size() == 3, "Nora's actual hoist did not complete the three-person reception.")
	var refuge: Node3D = _find("refuge", 25)
	_place(25)
	mission._interact_node(refuge)
	_check(mission.epilogue_playing and not mission.hud.end_panel.visible, "The closing sequence did not precede its final report.")
	mission._finish_epilogue()
	_check(mission.completed and mission.hud.end_panel.visible and not mission.player.active, "Completed rescue did not reach its accessible final report.")
	var final_save: Dictionary = Store.load_data(TEST_PATH)
	_check(final_save.get("completed", false) and final_save.get("radio_events") == ["bravo_echo", "bravo_verification"], "The final checkpoint lost optional reception markers.")
	var journal_button: Button = mission.hud.get("end_journal_button")
	_check(is_instance_valid(journal_button), "The final report has no journal button.")
	if is_instance_valid(journal_button):
		journal_button.pressed.emit()
	_check(mission.hud.journal_panel.visible and not mission.hud.end_panel.visible, "The ending modal still covers the opened journal.")
	_check(mission.hud.journal_text.text.contains("Ana Rios") and mission.hud.journal_text.text.contains("Samuel Breton") and mission.hud.journal_text.text.contains("Nora Haddad"), "The journal omits named rescue reception status.")
	_check(mission.hud.journal_text.text.contains("TRANSMISSIONS REÇUES") and mission.hud.journal_text.text.contains("réception confirmée"), "The final journal lacks received transmissions.")
	mission._resume()
	_check(mission.hud.end_panel.visible and not mission.hud.journal_panel.visible and not mission.player.active, "Closing the final journal did not restore the report without movement.")
	_check(Input.mouse_mode == Input.MOUSE_MODE_VISIBLE and not mission.world.is_processing(), "Closing the final journal captured the cursor or unfroze the scene.")
	mission._continue_game()
	_disable_ticks()
	_check(mission.completed and mission.hud.end_panel.visible and not mission.radio.is_busy(), "Loading a completed checkpoint replayed radio or hid its report.")
	_check(mission.radio.history_snapshot() == final_save.get("transmissions"), "Loading completion invented a new transmission.")
	mission._start_new(271104)
	_disable_ticks()
	_check(mission.radio_events.is_empty() and mission.rescued.is_empty(), "A new intervention inherited old optional markers or rescues.")
	_check(not mission.world.roof_rescued_people["survivor_30"].visible and not mission.world.roof_rescued_people["survivor_28"].visible and not mission.world.roof_rescued_people["survivor_26"].visible, "New-game reception retained previous people.")
	_check(not _history_has(mission.radio.history, "Samuel Breton : réception confirmée"), "New-game radio retained the previous intervention's transcript.")
	mission.free()
	_cleanup()
	_finish()


func _place(floor_number: int) -> void:
	mission.player.teleport_to_floor(floor_number)
	mission.last_floor = floor_number


func _extract(floor_number: int) -> void:
	var person: Node3D = _find("survivor", floor_number)
	_place(floor_number)
	mission._interact_node(person)
	mission._interact_node(_find("beacon", floor_number))
	mission._process_hoist(5.01)


func _find(kind: String, floor_number: int) -> Node3D:
	for target: Node3D in mission.world_data.get("interactables", []):
		if target.get_meta("kind", "") == kind and int(target.get_meta("floor", 0)) == floor_number:
			return target
	return null


func _silence() -> void:
	mission.radio.reset(mission.radio.history_snapshot())
	mission.radio_quiet_time = 0.0
	mission._sync_radio()


func _queue_ordinary() -> void:
	_silence()
	mission._say("ORDINAIRE", "Message ordinaire actif", 20.0)
	mission._say("ORDINAIRE", "Message ordinaire en attente", 20.0)


func _history_has(history: Array, words: String) -> bool:
	for entry: Dictionary in history:
		if str(entry.get("message", "")).contains(words):
			return true
	return false


func _disable_ticks() -> void:
	mission.set_process(false)
	mission.player.set_process(false)
	mission.player.set_physics_process(false)
	mission.world.set_process(false)


func _has_property(object: Object, key: String) -> bool:
	for entry: Dictionary in object.get_property_list():
		if entry["name"] == key:
			return true
	return false


func _cleanup() -> void:
	for path: String in [TEST_PATH, PREFS_PATH]:
		if FileAccess.file_exists(path):
			DirAccess.remove_absolute(ProjectSettings.globalize_path(path))


func _check(condition: bool, message: String) -> void:
	checks += 1
	if not condition:
		failures.append(message)


func _finish() -> void:
	if failures.is_empty():
		print("PASS radio integration: %d checks; confirmed rescue, quiet-time guards, optional exchange persistence, operational priority and accessible final journal. Uses placements; does not prove physical route traversal." % checks)
		quit(0)
	else:
		for failure: String in failures:
			push_error(failure)
		print("FAIL radio integration: %d failures / %d checks." % [failures.size(), checks])
		quit(1)
