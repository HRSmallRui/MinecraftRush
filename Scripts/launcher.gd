extends CanvasLayer

signal file_process_finished

@onready var full_screen_check: CheckBox = $FullScreen/FullScreenCheck
@onready var resolution_option: OptionButton = $Resolution/ResolutionOption
@onready var language_option: OptionButton = $Language/LanguageOption
@onready var version_label: Label = $VersionLabel
@onready var stop_layer: ColorRect = $StopLayer

var user_sav: UserSaver


func _ready() -> void:
	if OS.get_name() == "Android":
		get_tree().change_scene_to_file("res://Scenes/entry.tscn")
		return
	stop_layer.hide()
	get_window().files_dropped.connect(on_files_droped)
	
	version_label.text = "ver.mr.rebirth.desktop-" + Global.version_text + Global.get_version_back_words()
	full_screen_check.button_pressed = user_sav.full_screen
	resolution_option.selected = user_sav.resolution_mode
	language_option.selected = user_sav.language_select
	_on_language_option_item_selected(user_sav.language_select)
	
	get_window().set_title("MinecraftRushLauncher")
	get_window().content_scale_size = Vector2i(640,960)
	var global_center_position:Vector2 = get_window().position + get_window().size/2
	var screen_resolution = global_center_position * 2
	var rate:float = screen_resolution.x / 2560
	get_window().set_size(Vector2i(640,960) * rate)
	get_window().position = global_center_position as Vector2i - get_window().size/2
	pass


func _init() -> void:
	
	user_sav = Global.get_user_sav() as UserSaver
	if user_sav == null:
		user_sav = UserSaver.new()
		Global.sav_user_sav(user_sav)
	pass


func _on_start_button_pressed() -> void:
	get_window().mode = Window.MODE_MINIMIZED
	Entry.resolution_mode = resolution_option.selected
	Entry.full_screen = full_screen_check.button_pressed
	get_tree().change_scene_to_file("res://Scenes/entry.tscn")
	pass # Replace with function body.


func _on_language_option_item_selected(index: int) -> void:
	match index:
		0:
			TranslationServer.set_locale("zh_CN")
		1:
			TranslationServer.set_locale("en")
	user_sav.language_select = index
	Global.sav_user_sav(user_sav)
	pass # Replace with function body.


func _on_resolution_option_item_selected(index: int) -> void:
	user_sav.resolution_mode = resolution_option.selected
	Global.sav_user_sav(user_sav)
	pass # Replace with function body.


func _on_full_screen_check_pressed() -> void:
	user_sav.full_screen = full_screen_check.button_pressed
	Global.sav_user_sav(user_sav)
	pass # Replace with function body.


func _on_close_button_pressed() -> void:
	get_tree().quit()
	pass # Replace with function body.


func on_files_droped(files_paths: PackedStringArray):
	return
	if stop_layer.visible: return
	stop_layer.show()
	for file_path in files_paths:
		on_file_droped(file_path)
		await file_process_finished
	
	stop_layer.hide()
	pass


func on_file_droped(file_path: String):
	var file = load(file_path)
	if file is GameSaver and (
		"Sav1.tres" in file_path or
		"Sav2.tres" in file_path or
		"Sav3.tres" in file_path
	):
		var dialog_window: ConfirmationDialog = ConfirmationDialog.new()
		dialog_window.force_native = true
		dialog_window.title = "MinecraftRushSavChanger"
		dialog_window.dialog_text = "是否覆盖存档？"
		dialog_window.ok_button_text = "是"
		dialog_window.cancel_button_text = "否"
		dialog_window.initial_position = Window.WINDOW_INITIAL_POSITION_CENTER_MAIN_WINDOW_SCREEN
		dialog_window.transient_to_focused = true
		dialog_window.theme = load("res://Assets/Resources/window_resouece.tres")
		dialog_window.unresizable = true
		add_child(dialog_window)
		dialog_window.show()
		dialog_window.get_label().horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		dialog_window.close_requested.connect(func():
			file_process_finished.emit()
			)
		dialog_window.get_ok_button().pressed.connect(func():
			save_game_sav(file_path)
			file_process_finished.emit())
		dialog_window.get_cancel_button().pressed.connect(func():
			file_process_finished.emit())
	elif file is UserSaver:
		var dialog_window: ConfirmationDialog = ConfirmationDialog.new()
		dialog_window.force_native = true
		dialog_window.title = "MinecraftRushSavChanger"
		dialog_window.dialog_text = "是否覆盖存档？"
		dialog_window.ok_button_text = "是"
		dialog_window.cancel_button_text = "否"
		dialog_window.initial_position = Window.WINDOW_INITIAL_POSITION_CENTER_MAIN_WINDOW_SCREEN
		dialog_window.transient_to_focused = true
		dialog_window.theme = load("res://Assets/Resources/window_resouece.tres")
		dialog_window.unresizable = true
		add_child(dialog_window)
		dialog_window.show()
		dialog_window.get_label().horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		dialog_window.close_requested.connect(func():
			file_process_finished.emit()
			)
		dialog_window.get_ok_button().pressed.connect(func():
			file_process_finished.emit())
		dialog_window.get_cancel_button().pressed.connect(func():
			file_process_finished.emit())
	else:
		OS.alert("未知文件","错误！")
		await get_tree().process_frame
		file_process_finished.emit()
	pass


func save_game_sav(file_path: String):
	
	pass
