extends Reinforcement


func anim_offset():
	match ally_id:
		1:
			match ally_sprite.animation:
				"attack","idle":
					ally_sprite.position = Vector2(10,-125) if ally_sprite.flip_h else Vector2(-15,-125)
				"move":
					ally_sprite.position = Vector2(-15,-100) if ally_sprite.flip_h else Vector2(15,-100)
				"start":
					ally_sprite.position = Vector2(10,-200) if ally_sprite.flip_h else Vector2(-10,-200)
		
		2:
			match ally_sprite.animation:
				"attack","idle":
					ally_sprite.position = Vector2(15,-120) if ally_sprite.flip_h else Vector2(-15,-120)
				"move":
					ally_sprite.position = Vector2(-10,-100) if ally_sprite.flip_h else Vector2(10,-100)
				"start":
					ally_sprite.position = Vector2(10,-200) if ally_sprite.flip_h else Vector2(-10,-200)
			
		3:
			match ally_sprite.animation:
				"attack","idle":
					ally_sprite.position = Vector2(15,-120) if ally_sprite.flip_h else Vector2(-20,-120)
				"move":
					ally_sprite.position = Vector2(-5,-100) if ally_sprite.flip_h else Vector2(5,-100)
				"start":
					ally_sprite.position = Vector2(15,-200) if ally_sprite.flip_h else Vector2(-15,-200)
	
	if ally_sprite.animation == "far_attack":
		ally_sprite.position = Vector2(-20,-90) if ally_sprite.flip_h else Vector2(15,-90)
	pass


func frame_changed():
	if ally_sprite.animation == "attack" and ally_sprite.frame == 16:
		cause_damage()
	if ally_sprite.animation == "far_attack" and ally_sprite.frame == 17:
		far_attack_frame()
		AudioManager.instance.shoot_audio_1.play()
	pass
