extends Enemy


func anim_offset():
	match enemy_sprite.animation:
		"idle","attack":
			enemy_sprite.position = Vector2(15,-90) if enemy_sprite.flip_h else Vector2(-20,-90)
		"die":
			enemy_sprite.position = Vector2(-35,-85) if enemy_sprite.flip_h else Vector2(30,-85)
		"move_back","move_front":
			enemy_sprite.position = Vector2(0,-80)
		"move_normal":
			enemy_sprite.position = Vector2(-30,-85) if enemy_sprite.flip_h else Vector2(25,-85)
	pass


func frame_changed():
	if enemy_sprite.animation == "attack" and enemy_sprite.frame == 21:
		cause_damage()
	pass


func on_normal_attack_hit(target_ally: Ally):
	var hunger_buff: DotBuff = preload("res://Scenes/Buffs/Enemies/hunger_buff.tscn").instantiate()
	hunger_buff.unit = current_intercepting_units[0]
	target_ally.buffs.add_child(hunger_buff)
	pass
