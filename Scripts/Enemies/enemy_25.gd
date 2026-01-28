extends Enemy


func anim_offset():
	match enemy_sprite.animation:
		"idle","attack":
			enemy_sprite.position = Vector2(20,-90) if enemy_sprite.flip_h else Vector2(-20,-90)
		"die":
			enemy_sprite.position = Vector2(-30,-85) if enemy_sprite.flip_h else Vector2(30,-85)
		"move_back","move_front":
			enemy_sprite.position = Vector2(0,-85)
		"move_normal":
			enemy_sprite.position = Vector2(-25,-85) if enemy_sprite.flip_h else Vector2(25,-85)
	pass


func frame_changed():
	if enemy_sprite.animation == "attack" and enemy_sprite.frame == 21:
		cause_damage()
	pass


func on_normal_attack_hit(target_ally: Ally):
	var hunger_buff: DotBuff = preload("res://Scenes/Buffs/Enemies/cactus_poison_debuff.tscn").instantiate()
	hunger_buff.unit = current_intercepting_units[0]
	target_ally.buffs.add_child(hunger_buff)
	
	var blood_damage: int = 15
	var start_health: int = target_ally.current_data.health
	target_ally.take_damage(blood_damage,DataProcess.DamageType.TrueDamage,0)
	if target_ally.ally_state == Ally.AllyState.DIE:
		current_data.heal(start_health)
	else:
		var delta_health: int = start_health - target_ally.current_data.health
		current_data.heal(max(0,delta_health))
	pass


func die_blood(blood_packed_scene: PackedScene = preload("res://Scenes/Effects/blood.tscn")):
	var blood = blood_packed_scene.instantiate() as Sprite2D
	blood.position = position
	blood.modulate *= 0.5
	blood.modulate.a = 1
	get_parent().add_child(blood)
	pass
