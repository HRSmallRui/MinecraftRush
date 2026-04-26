extends Magician


func anim_offset():
	offset.x = 0 if animation == "shoot_front" or animation == "idle_front" else -4
	pass


func frame_condition():
	
	pass


func _process(delta: float) -> void:
	
	pass
