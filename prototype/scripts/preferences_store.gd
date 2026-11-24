extends RefCounted
class_name DescentPreferences

const DEFAULTS: Dictionary = {"audio":true, "reduced_motion":true, "flashes":false, "startup_intro":true}
const FILE: String = "user://preferences.cfg"

static func load_settings(path: String = FILE) -> Dictionary:
	var result: Dictionary = DEFAULTS.duplicate()
	var config: ConfigFile = ConfigFile.new()
	if config.load(path) != OK:
		return result
	for key: String in DEFAULTS:
		var value: Variant = config.get_value("comfort",key,DEFAULTS[key])
		if typeof(value) == TYPE_BOOL:
			result[key] = value
	return result

static func save_settings(settings: Dictionary, path: String = FILE) -> Error:
	var config: ConfigFile = ConfigFile.new()
	for key: String in DEFAULTS:
		if typeof(settings.get(key)) != TYPE_BOOL:
			return ERR_INVALID_DATA
		config.set_value("comfort",key,settings[key])
	var temp: String = path + ".tmp"
	var error: Error = config.save(temp)
	if error != OK:
		return error
	return DirAccess.rename_absolute(ProjectSettings.globalize_path(temp),ProjectSettings.globalize_path(path))
