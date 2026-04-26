extends SkillConditionArea2D


func _ready() -> void:
	var lighting_effect: Line2D = preload("res://Scenes/Effects/lightning.tscn").instantiate()
	lighting_effect.position = position
	if randf_range(0,1) < 0.5:
		lighting_effect.scale.x = -1
	Stage.instance.bullets.add_child(lighting_effect)
	var explosion_effect: AnimatedSprite2D = preload("res://Scenes/Effects/bullet_explosion_effect.tscn").instantiate()
	explosion_effect.position = position
	Stage.instance.bullets.add_child(explosion_effect)
	AudioManager.instance.play_explosion_audio()
	
	await get_tree().physics_frame
	await get_tree().physics_frame
	var damage_low: int = HeroSkillLibrary.hero_skill_data_library[4][5].damage_low
	var damage_high: int = HeroSkillLibrary.hero_skill_data_library[4][5].damage_high
	for body in get_overlapping_bodies():
		var enemy: Enemy = body.owner
		if "creeper" in enemy.get_groups():
			enemy.enemy_buff_tags["lightning"] = 1
			enemy.remove_from_group("creeper")
			enemy.add_new_buff_tag("lightning")
			var lightning_buff: PropertyBuff = preload("res://Scenes/Buffs/lightning_sheild.tscn").instantiate()
			lightning_buff.unit = enemy
			enemy.buffs.add_child(lightning_buff)
			continue
		var damage: int = randi_range(damage_low,damage_high)
		enemy.take_damage(damage,DataProcess.DamageType.TrueDamage,0,true)
	
	queue_free()
	pass
