extends Hero

@export var lightning_hit_random_textures: Array[Texture]

@onready var robort_teleport_audio: AudioStreamPlayer = $RobortTeleportAudio
@onready var lightning_start: Sprite2D = $FarAttackLightningComponent/LightningStart
@onready var lightning_start_particle: Sprite2D = $FarAttackLightningComponent/LightningStart/LightningStartParticle
@onready var lightning_end: Sprite2D = $FarAttackLightningComponent/LightningEnd
@onready var lightning_end_particle: Sprite2D = $FarAttackLightningComponent/LightningEnd/LightningEndParticle
@onready var lightning_line: Line2D = $FarAttackLightningComponent/LightningLine
@onready var far_attack_lightning_component: Node2D = $FarAttackLightningComponent
@onready var lightning_audio: AudioStreamPlayer = $LightningAudio
@onready var skill_1_condition_area: Area2D = $UnitBody/Skill1ConditionArea
@onready var skill_1_timer: Timer = $Skill1Timer
@onready var skill_2_audio: AudioStreamPlayer = $Skill2Audio
@onready var skill_2_timer: Timer = $Skill2Timer
@onready var skill_2_hit_area: Area2D = $Skill2HitArea
@onready var fire_end_marker: Marker2D = $Skill2HitArea/FireEndMarker
@onready var skill_3_condition_area: Area2D = $UnitBody/Skill3ConditionArea
@onready var skill_3_timer: Timer = $Skill3Timer

var skill1_locked_enemy: Enemy
var skill2_locked_enemy: Enemy
var skill3_locked_enemy_path: EnemyPath


func _ready() -> void:
	super()
	far_attack_lightning_component.hide()
	skill_1_timer.wait_time = HeroSkillLibrary.hero_skill_data_library[ally_id][1].CD
	skill_2_timer.wait_time = HeroSkillLibrary.hero_skill_data_library[ally_id][2].CD
	skill_3_timer.wait_time = HeroSkillLibrary.hero_skill_data_library[ally_id][3].CD
	pass


func start_data_process():
	super()
	match hero_level:
		1,2,3,4: skill_levels[0] = 1
		5,6,7,8: skill_levels[0] = 2
		9,10: skill_levels[0] = 3
	if skill_levels[4] > 0:
		var upgrade_damage: int = HeroSkillLibrary.hero_skill_data_library[ally_id][4].upgrade_damage[skill_levels[4]-1]
		start_data.far_damage_low += upgrade_damage
		start_data.far_damage_high += upgrade_damage
	pass


func anim_offset():
	match ally_sprite.animation:
		"attack","idle":
			ally_sprite.position = Vector2(10,-105) if ally_sprite.flip_h else Vector2(-15,-105)
		"die":
			ally_sprite.position = Vector2(-30,-90) if ally_sprite.flip_h else Vector2(25,-90)
		"far_attack","skill2":
			ally_sprite.position = Vector2(20,-95) if ally_sprite.flip_h else Vector2(-20,-95)
		"move":
			ally_sprite.position = Vector2(-10,-85) if ally_sprite.flip_h else Vector2(10,-85)
		"skill1","teleport":
			ally_sprite.position = Vector2(-5,-95) if ally_sprite.flip_h else Vector2(0,-95)
		"skill3":
			ally_sprite.position = Vector2(-5,-100) if ally_sprite.flip_h else Vector2(0,-100)
		"rebirth":
			ally_sprite.position = Vector2(60,-135) if ally_sprite.flip_h else Vector2(-60,-135)
	pass


func frame_changed():
	if ally_sprite.animation == "attack" and ally_sprite.frame == 20:
		cause_damage()
	if ally_sprite.animation == "teleport":
		if ally_sprite.frame == 16:
			teleport_effect()
			ally_sprite.hide()
		if ally_sprite.frame == 20:
			teleport_finished()
			ally_sprite.show()
	if ally_sprite.animation == "far_attack" and ally_sprite.frame == 16:
		release_lightning()
		lightning_audio.play()
	if ally_sprite.animation == "skill1" and ally_sprite.frame == 16:
		release_tornado()
		robort_teleport_audio.play()
	if ally_sprite.animation == "skill2" and ally_sprite.frame == 16:
		skill_2_audio.play(0.2)
		release_flame()
	if ally_sprite.animation == "skill3" and ally_sprite.frame == 18:
		release_earth_queake()
		AudioManager.instance.play_explosion_audio()
		var teleport_effect: AnimatedSprite2D = preload("res://Scenes/Effects/bullet_explosion_effect.tscn").instantiate()
		teleport_effect.position = global_position
		Stage.instance.bullets.add_child(teleport_effect)
	pass


