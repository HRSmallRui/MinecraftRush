extends Enemy

@export var appear_marker_list: Array[Marker2D]
@export var roar_audio_list: Array[AudioStream]
@export var whale_audio_list: Array[AudioStream]
@export var start_marker_begin_position: Vector2
@export var start_marker_end_position: Vector2

@onready var boss_ui: BossUI = $BossUI
@onready var poise_bar: TextureProgressBar = $BossUI/Panel/PoiseBar
@onready var roar_audio: AudioStreamPlayer = $RoarAudio
@onready var whale_audio: AudioStreamPlayer = $WhaleAudio
@onready var ray_start_marker: Marker2D = $UnitBody/RayStartMarker
@onready var ray_line: Line2D = $RayLine
@onready var end_point_particle: GPUParticles2D = $EndPointParticle
@onready var start_point_particle: GPUParticles2D = $StartPointParticle
@onready var on_water_timer: Timer = $OnWaterTimer
@onready var wait_skill_timer: Timer = $WaitSkillTimer
@onready var appear_again_timer: Timer = $AppearAgainTimer
@onready var ray_audio: AudioStreamPlayer = $RayAudio
@onready var elec_audio: AudioStreamPlayer = $ElecAudio
@onready var explosion_timer: Timer = $ExplosionTimer
@onready var ray_hit_area: Area2D = $RayHitArea
@onready var explosion_hit_area: Area2D = $ExplosionHitArea
@onready var recover_timer: Timer = $RecoverTimer
@onready var ray_condition_area: Area2D = $UnitBody/RayConditionArea
@onready var ray_audio_2: AudioStreamPlayer = $RayAudio2
@onready var doom_timer: Timer = $DoomTimer
@onready var energy_ball: Sprite2D = $UnitBody/EnergyBall
@onready var skill_3_audio: AudioStreamPlayer = $Skill3Audio
@onready var doom_animation_player: AnimationPlayer = $DangerTip/DoomAnimationPlayer
@onready var roar_animation_player: AnimationPlayer = $RoarLayer/RoarAnimationPlayer

var max_poise: int = 800
var poise: int = 800
var ray_end_position: Vector2
var ray_link_enemy_curve: Curve2D
var ray_shoot_progress: float = 0:
	set(v):
		ray_shoot_progress = v
		if ray_link_enemy_curve == null: return
		ray_end_position = ray_link_enemy_curve.sample_baked(ray_shoot_progress)
		var land_dust: Sprite2D = preload("res://Scenes/Effects/fuchen_land_dust.tscn").instantiate()
		land_dust.position = ray_end_position
		Stage.instance.bullets.add_child(land_dust)


var is_broken_state: bool = false
var lock_poise: bool = false
var is_first_appear: bool = true
var last_skill_id: int = 1
var doom_released: bool = false


func _ready() -> void:
	ray_line.hide()
	end_point_particle.hide()
	start_point_particle.hide()
	ray_line.width = 0
	wait_skill_timer.wait_time = randf_range(3,5)
	ray_hit_area.monitoring = false
	energy_ball.hide()
	super()
	enemy_button.hide()
	poise_bar.value = 0
	start_data.total_defence_rate = 0.2
	current_data.update_total_defence_rate()
	translate_to_new_state(EnemyState.SPECIAL)
	body_collision.disabled = true
	hurt_box.monitorable = false
	await get_tree().process_frame
	hide()
	boss_ui.process_mode = Node.PROCESS_MODE_DISABLED
	await get_tree().create_timer(2.5,false).timeout
	show()
	enemy_button.show()
	body_collision.disabled = false
	hurt_box.monitorable = true
	boss_ui.process_mode = Node.PROCESS_MODE_INHERIT
	Stage.instance.is_special_wave = true
	enemy_sprite.play("appear")
	position = appear_marker_list[0].global_position
	await get_tree().create_timer(1,false).timeout
	enemy_sprite.play("bark")
	wait_skill_timer.start()
	pass


@warning_ignore("unused_parameter")
func move_process(delta_time: float):
	
	pass


