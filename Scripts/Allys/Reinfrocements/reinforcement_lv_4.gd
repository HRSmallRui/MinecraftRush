extends Reinforcement


func anim_offset():
	if ally_sprite.animation == "far_attack":
		ally_sprite.position = Vector2(-20,-90) if ally_sprite.flip_h else Vector2(15,-90)
	else:
		match ally_id:
			1:
				match ally_sprite.animation:
					"attack","idle":
						ally_sprite.position = Vector2(15,-120) if ally_sprite.flip_h else Vector2(-15,-120)
					"move":
						ally_sprite.position = Vector2(-20,-100) if ally_sprite.flip_h else Vector2(15,-100)
					"start":
						ally_sprite.position = Vector2(10,-200) if ally_sprite.flip_h else Vector2(-10,-200)
			2:
				match ally_sprite.animation:
					"attack","idle":
						ally_sprite.position = Vector2(15,-120) if ally_sprite.flip_h else Vector2(-15,-120)
					"move":
						ally_sprite.position = Vector2(-20,-100) if ally_sprite.flip_h else Vector2(15,-100)
					"start":
						ally_sprite.position = Vector2(10,-200) if ally_sprite.flip_h else Vector2(-10,-200)
			3:
				match ally_sprite.animation:
					"attack","idle":
						ally_sprite.position = Vector2(-55,-95) if ally_sprite.flip_h else Vector2(55,-95)
					"move":
						ally_sprite.position = Vector2(-50,-100) if ally_sprite.flip_h else Vector2(50,-100)
					"start":
						ally_sprite.position = Vector2(-45,-200) if ally_sprite.flip_h else Vector2(45,-200)
	pass


func frame_changed():
	if ally_sprite.animation == "far_attack" and ally_sprite.frame == 17:
		AudioManager.instance.shoot_audio_1.play()
		far_attack_frame()
	if ally_sprite.animation == "attack":
		match ally_id:
			1,2:
				if ally_sprite.frame == 16: cause_damage()
			3:
				if ally_sprite.frame == 13: cause_damage()
	pass
