extends Sprite2D


func _ready() -> void:
	#global_position = get_parent().global_position
	await get_tree().process_frame
	show()
	await get_tree().create_timer(0.05,false).timeout
	create_tween().tween_property(self,"scale",Vector2.ZERO,0.05)
	queue_free()
	pass
