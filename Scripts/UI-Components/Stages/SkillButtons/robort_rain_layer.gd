extends CanvasLayer

@onready var rain_animation_player: AnimationPlayer = $RainAnimationPlayer


func _process(delta: float) -> void:
	if get_tree().paused:
		if rain_animation_player.current_animation != "pause":
			rain_animation_player.play("pause")
	else:
		if rain_animation_player.current_animation != "no_pause":
			rain_animation_player.play("no_pause")
	pass
