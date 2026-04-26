extends DotBuff

@export var lower_damage_list: Array[int] = [1,2,3,4,5,6,7,8,9]
@export var higher_damage_list: Array[int] = [2,4,6,8,10,12,14,16,18]

@onready var explosion_area: Area2D = $ExplosionArea

var passive_level: int
var dead_explosion_level: int

func buff_start() -> void:
	super()
	if passive_level == 1:
		dot_damage = lower_damage_list
	else:
		dot_damage = higher_damage_list
	var enemy: Enemy = unit
	if enemy.enemy_buff_tags.has("salem_plugin"):
		buff_level = clampi(enemy.enemy_buff_tags["salem_plugin"]+1,0,6)
		enemy.enemy_buff_tags["salem_plugin"] = buff_level
	else:
		buff_level = 1
		enemy.enemy_buff_tags["salem_plugin"] = 1
	pass


func remove_buff():
	if buff_timer >= duration:
		var enemy: Enemy = unit
		enemy.enemy_buff_tags["salem_plugin"] = 0
	var enemy: Enemy = unit
	if enemy.enemy_state == Enemy.EnemyState.DIE and dead_explosion_level > 0:
		var explosion_effect: AnimatedSprite2D = preload("res://Scenes/Effects/bullet_explosion_effect.tscn").instantiate()
		explosion_effect.position = enemy.hurt_box.global_position
		explosion_effect.modulate = Color.DARK_GREEN
		Stage.instance.bullets.add_child(explosion_effect)
		AudioManager.instance.play_explosion_audio()
		var damage: int = HeroSkillLibrary.hero_skill_data_library[7][1].explosion_damage[dead_explosion_level-1]
		for body in explosion_area.get_overlapping_bodies():
			var now_enemy: Enemy = body.owner
			now_enemy.take_damage(damage,DataProcess.DamageType.ExplodeDamage,0,false,null,false,true,)
			if now_enemy.enemy_state == Enemy.EnemyState.DIE: continue
			for i in 2:
				var plugin_buff: DotBuff = preload("res://Scenes/Buffs/Salem/salem_plugin_buff.tscn").instantiate()
				plugin_buff.dead_explosion_level = dead_explosion_level
				plugin_buff.passive_level = passive_level
				now_enemy.buffs.add_child(plugin_buff)
		await get_tree().process_frame
		var spread_buff: BuffClass = preload("res://Scenes/Buffs/Salem/salem_spread_buff.tscn").instantiate()
		spread_buff.dead_explosion_level = dead_explosion_level
		spread_buff.passive_level = passive_level
		enemy.buffs.add_child(spread_buff)
	super()
	pass
