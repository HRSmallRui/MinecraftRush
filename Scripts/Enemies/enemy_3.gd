extends Enemy

@onready var appear_audio: AudioStreamPlayer = $AppearAudio


func anim_offset():
	match enemy_sprite.animation:
		"idle":
			enemy_sprite.position = Vector2(-15,-90) if enemy_sprite.flip_h else Vector2(10,-90)
		"move_back":
			enemy_sprite.position = Vector2(-5,-105) if enemy_sprite.flip_h else Vector2(5,-105)
		"move_front":
			enemy_sprite.position = Vector2(0,-95)
		"move_normal":
			enemy_sprite.position = Vector2(-10,-100) if enemy_sprite.flip_h else Vector2(5,-100)
	
	
	pass


func _ready() -> void:
	super()
	var audio_id: int = randi_range(1,3)
	var entry_label: String = "chicken" + str(audio_id)
	if entry_label in AudioManager.instance.registor_enemy_entry_audio_list:
		if randf_range(0,1) < 0.2:
			entry_audio_play(audio_id)
	else:
		entry_audio_play(audio_id)
		AudioManager.instance.entry_audio_registor(entry_label)
	pass


func entry_audio_play(audio_id: int):
	var stream: AudioStream
	match audio_id:
		1: stream = load("res://Assets/Sounds/FXs/Enemies/鸡骑士/鸡叫1.wav")
		2: stream = load("res://Assets/Sounds/FXs/Enemies/鸡骑士/鸡叫2.wav")
		3: stream = load("res://Assets/Sounds/FXs/Enemies/鸡骑士/鸡叫3.wav")
	appear_audio.stream = stream
	appear_audio.play()
	pass


func die(explosion: bool = false):
	enemy_button.hide()
	clear_buff()
	delay_free()
	translate_to_new_state(EnemyState.DIE)
	Stage.instance.current_money += bounty
	Stage.instance.enemy_die()
	current_data.unit_move_speed = 0
	if explosion:
		hide()
		var dead_explosion = preload("res://Scenes/Effects/dead_body_explosion.tscn").instantiate() as AnimatedSprite2D
		dead_explosion.position = position
		if AudioManager.instance.dead_body_explosion_audio.playing:
			if randf_range(0,1) < 0.5:
				AudioManager.instance.dead_body_explosion_audio.play()
		else: AudioManager.instance.dead_body_explosion_audio.play()
		get_parent().add_child(dead_explosion)
	else:
		var new_enemy: Enemy = preload("res://Scenes/Enemies/enemy_2.tscn").instantiate()
		new_enemy.progress = progress
		hide()
		die_audio_play()
		get_parent().add_child(new_enemy)
		var smoke_effect: AnimatedSprite2D = preload("res://Scenes/Effects/bullet_explosion_effect.tscn").instantiate()
		smoke_effect.position = position
		smoke_effect.scale *= 0.6
		Stage.instance.bullets.add_child(smoke_effect)
	pass
