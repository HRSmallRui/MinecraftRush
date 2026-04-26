extends Enemy


func anim_offset():
	match enemy_sprite.animation:
		"idle","attack":
			enemy_sprite.position = Vector2(-15,-85) if enemy_sprite.flip_h else Vector2(15,-85)
		"move_normal","move_back","move_front":
			enemy_sprite.position = Vector2(0,-90)
		"attack":
			enemy_sprite.position = Vector2(-20,-85) if enemy_sprite.flip_h else Vector2(15,-85)
		"die":
			enemy_sprite.position = Vector2(85,-100) if enemy_sprite.flip_h else Vector2(-85,-100)
	pass


func frame_changed():
	if enemy_sprite.animation == "attack" and enemy_sprite.frame == 14:
		cause_damage()
	pass
