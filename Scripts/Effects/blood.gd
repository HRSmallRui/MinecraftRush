extends Sprite2D


func _ready() -> void:
	await get_tree().create_timer(5,false).timeout
	create_tween().tween_property(self,"modulate:a",0,0.5)
	await get_tree().create_timer(2,false).timeout
	queue_free()
	pass
