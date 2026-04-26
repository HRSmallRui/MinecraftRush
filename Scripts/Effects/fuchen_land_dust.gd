extends Sprite2D


func _ready() -> void:
	await get_tree().create_timer(1,false).timeout
	var disappear_tween: Tween = create_tween()
	disappear_tween.tween_property(self,"modulate:a",0,2)
	await disappear_tween.finished
	queue_free()
	pass
