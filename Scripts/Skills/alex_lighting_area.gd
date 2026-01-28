extends SkillConditionArea2D


func _ready() -> void:
	var lighting_effect: Line2D = preload("res://Scenes/Effects/lightning.tscn").instantiate()
	lighting_effect.position = position
	Stage.instance.bullets.add_child(lighting_effect)
	var explosion_effect: AnimatedSprite2D = preload("res://Scenes/Effects/bullet_explosion_effect.tscn").instantiate()
	explosion_effect.position = position
	Stage.instance.bullets.add_child(explosion_effect)
	AudioManager.instance.play_explosion_audio()
	
	await get_tree().physics_frame
	await get_tree().physics_frame
	var damage: int
	damage = HeroSkillLibrary.hero_skill_data_library[2][1].lightning_damage[skill_level-1]
	for body in get_overlapping_bodies():
		var enemy: Enemy = body.owner
		var dizness_debuff: PropertyBuff = preload("res://Scenes/Buffs/Alex/alex_dizness_debuff.tscn").instantiate()
		dizness_debuff.unit = enemy
		enemy.buffs.add_child(dizness_debuff)
		if "creeper" in enemy.get_groups():
			enemy.enemy_buff_tags["lightning"] = 1
			enemy.remove_from_group("creeper")
			enemy.add_new_buff_tag("lightning")
			var lightning_buff: PropertyBuff = preload("res://Scenes/Buffs/lightning_sheild.tscn").instantiate()
			lightning_buff.unit = enemy
			enemy.buffs.add_child(lightning_buff)
			continue
		enemy.take_damage(damage,DataProcess.DamageType.TrueDamage,0,true)
	
	queue_free()
	pass
