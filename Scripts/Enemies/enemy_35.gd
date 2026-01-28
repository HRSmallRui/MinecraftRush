extends Enemy

@export var horn_audio_list: Array[AudioStream]

@onready var horn_audio: AudioStreamPlayer = $HornAudio
@onready var enemy_encourage_area: Area2D = $UnitBody/EnemyEncourageArea
@onready var horn_timer: Timer = $HornTimer


func anim_offset():
	match enemy_sprite.animation:
		"attack","idle":
			enemy_sprite.position = Vector2(-5,-150) if enemy_sprite.flip_h else Vector2(10,-150)
		"die":
			enemy_sprite.position = Vector2(150,-150) if enemy_sprite.flip_h else Vector2(-150,-150)
		"far_attack":
			enemy_sprite.position = Vector2(5,-150) if enemy_sprite.flip_h else Vector2(-5,-150)
		"horn":
			enemy_sprite.position = Vector2(-15,-150) if enemy_sprite.flip_h else Vector2(15,-150)
		"move_back":
			enemy_sprite.position = Vector2(-5,-165) if enemy_sprite.flip_h else Vector2(5,-165)
		"move_front":
			enemy_sprite.position = Vector2(15,-160) if enemy_sprite.flip_h else Vector2(-15,-160)
		"move_normal":
			enemy_sprite.position = Vector2(0,-160)
	pass


func frame_changed():
	if enemy_sprite.animation == "attack" and enemy_sprite.frame == 14:
		cause_damage()
	if enemy_sprite.animation == "far_attack" and enemy_sprite.frame == 20:
		var summon_pos: Vector2 = far_attack_marker_flip.global_position if enemy_sprite.flip_h else far_attack_marker.global_position
		var damage: int = randi_range(current_data.far_damage_low,current_data.far_damage_high)
		var bullet: Bullet = summon_bullet(far_attack_bullet_scene,summon_pos,far_attack_position,damage,DataProcess.DamageType.PhysicsDamage)
		bullet.bullet_speed = 1500
		Stage.instance.bullets.add_child(bullet)
		AudioManager.instance.shoot_audio_2.play()
	if enemy_sprite.animation == "horn":
		if enemy_sprite.frame >= 8 and enemy_sprite.frame <= 30:
			encourage()
		if enemy_sprite.frame == 40:
			update_state()
			if current_intercepting_units.size() > 0:
				translate_to_new_state(EnemyState.BATTLE)
		if enemy_sprite.frame == 8:
			horn_audio.stream = horn_audio_list.pick_random()
			horn_audio.play()
	pass


func move_process(delta: float):
	if far_attack_area.has_overlapping_bodies():
		translate_to_new_state(EnemyState.SPECIAL)
		enemy_sprite.play("idle")
		return
	if horn_can_release() and horn_timer.is_stopped():
		translate_to_new_state(EnemyState.SPECIAL)
		enemy_sprite.play("horn")
		horn_timer.start()
		return
	super(delta)
	pass


func special_process():
	if enemy_sprite.animation == "idle" and far_attack_area.get_overlapping_bodies().size() == 0:
		translate_to_new_state(EnemyState.MOVE)
		return
	if current_intercepting_units.size() > 0:
		translate_to_new_state(EnemyState.BATTLE)
	elif far_attack_area.get_overlapping_bodies().size() > 0 and far_attack_timer.is_stopped():
		var ally: Ally = far_attack_area.get_overlapping_bodies()[0].owner
		far_attack_position = ally.hurt_box.global_position
		far_attack_timer.start()
		enemy_sprite.play("far_attack")
		enemy_sprite.flip_h = far_attack_position.x < position.x
	pass


func horn_can_release() -> bool:
	for body in enemy_encourage_area.get_overlapping_bodies():
		var enemy: Enemy = body.owner
		if enemy == self: continue
		if enemy.get_groups().has("illager") and enemy.enemy_type < EnemyType.Big: return true
		
	return false
	pass


func encourage():
	for body in enemy_encourage_area.get_overlapping_bodies():
		var enemy: Enemy = body.owner
		if enemy == self: continue
		if !enemy.get_groups().has("illager"): continue
		if enemy.enemy_type >= EnemyType.Big: continue
		var courage_buff: PropertyBuff = preload("res://Scenes/Buffs/Enemies/encourage_buff.tscn").instantiate()
		enemy.buffs.add_child(courage_buff)
	pass


func battle():
	if enemy_sprite.animation == "idle" and horn_timer.is_stopped() and horn_can_release():
		enemy_sprite.play("horn")
		horn_timer.start()
		return
	super()
	pass
