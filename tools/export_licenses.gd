extends SceneTree

func _initialize() -> void:
	var args: PackedStringArray = OS.get_cmdline_user_args()
	if args.is_empty():
		push_error("Pass an absolute output file after --")
		quit(1)
		return
	var file: FileAccess = FileAccess.open(args[0], FileAccess.WRITE)
	if file == null:
		quit(1)
		return
	file.store_string("GODOT ENGINE AND BUNDLED COMPONENTS\n\n")
	file.store_string(Engine.get_license_text() + "\n\n")
	file.store_string("COPYRIGHT RECORDS\n" + JSON.stringify(Engine.get_copyright_info(), "  ") + "\n\n")
	var licenses: Dictionary = Engine.get_license_info()
	for key in licenses:
		file.store_string(str(key) + "\n" + str(licenses[key]) + "\n\n")
	file.close()
	print("Godot license notices exported.")
	quit()
