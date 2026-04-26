extends CanvasLayer

@onready var ghost_0: Sprite2D = $Ghost0


func _on_free_timer_timeout() -> void:
	var disappear_tween: Tween = create_tween()
	disappear_tween.tween_property(ghost_0,"modulate:a",0,0.6)
	await disappear_tween.finished
	queue_free()
	pass # Replace with function body.
