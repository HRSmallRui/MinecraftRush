extends Sprite2D

@onready var collision_shape_2d: CollisionShape2D = $ClickArea/CollisionShape2D
@onready var fire: AnimatedSprite2D = $Fire
@onready var fire_audio: AudioStreamPlayer = $FireAudio


func _on_click_area_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event.is_action_pressed("click"):
		collision_shape_2d.disabled = true
		fire_audio.play()
		await get_tree().create_timer(0.8,false).timeout
		fire.show()
		Achievement.achieve_complete("TheForest")
	pass # Replace with function body.
