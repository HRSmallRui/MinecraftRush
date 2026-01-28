extends Hero

enum PowerElement{
	FIRE,
	WATER,
	EARTH,
	WIND
}

@export_range(0,1,0.05) var element_hue_list: Array[float]

@onready var god_ring: Node2D = $UnitBody/GodRing
@onready var total_control_ring: Node2D = $UnitBody/GodRing/TotalControlRing
@onready var teleport_audio: AudioStreamPlayer = $TeleportAudio
@onready var teleport_audio_2: AudioStreamPlayer = $TeleportAudio2
@onready var shadow_timer: Timer = $ShadowTimer
@onready var skill_1_trace_area: Area2D = $UnitBody/Skill1TraceArea
@onready var skill_1_timer: Timer = $Skill1Timer
@onready var skill_2_timer: Timer = $Skill2Timer
@onready var skill_3_timer: Timer = $Skill3Timer
@onready var skill_4_timer: Timer = $Skill4Timer
@onready var power_timer: Timer = $PowerTimer
@onready var power_light: Sprite2D = $UnitBody/PowerLight
@onready var path_navigation_agent: NavigationAgent2D = $PathNavigationAgent
@onready var sould_marker: Marker2D = $UnitBody/SouldMarker
@onready var skill_2_area: Area2D = $UnitBody/Skill2Area
@onready var energy_explosion: Sprite2D = $UnitBody/EnergyExplosion
@onready var skill_2_audio: AudioStreamPlayer = $Skill2Audio
@onready var skill_3_area: Area2D = $UnitBody/Skill3Area
@onready var skill_3_dot_timer: Timer = $Skill3DotTimer
@onready var skill_3_particle: GPUParticles2D = $UnitBody/Skill3Particle
@onready var skill_3_prepare_audio: AudioStreamPlayer = $Skill3PrepareAudio
@onready var skill_3_release_audio: AudioStreamPlayer = $Skill3ReleaseAudio
@onready var magic_book_area: Area2D = $UnitBody/MagicBookArea
@onready var skill_3_layer: ColorRect = $EffectLayer/Skill3Layer
@onready var skill_4_animation_player: AnimationPlayer = $EffectLayer/Skill4AnimationPlayer
@onready var skill_4_duration_timer: Timer = $Skill4DurationTimer
@onready var skill_4_layer: Sprite2D = $UnitBody/Skill4Layer
@onready var stop_timer_player: AnimationPlayer = $EffectLayer/StopTimerPlayer
@onready var stop_time_layer: ColorRect = $UnitBody/StopTimeLayer
@onready var effect_layer: CanvasLayer = $EffectLayer
@onready var stop_time_layer_player: AnimationPlayer = $UnitBody/StopTimeLayer/StopTimeLayerPlayer
@onready var clock_audio: AudioStreamPlayer = $ClockAudio
@onready var stop_time_audio: AudioStreamPlayer = $StopTimeAudio

var current_element_strength: PowerElement = PowerElement.WIND
var is_power_type: bool = false


func _ready() -> void:
	super()
	skill_1_timer.wait_time = HeroSkillLibrary.hero_skill_data_library[ally_id][1].CD
	skill_2_timer.wait_time = HeroSkillLibrary.hero_skill_data_library[ally_id][2].CD[skill_levels[2]-1]
	skill_3_timer.wait_time = HeroSkillLibrary.hero_skill_data_library[ally_id][3].CD
	skill_4_timer.wait_time = HeroSkillLibrary.hero_skill_data_library[ally_id][4].CD[skill_levels[4]-1]
	skill_4_duration_timer.wait_time = HeroSkillLibrary.hero_skill_data_library[ally_id][4].stop_time[skill_levels[4]-1]
	power_light.modulate.a = 0
	energy_explosion.scale = Vector2.ZERO
	energy_explosion.modulate.a = 1
	skill_3_layer.hide()
	skill_3_particle.hide()
	skill_3_particle.modulate.a = 0.8
	skill_4_layer.hide()
	stop_time_layer.hide()
	pass


func start_data_process():
	super()
	start_data.explode_defence = 0.9
	start_data.near_hit_rate = 999
	pass


