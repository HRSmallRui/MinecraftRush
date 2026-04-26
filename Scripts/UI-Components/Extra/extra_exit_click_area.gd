extends Area2D

@onready var white_arrow: Sprite2D = $WhiteArrow
@onready var yellow_arrow: Sprite2D = $YellowArrow


func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event.is_action_pressed("click"):
		var back_path: String
		if OS.get_name() == "Android":
			back_path = "res://Scenes/GameBased/main_title_mobile.tscn"
		else:
			back_path = "res://Scenes/GameBased/main_title.tscn"
		Global.change_scene(back_path)
	pass # Replace with function body.


func _on_mouse_entered() -> void:
	white_arrow.hide()
	yellow_arrow.show()
	pass # Replace with function body.


func _on_mouse_exited() -> void:
	white_arrow.show()
	yellow_arrow.hide()
	pass # Replace with function body.