func anim_offset():
	match enemy_sprite.animation:
		"idle":
			enemy_sprite.position = Vector2(0,-545)
		"appear":
			enemy_sprite.position = Vector2(0,-720)
		"bark":
			enemy_sprite.position = Vector2(-35,-590)
		"broken":
			enemy_sprite.position = Vector2(-10,-690)
		"die":
			enemy_sprite.position = Vector2(-30,-555)
		"hide":
			enemy_sprite.position = Vector2(60,-885)
		"recover":
			enemy_sprite.position = Vector2(-35,-550)
		"skill1":
			enemy_sprite.position = Vector2(0,-680)
		"skill2":
			enemy_sprite.position = Vector2(-30,-485)
		"skill3_loop":
			enemy_sprite.position = Vector2(0,-655)
		"skill3_start":
			enemy_sprite.position = Vector2(0,-635)
		"skill3_release":
			enemy_sprite.position = Vector2(-5,-810)
	pass


func frame_changed():
	if enemy_sprite.animation == "bark" and enemy_sprite.frame == 9:
		roar()
	if enemy_sprite.animation == "broken" and enemy_sprite.frame == 20:
		enemy_sprite.pause()
	if enemy_sprite.animation == "appear" and enemy_sprite.frame == 5:
		water_effect()
	if enemy_sprite.animation == "skill1":
		if enemy_sprite.frame == 10:
			enemy_sprite.speed_scale = 0.5
			ray_start_marker.position = start_marker_begin_position
			create_tween().tween_property(ray_start_marker,"position",start_marker_end_position,2)
			ray_line.show()
			ray_audio.play()
			elec_audio.play()
			start_point_particle.show()
			end_point_particle.show()
			create_tween().tween_property(ray_line,"width",60,0.5)
			shoot_ray()
			lock_poise = true
			ray_hit_area.monitoring = true
			start_point_particle.amount_ratio = 1
			end_point_particle.amount_ratio = 1
		if enemy_sprite.frame == 41:
			#ray_line.hide()
			explosion_timer.stop()
			enemy_sprite.speed_scale = 1
			ray_audio.stop()
			elec_audio.stop()
			var ray_tween: Tween = create_tween()
			ray_tween.tween_property(ray_line,"width",0,0.5)
			create_tween().tween_property(ray_start_marker,"position",start_marker_begin_position,0.5)
			ray_hit_area.monitoring = false
			
			await ray_tween.finished
			ray_line.hide()
			start_point_particle.hide()
			end_point_particle.hide()
			if enemy_state != EnemyState.DIE:
				on_water_timer.start()
			start_point_particle.amount_ratio = 0
			end_point_particle.amount_ratio = 0
	
	if enemy_sprite.animation == "hide":
		if enemy_sprite.frame == 14:
			water_effect()
		if enemy_sprite.frame == 24:
			hide()
			enemy_sprite.pause()
			if Stage.instance.information_bar.current_check_member == self:
				Stage.instance.ui_process(null)
			var heal_health: int
			var heal_rate: float = 0.05
			if health_bar.value < 0.1: 
				heal_rate += 0.03
				max_poise = 1000
			heal_health = float(start_data.health) * heal_rate
			#print(heal_health)
			poise = max_poise
			current_data.heal(heal_health)
			set_appear_again_timer_time()
			appear_again_timer.start()
	
	if enemy_sprite.animation == "skill2" and enemy_sprite.frame == 18:
		lock_poise = true
		skill2_release()
		on_water_timer.start()
	
	if enemy_sprite.animation == "skill3_start" and enemy_sprite.frame == 10:
		enemy_sprite.play("skill3_loop")
		doom_timer.start()
		energy_ball.show()
		doom_animation_player.play("appear")
	if enemy_sprite.animation == "skill3_release" and enemy_sprite.frame == 6:
		energy_ball.hide()
		skill3_release()
		skill_3_audio.play()
	
	if enemy_sprite.animation == "die" and enemy_sprite.frame == 8:
		roar()
	if enemy_sprite.animation == "die" and enemy_sprite.frame == 36:
		water_effect()
	if enemy_sprite.animation == "broken" and enemy_sprite.frame == 19:
		water_effect()
	pass


func _process(delta: float) -> void:
	super(delta)
	if boss_ui.process_mode == ProcessMode.PROCESS_MODE_DISABLED: return
	var poise_tween: Tween = create_tween().set_speed_scale(1 / Engine.time_scale)
	var target_value: float = float(poise) / max_poise
	poise_tween.tween_property(poise_bar,"value",target_value ,abs(target_value - poise_bar.value)/(50 * delta))
	
	ray_process()
	pass


