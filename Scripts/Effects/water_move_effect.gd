extends Sprite2D


func _ready() -> void:
	var disappear_tween: Tween = create_tween()
	disappear_tween.tween_property(self,"scale",Vector2.ZERO,1)
	await disappear_tween.finished
	queue_free()
	pass
