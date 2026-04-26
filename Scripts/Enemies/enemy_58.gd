extends Enemy

@onready var normal_attack_audio: AudioStreamPlayer = $NormalAttackAudio
@onready var aoe_hit_audio: AudioStreamPlayer = $AoeHitAudio
@onready var attack_area: Area2D = $UnitBody/AttackArea
@onready var skill_timer: Timer = $SkillTimer
@onready var rain_audio: AudioStreamPlayer = $RainAudio


func anim_offset():
	match enemy_sprite.animation:
		"attack","idle":
			enemy_sprite.position = Vector2(-70,-215) if enemy_sprite.flip_h else Vector2(70,-215)
		"die":
			enemy_sprite.position = Vector2(-25,-260) if enemy_sprite.flip_h else Vector2(25,-260)
		"move_back":
			enemy_sprite.position = Vector2(0,-220)
		"move_front":
			enemy_sprite.position = Vector2(0,-215)
		"move_normal":
			enemy_sprite.position = Vector2(-40,-225) if enemy_sprite.flip_h else Vector2(40,-225)
		"skill_attack":
			enemy_sprite.position = Vector2(-25,-270) if enemy_sprite.flip_h else Vector2(25,-270)
	pass


func frame_changed():
	if enemy_sprite.animation == "attack" and enemy_sprite.frame == 12:
		cause_damage()
		normal_attack_audio.play()
	if enemy_sprite.animation == "skill_attack" and enemy_sprite.frame == 24:
		aoe_attack()
		aoe_hit_audio.play()
	pass


func battle():
	if enemy_sprite.animation == "idle" and skill_timer.is_stopped():
		enemy_sprite.play("skill_attack")
		skill_timer.start()
		return
	super()
	pass


func aoe_attack():
	var damage: int = 500
	for body in attack_area.get_overlapping_bodies():
		var ally: Ally = body.owner
		ally.take_damage(damage,DataProcess.DamageType.PhysicsDamage,0,false,self,false,true,)
	pass


func die_blood(blood_packed_scene: PackedScene = null):
	
	pass


func die(explosion: bool = false):
	Achievement.achieve_complete("Boss5Dead")
	super(explosion)
	var blood_effect: AnimatedSprite2D = preload("res://Scenes/Effects/blood_spit_effect.tscn").instantiate()
	blood_effect.position = hurt_box.position + Vector2(0,-20)
	blood_effect.scale *= 2
	unit_body.add_child(blood_effect)
	await get_tree().create_timer(1,false).timeout
	rain_audio.play()
	pass
