extends ShooterBullet


@onready var condition_area: Area2D = $ConditionArea
@onready var explosion_hit_area: Area2D = $ExplosionHitArea


func enemy_take_damage(enemy: Enemy):
	super(enemy)
	for hurt_box in condition_area.get_overlapping_areas():
		var new_enemy = hurt_box.owner
		if new_enemy == enemy: continue
		var stone_bullet: Bullet = preload("res://Scenes/Bullets/physics_stone.tscn").instantiate()
		stone_bullet.position = position
		stone_bullet.erase_enemy_list.append(enemy)
		stone_bullet.damage = damage * 2/3
		var target_pos:Vector2 = hurt_box.global_position
		target_pos += new_enemy.direction * new_enemy.current_data.unit_move_speed * 2
		stone_bullet.target_position = target_pos
		if bullet_special_tag_levels.has("stone_explosion"):
			stone_bullet.bullet_special_tag_levels["stone_explosion"] = bullet_special_tag_levels["stone_explosion"]
		Stage.instance.bullets.add_child(stone_bullet)
		return
	if bullet_special_tag_levels.has("stone_explosion"):
		var explosion_stone_effect: AnimatedSprite2D = preload("res://Scenes/Effects/explosion_stone_effect.tscn").instantiate()
		explosion_stone_effect.position = position
		Stage.instance.bullets.add_child(explosion_stone_effect)
		AudioManager.instance.stone_explosion_audio.play()
		var damage_low: int
		var damage_high: int
		match bullet_special_tag_levels["stone_explosion"]:
			1:
				damage_low = 10
				damage_high = 15
			2:
				damage_low = 15
				damage_high = 24
		for box in explosion_hit_area.get_overlapping_areas():
			var new_enemy: Enemy = box.owner
			new_enemy.take_damage(randi_range(damage_low,damage_high),DataProcess.DamageType.PhysicsDamage,0,false,source,explosion,true)
	
	pass
