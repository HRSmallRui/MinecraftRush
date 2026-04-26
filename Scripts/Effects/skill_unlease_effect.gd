extends Sprite2D


func _ready() -> void:
	create_tween().tween_property(self,"modulate:a",0,0.6)
	create_tween().tween_property(self,"position",position + Vector2(0,-30),0.6)
	await $Timer.timeout
	queue_free()
	pass
