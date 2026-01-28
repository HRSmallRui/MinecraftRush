extends Enemy

@onready var hit_area: Area2D = $UnitBody/HitArea
@onready var aoe_hit_audio: AudioStreamPlayer = $AoeHitAudio


func anim_offset():
	match enemy_sprite.animation:
		"idle","attack":
			enemy_sprite.position = Vector2(25,-150) if enemy_sprite.flip_h else Vector2(-25,-150)
		"die":
			enemy_sprite.position = Vector2(-50,-90) if enemy_sprite.flip_h else Vector2(50,-90)
		"move_back","move_front":
			enemy_sprite.position = Vector2(0,-110)
		"move_normal":
			enemy_sprite.position = Vector2(10,-105) if enemy_sprite.flip_h else Vector2(-10,-105)
	pass


func frame_changed():
	if enemy_sprite.animation == "attack" and enemy_sprite.frame == 20:
		var damage: int = randi_range(current_data.near_damage_low,current_data.near_damage_high)
		aoe_hit_audio.play()
		for body in hit_area.get_overlapping_bodies():
			var ally: Ally = body.owner
			ally.take_damage(damage,DataProcess.DamageType.PhysicsDamage,0,false,self,false,true)
	pass


func die_blood(blood_packed_scene: PackedScene = null):
	
	pass
