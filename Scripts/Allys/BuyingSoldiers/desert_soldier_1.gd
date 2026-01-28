extends BuyingSoldier


func anim_offset():
	match ally_sprite.animation:
		"attack","idle":
			ally_sprite.position = Vector2(10,-120) if ally_sprite.flip_h else Vector2(-10,-120)
		"die":
			ally_sprite.position = Vector2(75,-100) if ally_sprite.flip_h else Vector2(-75,-100)
		"dodge":
			ally_sprite.position = Vector2(-10,-90) if ally_sprite.flip_h else Vector2(10,-90)
		"move":
			ally_sprite.position = Vector2(-20,-90) if ally_sprite.flip_h else Vector2(15,-90)
	pass


func frame_changed():
	if ally_sprite.animation == "attack" and ally_sprite.frame == 14:
		cause_damage()
	if ally_sprite.animation == "dodge" and ally_sprite.frame == 17:
		cause_damage()
	pass


func dodge():
	super()
	ally_sprite.play("dodge")
	pass
