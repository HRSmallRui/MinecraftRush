extends Enemy


func anim_offset():
	match enemy_sprite.animation:
		"attack","idle":
			enemy_sprite.position = Vector2(-10,-120) if enemy_sprite.flip_h else Vector2(5,-120)
		"die":
			enemy_sprite.position = Vector2(55,-100) if enemy_sprite.flip_h else Vector2(-55,-100)
		"move_back":
			enemy_sprite.position = Vector2(-5,-85) if enemy_sprite.flip_h else Vector2(0,-85)
		"move_front":
			enemy_sprite.position = Vector2(0,-95)
		"move_normal":
			enemy_sprite.position = Vector2(-20,-95) if enemy_sprite.flip_h else Vector2(15,-95)
	
	pass


func frame_changed():
	if enemy_sprite.animation == "attack" and enemy_sprite.frame == 14:
		cause_damage()
	pass
