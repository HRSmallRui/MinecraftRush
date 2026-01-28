extends Area2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D


func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event.is_action_pressed("click"):
		collision_shape_2d.disabled = true
		if animated_sprite_2d.frame < 2:
			animated_sprite_2d.play()
		else:
			animated_sprite_2d.play_backwards()
		AudioManager.instance.play_water_audio()
		await animated_sprite_2d.animation_finished
		Achievement.achieve_complete("INSIDE")
		collision_shape_2d.disabled = false
	pass # Replace with function body.
