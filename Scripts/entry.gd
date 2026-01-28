extends CanvasLayer
class_name Entry

static var resolution_mode: int = 1
static var full_screen:bool

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if OS.get_name() == "Android":
		get_tree().change_scene_to_file("res://Scenes/GameBased/main_title_mobile.tscn")
		return
	get_tree().change_scene_to_file("res://Scenes/GameBased/main_title.tscn")
	pass # Replace with function body.

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("escape") or event.is_action_pressed("click"):
		$AnimationPlayer.pause()
		await get_tree().create_timer(0.2).timeout
		if OS.get_name() == "Android":
			get_tree().change_scene_to_file("res://Scenes/GameBased/main_title_mobile.tscn")
			return
		get_tree().change_scene_to_file("res://Scenes/GameBased/main_title.tscn")
	pass


func _ready() -> void:
	if OS.get_name() == "Android":
		get_window().mode = Window.MODE_EXCLUSIVE_FULLSCREEN
		return
	
	get_window().title = "MinecraftRush V" + Global.version_text + Global.get_version_back_words()
	get_window().mode = Window.MODE_EXCLUSIVE_FULLSCREEN if full_screen else Window.MODE_WINDOWED
	get_window().content_scale_size = Vector2(1920,1080)
	var global_center_position = get_window().position + get_window().size/2
	match resolution_mode:
		0:
			get_window().size = Vector2(3840,2160)
		1:
			get_window().size = Vector2(2560,1440)
		2:
			get_window().size = Vector2(1920,1080)
		3:
			get_window().size = Vector2(1280,720)
		4:
			get_window().size = Vector2(1024,576)
		5:
			get_window().size = Vector2(640,360)
	get_window().position = global_center_position - get_window().size/2
	Input.set_custom_mouse_cursor(load("res://Assets/Images/UI/cursor.png"),Input.CURSOR_ARROW,Vector2(24,24))
	pass
