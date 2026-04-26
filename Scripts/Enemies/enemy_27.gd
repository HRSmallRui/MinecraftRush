extends Enemy


func anim_offset():
	match enemy_sprite.animation:
		"appear":
			enemy_sprite.position = Vector2(60,-105) if enemy_sprite.flip_h else Vector2(-60,-105)
		"attack","idle":
			enemy_sprite.position = Vector2(0,-115)
		"die":
			enemy_sprite.position = Vector2(55,-110) if enemy_sprite.flip_h else Vector2(-55,-110)
		"move_back","move_front":
			enemy_sprite.position = Vector2(0,-90)
		"move_normal":
			enemy_sprite.position = Vector2(-15,-95) if enemy_sprite.flip_h else Vector2(20,-95)
	pass


func frame_changed():
	if enemy_sprite.animation == "attack" and enemy_sprite.frame == 14:
		cause_damage()
	if enemy_sprite.animation == "appear" and enemy_sprite.frame == 1:
		modulate.a = 0
		unit_body.set_collision_layer_value(6,false)
		hurt_box.set_collision_layer_value(6,false)
		create_tween().tween_property(self,"modulate:a",1,0.5)
	if enemy_sprite.animation == "appear" and enemy_sprite.frame == 25:
		unit_body.set_collision_layer_value(6,true)
		hurt_box.set_collision_layer_value(6,true)
		translate_to_new_state(EnemyState.MOVE)
	pass
