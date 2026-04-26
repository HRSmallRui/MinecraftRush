extends Enemy


func anim_offset():
	match enemy_sprite.animation:
		"idle","attack":
			enemy_sprite.position = Vector2(-5,-120) if enemy_sprite.flip_h else Vector2(5,-120)
		"die":
			enemy_sprite.position = Vector2(-5,-85) if enemy_sprite.flip_h else Vector2(5,-85)
		"move_back":
			enemy_sprite.position = Vector2(0,-85)
		"move_front":
			enemy_sprite.position = Vector2(0,-100)
		"move_normal":
			enemy_sprite.position = Vector2(-15,-100) if enemy_sprite.flip_h else Vector2(15,-100)
	pass


func frame_changed():
	if enemy_sprite.animation == "attack" and enemy_sprite.frame == 14:
		cause_damage()
	pass


func die_blood(blood_packed_scene: PackedScene = null):
	
	pass
