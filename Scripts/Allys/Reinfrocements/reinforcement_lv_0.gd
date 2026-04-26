extends Reinforcement


func anim_offset():
	match ally_sprite.animation:
		"idle","attack":
			ally_sprite.offset = Vector2(5,-120) / ally_sprite.scale if ally_sprite.flip_h else Vector2(-10,-120) / ally_sprite.scale
		"move":
			ally_sprite.offset = Vector2(-10,-100) / ally_sprite.scale if ally_sprite.flip_h else Vector2(5,-100) / ally_sprite.scale
		"start":
			ally_sprite.offset = Vector2(0,-205) / ally_sprite.scale
	pass


func frame_changed():
	if ally_sprite.animation == "attack" and ally_sprite.frame == 18:
		cause_damage()
	pass
