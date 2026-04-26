extends Enemy

@onready var attack_area: Area2D = $UnitBody/AttackArea
@onready var attack_audio: AudioStreamPlayer = $AttackAudio
@onready var rain_audio: AudioStreamPlayer = $RainAudio
@onready var knee_audio: AudioStreamPlayer = $KneeAudio
@onready var fall_audio: AudioStreamPlayer = $FallAudio


func anim_offset():
	match enemy_sprite.animation:
		"attack","idle":
			enemy_sprite.position = Vector2(-5,-110) if enemy_sprite.flip_h else Vector2(0,-110)
		"die":
			enemy_sprite.position = Vector2(-115,-125) if enemy_sprite.flip_h else Vector2(110,-125)
		"move_back":
			enemy_sprite.position = Vector2(0,-80)
		"move_front":
			enemy_sprite.position = Vector2(0,-85) if enemy_sprite.flip_h else Vector2(-5,-85)
		"move_normal":
			enemy_sprite.position = Vector2(-40,-90) if enemy_sprite.flip_h else Vector2(35,-90)
	pass


func frame_changed():
	if enemy_sprite.animation == "attack" and enemy_sprite.frame == 14:
		cause_damage()
	if enemy_sprite.animation == "die":
		if enemy_sprite.frame == 34:
			knee_audio.play()
		elif enemy_sprite.frame == 41:
			fall_audio.play()
	pass


func _process(delta: float) -> void:
	super(delta)
	attack_area.position.x = -115 if enemy_sprite.flip_h else 115
	pass


func cause_damage(damage_type: int = 0):
	attack_audio.play()
	var damage: int = randi_range(current_data.near_damage_low,current_data.near_damage_high)
	for ally_body: UnitBody in attack_area.get_overlapping_bodies():
		var ally: Ally = ally_body.owner
		ally.take_damage(damage,DataProcess.DamageType.ExplodeDamage,0,false,self,false,true)
	pass


func die(explosion: bool = false):
	super(explosion)
	var blood_effect: AnimatedSprite2D = preload("res://Scenes/Effects/blood_spit_effect.tscn").instantiate()
	blood_effect.position = hurt_box.position + Vector2(0,-20)
	unit_body.add_child(blood_effect)
	await get_tree().create_timer(1,false).timeout
	rain_audio.play()
	await get_tree().create_timer(2,false).timeout
	Achievement.achieve_complete("Boss1Dead")
	pass
