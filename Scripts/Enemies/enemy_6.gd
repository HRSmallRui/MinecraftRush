extends Enemy


func anim_offset():
	match enemy_sprite.animation:
		"attack","idle":
			enemy_sprite.position = Vector2(-10,-105) if enemy_sprite.flip_h else Vector2(10,-105)
		"move_normal":
			enemy_sprite.position = Vector2(-20,-95) if enemy_sprite.flip_h else Vector2(20,-95)
		"die":
			enemy_sprite.position = Vector2(85,-105) if enemy_sprite.flip_h else Vector2(-90,-105)
		"move_back":
			enemy_sprite.position = Vector2(0,-85)
		"move_front":
			enemy_sprite.position = Vector2(0,-80)
	pass


func frame_changed():
	if enemy_sprite.animation == "attack":
		if enemy_sprite.frame == 9 or enemy_sprite.frame == 23:
			cause_damage()
	pass


func cause_damage(damage_type: int = 0):
	if current_intercepting_units.size() > 0:
		var damage: int = randi_range(current_data.near_damage_low / 2, current_data.near_damage_high / 2)
		current_intercepting_units[0].take_damage(damage,DataProcess.DamageType.PhysicsDamage,0,false,self,)
	pass
