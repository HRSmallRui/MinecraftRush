extends Enemy


func anim_offset():
	match enemy_sprite.animation:
		"idle","attack":
			enemy_sprite.offset = Vector2(-5,-60) if enemy_sprite.flip_h else Vector2(5,-60)
		"die":
			enemy_sprite.offset = Vector2(50,-60) if enemy_sprite.flip_h else Vector2(-55,-60)
		"move_back","move_front":
			enemy_sprite.offset = Vector2(0,-60)
		"move_normal":
			enemy_sprite.offset = Vector2(0,-65)
	
	enemy_sprite.offset /= enemy_sprite.scale.length()
	pass


func frame_changed():
	if enemy_sprite.animation == "attack" and enemy_sprite.frame == 14:
		cause_damage()
	pass
