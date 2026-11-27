extends RefCounted
class_name DescentPreferences

# Keep the legacy keys and file: existing installations migrate independently
# for every added setting, without touching a mission checkpoint.
const DEFAULTS: Dictionary = {
	"audio": true, "reduced_motion": true, "flashes": false, "startup_intro": true,
	"master_volume": 1.0, "mouse_sensitivity": 1.0, "field_of_view": 77.0, "invert_y": false
}
const LEGACY_KEYS: Array[String] = ["audio", "reduced_motion", "flashes", "startup_intro"]
const LIMITS: Dictionary = {
	"master_volume": Vector2(0.0, 1.0),
	"mouse_sensitivity": Vector2(0.25, 2.5),
	"field_of_view": Vector2(65.0, 100.0)
}
const FILE: String = "user://preferences.cfg"

static func valid_value(setting: String, value: Variant) -> bool:
	if not DEFAULTS.has(setting):
		return false
	if typeof(DEFAULTS[setting]) == TYPE_BOOL:
		return typeof(value) == TYPE_BOOL
	if typeof(value) != TYPE_FLOAT and typeof(value) != TYPE_INT:
		return false
	var number: float = float(value)
	var limits: Vector2 = LIMITS[setting]
	return is_finite(number) and number >= limits.x and number <= limits.y

static func normalize(settings: Dictionary) -> Dictionary:
	var result: Dictionary = DEFAULTS.duplicate()
	for key: String in DEFAULTS:
		var value: Variant = settings.get(key, DEFAULTS[key])
		if typeof(DEFAULTS[key]) == TYPE_BOOL:
			if typeof(value) == TYPE_BOOL:
				result[key] = value
		elif typeof(value) == TYPE_FLOAT or typeof(value) == TYPE_INT:
			var number: float = float(value)
			if is_finite(number):
				var limits: Vector2 = LIMITS[key]
				result[key] = clampf(number, limits.x, limits.y)
	return result

static func load_settings(path: String = FILE) -> Dictionary:
	var config: ConfigFile = ConfigFile.new()
	if config.load(path) != OK:
		return DEFAULTS.duplicate()
	var settings: Dictionary = {}
	for key: String in DEFAULTS:
		settings[key] = config.get_value("comfort", key, DEFAULTS[key])
	return normalize(settings)

static func save_settings(settings: Dictionary, path: String = FILE) -> Error:
	# Accept complete v0.4/v0.5 callers; absent new keys acquire safe defaults.
	# Invalid supplied values never replace a previously valid file.
	for key: String in LEGACY_KEYS:
		if not settings.has(key) or not valid_value(key, settings[key]):
			return ERR_INVALID_DATA
	for key: String in DEFAULTS:
		if settings.has(key) and not valid_value(key, settings[key]):
			return ERR_INVALID_DATA
	var clean: Dictionary = normalize(settings)
	var config: ConfigFile = ConfigFile.new()
	for key: String in DEFAULTS:
		config.set_value("comfort", key, clean[key])
	var temp: String = path + ".tmp"
	var error: Error = config.save(temp)
	if error != OK:
		return error
	return DirAccess.rename_absolute(ProjectSettings.globalize_path(temp), ProjectSettings.globalize_path(path))