func anim_offset():
	match ally_sprite.animation:
		"attack","far_attack":
			ally_sprite.position = Vector2(20,-105) if ally_sprite.flip_h else Vector2(-20,-105)
			total_control_ring.position.x = -20
		"die":
			ally_sprite.position = Vector2(-15,-105) if ally_sprite.flip_h else Vector2(10,-105)
			total_control_ring.position.x = -20
		"idle":
			ally_sprite.position = Vector2(0,-105) if ally_sprite.flip_h else Vector2(-5,-105)
			total_control_ring.position.x = -20
		"move":
			ally_sprite.position = Vector2(10,-105) if ally_sprite.flip_h else Vector2(-10,-105)
			total_control_ring.position.x = 5
		"rebirth":
			ally_sprite.position = Vector2(20,-110) if ally_sprite.flip_h else Vector2(-25,-110)
			total_control_ring.position.x = -20
		"skill1":
			ally_sprite.position = Vector2(10,-110) if ally_sprite.flip_h else Vector2(-15,-110)
			total_control_ring.position.x = -20
		"skill2","skill2_end":
			ally_sprite.position = Vector2(-5,-110) if ally_sprite.flip_h else Vector2(0,-110)
			total_control_ring.position.x = -20
		"skill2_power":
			ally_sprite.position = Vector2(0,-115) if ally_sprite.flip_h else Vector2(-5,-115)
			total_control_ring.position.x = -20
		"skill3":
			ally_sprite.position = Vector2(20,-120) if ally_sprite.flip_h else Vector2(-25,-120)
			total_control_ring.position.x = -20
		"skill4":
			ally_sprite.position = Vector2(10,-115) if ally_sprite.flip_h else Vector2(-15,-115)
			total_control_ring.position.x = -20
	
	god_ring.scale.x = -1 if ally_sprite.flip_h else 1
	pass 


func frame_changed():
	if ally_sprite.animation == "attack" and ally_sprite.frame == 7:
		var summon_pos: Vector2 = position
		summon_pos.x += -40 if ally_sprite.flip_h else 40
		normal_attack(summon_pos)
	elif ally_sprite.animation == "far_attack" and ally_sprite.frame == 7:
		if far_attack_target_enemy == null: return
		normal_attack(far_attack_target_enemy.position)
	elif ally_sprite.animation == "skill1" and ally_sprite.frame == 19:
		release_skill1()
	if ally_sprite.animation == "skill2":
		if ally_sprite.frame == 25:
			if is_power_type: ally_sprite.play("skill2_power")
			else: ally_sprite.play("skill2_end")
		elif ally_sprite.frame == 5:
			soul_kill()
		elif ally_sprite.frame == 17:
			var heal_rate: float = HeroSkillLibrary.hero_skill_data_library[ally_id][2].heal_rate[skill_levels[2]-1]
			var heal_data: int = float(start_data.health) * heal_rate
			current_data.heal(heal_data)
	if ally_sprite.animation == "skill2_power" and ally_sprite.frame == 14:
		skill2_second_hit()
	
	if ally_sprite.animation == "skill3" and ally_sprite.frame == 44:
		ally_sprite.pause()
		skill_3_release()
		await get_tree().create_timer(2,false).timeout
		if ally_state != AllyState.DIE:
			ally_sprite.play()
			create_tween().tween_property(total_control_ring,"scale",Vector2.ONE,0.5)
			skill_4_animation_player.play_backwards("release")
	
	if ally_sprite.animation == "skill4" and ally_sprite.frame == 42:
		stop_time()
	pass


func take_damage(damage: int, damage_type: DataProcess.DamageType, broken_rate: float, far_attack: bool = false, source: Node2D = null,explosion: bool = false,aoe_attack: bool = false, deadly: bool = true) -> bool:
	if damage_type == DataProcess.DamageType.TrueDamage or damage_type == DataProcess.DamageType.SuperDamage:
		return false
	broken_rate = 0
	return super(damage,damage_type,broken_rate,far_attack,source,explosion,aoe_attack,deadly)
	pass


func normal_attack(summon_pos: Vector2):
	get_exp(hero_property_block.xp_speed_rate * 100)
	var normal_attack_area: SkillConditionArea2D = preload("res://Scenes/Skills/mike_attack_area.tscn").instantiate()
	normal_attack_area.position = summon_pos
	normal_attack_area.skill_level = hero_level
	normal_attack_area.damage_low = current_data.near_damage_low
	normal_attack_area.damage_high = current_data.near_damage_high
	Stage.instance.bullets.add_child(normal_attack_area)
	pass


