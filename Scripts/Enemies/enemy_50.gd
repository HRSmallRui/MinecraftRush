extends Enemy


func anim_offset():
	match enemy_sprite.animation:
		"idle","attack":
			enemy_sprite.position = Vector2(0,-40)
		"die":
			enemy_sprite.position = Vector2(0,-45)
		"move_back":
			enemy_sprite.position = Vector2(0,-25)
		"move_front":
			enemy_sprite.position = Vector2(0,-30)
		"move_normal":
			enemy_sprite.position = Vector2(0,-35)
	pass


func frame_changed():
	if enemy_sprite.animation == "attack" and enemy_sprite.frame == 12:
		cause_damage()
	pass


func die_blood(blood_packed_scene: PackedScene = preload("res://Scenes/Effects/blood_green.tscn")):
	super(blood_packed_scene)
	pass


func on_normal_attack_hit(target_ally: Ally):
	var poison_buff: DotBuff = preload("res://Scenes/Buffs/Enemies/spider_poison_dot_buff.tscn").instantiate()
	target_ally.buffs.add_child(poison_buff)
	pass
