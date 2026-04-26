extends Enemy


func anim_offset():
	match enemy_sprite.animation:
		"idle","attack":
			enemy_sprite.position = Vector2(0,-55)
		"die":
			enemy_sprite.position = Vector2(5,-60) if enemy_sprite.flip_h else Vector2(-5,-60)
		"move_back":
			enemy_sprite.position = Vector2(0,-35)
		"move_front","move_normal":
			enemy_sprite.position = Vector2(0,-45)
	pass


func frame_changed():
	if enemy_sprite.animation == "attack" and enemy_sprite.frame == 12:
		cause_damage()
	pass


func die_blood(blood_packed_scene: PackedScene = preload("res://Scenes/Effects/blood_green.tscn")):
	super(blood_packed_scene)
	pass
