extends Reinforcement


func anim_offset():
	match ally_id:
		1:
			match ally_sprite.animation:
				"attack","idle":
					ally_sprite.position = Vector2(-30,-125) if ally_sprite.flip_h else Vector2(30,-125)
				"move":
					ally_sprite.position = Vector2(-20,-95) if ally_sprite.flip_h else Vector2(20,-95)
				"start":
					ally_sprite.position = Vector2(-20,-195) if ally_sprite.flip_h else Vector2(15,-195)
		2:
			match ally_sprite.animation:
				"attack","idle":
					ally_sprite.position = Vector2(15,-115) if ally_sprite.flip_h else Vector2(-15,-115)
				"move":
					ally_sprite.position = Vector2(-10,-95) if ally_sprite.flip_h else Vector2(10,-95)
				"start":
					ally_sprite.position = Vector2(5,-195) if ally_sprite.flip_h else Vector2(-5,-195)
		3:
			match ally_sprite.animation:
				"attack","idle":
					ally_sprite.position = Vector2(15,-115) if ally_sprite.flip_h else Vector2(-15,-115)
				"move":
					ally_sprite.position = Vector2(5,-95) if ally_sprite.flip_h else Vector2(-5,-95)
				"start":
					ally_sprite.position = Vector2(20,-200) if ally_sprite.flip_h else Vector2(-20,-200)
	pass


func frame_changed():
	match ally_id:
		1:
			if ally_sprite.animation == "attack" and ally_sprite.frame == 17:
				cause_damage()
		2,3:
			if ally_sprite.animation == "attack" and ally_sprite.frame == 16:
				cause_damage()
		
	pass
