extends DotBuff

@onready var explosion_area: Area2D = $ExplosionArea
@onready var plugin_explosion: AudioStreamPlayer = $PluginExplosion
@onready var plugin_effect: Sprite2D = $PluginEffect

var has_explosion: bool


func remove_buff():
	plugin_effect.hide()
	if unit is Enemy:
		var enemy: Enemy = unit
		if enemy.enemy_state == Enemy.EnemyState.DIE and !enemy.is_disappear_killing and !has_explosion:
			has_explosion = true
			var explosion_effect: AnimatedSprite2D = preload("res://Scenes/Effects/bullet_explosion_effect.tscn").instantiate()
			explosion_effect.position = enemy.hurt_box.global_position
			explosion_effect.modulate = Color.DARK_RED
			explosion_effect.scale *= 0.5
			explosion_effect.z_index = 0
			Stage.instance.bullets.add_child(explosion_effect)
			plugin_explosion.play()
			var enemy_list: Array[Enemy]
			for body in explosion_area.get_overlapping_bodies():
				var new_enemy: Enemy = body.owner
				enemy_list.append(new_enemy)
			for new_enemy in enemy_list:
				if new_enemy == self: continue
				new_enemy.take_damage(30,DataProcess.DamageType.TrueDamage,0,false,null,false,true,)
			for new_enemy in enemy_list:
				#if new_enemy.enemy_state == Enemy.EnemyState.DIE: continue
				var dot_debuff: DotBuff = preload("res://Scenes/Buffs/Allys/medical_plugin_dot_debuff.tscn").instantiate()
				dot_debuff.duration = duration
				dot_debuff.buff_level = buff_level
				new_enemy.buffs.add_child(dot_debuff)
			await plugin_explosion.finished
	super()
	pass


func buff_start():
	var enemy: Enemy = unit
	plugin_effect.global_position = enemy.hurt_box.global_position
	Achievement.achieve_int_add("PluginPeople",1,2000)
	pass
