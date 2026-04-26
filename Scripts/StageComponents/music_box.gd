extends Area2D

@onready var music: AudioStreamPlayer = $Music
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var lingering_potion_shooter: LingeringPotionShooter = $LingeringPotionShooter


func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event.is_action_pressed("click"):
		music.play()
		collision_shape_2d.disabled = true
		#Stage.instance.preparation_music.process_mode = Node.PROCESS_MODE_DISABLED
		#Stage.instance.battle_music.process_mode = Node.PROCESS_MODE_DISABLED
		#pause_wave()
		lingering_potion_shooter.process_mode = Node.PROCESS_MODE_INHERIT
		await music.finished
		#continue_wave()
		#Stage.instance.preparation_music.process_mode = Node.PROCESS_MODE_ALWAYS
		#Stage.instance.battle_music.process_mode = Node.PROCESS_MODE_ALWAYS
		Achievement.achieve_complete("GAIA1")
	pass # Replace with function body.


func pause_wave():
	for enemy_path: EnemyPath in Stage.instance.enemies.get_children():
		enemy_path.process_mode = Node.PROCESS_MODE_DISABLED
	Stage.instance.wave_during_timer.paused = true
	Stage.instance.wave_next_timer.paused = true
	pass


func continue_wave():
	for enemy_path: EnemyPath in Stage.instance.enemies.get_children():
		enemy_path.process_mode = Node.PROCESS_MODE_INHERIT
	Stage.instance.wave_during_timer.paused = false
	Stage.instance.wave_next_timer.paused = false
	pass
