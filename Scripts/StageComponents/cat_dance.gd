extends AnimatedSprite2D

@onready var collision_shape_2d: CollisionShape2D = $ClickArea/CollisionShape2D
@onready var dancing_music: AudioStreamPlayer = $DancingMusic


func _on_click_area_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event.is_action_pressed("click"):
		dancing_music.play()
		collision_shape_2d.disabled = true
		play()
		Achievement.achieve_complete("DancingCat")
		Stage.instance.preparation_music.process_mode = Node.PROCESS_MODE_DISABLED
		Stage.instance.battle_music.process_mode = Node.PROCESS_MODE_DISABLED
		await dancing_music.finished
		Stage.instance.preparation_music.process_mode = Node.PROCESS_MODE_INHERIT
		Stage.instance.battle_music.process_mode = Node.PROCESS_MODE_INHERIT
	pass # Replace with function body.
