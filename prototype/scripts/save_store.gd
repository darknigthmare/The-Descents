class_name DescentSave
extends RefCounted
## Versioned local checkpoint storage. Invalid input never overwrites a valid save.

const SAVE_VERSION: int = 2
# Keep the original filename so a 0.1 installation can find its checkpoint.
const DEFAULT_PATH: String = "user://save_v1.json"
const MAX_BYTES: int = 65536
const MAX_IDS: int = 64
const MAX_ID_LENGTH: int = 80
const INTEGER_LIMITS: Dictionary = {
	"version": [SAVE_VERSION, SAVE_VERSION],
	"seed": [1, 999999],
	"floor": [25, 31],
	"anchors": [0, 8],
	"flares": [0, 6]
}
const FLOAT_LIMITS: Dictionary = {
	"health": [0.0, 100.0],
	"oxygen": [0.0, 100.0],
	"stress": [0.0, 100.0],
	"elapsed": [0.0, INF]
}
const ID_FIELDS: Array[String] = ["rescued", "clues", "supplies_used"]
const REQUIRED_KEYS: Array[String] = [
	"version", "seed", "floor", "health", "oxygen", "stress", "anchors",
	"flares", "rescued", "clues", "supplies_used", "elapsed", "seen_floors", "completed",
	"incident_state"
]


static func save_data(data: Dictionary, path: String = DEFAULT_PATH) -> Error:
	var normalized: Dictionary = _normalize(data, false)
	if normalized.is_empty():
		return ERR_INVALID_DATA
	if not _valid_path(path):
		return ERR_INVALID_PARAMETER
	var json_text: String = JSON.stringify(normalized, "\t", true, true)
	var bytes: PackedByteArray = json_text.to_utf8_buffer()
	if bytes.size() > MAX_BYTES:
		return ERR_INVALID_DATA
	# A sibling temporary file keeps the replacement on the same filesystem.
	# Never delete the previous checkpoint before the rename succeeds.
	var absolute_path: String = ProjectSettings.globalize_path(path)
	var temporary_path: String = absolute_path + ".tmp." + str(Time.get_ticks_usec())
	var file: FileAccess = FileAccess.open(temporary_path, FileAccess.WRITE)
	if file == null:
		return FileAccess.get_open_error()
	file.store_buffer(bytes)
	file.flush()
	var write_error: Error = file.get_error()
	var complete_write: bool = file.get_length() == bytes.size()
	file.close()
	if write_error != OK or not complete_write:
		DirAccess.remove_absolute(temporary_path)
		return write_error if write_error != OK else ERR_FILE_CANT_WRITE
	var rename_error: Error = DirAccess.rename_absolute(temporary_path, absolute_path)
	if rename_error != OK:
		DirAccess.remove_absolute(temporary_path)
	return rename_error


static func load_data(path: String = DEFAULT_PATH) -> Dictionary:
	if not _valid_path(path) or not FileAccess.file_exists(path):
		return {}
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	if file == null:
		return {}
	var length: int = file.get_length()
	if length <= 0 or length > MAX_BYTES:
		file.close()
		return {}
	var bytes: PackedByteArray = file.get_buffer(length)
	var read_error: Error = file.get_error()
	file.close()
	if bytes.size() != length or (read_error != OK and read_error != ERR_FILE_EOF):
		return {}
	var parser: JSON = JSON.new()
	if parser.parse(bytes.get_string_from_utf8()) != OK:
		return {}
	if not parser.data is Dictionary:
		return {}
	# JSON numbers do not preserve GDScript integer types. Only mathematically
	# integral, bounded values are converted for the integer fields.
	var data: Dictionary = parser.data
	var version: Variant = data.get("version")
	if (typeof(version) == TYPE_INT or typeof(version) == TYPE_FLOAT) and version == 1:
		# Migration is read-only until the next valid v2 checkpoint is saved.
		# Validate the entire exact legacy schema before adding any new fields.
		var legacy: Dictionary = _normalize(data, true, true)
		if legacy.is_empty():
			return {}
		legacy["version"] = SAVE_VERSION
		legacy["incident_state"] = "aftermath" if legacy["completed"] else "intact"
		return legacy
	return _normalize(data, true)


static func _valid_path(path: String) -> bool:
	return not path.is_empty() and not path.get_file().is_empty() and (path.begins_with("user://") or path.is_absolute_path())


static func _normalize(data: Dictionary, from_json: bool, legacy: bool = false) -> Dictionary:
	var required_keys: Array[String] = REQUIRED_KEYS.duplicate()
	if legacy:
		required_keys.erase("incident_state")
	if data.size() != required_keys.size():
		return {}
	for key in required_keys:
		if not data.has(key):
			return {}
	var result: Dictionary = {}
	for key in INTEGER_LIMITS:
		var value: Variant = data[key]
		if typeof(value) != TYPE_INT:
			if not from_json or typeof(value) != TYPE_FLOAT or not is_finite(float(value)) or floorf(float(value)) != float(value):
				return {}
		var limits: Array = [1, 1] if legacy and key == "version" else INTEGER_LIMITS[key]
		if value < limits[0] or value > limits[1]:
			return {}
		result[key] = int(value)
	for key in FLOAT_LIMITS:
		var value: Variant = data[key]
		if typeof(value) != TYPE_INT and typeof(value) != TYPE_FLOAT:
			return {}
		var number: float = float(value)
		var limits: Array = FLOAT_LIMITS[key]
		if not is_finite(number) or number < float(limits[0]) or number > float(limits[1]):
			return {}
		result[key] = number
	for field in ID_FIELDS:
		if not data[field] is Array or data[field].size() > MAX_IDS:
			return {}
		var ids: Array[String] = []
		for value in data[field]:
			if typeof(value) != TYPE_STRING or value.is_empty() or value.length() > MAX_ID_LENGTH or ids.has(value):
				return {}
			ids.append(value)
		result[field] = ids
	if not data["seen_floors"] is Array or data["seen_floors"].size() > 7:
		return {}
	var seen_floors: Array[int] = []
	for value in data["seen_floors"]:
		if typeof(value) != TYPE_INT:
			if not from_json or typeof(value) != TYPE_FLOAT or not is_finite(float(value)) or floorf(float(value)) != float(value):
				return {}
		if value < 25 or value > 31 or seen_floors.has(int(value)):
			return {}
		seen_floors.append(int(value))
	result["seen_floors"] = seen_floors
	if typeof(data["completed"]) != TYPE_BOOL:
		return {}
	result["completed"] = data["completed"]
	if not legacy:
		if typeof(data["incident_state"]) != TYPE_STRING or data["incident_state"] not in ["intact", "aftermath"]:
			return {}
		if data["completed"] and data["incident_state"] != "aftermath":
			return {}
		result["incident_state"] = data["incident_state"]
	return result
