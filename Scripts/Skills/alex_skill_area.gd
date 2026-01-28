extends SkillConditionArea2D

var loop_count: int
var fork_list: Array[Sprite2D]
@onready var explosion_timer: Timer = $ExplosionTimer
@onready var explosion_area: Area2D = $ExplosionArea


func _ready() -> void:
	loop_count = HeroSkillLibrary.hero_skill_data_library[2][5].count[skill_level]
	var explosion_damage: int = HeroSkillLibrary.hero_skill_data_library[2][5].explosion_damage[skill_level]
	var fork_scene: PackedScene = preload("res://Scenes/Skills/fork_sprite.tscn")
	for i in loop_count:
		var fork: Sprite2D = fork_scene.instantiate()
		add_child(fork)
		fork.position = Vector2(randf_range(-70,70),randf_range(-150,-140))
		var target_pos: Vector2 = Vector2(randf_range(-40,40),randf_range(-30,30))
		fork.look_at(target_pos + global_position)
		fork_list.append(fork)
		var fork_tween: Tween = create_tween()
		fork_tween.tween_property(fork,"position",target_pos,0.1)
		AudioManager.instance.play_fork_throw_audio()
		await fork_tween.finished
		for body in get_overlapping_bodies():
			var enemy: Enemy = body.owner
			enemy.take_damage(80,DataProcess.DamageType.PhysicsDamage,0)
	explosion_timer.start()
	await explosion_timer.timeout
	AudioManager.instance.play_explosion_audio()
	var explosion_effect: AnimatedSprite2D = preload("res://Scenes/Effects/bullet_explosion_effect.tscn").instantiate()
	explosion_effect.position = position
	explosion_effect.z_index += 1
	Stage.instance.bullets.add_child(explosion_effect)
	for body in explosion_area.get_overlapping_bodies():
		var enemy: Enemy = body.owner
		var dizness_buff: PropertyBuff = preload("res://Scenes/Buffs/Alex/alex_dizness_debuff.tscn").instantiate()
		dizness_buff.buff_tag = "AlexSkill5Dizness"
		dizness_buff.unit = enemy
		enemy.buffs.add_child(dizness_buff)
		enemy.take_damage(explosion_damage,DataProcess.DamageType.ExplodeDamage,0,false,null,true)
	for fork in fork_list:
		create_tween().tween_property(fork,"modulate:a",0,0.4)
	await get_tree().create_timer(0.4,false).timeout
	queue_free()
	pass


func _on_speed_low_area_body_entered(body: Node2D) -> void:
	var enemy: Enemy = body.owner
	var speed_low_buff: PropertyBuff = preload("res://Scenes/Buffs/Alex/alex_skill_4_speed_low.tscn").instantiate()
	speed_low_buff.buff_tag = "AlexSkill5SpeedLow"
	speed_low_buff.duration = 2
	speed_low_buff.unit = enemy
	enemy.buffs.add_child(speed_low_buff)
	pass # Replace with function body.
