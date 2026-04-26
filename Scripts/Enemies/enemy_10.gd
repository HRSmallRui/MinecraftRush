extends Enemy

@onready var bite_timer: Timer = $BiteTimer
@onready var bite_audio: AudioStreamPlayer = $BiteAudio


func anim_offset():
	match enemy_sprite.animation:
		"idle","attack":
			enemy_sprite.position = Vector2(15,-110) if enemy_sprite.flip_h else Vector2(-20,-110)
		"die":
			enemy_sprite.position = Vector2(-35,-85) if enemy_sprite.flip_h else Vector2(30,-85)
		"move_back","move_front":
			enemy_sprite.position = Vector2(0,-80)
		"move_normal":
			enemy_sprite.position = Vector2(-30,-85) if enemy_sprite.flip_h else Vector2(25,-85)
		"special_attack":
			enemy_sprite.position = Vector2(-15,-85) if enemy_sprite.flip_h else Vector2(10,-85)
	pass


func frame_changed():
	if enemy_sprite.animation == "attack" and enemy_sprite.frame == 21:
		cause_damage()
	elif enemy_sprite.animation == "special_attack" and enemy_sprite.frame == 9:
		bite()
	pass


func battle():
	if bite_timer.is_stopped() and enemy_sprite.animation == "idle":
		bite_timer.start()
		enemy_sprite.play("special_attack")
		bite_audio.play()
		return
	super()
	pass


func bite():
	var damage: int = randi_range(20,40)
	if current_intercepting_units.size() > 0:
		var ally: Ally = current_intercepting_units[0]
		if ally.take_damage(damage,DataProcess.DamageType.PhysicsDamage,0,false,self,false,false):
			current_data.heal(30)
			var blood_effect: AnimatedSprite2D = preload("res://Scenes/Effects/blood_effect.tscn").instantiate()
			blood_effect.global_position = ally.hurt_box.global_position
			Stage.instance.bullets.add_child(blood_effect)
	pass
