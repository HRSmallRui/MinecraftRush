extends SummonAlly

@onready var attack_area: Area2D = $UnitBody/AttackArea
@onready var die_audio: AudioStreamPlayer = $DieAudio
@onready var aoe_hit_audio: AudioStreamPlayer = $AoeHitAudio


func anim_offset():
	match ally_sprite.animation:
		"attack","idle":
			ally_sprite.position = Vector2(25,-145) if ally_sprite.flip_h else Vector2(-25,-145)
		"die":
			ally_sprite.position = Vector2(-50,-85) if ally_sprite.flip_h else Vector2(45,-85)
		"move":
			ally_sprite.position = Vector2(10,-100) if ally_sprite.flip_h else Vector2(-10,-100)
		"rebirth":
			ally_sprite.position = Vector2(-40,-95) if ally_sprite.flip_h else Vector2(35,-95)
	
	attack_area.position.x = -175 if ally_sprite.flip_h else 175
	pass


func frame_changed():
	if ally_sprite.animation == "attack" and ally_sprite.frame == 20:
		aoe_hit_audio.play()
		for unit_body: UnitBody in attack_area.get_overlapping_bodies():
			var enemy: Enemy = unit_body.owner
			var damage: int = randi_range(current_data.near_damage_low,current_data.near_damage_high)
			enemy.take_damage(damage,DataProcess.DamageType.PhysicsDamage,0,false,self,false,true)
	pass


func _ready() -> void:
	ally_sprite.play("rebirth")
	translate_to_new_state(AllyState.SPECIAL)
	super()
	pass


func rebirth():
	ally_sprite.play("rebirth")
	await ally_sprite.animation_finished
	super()
	pass


func die(explosion: bool):
	super(explosion)
	die_audio.play()
	pass


func _on_heal_timer_timeout():
	var before_health: int = current_data.health
	super()
	var delta_health: int = current_data.health - before_health
	if delta_health > 0:
		Achievement.achieve_int_add("IronGolem",delta_health,40000)
	pass
