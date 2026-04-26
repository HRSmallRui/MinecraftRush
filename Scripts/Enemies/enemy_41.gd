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
		if current_intercepting_units.size() > 0:
			var target_ally: Ally = current_intercepting_units[0]
			var damage = randi_range(current_data.near_damage_low,current_data.near_damage_high)
			if target_ally.take_damage(damage,DataProcess.DamageType.TrueDamage,0,false,self,false,false):
				if target_ally.ally_state != Ally.AllyState.DIE:
					on_normal_attack_hit(target_ally)
	pass


func die_blood(blood_packed_scene: PackedScene = preload("res://Scenes/Effects/blood_green.tscn")):
	super(blood_packed_scene)
	pass
