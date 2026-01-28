extends Enemy


func anim_offset():
	match enemy_sprite.animation:
		"attack","idle":
			enemy_sprite.position = Vector2(-10,-120) if enemy_sprite.flip_h else Vector2(5,-120)
		"die":
			enemy_sprite.position = Vector2(55,-100) if enemy_sprite.flip_h else Vector2(-55,-100)
		"move_back":
			enemy_sprite.position = Vector2(-5,-85) if enemy_sprite.flip_h else Vector2(0,-85)
		"move_front":
			enemy_sprite.position = Vector2(-5,-95) if enemy_sprite.flip_h else Vector2(0,-95)
		"move_normal":
			enemy_sprite.position = Vector2(-25,-95) if enemy_sprite.flip_h else Vector2(20,-95)
	pass


func frame_changed():
	if enemy_sprite.animation == "attack":
		if enemy_sprite.frame == 14 or enemy_sprite.frame == 29:
			cause_damage()
	pass


func cause_damage(damage_type: int = 0):
	if current_intercepting_units.size() > 0:
		var damage = randi_range(current_data.near_damage_low,current_data.near_damage_high)
		current_intercepting_units[0].take_damage(damage,DataProcess.DamageType.TrueDamage,0,false,self,false,false)
	pass
