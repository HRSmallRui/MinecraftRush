extends Enemy

@onready var aoe_hit_audio: AudioStreamPlayer = $AoeHitAudio
@onready var attack_area: Area2D = $UnitBody/AttackArea


func anim_offset():
	match enemy_sprite.animation:
		"attack","idle":
			enemy_sprite.position = Vector2(-15,-195) if enemy_sprite.flip_h else Vector2(15,-195)
		"die":
			enemy_sprite.position = Vector2(-85,-170) if enemy_sprite.flip_h else Vector2(80,-170)
		"move_back":
			enemy_sprite.position = Vector2(-10,-170) if enemy_sprite.flip_h else Vector2(10,-170)
		"move_front":
			enemy_sprite.position = Vector2(10,-180) if enemy_sprite.flip_h else Vector2(-10,-180)
		"move_normal":
			enemy_sprite.position = Vector2(20,-165) if enemy_sprite.flip_h else Vector2(-25,-165)
	pass


func frame_changed():
	if enemy_sprite.animation == "attack" and enemy_sprite.frame == 25:
		aoe_hit_audio.play()
		var damage: int = randi_range(current_data.near_damage_low,current_data.near_damage_high)
		for body in attack_area.get_overlapping_bodies():
			var ally: Ally = body.owner
			ally.take_damage(damage,DataProcess.DamageType.PhysicsDamage,0,false,self,false,true,)
	pass
