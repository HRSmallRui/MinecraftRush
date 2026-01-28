extends Enemy


func anim_offset():
	match enemy_sprite.animation:
		"attack","idle":
			enemy_sprite.position = Vector2(5,-90) if enemy_sprite.flip_h else Vector2(-5,-90)
		"die":
			enemy_sprite.position = Vector2(85,-90) if enemy_sprite.flip_h else Vector2(-85,-90)
		"far_attack":
			enemy_sprite.position = Vector2(5,-90) if enemy_sprite.flip_h else Vector2(-5,-90)
		"move_back":
			enemy_sprite.position = Vector2(-5,-95) if enemy_sprite.flip_h else Vector2(5,-95)
		"move_front":
			enemy_sprite.position = Vector2(15,-95) if enemy_sprite.flip_h else Vector2(-15,-95)
		"move_normal":
			enemy_sprite.position = Vector2(0,-95)
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
	pass


func move_process(delta: float):
	if far_attack_area.has_overlapping_bodies():
		translate_to_new_state(EnemyState.SPECIAL)
		enemy_sprite.play("idle")
		#print(far_attack_timer.time_left)
		return
	super(delta)
	pass


func special_process():
	#print(far_attack_timer.time_left)
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
