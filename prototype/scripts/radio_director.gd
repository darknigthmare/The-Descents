class_name DescentRadio
extends RefCounted
## Received words are durable; the currently displayed subtitle is transient.

const MAX_HISTORY: int = 32
const MAX_PENDING: int = 6

var current: Dictionary = {}
var pending: Array[Dictionary] = []
var history: Array[Dictionary] = []
var remaining: float = 0.0


func submit(speaker: String, message: String, seconds: float, elapsed: float, priority: bool = false, archive_only: bool = false) -> bool:
	if speaker.strip_edges().is_empty() or message.strip_edges().is_empty():
		return false
	if not is_finite(seconds) or seconds <= 0.0 or not is_finite(elapsed) or elapsed < 0.0:
		return false
	# Repeated ordinary requests must not extend a subtitle or fill its queue.
	if not priority:
		if _same_words(current, speaker, message):
			return false
		for entry: Dictionary in pending:
			if _same_words(entry, speaker, message):
				return false
	var received: Dictionary = {"speaker": speaker, "message": message, "elapsed": elapsed}
	history.append(received.duplicate(true))
	while history.size() > MAX_HISTORY:
		history.pop_front()
	if archive_only:
		return true
	var subtitle: Dictionary = received.duplicate(true)
	subtitle["duration"] = seconds
	if priority:
		pending.clear()
		_present(subtitle)
	elif not is_busy():
		_present(subtitle)
	else:
		# Keep the newest actionable words, while the entire recent exchange is
		# still available in the journal, including displaced pending messages.
		if pending.size() >= MAX_PENDING:
			pending.pop_front()
		pending.append(subtitle)
	return true


func advance(delta: float) -> bool:
	if not is_finite(delta) or delta <= 0.0 or not is_busy():
		return false
	remaining = maxf(0.0, remaining - delta)
	if remaining > 0.0:
		return false
	if pending.is_empty():
		current = {}
	else:
		# Do not consume the next line with the overshoot of a long frame: it
		# has not yet been visible and deserves its complete reading duration.
		_present(pending.pop_front())
	return true


func is_busy() -> bool:
	return not current.is_empty() and remaining > 0.0


func history_snapshot() -> Array:
	return history.duplicate(true)


func reset(received: Array = []) -> void:
	current = {}
	pending.clear()
	remaining = 0.0
	history.clear()
	for index in range(maxi(0, received.size() - MAX_HISTORY), received.size()):
		if received[index] is Dictionary:
			history.append(received[index].duplicate(true))


func _present(subtitle: Dictionary) -> void:
	current = subtitle.duplicate(true)
	remaining = float(current["duration"])


func _same_words(entry: Dictionary, speaker: String, message: String) -> bool:
	return entry.get("speaker", "") == speaker and entry.get("message", "") == message
