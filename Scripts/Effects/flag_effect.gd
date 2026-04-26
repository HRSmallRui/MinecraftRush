extends AnimatedSprite2D


func _ready() -> void:
	offset = Vector2(10,-330)
	await animation_finished
	play("flow")
	offset = Vector2(10,-225)
	create_tween().tween_property(self,"modulate:a",0,0.8)
	await get_tree().create_timer(1.5,false).timeout
	queue_free()
	pass