func teleport_move(target_pos: Vector2):
	Stage.instance.move_point_effect(target_pos)
	if ally_state == AllyState.SPECIAL:
		waiting_to_move = true
		next_move_position = navigation_agent.target_position
		return
	if current_intercepting_enemy != null:
		current_intercepting_enemy.current_intercepting_units.erase(self)
		current_intercepting_enemy = null
	if move_tween != null: move_tween.kill()
	translate_to_new_state(AllyState.SPECIAL)
	ally_sprite.play("move")
	ally_sprite.flip_h = target_pos.x < position.x
	await get_tree().create_timer(0.1,false).timeout
	shadow_timer.start()
	if randi_range(0,1) == 0:
		teleport_audio.play()
	else:
		teleport_audio_2.play()
	var teleport_tween: Tween = create_tween()
	var move_time: float = position.distance_to(target_pos) / 10000
	teleport_tween.tween_property(self,"position",target_pos,move_time)
	await teleport_tween.finished
	translate_to_new_state(AllyState.IDLE)
	shadow_timer.stop()
	station_position = target_pos
	intercepting_area.position = target_pos
	pass


func _on_shadow_timer_timeout() -> void:
	var shadow: AnimatedSprite2D = preload("res://Scenes/Effects/mike_shadow_effect.tscn").instantiate()
	shadow.scale.x = -1 if ally_sprite.flip_h else 1
	shadow.animation = ally_sprite.animation
	shadow.frame = ally_sprite.frame
	shadow.position = position
	Stage.instance.bullets.add_child(shadow)
	pass # Replace with function body.


func idle_process():
	if ally_sprite.animation == "idle":
		if skill_levels[2] > 0 and skill_2_timer.is_stopped() and magic_book_area.get_overlapping_bodies().size() >= 4:
			translate_to_new_state(AllyState.SPECIAL)
			ally_sprite.play("skill2")
			skill_2_timer.start()
			return
		if skill_levels[1] > 0 and skill_1_timer.is_stopped() and magic_book_area.get_overlapping_bodies().size() >= 3:
			translate_to_new_state(AllyState.SPECIAL)
			ally_sprite.play("skill1")
			skill_1_timer.start()
			return
		if skill_levels[4] > 0 and skill_4_timer.is_stopped() and skill_3_area.get_overlapping_bodies().size() >= 10:
			translate_to_new_state(AllyState.SPECIAL)
			ally_sprite.play("skill4")
			skill_4_timer.start()
			return
		if skill_levels[3] > 0 and skill_3_timer.is_stopped() and skill_3_area.get_overlapping_bodies().size() >= 6:
			translate_to_new_state(AllyState.SPECIAL)
			ally_sprite.play("skill3")
			skill_3_timer.start()
			ring_big_animation()
			return
	super()
	pass


func _on_power_timer_timeout() -> void:
	is_power_type = false
	create_tween().tween_property(power_light,"modulate:a",0,0.3)
	current_data.physic_immune = false
	current_data.magic_immune = false
	pass # Replace with function body.


func into_power_type():
	if current_element_strength == PowerElement.WIND:
		current_element_strength = PowerElement.FIRE
	else:
		current_element_strength += 1
	
	if current_element_strength == PowerElement.FIRE:
		var fire_buff: PropertyBuff = preload("res://Scenes/Buffs/Mike/mike_fire_buff.tscn").instantiate()
		buffs.add_child(fire_buff)
	elif current_element_strength == PowerElement.WATER:
		var water_buff: PropertyBuff = preload("res://Scenes/Buffs/Mike/mike_water_buff.tscn").instantiate()
		buffs.add_child(water_buff)
	elif current_element_strength == PowerElement.EARTH:
		current_data.physic_immune = true
	elif current_element_strength == PowerElement.WIND:
		current_data.magic_immune = true
	
	is_power_type = true
	power_timer.start()
	var power_shader: ShaderMaterial = power_light.material
	power_shader.set_shader_parameter("hue_shift",element_hue_list[current_element_strength])
	create_tween().tween_property(power_light,"modulate:a",1,0.3)
	pass


func release_skill1():
	var pos_list: Array[Vector2]
	for body in skill_1_trace_area.get_overlapping_bodies():
		var enemy: Enemy = body.owner
		var is_continue: bool = false
		for pos in pos_list:
			var distance: float = enemy.position.distance_to(pos)
			if distance < 100:
				is_continue = true
				break
		if is_continue: continue
		pos_list.append(enemy.position)
	#print(pos_list)
	var fire_count: int = HeroSkillLibrary.hero_skill_data_library[ally_id][1].fire_count[skill_levels[1]-1]
	if pos_list.size() > fire_count:
		pos_list.resize(fire_count)
	else:
		for i in fire_count - pos_list.size():
			var map = path_navigation_agent.get_navigation_map()
			var random_point: Vector2 = NavigationServer2D.map_get_random_point(map,path_navigation_agent.navigation_layers,true)
			pos_list.append(random_point)
	
	release_destroy_fire(pos_list)
	if is_power_type:
		destroy_second_explosion(pos_list)
	pass