func teleport_effect():
	var teleport_effect: AnimatedSprite2D = preload("res://Scenes/Effects/bullet_explosion_effect.tscn").instantiate()
	teleport_effect.scale *= 1
	teleport_effect.position = global_position
	Stage.instance.bullets.add_child(teleport_effect)
	robort_teleport_audio.play(0.2)
	pass


func _on_lightning_timer_timeout() -> void:
	lightning_start.rotation_degrees = randf_range(0,360)
	lightning_start_particle.global_rotation = 0
	var erase_texture: Texture = lightning_start_particle.texture
	var start_array: Array[Texture] = lightning_hit_random_textures.duplicate()
	start_array.erase(erase_texture)
	lightning_start_particle.texture = start_array[randi_range(0,start_array.size()-1)]
	
	lightning_end.rotation_degrees = randf_range(0,360)
	lightning_end_particle.global_rotation = 0
	erase_texture = lightning_end_particle.texture
	var end_array: Array[Texture] = lightning_hit_random_textures.duplicate()
	end_array.erase(erase_texture)
	lightning_end_particle.texture = end_array[randi_range(0,end_array.size()-1)]
	pass # Replace with function body.


func _process(delta: float) -> void:
	super(delta)
	lightning_start.position = far_attack_marker_flip.position if ally_sprite.flip_h else far_attack_marker.position
	if far_attack_target_enemy != null:
		lightning_end.global_position = far_attack_target_enemy.hurt_box.global_position
	lightning_line.set_point_position(0,lightning_start.global_position)
	lightning_line.set_point_position(1,lightning_end.global_position)
	pass


func release_lightning():
	if far_attack_target_enemy == null:
		if far_attack_area.has_overlapping_bodies():
			far_attack_target_enemy = far_attack_area.get_overlapping_bodies()[0].owner
			ally_sprite.flip_h = far_attack_target_enemy.position.x < position.x
			anim_offset()
			release_lightning()
			return
		else:
			null_release()
			return
	elif far_attack_target_enemy.enemy_state == Enemy.EnemyState.DIE:
		if far_attack_area.has_overlapping_bodies():
			far_attack_target_enemy = far_attack_area.get_overlapping_bodies()[0].owner
			anim_offset()
			release_lightning()
			return
		else:
			null_release()
			return
	
	var dot_buff: DotBuff = preload("res://Scenes/Buffs/Robort/robort_lighning_dot.tscn").instantiate()
	var damage: float = randi_range(current_data.far_damage_low,current_data.far_damage_high)
	dot_buff.duration *= damage
	far_attack_target_enemy.buffs.add_child(dot_buff)
	get_exp(int(damage * exp_rate))
	
	far_attack_lightning_component.show()
	lightning_line.show()
	lightning_start.modulate.a = 0
	lightning_end.modulate.a = 0
	var show_time: float = 0.2
	create_tween().tween_property(lightning_start,"modulate:a",1,show_time)
	create_tween().tween_property(lightning_end,"modulate:a",1,show_time)
	await get_tree().create_timer(show_time,false).timeout
	if far_attack_target_enemy != null:
		passive_skill_release(far_attack_target_enemy.hurt_box.global_position)
		if skill_levels[4] > 0:
			strength_area_release(far_attack_target_enemy.hurt_box.global_position)
	lightning_line.hide()
	var disappear_time: float = 0.2
	create_tween().tween_property(lightning_start,"modulate:a",0,disappear_time)
	create_tween().tween_property(lightning_end,"modulate:a",0,disappear_time)
	await get_tree().create_timer(disappear_time,false).timeout
	far_attack_lightning_component.hide()
	pass


