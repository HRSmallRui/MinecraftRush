extends Enemy

@onready var aoe_attack_area: Area2D = $UnitBody/AOEAttackArea
@onready var super_attack_area: Area2D = $UnitBody/SuperAttackArea
@onready var aoe_hit_audio: AudioStreamPlayer = $AoeHitAudio
@onready var super_attack_timer: Timer = $SuperAttackTimer
@onready var super_attack_audio: AudioStreamPlayer = $SuperAttackAudio
@onready var explosion_area: Area2D = $UnitBody/ExplosionArea

var has_damaged: bool = false
var explosion_damage: int = 400


func anim_offset():
	match enemy_sprite.animation:
		"idle","attack":
			enemy_sprite.position = Vector2(40,-175) if enemy_sprite.flip_h else Vector2(-40,-175)
		"attack2":
			enemy_sprite.position = Vector2(0,-150)
		"move_back":
			enemy_sprite.position = Vector2(-5,-90) if enemy_sprite.flip_h else Vector2(5,-90)
		"move_front":
			enemy_sprite.position = Vector2(5,-95) if enemy_sprite.flip_h else Vector2(-5,-95)
		"move_normal":
			enemy_sprite.position = Vector2(5,-90) if enemy_sprite.flip_h else Vector2(-5,-90)
		"super_attack":
			enemy_sprite.position = Vector2(-25,-230) if enemy_sprite.flip_h else Vector2(25,-230)
	pass


func frame_changed():
	if enemy_sprite.animation == "attack" and enemy_sprite.frame == 20:
		aoe_attack()
		has_damaged = true
	if enemy_sprite.animation == "attack2" and enemy_sprite.frame == 20:
		aoe_attack()
		has_damaged = false
	if enemy_sprite.animation == "super_attack" and enemy_sprite.frame == 16:
		super_attack_audio.play()
		var damage: int = randi_range(current_data.near_damage_low,current_data.near_damage_high) * 4
		for body in super_attack_area.get_overlapping_bodies():
			var ally: Ally = body.owner
			ally.take_damage(damage,DataProcess.DamageType.TrueDamage,0,false,self,false,true,)
	pass



func battle():
	if enemy_sprite.animation == "idle":
		if normal_attack_timer.is_stopped() and super_attack_timer.is_stopped() and silence_layers <= 0:
			enemy_sprite.play("super_attack")
			super_attack_timer.start()
			normal_attack_timer.start()
			return
		if normal_attack_timer.is_stopped() and has_damaged:
			enemy_sprite.play("attack2")
			normal_attack_timer.start()
			return
	super()
	pass


func aoe_attack():
	aoe_hit_audio.play()
	var damage: int = randi_range(current_data.near_damage_low,current_data.near_damage_high)
	for body in aoe_attack_area.get_overlapping_bodies():
		var ally: Ally = body.owner
		ally.take_damage(damage,DataProcess.DamageType.TrueDamage,0,false,self,false,true,)
	pass


func explosion():
	AudioManager.instance.play_explosion_audio()
	var explosion_effect: AnimatedSprite2D = preload("res://Scenes/Effects/bullet_explosion_effect.tscn").instantiate()
	
	explosion_effect.global_position = self.hurt_box.global_position
	Stage.instance.bullets.add_child(explosion_effect)
	
	for ally_body: UnitBody in explosion_area.get_overlapping_bodies():
		var ally: Ally = ally_body.owner
		ally.take_damage(explosion_damage,DataProcess.DamageType.ExplodeDamage,0,false,self,false,true)
	pass


func die(explosion: bool = false):
	explosion()
	super(false)
	hide()
	pass


func die_blood(blood_packed_scene: PackedScene = null):
	
	pass


func add_new_buff_tag(tag_name: String, tag_level: int = 1):
	if tag_name == "lightning":
		explosion_area.scale *= 1.5
		explosion_damage  = 500
	pass
