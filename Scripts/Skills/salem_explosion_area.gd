extends SkillConditionArea2D

var dead_explosion_level: int
var passive_level: int


func _ready() -> void:
	var damage_low: int = HeroSkillLibrary.hero_skill_data_library[7][4].damage_low[skill_level-1]
	var damage_high: int = HeroSkillLibrary.hero_skill_data_library[7][4].damage_high[skill_level-1]
	var explosion_effect: AnimatedSprite2D = preload("res://Scenes/Effects/bullet_explosion_effect.tscn").instantiate()
	explosion_effect.position = position
	explosion_effect.modulate = Color.DARK_GREEN
	explosion_effect.scale *= 1.5
	Stage.instance.bullets.add_child(explosion_effect)
	var smoke_effect: AnimatedSprite2D = preload("res://Scenes/Effects/smoke_effect.tscn").instantiate()
	smoke_effect.position = position
	smoke_effect.modulate = Color.GREEN
	smoke_effect.scale *= 2
	Stage.instance.bullets.add_child(smoke_effect)
	AudioManager.instance.play_explosion_audio()
	await get_tree().physics_frame
	await get_tree().physics_frame
	for body in get_overlapping_bodies():
		var enemy: Enemy = body.owner
		var damage: int = randi_range(damage_low,damage_high)
		enemy.take_damage(damage,DataProcess.DamageType.MagicDamage,0,false,null,false,true,)
		for i in 3:
			var plugin_buff: DotBuff = preload("res://Scenes/Buffs/Salem/salem_plugin_buff.tscn").instantiate()
			plugin_buff.dead_explosion_level = dead_explosion_level
			plugin_buff.passive_level = passive_level
			enemy.buffs.add_child(plugin_buff)
	
	await get_tree().create_timer(1,false).timeout
	queue_free()
	pass
