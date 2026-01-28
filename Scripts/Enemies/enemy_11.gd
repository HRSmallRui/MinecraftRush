extends Enemy


func anim_offset():
	match enemy_sprite.animation:
		"attack","idle":
			enemy_sprite.position = Vector2(20,-115) if enemy_sprite.flip_h else Vector2(-20,-115)
		"die":
			enemy_sprite.position = Vector2(-35,-80) if enemy_sprite.flip_h else Vector2(30,-80)
		"move_back","move_front":
			enemy_sprite.position = Vector2(0,-80)
		"move_normal":
			enemy_sprite.position = Vector2(-30,-85) if enemy_sprite.flip_h else Vector2(25,-85)
	pass


func frame_changed():
	if enemy_sprite.animation == "attack" and enemy_sprite.frame == 21:
		cause_damage()
	pass
