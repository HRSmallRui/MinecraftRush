extends Enemy

@export var vex_audio: AudioStream
@export var fange_audio_list: Array[AudioStream]
@export var skill_complete_audio_list: Array[AudioStream]
@export var vex_marker_list: Array[Marker2D]

@onready var skill_releasing_audio: AudioStreamPlayer = $SkillReleasingAudio
@onready var skill_finish_audio: AudioStreamPlayer = $SkillFinishAudio
@onready var attack_area: Area2D = $UnitBody/AttackArea
@onready var fange_skill_area: Area2D = $UnitBody/FangeSkillArea
@onready var fang_timer: Timer = $FangTimer
@onready var vex_timer: Timer = $VexTimer

var is_fang_skill_adding_release: bool


func anim_offset():
	match enemy_sprite.animation:
		"idle","attack","special_attack","summon_vex":
			enemy_sprite.position = Vector2(10,-90) if enemy_sprite.flip_h else Vector2(-10,-90)
		"die":
			enemy_sprite.position = Vector2(-30,-85) if enemy_sprite.flip_h else Vector2(30,-85)
		"move_back":
			enemy_sprite.position = Vector2(0,-80)
		"move_front","move_normal":
			enemy_sprite.position = Vector2(0,-85)
	pass


func frame_changed():
	if enemy_sprite.animation == "attack":
		if enemy_sprite.frame == 27:
			for body in attack_area.get_overlapping_bodies():
				var damage: int = randi_range(current_data.near_damage_low,current_data.near_damage_high)
				var ally: Ally = body.owner
				ally.take_damage(damage,DataProcess.DamageType.PhysicsDamage,0,false,null,false,true,)
		if enemy_sprite.frame == 18:
			for marker in attack_area.get_children():
				if marker is Marker2D:
					summon_fangs(marker.global_position)
					await get_tree().create_timer(0.08,false).timeout
		if enemy_sprite.frame == 1:
			skill_releasing_audio.stream = fange_audio_list.pick_random()
			skill_releasing_audio.play()
		if enemy_sprite.frame == 44:
			skill_finished()
	if enemy_sprite.animation == "special_attack" and enemy_sprite.frame == 18:
		var delta_progress: float = 30 if is_fang_skill_adding_release else -30
		var current_progress: float = progress + delta_progress
		var curve: Curve2D = get_parent().curve
		for i in 12:
			if current_progress < 0 or current_progress > curve.get_baked_length():
				current_progress = clampf(current_progress,0,curve.get_baked_length())
				release_fang(curve.sample_baked(current_progress))
				break
			release_fang(curve.sample_baked(current_progress))
			current_progress += delta_progress
			await get_tree().create_timer(0.08,false).timeout
	if enemy_sprite.animation == "special_attack" and enemy_sprite.frame == 45:
		update_state()
		if current_intercepting_units.size() > 0:
			translate_to_new_state(EnemyState.BATTLE)
		skill_finished()
	
	if enemy_sprite.animation == "summon_vex" and enemy_sprite.frame == 45:
		update_state()
		if current_intercepting_units.size() > 0:
			translate_to_new_state(EnemyState.BATTLE)
		skill_finished()
	if enemy_sprite.animation == "summon_vex" and enemy_sprite.frame == 18:
		summon_vex()
	pass


func _process(delta: float) -> void:
	super(delta)
	if enemy_state != EnemyState.DIE:
		current_data.near_damage_buffs.clear()
		current_data.update_near_damage()
	pass


func battle():
	if silence_layers <= 0:
		if vex_timer.is_stopped() and enemy_sprite.animation == "idle" and normal_attack_timer.is_stopped():
			enemy_sprite.play("summon_vex")
			vex_timer.start()
			skill_releasing_audio.stream = vex_audio
			skill_releasing_audio.play()
			normal_attack_timer.start()
			return
		super()
	pass


func summon_fangs(fang_pos: Vector2):
	var fang: Node2D = preload("res://Scenes/Effects/evoker_fang.tscn").instantiate()
	fang.position = fang_pos
	Stage.instance.bullets.add_child(fang)
	var block_effect: Node2D = preload("res://Scenes/Effects/block_particle.tscn").instantiate()
	block_effect.position = fang_pos
	block_effect.modulate = Color.SADDLE_BROWN
	Stage.instance.add_child(block_effect)
	pass


func move_process(delta: float):
	if fang_timer.is_stopped() and silence_layers <= 0 and fange_skill_area.has_overlapping_bodies():
		var enemy_path: EnemyPath = get_parent()
		var curve: Curve2D = enemy_path.curve
		for body in fange_skill_area.get_overlapping_bodies():
			var ally: Ally = body.owner
			if ally.position.distance_to(curve.get_closest_point(ally.position)) > 20: continue
			var target_progress: float = curve.get_closest_offset(ally.position)
			enemy_sprite.play("special_attack")
			skill_releasing_audio.stream = fange_audio_list.pick_random()
			skill_releasing_audio.play()
			fang_timer.start()
			var face_position: Vector2
			if target_progress > progress:
				face_position = curve.sample_baked(progress + 1)
				is_fang_skill_adding_release = true
			else:
				face_position = curve.sample_baked(progress - 1)
				is_fang_skill_adding_release = false
			enemy_sprite.flip_h = face_position.x < position.x
			translate_to_new_state(EnemyState.SPECIAL)
			return
	if vex_timer.is_stopped() and silence_layers <= 0 and fange_skill_area.has_overlapping_bodies():
		translate_to_new_state(EnemyState.SPECIAL)
		enemy_sprite.play("summon_vex")
		vex_timer.start()
		skill_releasing_audio.stream = vex_audio
		skill_releasing_audio.play()
		return
	super(delta)
	pass


func release_fang(summon_pos: Vector2):
	summon_fangs(summon_pos)
	var hit_box: SkillConditionArea2D = preload("res://Scenes/Skills/evoker_fang_area.tscn").instantiate()
	hit_box.position = summon_pos
	Stage.instance.bullets.add_child(hit_box)
	pass


func summon_vex():
	for marker in vex_marker_list:
		var vex: Enemy = preload("res://Scenes/Enemies/enemy_42.tscn").instantiate()
		var enemy_path: EnemyPath = Stage.instance.get_closest_enemy_path(marker.global_position)
		vex.progress = enemy_path.curve.get_closest_offset(marker.global_position)
		enemy_path.add_child(vex)
		vex.unit_body.set_collision_layer_value(7,false)
		vex.hurt_box.set_collision_layer_value(7,false)
		vex.translate_to_new_state(EnemyState.SPECIAL)
		vex.position = position
		vex_progress(vex,enemy_path.curve.sample_baked(vex.progress))
	pass


func skill_finished():
	skill_finish_audio.stream = skill_complete_audio_list.pick_random()
	skill_finish_audio.play()
	pass


func vex_progress(vex: Enemy, target_pos: Vector2):
	vex.enemy_sprite.flip_h = target_pos.x < vex.position.x
	var move_tween: Tween = create_tween()
	move_tween.tween_property(vex,"position",target_pos,0.4)
	await move_tween.finished
	vex.hurt_box.set_collision_layer_value(7,true)
	vex.unit_body.set_collision_layer_value(7,true)
	vex.translate_to_new_state(EnemyState.MOVE)
	pass
