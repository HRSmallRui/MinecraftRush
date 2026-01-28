extends Enemy

@onready var skeleton_explosion_audio: AudioStreamPlayer = $SkeletonExplosionAudio


func anim_offset():
	match enemy_sprite.animation:
		"idle","attack":
			enemy_sprite.position = Vector2(10,-115) if enemy_sprite.flip_h else Vector2(-10,-115)
		"die":
			enemy_sprite.position = Vector2(-50,-90) if enemy_sprite.flip_h else Vector2(50,-90)
		"far_attack":
			enemy_sprite.position = Vector2(20,-100) if enemy_sprite.flip_h else Vector2(-25,-100)
		"move_back":
			enemy_sprite.position = Vector2(0,-85)
		"move_front":
			enemy_sprite.position = Vector2(5,-80) if enemy_sprite.flip_h else Vector2(-5,-80)
		"move_normal":
			enemy_sprite.position = Vector2(0,-90) if enemy_sprite.flip_h else Vector2(-5,-90)
	pass


func frame_changed():
	if enemy_sprite.animation == "attack" and enemy_sprite.frame == 11:
		cause_damage()
	if enemy_sprite.animation == "far_attack" and enemy_sprite.frame == 16:
		var summon_pos: Vector2 = far_attack_marker_flip.global_position if enemy_sprite.flip_h else far_attack_marker.global_position
		var damage: int = randi_range(current_data.far_damage_low,current_data.far_damage_high)
		var bullet: Bullet = summon_bullet(far_attack_bullet_scene,summon_pos,far_attack_position,damage,DataProcess.DamageType.PhysicsDamage)
		bullet.damage_type = DataProcess.DamageType.TrueDamage
		Stage.instance.bullets.add_child(bullet)
		AudioManager.instance.shoot_audio_1.play()
	pass


func move_process(delta: float):
	if far_attack_area.get_overlapping_bodies().size() > 0 and far_attack_timer.is_stopped():
		translate_to_new_state(EnemyState.SPECIAL)
		enemy_sprite.play("idle")
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


func die_blood(blood_packed_scene: PackedScene = null):
	
	pass


func die_explosion_process():
	var effect: AnimatedSprite2D = preload("res://Scenes/Effects/skeleton_dead_body_explosion.tscn").instantiate()
	effect.position = position
	skeleton_explosion_audio.play()
	get_parent().add_child(effect)
	pass
