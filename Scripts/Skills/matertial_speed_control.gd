extends Node2D


func _process(delta: float) -> void:
	if get_tree().paused:
		$AnimationPlayer.play("0")
	else:
		$AnimationPlayer.play("1")
	pass