func take_damage(damage: int, damage_type: DataProcess.DamageType, broken_rate: float, far_attack: bool = false, source: Node2D = null,explosion: bool = false,aoe_attack: bool = false, deadly: bool = true) -> bool:
	if !is_broken_state and !lock_poise:
		poise -= damage
		if poise <= 0: broken()
	
	return super(damage,damage_type,broken_rate,far_attack,source,explosion,aoe_attack,deadly)
	pass


func broken():
	is_broken_state = true
	roar()
	start_data.total_defence_rate = 0
	if enemy_sprite.animation == "skill3_loop":
		take_damage(400,DataProcess.DamageType.TrueDamage,0,)
		var explosion_effect: AnimatedSprite2D = preload("res://Scenes/Effects/bullet_explosion_effect.tscn").instantiate()
		explosion_effect.position = energy_ball.global_position
		explosion_effect.scale *= 3
		Stage.instance.bullets.add_child(explosion_effect)
		AudioManager.instance.play_explosion_audio()
		Stage.instance.stage_camera.shake(20)
	
	start_data.vulnerable_rate = 0.2
	current_data.update_total_defence_rate()
	current_data.update_vulnerable_rate()
	wait_skill_timer.stop()
	recover_timer.start()
	doom_timer.stop()
	energy_ball.hide()
	enemy_sprite.play("broken")
	enemy_sprite.speed_scale = 1
	pass


func roar():
	Stage.instance.stage_camera.shake(30)
	roar_audio.stream = roar_audio_list.pick_random()
	whale_audio.stream = whale_audio_list.pick_random()
	roar_audio.play()
	whale_audio.play()
	roar_animation_player.play("shake")
	pass


func water_effect():
	AudioManager.instance.play_water_audio()
	var water_particle: AnimatedSprite2D = preload("res://Scenes/Effects/block_particle.tscn").instantiate()
	water_particle.position = position + Vector2(0,-20)
	water_particle.modulate = Color(0,0.8,1,0.6)
	water_particle.scale *= 4
	Stage.instance.bullets.add_child(water_particle)
	AudioManager.instance.play_water_audio()
	pass


func release_skill_1():
	lock_poise = true
	pass


func ray_process():
	ray_line.set_point_position(0,ray_start_marker.global_position)
	start_point_particle.global_position = ray_start_marker.global_position
	ray_line.set_point_position(1,ray_end_position)
	end_point_particle.global_position = ray_end_position
	ray_hit_area.global_position = ray_end_position
	pass


func _on_on_water_timer_timeout() -> void:
	body_collision.disabled = true
	hurt_box.get_child(0).disabled = true
	clear_buff()
	enemy_sprite.play("hide")
	pass # Replace with function body.


func _on_wait_skill_timer_timeout() -> void:
	var skill_list: Array[int] = [1,2,3]
	skill_list.erase(last_skill_id)
	
	var skill_type: int = skill_list.pick_random()
	if is_first_appear: 
		skill_type = 1
		is_first_appear = false
	
	
	match skill_type:
		1:
			enemy_sprite.play("skill1")
			last_skill_id = 1
		2:
			enemy_sprite.play("skill2")
			last_skill_id = 2
		3:
			enemy_sprite.play("skill3_start")
			last_skill_id = 3
	pass # Replace with function body.


func _on_appear_again_timer_timeout() -> void:
	appear()
	await get_tree().create_timer(4,false).timeout
	if enemy_state != EnemyState.DIE and randf_range(0,1) < 0.4:
		ghost_skill()
	pass # Replace with function body.


func appear():
	show()
	lock_poise = false
	var marker_id: int = randi_range(0,2)
	match marker_id:
		0:
			progress_ratio = 0.17
		1:
			progress_ratio = 0.5
		2:
			progress_ratio = 0.8
	position = appear_marker_list[marker_id].global_position
	
	enemy_sprite.play("appear")
	await get_tree().create_timer(1,false).timeout
	enemy_sprite.play("bark")
	wait_skill_timer.wait_time = randf_range(3,5)
	wait_skill_timer.start()
	body_collision.disabled = false
	hurt_box.get_child(0).disabled = false
	#print(global_position)
	#print(hurt_box.global_position)
	pass


func into_water():
	
	pass