func null_release():
	far_attack_lightning_component.show()
	lightning_end.modulate.a = 0
	lightning_start.modulate.a = 0
	lightning_line.hide()
	var show_time: float = 0.2
	create_tween().tween_property(lightning_start,"modulate:a",1,show_time)
	await get_tree().create_timer(show_time,false).timeout
	var disappear_time: float = 0.2
	create_tween().tween_property(lightning_start,"modulate:a",0,disappear_time)
	await get_tree().create_timer(disappear_time,false).timeout
	far_attack_lightning_component.hide()
	pass


func passive_skill_release(target_pos: Vector2):
	var robort_aoe_area: SkillConditionArea2D = preload("res://Scenes/Skills/robort_lightning_hit_area.tscn").instantiate()
	robort_aoe_area.global_position = target_pos
	robort_aoe_area.skill_level = skill_levels[0]
	Stage.instance.bullets.add_child(robort_aoe_area)
	pass


func strength_area_release(target_pos: Vector2):
	var stength_area: SkillConditionArea2D = preload("res://Scenes/Skills/robort_lightning_ally_area.tscn").instantiate()
	stength_area.global_position = target_pos
	stength_area.skill_level = skill_levels[4]
	Stage.instance.bullets.add_child(stength_area)
	pass


func idle_process():
	super()
	if ally_state != AllyState.IDLE: return
	if ally_sprite.animation != "idle": return
	if skill_levels[2] > 0 and skill_2_timer.is_stopped() and far_attack_area.has_overlapping_bodies():
		skill2_locked_enemy = far_attack_area.get_overlapping_bodies()[0].owner
		translate_to_new_state(AllyState.SPECIAL)
		ally_sprite.play("skill2")
		ally_sprite.flip_h = skill2_locked_enemy.position.x < position.x
		skill_2_timer.start()
		far_attack_timer.start()
		return
	if skill_levels[3] > 0 and skill_3_timer.is_stopped() and skill_3_condition_area.get_overlapping_bodies().size() >= 2:
		var locked_enemy_path: EnemyPath = Stage.instance.get_closest_enemy_path(position)
		if locked_enemy_path != null:
			skill3_locked_enemy_path = locked_enemy_path
			translate_to_new_state(AllyState.SPECIAL)
			ally_sprite.play("skill3")
			skill_3_timer.start()
			return
	if skill_levels[1] > 0 and skill_1_timer.is_stopped() and skill_1_condition_area.has_overlapping_bodies():
		var locked_enemy: Enemy = get_skill1_locked_enemy()
		if locked_enemy != null:
			skill1_locked_enemy = locked_enemy
			translate_to_new_state(AllyState.SPECIAL)
			ally_sprite.play("skill1")
			ally_sprite.flip_h = locked_enemy.position.x < position.x
			skill_1_timer.start()
			far_attack_timer.start()
			return
	pass


func release_tornado():
	if skill1_locked_enemy == null: 
		skill_1_timer.stop()
		return
	get_exp(skill1_exp_get[skill_levels[1]-1])
	var tornado_vihicle: PathFollow2D = PathFollow2D.new()
	tornado_vihicle.loop = false
	tornado_vihicle.rotates = false
	skill1_locked_enemy.get_parent().add_child(tornado_vihicle)
	tornado_vihicle.progress = skill1_locked_enemy.progress + 100
	var robort_tornado_area: SkillConditionArea2D = preload("res://Scenes/Skills/robort_tornado_area.tscn").instantiate()
	robort_tornado_area.skill_level = skill_levels[1]
	tornado_vihicle.add_child(robort_tornado_area)
	pass


func get_skill1_locked_enemy() -> Enemy:
	var enemy_list: Array[Enemy]
	for body in skill_1_condition_area.get_overlapping_bodies():
		var enemy: Enemy = body.owner
		if enemy.enemy_type >= Enemy.EnemyType.Super: continue
		if "special" in enemy.get_groups(): continue
		enemy_list.append(enemy)
	if enemy_list.is_empty(): return null
	var back_enemy: Enemy = enemy_list[0]
	for enemy in enemy_list:
		if enemy.progress_ratio > back_enemy.progress_ratio:
			back_enemy = enemy
	
	return back_enemy
	pass


