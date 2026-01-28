extends SkillConditionArea2D

@onready var earth_effect: Sprite2D = $EarthEffect


func _ready() -> void:
	earth_effect.modulate.a = 0
	earth_animation()
	var damage: int = HeroSkillLibrary.hero_skill_data_library[9][5].earth_damage
	await get_tree().physics_frame
	await get_tree().physics_frame
	for body in get_overlapping_bodies():
		var enemy: Enemy = body.owner
		enemy.take_damage(damage,DataProcess.DamageType.ExplodeDamage,0,false,null,true,true,)
		var dizness_buff: DiznessBuff = preload("res://Scenes/Buffs/dizness_buff.tscn").instantiate()
		dizness_buff.immune_groups = dizness_buff.immune_groups.duplicate()
		dizness_buff.immune_groups.erase("super_unit")
		dizness_buff.buff_tag = "mike_dizness"
		dizness_buff.duration = 2
		enemy.buffs.add_child(dizness_buff)
	await get_tree().create_timer(2,false).timeout
	var disappear_tween: Tween = create_tween()
	disappear_tween.tween_property(earth_effect,"modulate:a",0,1)
	await disappear_tween.finished
	queue_free()
	pass


func earth_animation():
	create_tween().tween_property(earth_effect,"modulate:a",1,0.5)
	for i in 3:
		var block_effect: AnimatedSprite2D = preload("res://Scenes/Effects/block_particle.tscn").instantiate()
		block_effect.modulate = Color.SADDLE_BROWN
		block_effect.position = position
		block_effect.position += Vector2(randf_range(-120,120),randf_range(-80,80))
		block_effect.scale *= 2
		Stage.instance.bullets.add_child(block_effect)
		Stage.instance.stage_camera.shake(15)
		AudioManager.instance.play_explosion_audio()
		await get_tree().create_timer(randf_range(0.1,0.2),false).timeout
	pass
