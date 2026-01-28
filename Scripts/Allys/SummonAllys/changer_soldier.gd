extends SummonAlly

var rebirth_pos: Vector2


func _ready() -> void:
	rebirth_pos = global_position
	super()
	pass


func anim_offset():
	match ally_sprite.animation:
		"attack","idle":
			ally_sprite.position = Vector2(5,-90) if ally_sprite.flip_h else Vector2(-5,-90)
		"die":
			ally_sprite.position = Vector2(85,-90) if ally_sprite.flip_h else Vector2(-85,-90)
		"far_attack":
			ally_sprite.position = Vector2(5,-90) if ally_sprite.flip_h else Vector2(-5,-90)
		"move":
			ally_sprite.position = Vector2(0,-95)
	pass


func frame_changed():
	if ally_sprite.animation == "attack" and ally_sprite.frame == 14:
		cause_damage()
	if ally_sprite.animation == "far_attack" and ally_sprite.frame == 20:
		far_attack_frame()
		AudioManager.instance.shoot_audio_2.play()
	pass


func rebirth():
	position = rebirth_pos
	super()
	pass