func release_flame():
	if skill2_locked_enemy == null: return
	get_exp(skill2_exp_get[skill_levels[2]-1])
	skill_2_hit_area.monitoring = true
	ally_sprite.flip_h = skill2_locked_enemy.position.x < position.x
	skill_2_hit_area.global_position = far_attack_marker_flip.global_position if ally_sprite.flip_h else far_attack_marker.global_position
	skill_2_hit_area.look_at(skill2_locked_enemy.hurt_box.global_position)
	flame_animation_play(skill_2_hit_area.global_position,fire_end_marker.global_position)
	await get_tree().create_timer(0.4,false).timeout
	skill_2_hit_area.monitoring = false
	pass


func _on_skill_2_hit_area_area_entered(area: Area2D) -> void:
	var enemy: Enemy = area.owner
	
	var fire_dot_buff: DotBuff = preload("res://Scenes/Buffs/Robort/robort_fire_dot.tscn").instantiate()
	fire_dot_buff.duration = HeroSkillLibrary.hero_skill_data_library[ally_id][2].during_time[skill_levels[2]-1]
	enemy.buffs.add_child(fire_dot_buff)
	
	var damage_low: int = HeroSkillLibrary.hero_skill_data_library[ally_id][2].damage_low[skill_levels[2]-1]
	var damage_high: int = HeroSkillLibrary.hero_skill_data_library[ally_id][2].damage_high[skill_levels[2]-1]
	var damage: int = randi_range(damage_low,damage_high)
	enemy.take_damage(damage,DataProcess.DamageType.TrueDamage,0,true,self,false,true)
	pass # Replace with function body.


func flame_animation_play(start_pos: Vector2, end_pos: Vector2):
	for i in 40:
		for j in 3:
			var fire_particle: AnimatedSprite2D = preload("res://Scenes/Effects/robort_fire_particle.tscn").instantiate()
			fire_particle.global_position = start_pos + Vector2(randf_range(-20,20),randf_range(-20,20))
			Stage.instance.bullets.add_child(fire_particle)
			var end_position: Vector2 = end_pos + Vector2(randf_range(-50,50),randf_range(-50,50))
			create_tween().tween_property(fire_particle,"position",end_position,0.25)
			create_tween().tween_property(fire_particle,"scale",fire_particle.scale * 2, 0.5)
		await get_tree().create_timer(0.01,false).timeout
	pass


func release_earth_queake():
	if skill3_locked_enemy_path == null: return
	var delta_progress: float = 40
	var self_progress: float = skill3_locked_enemy_path.curve.get_closest_offset(position)
	loop_add_earth_area(true)
	loop_add_earth_area(false)
	get_exp(skill3_exp_get[skill_levels[3]-1])
	skill3_locked_enemy_path = null
	pass


func get_skill3_locked_enemy_path() -> EnemyPath:
	var back_enemy_path: EnemyPath
	var last_delta_progress: float = 10000
	for body in skill_3_condition_area.get_overlapping_bodies():
		var enemy: Enemy = body.owner
		var enemy_path: EnemyPath = enemy.get_parent()
		var delta_progress: float = abs(enemy_path.curve.get_closest_offset(position) - enemy.progress)
		if delta_progress < 160 and delta_progress < last_delta_progress:
			back_enemy_path = enemy_path
	
	return back_enemy_path
	pass


func loop_add_earth_area(is_plus: bool):
	var n: float = 1 if is_plus else -1
	var delta_progress: float = 50
	var self_progress: float = skill3_locked_enemy_path.curve.get_closest_offset(position)
	for i in 5:
		var earth_progress: float = self_progress + n * (i+1) * delta_progress
		if earth_progress < 0 or earth_progress > skill3_locked_enemy_path.curve.get_baked_length():
			return
		var earth_area: SkillConditionArea2D = preload("res://Scenes/Skills/robort_ground_area.tscn").instantiate()
		earth_area.position = skill3_locked_enemy_path.curve.sample_baked(earth_progress)
		earth_area.skill_level = skill_levels[3]
		Stage.instance.bullets.add_child(earth_area)
		delay_free_area(earth_area)
	pass


func delay_free_area(area: Area2D):
	await get_tree().create_timer(1,false).timeout
	area.queue_free()
	pass
