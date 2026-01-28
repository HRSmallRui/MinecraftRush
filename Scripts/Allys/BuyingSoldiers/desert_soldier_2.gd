extends BuyingSoldier

@onready var far_attack_audio: AudioStreamPlayer = $FarAttackAudio


func anim_offset():
	match ally_sprite.animation:
		"idle","attack":
			ally_sprite.position = Vector2(-5,-105) if ally_sprite.flip_h else Vector2(0,-105)
		"die":
			ally_sprite.position = Vector2(80,-90) if ally_sprite.flip_h else Vector2(-80,-90)
		"far_attack":
			ally_sprite.position = Vector2(25,-110) if ally_sprite.flip_h else Vector2(-30,-110)
		"move":
			ally_sprite.position = Vector2(0,-95)
	pass


func frame_changed():
	if ally_sprite.animation == "attack" and ally_sprite.frame == 14:
		cause_damage()
	if ally_sprite.animation == "far_attack" and ally_sprite.frame == 15:
		far_attack_frame()
		far_attack_audio.play()
	pass
