extends PanelContainer


func _ready() -> void:
	hide()
	if OS.get_name() == "Android":
		modulate.a = 0
	pass


func _process(delta: float) -> void:
	#1430
	var move_pos: Vector2 = get_global_mouse_position()
	move_pos.y -= size.y*scale.length()*scale.length() + 5
	if get_global_mouse_position().x < 1430: move_pos.x += 5
	else: move_pos.x -= size.x*scale.length()*scale.length() + 10
	
	position = move_pos
	
	size.y = 0
	pass
