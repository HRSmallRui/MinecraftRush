extends Soldier


func anim_offset():
	match ally_sprite.animation:
		"attack","idle":
			ally_sprite.position = Vector2(-5,-110) if ally_sprite.flip_h else Vector2(0,-110)
		"die":
			ally_sprite.position = Vector2(75,-100) if ally_sprite.flip_h else Vector2(-80,-100)
		"move":
			ally_sprite.position = Vector2(-10,-90) if ally_sprite.flip_h else Vector2(5,-90)
	
	pass


func frame_changed():
	if ally_sprite.animation == "attack" and ally_sprite.frame == 14:
		cause_damage()
	pass
