extends Soldier


func anim_offset():
	match ally_sprite.animation:
		"idle","attack":
			ally_sprite.position = Vector2(0,-100)
		"move":
			ally_sprite.position = Vector2(0,-95)
		"die":
			ally_sprite.position = Vector2(75,-100) if ally_sprite.flip_h else Vector2(-75,-100)
	pass


func frame_changed():
	if ally_sprite.animation == "attack" and ally_sprite.frame == 15:
		cause_damage()
	pass
