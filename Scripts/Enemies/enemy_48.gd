extends Enemy

@onready var aoe_hit_audio: AudioStreamPlayer = $AoeHitAudio
@onready var attack_area: Area2D = $UnitBody/AttackArea


func anim_offset():
	match enemy_sprite.animation:
		"attack","idle":
			enemy_sprite.position = Vector2(5,-120) if enemy_sprite.flip_h else Vector2(-5,-120)
		"die":
			enemy_sprite.position = Vector2(-70,-115) if enemy_sprite.flip_h else Vector2(70,-115)
		"move_back":
			enemy_sprite.position = Vector2(0,-115)
		"move_front":
			enemy_sprite.position = Vector2(0,-110)
		"move_normal":
			enemy_sprite.position = Vector2(15,-110) if enemy_sprite.flip_h else Vector2(-10,-110)
	pass


func frame_changed():
	if enemy_sprite.animation == "attack" and enemy_sprite.frame == 15:
		aoe_attack()
	pass


func aoe_attack():
	var damage: int = randi_range(current_data.near_damage_low,current_data.near_damage_high)
	aoe_hit_audio.play()
	for body in attack_area.get_overlapping_bodies():
		var ally:Ally = body.owner
		ally.take_damage(damage,DataProcess.DamageType.PhysicsDamage,0,false,self,false,true,)
	pass


func die_blood(blood_packed_scene: PackedScene = null):
	
	pass
