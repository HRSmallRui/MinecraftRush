extends SkillConditionArea2D


@onready var wind_hit_particle: GPUParticles2D = $WindHitParticle
@onready var attack_audio: AudioStreamPlayer = $AttackAudio
@onready var finish_audio: AudioStreamPlayer = $FinishAudio


func _ready() -> void:
	wind_animation()
	await get_tree().physics_frame
	await get_tree().physics_frame
	var damage: int = HeroSkillLibrary.hero_skill_data_library[9][5].wind_damage[skill_level]
	var slow_duration :float = HeroSkillLibrary.hero_skill_data_library[9][5].slow_duration[skill_level]
	for i in 10:
		attack_audio.play()
		for body in get_overlapping_bodies():
			var enemy:Enemy = body.owner
			enemy.take_damage(damage,DataProcess.DamageType.TrueDamage,0,false,null,false,true)
			if enemy.enemy_type >= Enemy.EnemyType.MiniBoss: continue
			var slow_buff: PropertyBuff = preload("res://Scenes/Buffs/Mike/mike_wind_slow_buff.tscn").instantiate()
			slow_buff.duration = slow_duration
			enemy.buffs.add_child(slow_buff)
			enemy.start_data.armor = 0
			enemy.current_data.update_armor()
		await get_tree().create_timer(0.05,false).timeout
	
	await get_tree().create_timer(2,false).timeout
	finish_audio.play()
	create_tween().tween_property(self,"modulate:a",0,0.2)
	var explosion_effect: AnimatedSprite2D = preload("res://Scenes/Effects/mike_wind_explosion_effect.tscn").instantiate()
	explosion_effect.position = position
	explosion_effect.scale *= 4
	var bom_effect: AnimatedSprite2D = preload("res://Scenes/Effects/bullet_explosion_effect.tscn").instantiate()
	bom_effect.scale *= 2
	bom_effect.position = position
	bom_effect.modulate = Color.GREEN
	Stage.instance.bullets.add_child(bom_effect)
	Stage.instance.bullets.add_child(explosion_effect)
	for i in 20:
		var block_effect: AnimatedSprite2D = preload("res://Scenes/Effects/block_particle.tscn").instantiate()
		block_effect.position = position + Vector2(randf_range(-150,150),randf_range(-120,120))
		block_effect.modulate = Color.GREEN
		Stage.instance.bullets.add_child(block_effect)
	
	await get_tree().create_timer(2,false).timeout
	queue_free()
	pass


func wind_animation():
	wind_hit_particle.emitting = true
	await get_tree().create_timer(0.5,false).timeout
	wind_hit_particle.emitting = false
	pass
