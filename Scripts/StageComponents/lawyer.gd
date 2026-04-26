extends Area2D

@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var objection_sprite: Sprite2D = $ObjectionSprite
@onready var objection_audio: AudioStreamPlayer = $ObjectionAudio


func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event.is_action_pressed("click"):
		collision_shape_2d.disabled = true
		objection_sprite.show()
		objection_audio.play()
		await get_tree().create_timer(2,false).timeout
		objection_sprite.hide()
		Achievement.achieve_complete("GyakutenSaiban")
	pass # Replace with function body.


func _process(delta: float) -> void:
	objection_sprite.offset = Vector2(randf_range(-20,20),randf_range(-20,20))
	pass
