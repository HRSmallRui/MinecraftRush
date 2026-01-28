extends SkillConditionArea2D

@onready var mike_water_effect: Sprite2D = $MikeWaterEffect


func _ready() -> void:
	water_animation()
	var damage: int = HeroSkillLibrary.hero_skill_data_library[9][5].water_damage[skill_level]
	var during_time: float = HeroSkillLibrary.hero_skill_data_library[9][5].water_buff_duration[skill_level]
	var damage_low: int = HeroSkillLibrary.hero_skill_data_library[9][5].damage_low[skill_level]
	var damage_high: int = HeroSkillLibrary.hero_skill_data_library[9][5].damage_high[skill_level]
	mike_water_effect.modulate.a = 0
	var appear_tween: Tween = create_tween()
	appear_tween.tween_property(mike_water_effect,"modulate:a",0.5,0.3)
	await appear_tween.finished
	for body in get_overlapping_bodies():
		var enemy: Enemy = body.owner
		enemy.take_damage(damage,DataProcess.DamageType.SuperDamage,0,)
		if enemy.enemy_type < Enemy.EnemyType.MiniBoss:
			enemy.start_data.near_damage_low = mini(enemy.start_data.near_damage_low,damage_low)
			enemy.start_data.near_damage_high = mini(enemy.start_data.near_damage_high,damage_high)
			enemy.current_data.update_near_damage()
		var broken_buff: PropertyBuff = preload("res://Scenes/Buffs/Mike/mike_water_broken_buff.tscn").instantiate()
		broken_buff.duration = during_time
		enemy.buffs.add_child(broken_buff)
		enemy.silence_layers += 1
	await get_tree().create_timer(0.5,false).timeout
	create_tween().tween_property(mike_water_effect,"modulate:a",0,1)
	await get_tree().create_timer(2,false).timeout
	queue_free()
	pass


func water_animation():
	for i in 10:
		var water_block: AnimatedSprite2D = preload("res://Scenes/Effects/block_particle.tscn").instantiate()
		water_block.position = position
		water_block.modulate = Color.ROYAL_BLUE
		water_block.position += Vector2(randf_range(-120,120),randf_range(-80,80))
		Stage.instance.bullets.add_child(water_block)
		water_block.scale *= 2
		AudioManager.instance.play_water_audio()
		await get_tree().create_timer(randf_range(0.1,0.2),false).timeout
	pass
