extends SceneTree
## Pure scheduling tests; no scene, save or wall-clock dependency.

const Director = preload("res://scripts/radio_director.gd")
var failures: Array[String] = []
var checks: int = 0


func _initialize() -> void:
	var radio = Director.new()
	_check(not radio.is_busy() and radio.history.is_empty(), "A new director had residual radio state.")
	_check(radio.submit("VARGA", "Première ligne", 4.0, 1.0), "A first ordinary line was rejected.")
	_check(radio.current.get("message") == "Première ligne" and radio.remaining == 4.0, "The first line did not display immediately.")
	_check(radio.submit("ANA", "Deuxième ligne", 6.0, 2.0), "A distinct ordinary line was rejected.")
	_check(radio.current["speaker"] == "VARGA" and radio.pending.size() == 1, "An ordinary line overwrote the current subtitle.")
	_check(radio.history.size() == 2 and radio.history[1]["speaker"] == "ANA", "Queued received words are missing from the journal.")
	radio.advance(1.0)
	_check(not radio.submit("VARGA", "Première ligne", 99.0, 3.0), "Duplicate active words were accepted.")
	_check(not radio.submit("ANA", "Deuxième ligne", 99.0, 3.0), "Duplicate pending words were accepted.")
	_check(radio.remaining == 3.0 and radio.pending.size() == 1 and radio.history.size() == 2, "Deduplication changed duration or appended duplicate history.")
	_check(not radio.advance(2.0) and radio.current["speaker"] == "VARGA", "An unfinished subtitle advanced early.")
	_check(radio.advance(1.0) and radio.current["speaker"] == "ANA" and radio.remaining == 6.0, "An expired subtitle did not present the next full line.")
	_check(radio.advance(1000.0) and not radio.is_busy(), "The last expired subtitle did not clear the display.")
	_check(radio.history.size() == 2, "Expiration removed received transmissions from history.")

	radio.reset()
	radio.submit("A", "Active", 10.0, 0.0)
	for index in range(8):
		radio.submit("Q", "Queued %d" % index, 3.0 + index, float(index))
	_check(radio.pending.size() == 6 and radio.pending[0]["message"] == "Queued 2", "A saturated queue did not retain its six newest pending lines.")
	_check(radio.history.size() == 9, "Bounded pending queue silently erased received history.")
	radio.advance(10000.0)
	_check(radio.current["message"] == "Queued 2" and radio.remaining == 5.0 and radio.pending.size() == 5, "A large frame consumed unread subtitles instead of preserving display duration.")
	radio.submit("VARGA", "ALERTE", 7.0, 20.0, true)
	_check(radio.current["message"] == "ALERTE" and radio.remaining == 7.0 and radio.pending.is_empty(), "Priority did not interrupt and clear ordinary pending lines.")
	_check(radio.history.size() == 10 and radio.history[1]["message"] == "Queued 0", "Priority erased interrupted or displaced words from the journal.")
	_check(radio.submit("NOTE", "Indice pendant la secousse", 8.0, 21.0, false, true), "An archive-only incident line was rejected.")
	_check(radio.current["message"] == "ALERTE" and radio.pending.is_empty() and radio.remaining == 7.0, "Archive-only words masked the urgent subtitle or entered its queue.")
	_check(radio.history.back()["speaker"] == "NOTE", "Archive-only incident words disappeared from the journal.")

	radio.reset()
	for index in range(40):
		radio.submit("JOURNAL", "Reçu %d" % index, 1.0, float(index), false, true)
	_check(radio.history.size() == 32 and radio.history.front()["message"] == "Reçu 8", "History failed to retain exactly the newest 32 records.")
	_check(not radio.is_busy() and radio.pending.is_empty(), "Archiving alone unexpectedly started a subtitle.")
	var snapshot: Array = radio.history_snapshot()
	snapshot[0]["message"] = "Changed copy"
	snapshot.pop_back()
	_check(radio.history.size() == 32 and radio.history.front()["message"] == "Reçu 8", "The history snapshot exposed mutable internal state.")
	var restored: Array = [{"speaker": "VARGA", "message": "Already received", "elapsed": 2.0}]
	radio.submit("LIVE", "Not restored", 8.0, 41.0)
	radio.reset(restored)
	restored[0]["message"] = "External mutation"
	_check(radio.history[0]["message"] == "Already received", "Reset retained a reference to externally mutable history.")
	_check(not radio.is_busy() and radio.remaining == 0.0 and radio.pending.is_empty(), "Reset replayed saved transmissions or retained a live queue.")
	radio.reset()
	_check(radio.history.is_empty(), "New-game reset retained a previous intervention's journal.")
	for bad_args: Array in [["", "word", 1.0, 0.0], ["A", "   ", 1.0, 0.0], ["A", "word", 0.0, 0.0], ["A", "word", NAN, 0.0], ["A", "word", 1.0, -1.0]]:
		_check(not radio.submit(bad_args[0], bad_args[1], bad_args[2], bad_args[3]), "Invalid radio input changed scheduler state.")
	_check(radio.history.is_empty() and not radio.is_busy(), "Rejected radio submissions left received or active state.")
	_finish()


func _check(condition: bool, message: String) -> void:
	checks += 1
	if not condition:
		failures.append(message)


func _finish() -> void:
	if failures.is_empty():
		print("PASS radio director: %d checks; serialized subtitles, deduplication, priority, archive-only messages, bounded copies and long-frame readability." % checks)
		quit(0)
	else:
		for failure: String in failures:
			push_error(failure)
		print("FAIL radio director: %d failures / %d checks." % [failures.size(), checks])
		quit(1)