func release_destroy_fire(pos_list: Array[Vector2]):
	#print(pos_list.size())
	for pos in pos_list:
		await get_tree().create_timer(randf_range(0.05,0.3),false).timeout
		var skill_area: SkillConditionArea2D = preload("res://Scenes/Skills/mike_terminator_area.tscn").instantiate()
		skill_area.position = pos
		Stage.instance.bullets.add_child(skill_area)
	pass


func destroy_second_explosion(pos_list: Array[Vector2]):
	await get_tree().create_timer(3,false).timeout
	for pos in pos_list:
		var second_area: Area2D = preload("res://Scenes/Skills/mike_ternimator_second_area.tscn").instantiate()
		second_area.position = pos
		Stage.instance.bullets.add_child(second_area)
		await get_tree().create_timer(randf_range(0.1,0.2),false).timeout
	pass


func battle():
	if ally_sprite.animation == "idle":
		if skill_1_timer.is_stopped() and skill_levels[1] > 0:
			translate_to_new_state(AllyState.SPECIAL)
			ally_sprite.play("skill1")
			skill_1_timer.start()
			return
		if skill_levels[2] > 0 and skill_2_timer.is_stopped() and skill2_can_release():
			translate_to_new_state(AllyState.SPECIAL)
			ally_sprite.play("skill2")
			skill_2_timer.start()
			return
		if skill_levels[3] > 0 and skill_3_timer.is_stopped() and skill_3_area.get_overlapping_bodies().size() >= 6:
			translate_to_new_state(AllyState.SPECIAL)
			ally_sprite.play("skill3")
			skill_3_timer.start()
			ring_big_animation()
			return
		if skill_levels[4] > 0 and skill_4_timer.is_stopped() and current_intercepting_enemy != null:
			if current_intercepting_enemy.enemy_type < Enemy.EnemyType.MiniBoss:
				translate_to_new_state(AllyState.SPECIAL)
				ally_sprite.play("skill4")
				skill_4_timer.start()
				return
	super()
	pass


func soul_kill():
	AudioManager.instance.witch_shot_audio.play()
	for body in magic_book_area.get_overlapping_bodies():
		var enemy: Enemy = body.owner
		if enemy.enemy_type == Enemy.EnemyType.Boss: continue
		enemy.disappear_kill()
		var dust: Node2D = preload("res://Scenes/Effects/dust_effect.tscn").instantiate()
		dust.position = enemy.position
		Stage.instance.bullets.add_child(dust)
		var soul: MagicBall = preload("res://Scenes/Effects/soul.tscn").instantiate()
		soul.position = enemy.hurt_box.global_position
		soul.target_position = sould_marker.global_position
		Stage.instance.bullets.add_child(soul)
		var effect: AnimatedSprite2D = preload("res://Scenes/Effects/bullet_explosion_effect.tscn").instantiate()
		effect.position = enemy.hurt_box.global_position
		Stage.instance.bullets.add_child(effect)
	pass


func skill2_second_hit():
	energy_explosion.show()
	energy_explosion.scale = Vector2.ZERO
	energy_explosion.modulate.a = 1
	create_tween().tween_property(energy_explosion,"scale",Vector2.ONE * 45, 0.6)
	create_tween().tween_property(energy_explosion,"modulate:a",0,0.55)
	AudioManager.instance.play_explosion_audio()
	skill_2_audio.play()
	Stage.instance.stage_camera.shake(20)
	var damage: int = HeroSkillLibrary.hero_skill_data_library[ally_id][2].second_damage[skill_levels[2]-1]
	for body in skill_2_area.get_overlapping_bodies():
		var enemy: Enemy = body.owner
		enemy.take_damage(damage,DataProcess.DamageType.SuperDamage,0,false,null,true,true,)
	pass


func skill2_can_release() -> bool:
	if current_intercepting_enemy == null: return false
	return current_intercepting_enemy.enemy_type != Enemy.EnemyType.Boss
	pass


func ring_big_animation():
	create_tween().tween_property(total_control_ring,"scale",Vector2.ONE * 4, 1)
	skill_3_prepare_audio.play()
	pass


func die(explosion: bool = false):
	create_tween().tween_property(god_ring,"modulate:a",0,0.4)
	total_control_ring.scale = Vector2.ONE
	skill_3_layer.hide()
	skill_3_particle.hide()
	super(explosion)
	pass


func rebirth():
	create_tween().tween_property(god_ring,"modulate:a",1,0.4)
	total_control_ring.scale = Vector2.ONE
	super()
	pass