func die(explosion: bool = false):
	super(explosion)
	wait_skill_timer.stop()
	on_water_timer.stop()
	appear_again_timer.stop()
	ray_audio.stop()
	elec_audio.stop()
	ray_line.hide()
	start_point_particle.hide()
	end_point_particle.hide()
	explosion_timer.stop()
	recover_timer.stop()
	doom_timer.stop()
	energy_ball.hide()
	roar_audio.stop()
	whale_audio.stop()
	enemy_sprite.speed_scale = 1
	
	Achievement.achieve_complete("Boss4Dead")
	if !doom_released:
		Achievement.achieve_complete("Boss4DeadPerfect")
	
	await get_tree().create_timer(2,false).timeout
	create_tween().tween_property(boss_ui.panel,"modulate:a",0,1)
	pass


func ghost_skill():
	var ghost: CanvasLayer = preload("res://Scenes/Skills/guardian_ghost.tscn").instantiate()
	Stage.instance.add_child(ghost)
	pass


func shoot_ray():
	explosion_timer.start()
	var enemy_path_array: Array[EnemyPath]
	for enemy_path: EnemyPath in Stage.instance.enemies.get_children():
		if enemy_path.enabled: enemy_path_array.append(enemy_path)
	var enemy_path = enemy_path_array.pick_random() as EnemyPath
	ray_link_enemy_curve = enemy_path.curve
	ray_shoot_progress = ray_link_enemy_curve.get_baked_length() - 50
	create_tween().tween_property(self,"ray_shoot_progress",ray_shoot_progress - 800,2)
	pass


func _on_explosion_timer_timeout() -> void:
	var explosion_pos: Vector2 = ray_end_position
	await get_tree().create_timer(2.5,false).timeout
	ray_explosion(explosion_pos)
	pass # Replace with function body.


func ray_explosion(explosion_pos: Vector2):
	var explosion_effect: AnimatedSprite2D = preload("res://Scenes/Effects/bullet_explosion_effect.tscn").instantiate()
	explosion_effect.position = explosion_pos
	explosion_effect.scale *= 2
	Stage.instance.bullets.add_child(explosion_effect)
	AudioManager.instance.play_explosion_audio()
	Stage.instance.stage_camera.shake(40)
	explosion_hit_area.position = explosion_pos
	
	var fire_effect: AnimatedSprite2D = preload("res://Scenes/Effects/fire_particle.tscn").instantiate()
	fire_effect.position = explosion_pos
	fire_effect.scale *= 2
	Stage.instance.bullets.add_child(fire_effect)
	var smoke_effect: AnimatedSprite2D = preload("res://Scenes/Effects/smoke_effect.tscn").instantiate()
	smoke_effect.position = explosion_pos
	smoke_effect.scale *= 2
	Stage.instance.bullets.add_child(smoke_effect)
	
	await get_tree().physics_frame
	for body in explosion_hit_area.get_overlapping_bodies():
		var ally: Ally = body.owner
		var damage: int = randi_range(300,400)
		ally.take_damage(damage,DataProcess.DamageType.ExplodeDamage,0,false,self,false,true,)
	pass


func _on_ray_hit_area_area_entered(area: Area2D) -> void:
	var ally: Ally = area.owner
	var damage: int = 180
	ally.take_damage(damage,DataProcess.DamageType.MagicDamage,0,true,self,false,true,)
	pass # Replace with function body.


func set_appear_again_timer_time():
	appear_again_timer.wait_time = randf_range(8,10)
	pass


func _on_recover_timer_timeout() -> void:
	enemy_sprite.play("recover")
	poise = max_poise
	start_data.total_defence_rate = 0.2
	start_data.vulnerable_rate = 0
	current_data.update_total_defence_rate()
	current_data.update_vulnerable_rate()
	on_water_timer.start()
	is_broken_state = false
	lock_poise = true
	await get_tree().create_timer(1,false).timeout
	if enemy_state != EnemyState.DIE:
		enemy_sprite.play("bark")
	pass # Replace with function body.


