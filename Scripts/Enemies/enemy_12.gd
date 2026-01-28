extends Enemy

@onready var sprint_sprite: AnimatedSprite2D = $UnitBody/SprintSprite
@onready var sprint_timer: Timer = $SprintTimer
@onready var sprint_continue_timer: Timer = $SprintContinueTimer
@onready var sprint_audio: AudioStreamPlayer = $SprintAudio
@onready var sprint_hit_area: Area2D = $UnitBody/SprintHitArea

var is_skill_releasing: bool = false


func anim_offset():
	match enemy_sprite.animation:
		"attack","idle":
			enemy_sprite.position = Vector2(-5,-115) if enemy_sprite.flip_h else Vector2(0,-115)
		"die":
			enemy_sprite.position = Vector2(-30,-85) if enemy_sprite.flip_h else Vector2(30,-85)
		"far_attack":
			enemy_sprite.position = Vector2(-5,-120) if enemy_sprite.flip_h else Vector2(5,-120)
		"move_back":
			enemy_sprite.position = Vector2(0,-85)
		"move_front":
			enemy_sprite.position = Vector2(0,-90)
		"move_normal":
			enemy_sprite.position = Vector2(5,-95) if enemy_sprite.flip_h else Vector2(-10,-95)
	pass


func frame_changed():
	if enemy_sprite.animation == "attack" and enemy_sprite.frame == 14:
		cause_damage()
	if enemy_sprite.animation == "far_attack" and enemy_sprite.frame == 22:
		var summon_pos: Vector2 = far_attack_marker_flip.global_position if enemy_sprite.flip_h else far_attack_marker.global_position
		var damage: int = randi_range(current_data.far_damage_low,current_data.far_damage_high)
		var bullet: Bullet = summon_bullet(far_attack_bullet_scene,summon_pos,far_attack_position,damage,DataProcess.DamageType.PhysicsDamage)
		Stage.instance.bullets.add_child(bullet)
		AudioManager.instance.play_fork_throw_audio()
	pass


func move_process(delta:float):
	super(delta)
	sprint_sprite.global_rotation = direction_sprite.global_rotation
	if enemy_state == EnemyState.MOVE:
		if far_attack_area.has_overlapping_bodies() and silence_layers <= 0 and sprint_timer.is_stopped():
			var enemy_path: EnemyPath = get_parent()
			if enemy_path.curve.get_baked_length() - progress > 700:
				sprint()
				is_skill_releasing = true
				return
		if far_attack_area.get_overlapping_bodies().size() > 0 and far_attack_timer.is_stopped() and !is_skill_releasing:
			translate_to_new_state(EnemyState.SPECIAL)
			enemy_sprite.play("idle")
			return
	pass


func special_process():
	if enemy_sprite.animation == "idle" and far_attack_area.get_overlapping_bodies().size() == 0:
		translate_to_new_state(EnemyState.MOVE)
		return
	if current_intercepting_units.size() > 0:
		translate_to_new_state(EnemyState.BATTLE)
	elif far_attack_area.get_overlapping_bodies().size() > 0 and far_attack_timer.is_stopped():
		var ally: Ally = far_attack_area.get_overlapping_bodies()[0].owner
		far_attack_position = ally.hurt_box.global_position
		far_attack_timer.start()
		enemy_sprite.play("far_attack")
		enemy_sprite.flip_h = far_attack_position.x < position.x
	pass


func sprint():
	sprint_timer.start()
	interceptable = false
	sprint_audio.play()
	enemy_sprite.hide()
	sprint_sprite.show()
	sprint_hit_area.monitoring = true
	sprint_continue_timer.start()
	var original_speed = start_data.unit_move_speed
	start_data.unit_move_speed *= 5
	current_data.update_move_speed()
	
	await sprint_continue_timer.timeout
	sprint_timer.start()
	interceptable = true
	enemy_sprite.show()
	sprint_sprite.hide()
	sprint_hit_area.monitoring = false
	start_data.unit_move_speed = original_speed
	current_data.update_move_speed()
	is_skill_releasing = false
	pass


func _on_sprint_hit_area_area_entered(area: Area2D) -> void:
	var ally: Ally = area.owner
	ally.take_damage(70,DataProcess.DamageType.PhysicsDamage,0,false,self)
	pass # Replace with function body.


func die(explosion: bool = false):
	super(explosion)
	sprint_continue_timer.stop()
	sprint_sprite.hide()
	enemy_sprite.show()
	pass
