extends Enemy


func anim_offset():
	match enemy_sprite.animation:
		"idle","attack":
			enemy_sprite.position = Vector2(0,-115)
		"die":
			enemy_sprite.position = Vector2(65,-95) if enemy_sprite.flip_h else Vector2(-65,-95)
		"move_back":
			enemy_sprite.position = Vector2(0,-90)
		"move_front","move_normal":
			enemy_sprite.position = Vector2(0,-95)
	pass


func frame_changed():
	if enemy_sprite.animation == "attack" and enemy_sprite.frame == 14:
		cause_damage()
	pass
