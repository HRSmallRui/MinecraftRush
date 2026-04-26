extends SkillConditionArea2D

@export var skill_damage_list: Array[int]
@export var slow_buff_scene: PackedScene
@export var armor_broken_buff_scene: PackedScene
@export var second_damage_list: Array[int]
@export var dizness_buff_scene: PackedScene
@export var dizness_duration: float
@export var extra_damage_per_layer_list: Array[int]
@export var explosion_effect_scene: PackedScene
@export var smoke_scene: PackedScene

@onready var animation_player: AnimationPlayer = $AnimationPlayer


func cause_damage():
	var damage: int = skill_damage_list[skill_level]
	for body in get_overlapping_bodies():
		var enemy: Enemy = body.owner
		enemy.take_damage(damage,DataProcess.DamageType.TrueDamage,0,false,null)
		var broken_buff: PropertyBuff = armor_broken_buff_scene.instantiate()
		enemy.buffs.add_child(broken_buff)
		var slow_buff: PropertyBuff = slow_buff_scene.instantiate()
		enemy.buffs.add_child(slow_buff)
	await get_tree().create_timer(1.2,false).timeout
	second_cause_damage()
	pass


func second_cause_damage():
	scale *= 1.2
	await get_tree().physics_frame
	await get_tree().physics_frame
	animation_player.play("second")
	AudioManager.instance.play_explosion_audio()
	var explosion_effect: AnimatedSprite2D = explosion_effect_scene.instantiate()
	var smoke_effect: AnimatedSprite2D = smoke_scene.instantiate()
	explosion_effect.position = position
	smoke_effect.position = position
	explosion_effect.scale *= 1.4
	smoke_effect.scale *= 1.4
	Stage.instance.bullets.add_child(smoke_effect)
	Stage.instance.bullets.add_child(explosion_effect)
	for i in 10:
		summon_explosion_effect()
	
	for body in get_overlapping_bodies():
		var enemy: Enemy = body.owner
		enemy_second_take_damage(enemy,second_damage_list[skill_level],extra_damage_per_layer_list[skill_level])
	pass


func enemy_second_take_damage(enemy: Enemy, based_damage:int, extra_damage_per_layer: int):
	var extra_layer: int
	for buff: BuffClass in enemy.buffs.get_children():
		if buff.buff_type == BuffClass.BuffType.Buff: buff.remove_buff()
		elif !"SteveSkill" in buff.buff_tag and extra_layer <= 5: extra_layer += 1
	var damage: int = based_damage + extra_damage_per_layer * extra_layer
	enemy.take_damage(damage,DataProcess.DamageType.ExplodeDamage,0,false,null,true,true)
	var dizness_buff: DiznessBuff = dizness_buff_scene.instantiate()
	dizness_buff.duration = dizness_duration
	enemy.buffs.add_child(dizness_buff)
	pass


func summon_explosion_effect():
	var explosion_effect: AnimatedSprite2D = explosion_effect_scene.instantiate()
	var smoke_effect: AnimatedSprite2D = smoke_scene.instantiate()
	explosion_effect.position = position + Vector2(randf_range(-1,1),randf_range(-1,1)).normalized() * randf_range(40,100)
	smoke_effect.position = explosion_effect.position
	Stage.instance.bullets.add_child(explosion_effect)
	Stage.instance.bullets.add_child(smoke_effect)
	pass
