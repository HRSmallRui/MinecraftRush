extends GPUParticles2D


func _process(delta: float) -> void:
	speed_scale = 0 if get_tree().paused else 1
	pass