func skill2_release():
	var ally_list: Array[Ally]
	var tower_list: Array[DefenceTower]
	for body in ray_condition_area.get_overlapping_bodies():
		var ally: Ally = body.owner
		ally_list.append(ally)
	for tower: DefenceTower in Stage.instance.towers.get_children():
		if tower.tower_level > 0: tower_list.append(tower)
	
	if !ally_list.is_empty() and randf_range(0,1) < 0.2:
		var target_ally: Ally = ally_list[0]
		for ally in ally_list:
			if ally.current_data.health > target_ally.current_data.health: target_ally = ally
		attack_ally(target_ally)
		return
	if tower_list.is_empty() and !ally_list.is_empty():
		var target_ally: Ally = ally_list[0]
		for ally in ally_list:
			if ally.current_data.health > target_ally.current_data.health: target_ally = ally
		attack_ally(target_ally)
		return
	if !tower_list.is_empty():
		destroy_tower(get_expensive_tower(tower_list))
		return
	enemy_sprite.play("skill1")
	enemy_sprite.frame = 9
	#print("change_skill")
	pass


func attack_ally(ally: Ally):
	start_point_particle.show()
	start_point_particle.amount_ratio = 1
	end_point_particle.show()
	end_point_particle.amount_ratio = 1
	ray_line.show()
	ray_line.width = 0
	ray_end_position = ally.hurt_box.global_position
	ray_start_marker.position = start_marker_begin_position
	var ray_tween: Tween = create_tween()
	ray_tween.tween_property(ray_line,"width",60,0.3)
	var damage: int = randi_range(800,1200)
	ally.take_damage(damage,DataProcess.DamageType.MagicDamage,0,true,self,false,true,)
	ray_audio_2.play()
	elec_audio.play()
	await ray_tween.finished
	
	var finish_tween: Tween = create_tween()
	finish_tween.tween_property(ray_line,"width",0,0.2)
	await finish_tween.finished
	elec_audio.stop()
	start_point_particle.hide()
	start_point_particle.amount_ratio = 0
	end_point_particle.hide()
	end_point_particle.amount_ratio = 0
	pass


func destroy_tower(tower: DefenceTower):
	start_point_particle.show()
	start_point_particle.amount_ratio = 1
	end_point_particle.show()
	end_point_particle.amount_ratio = 1
	ray_line.show()
	ray_line.width = 0
	ray_end_position = tower.position + Vector2(0,-10)
	ray_start_marker.position = start_marker_begin_position
	var ray_tween: Tween = create_tween()
	ray_tween.tween_property(ray_line,"width",60,0.3)
	var damage: int = randi_range(800,1200)
	tower.destroy_tower()
	ray_audio_2.play()
	elec_audio.play()
	
	var explosion_effect: AnimatedSprite2D = preload("res://Scenes/Effects/bullet_explosion_effect.tscn").instantiate()
	explosion_effect.position = tower.position
	Stage.instance.bullets.add_child(explosion_effect)
	AudioManager.instance.play_explosion_audio()
	Stage.instance.stage_camera.shake(20)
	var smoke_effect: AnimatedSprite2D = preload("res://Scenes/Effects/smoke_effect.tscn").instantiate()
	smoke_effect.position = tower.position
	Stage.instance.bullets.add_child(smoke_effect)
	await ray_tween.finished
	
	var finish_tween: Tween = create_tween()
	finish_tween.tween_property(ray_line,"width",0,0.2)
	await finish_tween.finished
	elec_audio.stop()
	start_point_particle.hide()
	start_point_particle.amount_ratio = 0
	end_point_particle.hide()
	end_point_particle.amount_ratio = 0
	pass


func _on_doom_timer_timeout() -> void:
	enemy_sprite.play("skill3_release")
	lock_poise = true
	on_water_timer.start()
	pass # Replace with function body.


func skill3_release():
	doom_released = true
	for i in 48:
		var target_pos: Vector2 = Vector2(randf_range(0,2100),randf_range(0,1300))
		var enemy_path: EnemyPath = Stage.instance.enemies.get_children()[randf_range(0,17)]
		target_pos = enemy_path.curve.get_closest_point(target_pos)
		var guardian_ball: Bullet = preload("res://Scenes/Bullets/guardian_ball.tscn").instantiate()
		guardian_ball.position = Vector2(randf_range(-200,2300),-100)
		guardian_ball.target_position = target_pos
		Stage.instance.bullets.add_child(guardian_ball)
		await get_tree().create_timer(0.02,false).timeout
	pass


func get_expensive_tower(tower_list: Array[DefenceTower]) -> DefenceTower:
	var back_tower: DefenceTower = tower_list[0]
	for tower in tower_list:
		if tower.tower_value > back_tower.tower_value:
			back_tower = tower
	return back_tower