func skill_3_release():
	z_index = 10
	skill_3_particle.show()
	skill_3_release_audio.play()
	skill_3_layer.show()
	skill_4_animation_player.play("release")
	for i in 10:
		AudioManager.instance.play_explosion_audio()
		Stage.instance.stage_camera.shake(40)
		skill_3_dot_timer.start()
		await skill_3_dot_timer.timeout
		if ally_state == AllyState.DIE: break
	if ally_state != AllyState.DIE:
		skill_3_particle.hide()
		await get_tree().create_timer(0.4,false).timeout
		z_index = 0
	if is_power_type:
		add_skill3_fire_buff()
	pass


func _on_skill_3_dot_timer_timeout() -> void:
	var damage: int = HeroSkillLibrary.hero_skill_data_library[ally_id][3].damage[skill_levels[3]-1]
	for body in skill_3_area.get_overlapping_bodies():
		var enemy: Enemy = body.owner
		enemy.take_damage(damage,DataProcess.DamageType.SuperDamage,0,false,null,true,true)
	pass # Replace with function body.


func add_skill3_fire_buff():
	await get_tree().create_timer(0.5,false).timeout
	#print("skill3_fire")
	for body in skill_3_area.get_overlapping_bodies():
		var enemy: Enemy = body.owner
		var fire_dot_buff: DotBuff = preload("res://Scenes/Buffs/Mike/mike_fire_dot_buff.tscn").instantiate()
		fire_dot_buff.buff_level = skill_levels[3]
		enemy.buffs.add_child(fire_dot_buff)
	pass


func stop_time():
	skill_4_layer.show()
	#skill_4_layer.position = Vector2(960,540)
	#skill_4_layer.position += self.to_local(Stage.instance.stage_camera.global_position)
	stop_time_audio_play()
	for_ready_to_wave()
	Stage.instance.background.process_mode = Node.PROCESS_MODE_DISABLED
	stop_timer_player.play("stop_time")
	Stage.instance.wave_buttons.process_mode = Node.PROCESS_MODE_DISABLED
	Stage.instance.wave_during_timer.paused = true
	Stage.instance.wave_next_timer.paused = true
	Stage.instance.enemies.process_mode = Node.PROCESS_MODE_DISABLED
	for enemy_path: EnemyPath in Stage.instance.enemies.get_children():
		for enemy in enemy_path.get_children():
			if enemy is Enemy:
				var freeze_buff: PropertyBuff = preload("res://Scenes/Buffs/Mike/freeze_buff.tscn").instantiate()
				freeze_buff.duration = skill_4_duration_timer.wait_time
				enemy.buffs.add_child(freeze_buff)
	
	skill_4_duration_timer.start()
	if is_power_type:
		await skill_4_duration_timer.timeout
		stop_time_power()
	pass


func stop_time_power():
	for enemy_path: EnemyPath in Stage.instance.enemies.get_children():
		for enemy in enemy_path.get_children():
			if enemy is Enemy:
				var slow_buff: PropertyBuff = preload("res://Scenes/Buffs/Mike/mike_slow_buff.tscn").instantiate()
				enemy.buffs.add_child(slow_buff)
	pass


func _on_skill_4_duration_timer_timeout() -> void:
	Stage.instance.wave_buttons.process_mode = Node.PROCESS_MODE_INHERIT
	Stage.instance.wave_during_timer.paused = false
	Stage.instance.wave_next_timer.paused = false
	Stage.instance.enemies.process_mode = Node.PROCESS_MODE_INHERIT
	Stage.instance.background.process_mode = Node.PROCESS_MODE_INHERIT
	stop_time_layer_player.play_backwards("show")
	var damage_rate: float = HeroSkillLibrary.hero_skill_data_library[ally_id][4].damage_rate[skill_levels[4]-1]
	for enemy_path: EnemyPath in Stage.instance.enemies.get_children():
		for enemy in enemy_path.get_children():
			if enemy is Enemy:
				if enemy.enemy_type >= Enemy.EnemyType.MiniBoss: continue
				var damage: int = float(enemy.start_data.health) * damage_rate
				enemy.take_damage(damage,DataProcess.DamageType.SuperDamage,0,false,null,false,true,false)
	pass # Replace with function body.


func on_stop_time():
	stop_time_layer_player.play("show")
	pass


func stop_time_audio_play():
	stop_time_audio.play()
	var loop_count: int = skill_4_duration_timer.wait_time
	for i in loop_count-1:
		await get_tree().create_timer(1,false).timeout
		clock_audio.play()
	pass


func for_ready_to_wave():
	var origin_ready: bool = Stage.instance.ready_for_new_wave
	Stage.instance.ready_for_new_wave = false
	await skill_4_duration_timer.timeout
	Stage.instance.ready_for_new_wave = origin_ready
	pass
