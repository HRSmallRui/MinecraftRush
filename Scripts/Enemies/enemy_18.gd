extends Enemy

@onready var attack_audio: AudioStreamPlayer = $AttackAudio
@onready var pounce_timer: Timer = $PounceTimer
@onready var pounce_hit_area: Area2D = $UnitBody/PounceHitArea
@onready var pounce_condition_area: Area2D = $UnitBody/PounceConditionArea

var pounce_tween: Tween
var pounce_list: Array[Ally]
var pounce_target_progress: float


func anim_offset():
	match enemy_sprite.animation:
		"attack","idle":
			enemy_sprite.position = Vector2(-35,-65) if enemy_sprite.flip_h else Vector2(35,-65)
		"die":
			enemy_sprite.position = Vector2(-40,-70) if enemy_sprite.flip_h else Vector2(35,-70)
		"move_back","move_front","move_normal":
			enemy_sprite.position = Vector2(-20,-65) if enemy_sprite.flip_h else Vector2(20,-65)
		"pounce1","pounce2":
			enemy_sprite.position = Vector2(-30,-65) if enemy_sprite.flip_h else Vector2(25,-65)
		"pounce3":
			enemy_sprite.position = Vector2(-35,-65) if enemy_sprite.flip_h else Vector2(30,-65)
	pass


func frame_changed():
	if enemy_sprite.animation == "attack":
		if enemy_sprite.frame == 1:
			attack_audio.play()
		if enemy_sprite.frame == 17:
			cause_damage()
	if enemy_sprite.animation == "pounce1" and enemy_sprite.frame == 6:
		attack_audio.play()
	if enemy_sprite.animation == "pounce3" and enemy_sprite.frame == 3:
		pounce_damage()
		pounce_condition_area.monitoring = true
		interceptable = true
	if enemy_sprite.animation == "pounce1" and enemy_sprite.frame == 8:
		pounce_release()
	pass


func pounce_damage():
	for ally_body in pounce_hit_area.get_overlapping_bodies():
		var ally: Ally = ally_body.owner
		ally.take_damage(40,DataProcess.DamageType.PhysicsDamage,0,false,self)
	pass


func _on_pounce_condition_area_body_entered(body: Node2D) -> void:
	var ally: Ally = body.owner
	var enemy_path: EnemyPath = get_parent()
	var current_curve: Curve2D = enemy_path.curve
	var target_progress: float = current_curve.get_closest_offset(ally.global_position)
	if target_progress < progress: return
	var length: float = (ally.position - current_curve.sample_baked(target_progress)).length()
	if length > 50: return
	pounce_list.append(ally)
	pass # Replace with function body.


func _on_pounce_condition_area_body_exited(body: Node2D) -> void:
	var ally: Ally = body.owner
	pounce_list.erase(ally)
	pass # Replace with function body.


func pounce_release():
	var enemy_path: EnemyPath = get_parent()
	var current_curve: Curve2D = enemy_path.curve
	var target_position:Vector2 = current_curve.sample_baked(pounce_target_progress)
	var move_time: float = (target_position - position).length() / 500
	
	pounce_condition_area.monitoring = false
	if pounce_tween != null:
		pounce_tween.kill()
	pounce_tween = create_tween()
	pounce_tween.tween_property(self,"position",target_position,move_time)
	pounce_list.clear()
	pounce_target_progress = pounce_target_progress
	
	pounce_tween.finished.connect(pounce_finished)
	
	await enemy_sprite.animation_finished
	enemy_sprite.play("pounce2")
	
	#if current_intercepting_units.size() == 0:
		#translate_to_new_state(EnemyState.MOVE)
	#else:
		#translate_to_new_state(EnemyState.BATTLE)
		#for ally in current_intercepting_units:
			#ally.move_to_intercept(self.intercepting_marker.global_position)
	pass


func move_process(delta: float):
	super(delta)
	if enemy_state == EnemyState.MOVE:
		if pounce_condition_area.has_overlapping_bodies() and pounce_timer.is_stopped() and silence_layers <= 0:
			var curve = get_parent().curve as Curve2D
			if curve.get_baked_length() - progress < 700:
				return
			var target_ally: Ally
			for body in pounce_condition_area.get_overlapping_bodies():
				var ally: Ally = body.owner
				var enemy_path: EnemyPath = get_parent()
				var current_curve: Curve2D = enemy_path.curve
				var target_progress: float = current_curve.get_closest_offset(ally.global_position)
				if target_progress < progress: continue
				var length: float = (ally.position - current_curve.sample_baked(target_progress)).length()
				if length > 50: continue
				target_ally = ally
				pounce_target_progress = target_progress
			if target_ally == null: return
			translate_to_new_state(EnemyState.SPECIAL)
			enemy_sprite.play("pounce1")
			enemy_sprite.flip_h = target_ally.position.x < position.x
			pounce_timer.start()
			interceptable = false
			return
	pass


func pounce_finished():
	if enemy_state == EnemyState.DIE: return
	enemy_sprite.play("pounce3")
	progress = pounce_target_progress
	pounce_list.clear()
	
	await enemy_sprite.animation_finished
	if enemy_state == EnemyState.DIE: return
	if current_intercepting_units.is_empty():
		translate_to_new_state(EnemyState.MOVE)
	else:
		translate_to_new_state(EnemyState.BATTLE)
	pass


func die(explosion: bool = false):
	enemy_sprite.pause()
	super(explosion)
	if pounce_tween != null:
		pounce_tween.kill()
	pass
