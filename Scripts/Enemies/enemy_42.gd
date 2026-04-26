extends Enemy

@export var attack_audio_list: Array[AudioStream]

@onready var attack_timer: Timer = $AttackTimer
@onready var shadow: Sprite2D = $UnitBody/Shadow
@onready var attack_area: Area2D = $UnitBody/AttackArea
@onready var attack_audio: AudioStreamPlayer = $AttackAudio


func anim_offset():
	match enemy_sprite.animation:
		"idle","move_normal":
			enemy_sprite.position = Vector2(5,-240) if enemy_sprite.flip_h else Vector2(-5,-240)
		"die":
			enemy_sprite.position = Vector2(5,-265) if enemy_sprite.flip_h else Vector2(-5,-265)
		"move_back","move_front":
			enemy_sprite.position = Vector2(0,-245)
		"attack":
			enemy_sprite.position = Vector2(-5,-255) if enemy_sprite.flip_h else Vector2(5,-255)
	pass


func frame_changed():
	
	pass


func die_audio_play():
	super()
	#AudioManager.instance.explosion_dead_body_audio_play()
	shadow.hide()
	pass


func die(explosion: bool = false):
	super(explosion)
	create_tween().tween_property(enemy_sprite,"modulate:a",0,0.5)
	await get_tree().create_timer(0.3,false).timeout
	var smoke_effect: AnimatedSprite2D = preload("res://Scenes/Effects/bullet_explosion_effect.tscn").instantiate()
	smoke_effect.position = hurt_box.global_position
	smoke_effect.scale *= 0.5
	Stage.instance.bullets.add_child(smoke_effect)
	pass


func die_blood(blood_packed_scene: PackedScene = null):
	await get_tree().create_timer(1.2,false).timeout
	hide()
	pass


func move_process(delta:float):
	if attack_timer.is_stopped() and silence_layers <= 0 and attack_area.has_overlapping_bodies():
		var enemy_path: EnemyPath = get_parent()
		var curve: Curve2D = enemy_path.curve
		for body in attack_area.get_overlapping_bodies():
			var ally: Ally = body.owner
			if ally.position.distance_to(curve.get_closest_point(ally.position)) > 20: continue
			var target_progress: float = curve.get_closest_offset(ally.position)
			if target_progress < progress: continue
			attack(ally,curve.sample_baked(target_progress))
			attack_timer.start()
			return
	super(delta)
	pass


func attack(target_ally: Ally, target_pos: Vector2):
	translate_to_new_state(EnemyState.SPECIAL)
	unit_body.set_collision_layer_value(7,false)
	hurt_box.set_collision_layer_value(7,false)
	attack_audio.stream = attack_audio_list.pick_random()
	attack_audio.play()
	enemy_sprite.play("attack")
	var move_time: float = 0.4
	var sprite_tween: Tween = create_tween()
	var move_tween: Tween = create_tween()
	sprite_tween.tween_property(enemy_sprite,"offset",Vector2(0,35),move_time)
	move_tween.tween_property(self,"position",target_pos,move_time)
	await move_tween.finished
	if target_ally != null: target_ally.take_damage(randi_range(16,30),DataProcess.DamageType.PhysicsDamage,0,false,self,false,false,)
	var curve: Curve2D = get_parent().curve
	progress = curve.get_closest_offset(target_pos)
	var ret_tween: Tween = create_tween()
	ret_tween.tween_property(enemy_sprite,"offset",Vector2.ZERO,0.3)
	await ret_tween.finished
	translate_to_new_state(EnemyState.MOVE)
	unit_body.set_collision_layer_value(7,true)
	hurt_box.set_collision_layer_value(7,true)
	pass
