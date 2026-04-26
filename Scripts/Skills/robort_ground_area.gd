extends SkillConditionArea2D


func _ready() -> void:
	var damage_low: int = HeroSkillLibrary.hero_skill_data_library[4][3].damage_low[skill_level-1]
	var damage_high: int = HeroSkillLibrary.hero_skill_data_library[4][3].damage_high[skill_level-1]
	var dizness_time: float = HeroSkillLibrary.hero_skill_data_library[4][3].dizness_time[skill_level-1]
	
	var block_particle: AnimatedSprite2D = preload("res://Scenes/Effects/block_particle.tscn").instantiate()
	block_particle.position = position
	block_particle.modulate = Color(0.27,0.1,0,1)
	Stage.instance.add_child(block_particle)
	await get_tree().physics_frame
	await get_tree().physics_frame
	for body in get_overlapping_bodies():
		var enemy: Enemy = body.owner
		
		var dizness_buff: BuffClass = preload("res://Scenes/Buffs/dizness_buff.tscn").instantiate()
		dizness_buff.duration = dizness_time
		enemy.buffs.add_child(dizness_buff)
		var damage: int = randi_range(damage_low,damage_high)
		enemy.take_damage(damage,DataProcess.DamageType.ExplodeDamage,0,false,null,true,true,)
	pass
