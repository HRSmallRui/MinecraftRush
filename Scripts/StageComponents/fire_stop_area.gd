extends Area2D


func _on_mouse_entered() -> void:
	Stage.instance.mouse_in_fire_stop_area = true
	pass # Replace with function body.


func _on_mouse_exited() -> void:
	Stage.instance.mouse_in_fire_stop_area = false
	pass # Replace with function body.
