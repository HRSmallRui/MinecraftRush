extends BuffClass

@export var explosion_damage_list: Array[DamageBlock]
@export var another_damage_list: Array[int]

@onready var bullet: Sprite2D = $Bullet
@onready var bombard_area: Area2D = $BombardArea

var enemy: Enemy
var has_shot: bool = false


func buff_start():
	enemy = unit
	pass


func _buff_process(delta: float):
	bullet.rotation = enemy.direction_sprite.global_rotation
	bullet.global_position = enemy.hurt_box.global_position
	pass


func remove_buff():
	if has_shot: return
	
	if enemy.enemy_state != Enemy.EnemyState.DIE:
		if enemy.enemy_type >= Enemy.EnemyType.Super:
			enemy.take_damage(another_damage_list[buff_level-1],DataProcess.DamageType.ExplodeDamage,0,false,null,true,true,)
		else:
			enemy.sec_kill(true)
	
	TextEffect.text_effect_show("轰！！",TextEffect.TextEffectType.SecKill,bullet.global_position)
	has_shot = true
	AudioManager.instance.play_explosion_audio()
	var explosion_effect: AnimatedSprite2D = preload("res://Scenes/Effects/bullet_explosion_effect.tscn").instantiate()
	explosion_effect.position = global_position
	explosion_effect.scale *= 2
	Stage.instance.bullets.add_child(explosion_effect)
	var smoke_effect: AnimatedSprite2D = preload("res://Scenes/Effects/smoke_effect.tscn").instantiate()
	smoke_effect.position = global_position
	smoke_effect.scale *= 2
	Stage.instance.bullets.add_child(smoke_effect)
	super()
	for body in bombard_area.get_overlapping_bodies():
		var now_enemy: Enemy = body.owner
		if now_enemy == enemy: continue
		var damage: int = randi_range(explosion_damage_list[buff_level-1].damage_low,explosion_damage_list[buff_level-1].damage_high)
		now_enemy.take_damage(damage,DataProcess.DamageType.ExplodeDamage,0,false,null,true,true,)
		var dizness_buff: DiznessBuff = preload("res://Scenes/Buffs/dizness_buff.tscn").instantiate()
		dizness_buff.duration = 2
		dizness_buff.buff_tag = "PlaneDizness"
		now_enemy.buffs.add_child(dizness_buff)
	pass
