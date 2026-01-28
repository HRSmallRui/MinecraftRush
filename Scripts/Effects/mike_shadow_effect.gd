extends AnimatedSprite2D


func _ready() -> void:
	var disappear_tween: Tween = create_tween()
	disappear_tween.tween_property(self,"modulate:a",0,0.4)
	await disappear_tween.finished
	queue_free()
	pass
