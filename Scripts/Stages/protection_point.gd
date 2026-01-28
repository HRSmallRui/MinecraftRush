extends Sprite2D

func _ready() -> void:
	modulate.a = 0
	create_tween().tween_property(self,"modulate:a",1,0.6)
	await get_tree().create_timer(1,false).timeout
	create_tween().tween_property(self,"modulate",Color(0,0,0,0.2),2)
	pass
