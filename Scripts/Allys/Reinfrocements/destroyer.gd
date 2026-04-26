extends Reinforcement

@onready var appear_audio: AudioStreamPlayer = $AppearAudio
@onready var aoe_hit_audio: AudioStreamPlayer = $AoeHitAudio
@onready var attack_area: Area2D = $UnitBody/AttackArea


func anim_offset():
	attack_area.position.x = -160 if ally_sprite.flip_h else 160
	match ally_sprite.animation:
		"attack","idle":
			ally_sprite.position = Vector2(-30,-165) if ally_sprite.flip_h else Vector2(20,-165)
		"move":
			ally_sprite.position = Vector2(-25,-105) if ally_sprite.flip_h else Vector2(20,-105)
		"start":
			ally_sprite.position = Vector2(35,-430) if ally_sprite.flip_h else Vector2(-35,-430)
	pass


func frame_changed():
	if ally_sprite.animation == "attack" and ally_sprite.frame == 12:
		aoe_hit_audio.play()
		for enemy_body in attack_area.get_overlapping_bodies():
			var enemy: Enemy = enemy_body.owner
			var damage: int = randi_range(current_data.near_damage_low,current_data.near_damage_high)
			enemy.take_damage(damage,DataProcess.DamageType.PhysicsDamage,0,false,self,false,true)
	
	if ally_sprite.animation == "start" and ally_sprite.frame == 6:
		appear_audio.play()
	pass
