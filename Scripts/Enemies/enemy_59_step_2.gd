extends Enemy

enum SkillElement{
	LIGHTNING,
	FIRE,
	DARK
}

@export var boss_name: String
@export_multiline var die_text: String
@export var explosion_scene: PackedScene
@export var summon_enemy_scene: PackedScene
@export var rain_layer_scene: PackedScene
@export var summon_count_limit: int
@export var summon_effect_scene: PackedScene
@export var teleport_foward_length: float
@export var end_skill_damage: DamageBlock
@export var end_skill_lock_duration: float
@export var ending_layer_scene: PackedScene
@export_group("Lightning")
@export var lightning_scene: PackedScene
@export var smoke_scene: PackedScene
@export var tower_lock_buff_scene: PackedScene
@export var lock_buff_duration: float
@export var lightning_end_skill_damage: int
@export_group("Dark")
@export var dark_fog_scene: PackedScene
@export var dark_skill_area_scene: PackedScene
@export var dark_end_skill_area_scene: PackedScene
@export_group("Fire")
@export var fire_sheild_armor: float
@export var fire_sheild_dot_damage: int
@export var fire_buff_scene: PackedScene
@export var fire_end_damage_per_time: int
@export var fire_dot_buff_scene: PackedScene

@onready var dialog_panel: DialogPanel = $UnitBody/DialogPanel
@onready var boss_ui: BossUI = $BossUI
@onready var teleport_audio: AudioStreamPlayer = $TeleportAudio
@onready var teleport_markers: Node2D = $TeleportMarkers
@onready var summon_markers: Node2D = $SummonMarkers
@onready var teleport_timer: Timer = $TeleportTimer
@onready var teleport_show_timer: Timer = $TeleportShowTimer
@onready var action_wait_timer: Timer = $ActionWaitTimer
@onready var lightning_skill_1_timer: Timer = $LightningSkill1Timer
@onready var lightning_skill_2_timer: Timer = $LightningSkill2Timer
@onready var dark_skill_1_timer: Timer = $DarkSkill1Timer
@onready var dark_skill_2_timer: Timer = $DarkSkill2Timer
@onready var fire_skill_1_timer: Timer = $FireSkill1Timer
@onready var fire_skill_2_timer: Timer = $FireSkill2Timer
@onready var super_skill_timer: Timer = $SuperSkillTimer
@onready var end_skill_timer: Timer = $EndSkillTimer
@onready var tower_condition_area: Area2D = $UnitBody/TowerConditionArea
@onready var ally_condition_area: Area2D = $UnitBody/AllyConditionArea
@onready var enemy_condition_area: Area2D = $UnitBody/EnemyConditionArea
@onready var skill_delay_timer: Timer = $SkillDelayTimer
@onready var summon_timer: Timer = $SummonTimer
@onready var enemy_teleport_timer: Timer = $EnemyTeleportTimer
@onready var sheild_audio: AudioStreamPlayer = $SheildAudio
@onready var sheild: Node2D = $UnitBody/Sheild
@onready var fire_skill_1_duration_timer: Timer = $FireSkill1DurationTimer
@onready var fire_dot_timer: Timer = $FireDotTimer
@onready var fire_dot_condtion_area: Area2D = $UnitBody/FireDotCondtionArea
@onready var point_light: PointLight2D = $UnitBody/PointLight
@onready var lightning_end_hit_area: Area2D = $UnitBody/LightningEndHitArea
@onready var fire_end_particle: GPUParticles2D = $UnitBody/FireEndParticle
@onready var fire_end_effect_mask: ColorRect = $EffectLayer/FireEndEffectMask
@onready var fire_end_animation_player: AnimationPlayer = $EffectLayer/FireEndAnimationPlayer
@onready var fire_end_dot_timer: Timer = $FireEndDotTimer
@onready var fire_end_release_audio: AudioStreamPlayer = $FireEndReleaseAudio
@onready var end_skill_hit_area: Area2D = $UnitBody/EndSkillHitArea
@onready var end_skill_effect: Sprite2D = $EndSkillEffect
@onready var end_skill_marker: Marker2D = $EndSkillEffect/EndSkillMarker
@onready var end_skill_destroy_area: Area2D = $UnitBody/EndSkillDestroyArea
@onready var broken_audio: AudioStreamPlayer = $BrokenAudio
@onready var die_white_mask: ColorRect = $DieLayer/DieWhiteMask
@onready var die_white_circle: Sprite2D = $UnitBody/DieWhiteCircle
@onready var die_release_audio: AudioStreamPlayer = $DieReleaseAudio

var teleport_marker_list: Array[Marker2D]
var summon_marker_list: Array[Marker2D]
var remain_teleport_marker_list: Array[Marker2D]
#var remain_summon_marker_list: Array[Marker2D]
var is_end_step: bool
var can_act: bool
var super_skill_pool: Array[SkillElement] = []
const super_skill_pool_init: Array[SkillElement] = [SkillElement.LIGHTNING,
SkillElement.FIRE, SkillElement.DARK]
var current_summon_count: int
var linked_rain_layer: RainSystem

#region shader_parameter
var shader_line_size: float:
	set(v):
		var shader_mater: ShaderMaterial = enemy_sprite.material as ShaderMaterial
		shader_mater.set_shader_parameter("outline_width",v)
		shader_line_size = v
var shader_line_color: Color = Color(0,0,0,0):
	set(v):
		var shader_mater: ShaderMaterial = enemy_sprite.material as ShaderMaterial
		shader_mater.set_shader_parameter("outline_color",v)
		shader_line_color = v
#endregion


func _ready() -> void:
	super()
	end_skill_effect.hide()
	end_skill_effect.modulate.a = 0
	init_marker_list()
	#start_data.health = 12000
	#current_data.health = 12000
	translate_to_new_state(EnemyState.SPECIAL)
	enemy_sprite.play("into")
	boss_ui.name_label.text = boss_name
	start_data.total_defence_rate = 0.5
	current_data.update_total_defence_rate()
	hurt_box.monitorable = false
	body_collision.disabled = true
	enemy_button.disabled = true
	teleport_show_timer.timeout.connect(teleport_show)
	#TODO: delete the await
	await get_tree().process_frame
	var rain_layer = rain_layer_scene.instantiate()
	Stage.instance.background.add_child(rain_layer)
	var rain_system: RainSystem = rain_layer.get_child(0)
	linked_rain_layer = rain_system
	rain_system.translate_to_rain_step(RainSystem.RainStep.Super)
	fire_skill_1_duration_timer.timeout.connect(on_fire_skill1_end)
	fire_dot_timer.timeout.connect(on_fire_dot_damage_timer_timeout)
	pass


func anim_offset():
	match enemy_sprite.animation:
		"idle":
			enemy_sprite.position = Vector2(5,-205)
		"into":
			enemy_sprite.position = Vector2(0,-145)
		"lightning_skill1": #NOTE:action1
			enemy_sprite.position = Vector2(0,-220)
		"lightning_skill2": #NOTE:action2
			enemy_sprite.position = Vector2(0,-220)
		"summon","teleport_finished","fire_skill2": #NOTE:action3
			enemy_sprite.position = Vector2(0,-220)
		"teleport_enemy": #NOTE:action4
			enemy_sprite.position = Vector2(-25,-220)
		"dark_skill1": #NOTE:action5
			enemy_sprite.position = Vector2(-15,-220)
		"dark_skill2": #NOTE:action6
			enemy_sprite.position = Vector2(0,-230)
		"lightning_end","dark_end","fire_end": #NOTE:action7
			enemy_sprite.position = Vector2(0,-240)
		"end_skill":
			enemy_sprite.position = Vector2(-5,-255)
		"die":
			enemy_sprite.position = Vector2(5,-210)
	pass


func frame_changed():
	if enemy_sprite.animation == "into" and enemy_sprite.frame == 25:
		enemy_sprite.pause()
		#await get_tree().create_timer(2,false).timeout
		disappear()
		enemy_button.disabled = false
		super_skill_timer.start()
		recover()
	if enemy_sprite.animation == "die" and enemy_sprite.frame == 26:
		enemy_sprite.pause()
	
	#region NormalSkill
	if enemy_sprite.animation == "summon" and enemy_sprite.frame == 5:
		summon_enemies()
	if enemy_sprite.animation == "teleport_enemy" and enemy_sprite.frame == 9:
		teleport_enemies()
	#endregion
	
	#region LightningSkill
	if enemy_sprite.animation == "lightning_skill1" and enemy_sprite.frame == 20:
		lightning_skill1_release()
	if enemy_sprite.animation == "lightning_skill2" and enemy_sprite.frame == 26:
		lightning_skill2_release()
	if enemy_sprite.animation == "lightning_end" and enemy_sprite.frame == 24:
		lightning_end_skill_release()
	#endregion
	
	#region FireSkill
	if enemy_sprite.animation == "fire_skill2" and enemy_sprite.frame == 5:
		fire_skill2_release()
	if enemy_sprite.animation == "fire_end" and enemy_sprite.frame == 24:
		fire_end_skill_release()
		enemy_sprite.pause()
	#endregion
	
	#region DarkSkill
	if enemy_sprite.animation == "dark_skill1" and enemy_sprite.frame == 13:
		dark_skill1_release()
	if enemy_sprite.animation == "dark_skill2" and enemy_sprite.frame == 2:
		dark_skill2_release()
	if enemy_sprite.animation == "dark_end" and enemy_sprite.frame == 24:
		dark_end_skill_release()
	#endregion
	
	if enemy_sprite.animation == "end_skill":
		if enemy_sprite.frame == 31:
			end_skill_release()
		if enemy_sprite.frame == 1:
			end_skill_prepare()
	pass


#TODO: remember to delete
func boss_music_play():
	#Stage.instance.on_boss_music_playing.emit()
	#Stage.instance.preparation_music.stop()
	pass


func init_marker_list():
	for marker: Marker2D in summon_markers.get_children():
		summon_marker_list.append(marker)
	for marker: Marker2D in teleport_markers.get_children():
		teleport_marker_list.append(marker)
	pass


func teleport_show():
	point_light.show()
	var target_marker: Marker2D
	if remain_teleport_marker_list.is_empty():
		target_marker = teleport_marker_list[0]
		remain_teleport_marker_list = teleport_marker_list.duplicate()
	else:
		target_marker = remain_teleport_marker_list.pick_random() as Marker2D
		remain_teleport_marker_list.erase(target_marker)
	
	current_summon_count = mini(current_summon_count+1, summon_count_limit)
	show()
	position = target_marker.global_position
	enemy_sprite.play("teleport_finished")
	teleport_effect_show(hurt_box.global_position)
	action_wait_timer.start()
	teleport_timer.start()
	Stage.instance.stage_camera.position = global_position
	await get_tree().physics_frame
	await get_tree().physics_frame
	hurt_box.monitorable = true
	body_collision.disabled = false
	can_act = true
	pass


func broken():
	broken_audio.play()
	take_damage(500,DataProcess.DamageType.TrueDamage,1)
	start_data.total_defence_rate = 0
	current_data.update_total_defence_rate()
	create_tween().tween_property(self,"shader_line_size",0,0.8)
	create_tween().tween_property(self,"shader_line_color:a",0,0.8)
	pass


func recover():
	shader_line_color = Color.PURPLE
	shader_line_color.a = 0
	start_data.total_defence_rate = 0.5
	current_data.update_total_defence_rate()
	create_tween().tween_property(self,"shader_line_size",45,0.8)
	create_tween().tween_property(self,"shader_line_color:a",1,0.8)
	pass


func disappear():
	hide()
	can_act = false
	hurt_box.monitorable = false
	body_collision.disabled = true
	teleport_effect_show(hurt_box.global_position)
	teleport_show_timer.start()
	if Stage.instance.information_bar.current_check_member == self:
		Stage.instance.ui_process(null)
	pass


func teleport_effect_show(effect_pos: Vector2):
	var teleport_effect: AnimatedSprite2D = explosion_scene.instantiate()
	teleport_effect.position = effect_pos
	teleport_effect.modulate = Color.PURPLE
	Stage.instance.bullets.add_child(teleport_effect)
	teleport_audio.play()
	pass


func skill_process():
	if teleport_timer.is_stopped() and fire_skill_1_duration_timer.is_stopped():
		disappear()
		return
	
	if fire_skill_1_timer.is_stopped():
		fire_skill1_release()
		skill_delay_timer.start()
		fire_skill_1_timer.start()
		return
	
	if summon_timer.is_stopped() and !summon_marker_list.is_empty():
		summon_timer.start()
		skill_delay_timer.start()
		enemy_sprite.play("summon")
		return
	
	if ally_condition_area.has_overlapping_bodies() and dark_skill_1_timer.is_stopped():
		dark_skill_1_timer.start()
		enemy_sprite.play("dark_skill1")
		skill_delay_timer.start()
		return
	
	if lightning_skill_2_timer.is_stopped() and tower_condition_area.get_overlapping_areas().size() > 6:
		lightning_skill_2_timer.start()
		enemy_sprite.play("lightning_skill2")
		skill_delay_timer.start()
		return
	
	if enemy_condition_area.get_overlapping_bodies().size() > 5 and enemy_teleport_timer.is_stopped():
		enemy_teleport_timer.start()
		enemy_sprite.play("teleport_enemy")
		skill_delay_timer.start()
		return
	
	if dark_skill_2_timer.is_stopped() and ally_condition_area.has_overlapping_bodies():
		dark_skill_2_timer.start()
		enemy_sprite.play("dark_skill2")
		skill_delay_timer.start()
		return
	
	if fire_skill_2_timer.is_stopped() and enemy_condition_area.get_overlapping_bodies().size() > 4:
		fire_skill_2_timer.start()
		skill_delay_timer.start()
		enemy_sprite.play("fire_skill2")
		return
	
	if lightning_skill_1_timer.is_stopped() and tower_condition_area.get_overlapping_areas().size() > 5:
		lightning_skill_1_timer.start()
		enemy_sprite.play("lightning_skill1")
		skill_delay_timer.start()
		return
	
	if super_skill_timer.is_stopped() and !is_end_step:
		if super_skill_pool.is_empty(): super_skill_pool = super_skill_pool_init.duplicate()
		var skill_tag: SkillElement = super_skill_pool.pick_random() as SkillElement
		super_skill_pool.erase(skill_tag)
		match skill_tag:
			SkillElement.LIGHTNING:
				enemy_sprite.play("lightning_end")
			SkillElement.FIRE:
				enemy_sprite.play("fire_end")
			SkillElement.DARK:
				enemy_sprite.play("dark_end")
		super_skill_timer.start()
		skill_delay_timer.start()
		return
	
	if end_skill_timer.is_stopped() and is_end_step:
		end_skill_timer.start()
		enemy_sprite.play("end_skill")
		skill_delay_timer.start()
		return
	pass


func special_process():
	if can_act and enemy_sprite.animation == "idle" and skill_delay_timer.is_stopped():
		skill_process()
	if !is_end_step:
		final_step_condition_process()
	pass


func into_final_step():
	is_end_step = true
	lightning_skill_1_timer.wait_time = 14
	end_skill_timer.start()
	lightning_skill_1_timer.start()
	summon_count_limit = 10
	pass


#region SkillProcess

#region NormalSkill
func summon_enemies():
	if summon_marker_list.is_empty(): return
	var target_marker: Marker2D = summon_marker_list.pick_random() as Marker2D
	summon_enemy_process(target_marker)
	summon_marker_list.erase(target_marker)
	pass


func teleport_enemies():
	var enemy_list: Array[Enemy]
	for body in enemy_condition_area.get_overlapping_bodies():
		var enemy: Enemy = body.owner
		if enemy == self: continue
		if enemy.enemy_state != EnemyState.MOVE: continue
		var remain_length: float
		var enemy_path: EnemyPath = enemy.get_parent()
		remain_length = enemy_path.curve.get_baked_length() - enemy.progress
		if remain_length > 300: enemy_list.append(enemy)
	if enemy_list.is_empty(): return
	teleport_audio.play()
	for enemy in enemy_list:
		teleport_effect_show(enemy.hurt_box.global_position)
		enemy.progress += teleport_foward_length
		teleport_effect_show(enemy.hurt_box.global_position)
	pass


func summon_enemy_process(target_marker: Marker2D):
	var summon_effect: AnimatedSprite2D = summon_effect_scene.instantiate()
	summon_effect.position = target_marker.global_position
	var target_scale: Vector2= summon_effect.scale
	summon_effect.scale = Vector2.ZERO
	Stage.instance.bullets.add_child(summon_effect)
	var show_tween: Tween = create_tween()
	show_tween.tween_property(summon_effect,"scale",target_scale,0.4)
	await show_tween.finished
	var summon_count: int = current_summon_count
	for i in summon_count:
		if enemy_state == EnemyState.DIE: return
		var enemy: Enemy = summon_enemy_scene.instantiate()
		enemy.position = target_marker.global_position
		enemy.position.x += randf_range(-50,50)
		enemy.position.y += randf_range(-25,25)
		var enemy_path: EnemyPath = Stage.instance.get_closest_enemy_path(enemy.position)
		enemy.progress = enemy_path.curve.get_closest_offset(enemy.position)
		enemy_path.add_child(enemy)
		await get_tree().create_timer(0.6,false).timeout
	
	var disappear_tween: Tween = create_tween()
	disappear_tween.tween_property(summon_effect,"scale",Vector2.ZERO,1)
	await disappear_tween.finished
	summon_effect.queue_free()
	summon_marker_list.append(target_marker)
	pass

#endregion


#region FireSkill
func fire_skill1_release():
	create_tween().tween_property(sheild,"modulate:a",1,1)
	sheild_audio.play()
	fire_skill_1_duration_timer.start()
	start_data.armor = fire_sheild_armor
	current_data.update_armor()
	fire_dot_timer.start()
	pass


func on_fire_skill1_end():
	create_tween().tween_property(sheild,"modulate:a",0,1)
	sheild_audio.play()
	start_data.armor = 0
	current_data.update_armor()
	fire_dot_timer.stop()
	pass


func on_fire_dot_damage_timer_timeout():
	for body in fire_dot_condtion_area.get_overlapping_bodies():
		var ally: Ally = body.owner
		ally.take_damage(fire_sheild_dot_damage,DataProcess.DamageType.TrueDamage,0,true)
	pass


func fire_skill2_release():
	var enemy_list: Array[Enemy]
	for body in enemy_condition_area.get_overlapping_bodies():
		var enemy: Enemy = body.owner
		if enemy == self: continue
		enemy_list.append(enemy)
	if enemy_list.size() > 10:
		enemy_list.shuffle()
		enemy_list.resize(10)
	for enemy in enemy_list:
		var sheild_buff: PropertyBuff = fire_buff_scene.instantiate()
		enemy.buffs.add_child(sheild_buff)
	pass


func fire_end_skill_release():
	z_index = 3
	fire_end_particle.show()
	fire_end_dot_timer.start()
	fire_end_effect_mask.show()
	fire_end_animation_player.play("release")
	fire_end_release_audio.play()
	for i in 20:
		await fire_end_dot_timer.timeout
		fire_end_skill_damage()
		if enemy_state == EnemyState.DIE:
			fire_end_skill_finished()
			return
		AudioManager.instance.play_explosion_audio()
		Stage.instance.stage_camera.shake(10)
	for body in ally_condition_area.get_overlapping_bodies():
		var ally: Ally = body.owner
		var dot_buff: DotBuff = fire_dot_buff_scene.instantiate()
		ally.buffs.add_child(dot_buff)
	
	if enemy_state != EnemyState.DIE:
		enemy_sprite.play()
	fire_end_dot_timer.stop()
	fire_end_skill_finished()
	pass


func fire_end_skill_damage():
	for body in ally_condition_area.get_overlapping_bodies():
		var ally: Ally = body.owner
		ally.take_damage(fire_end_damage_per_time,DataProcess.DamageType.TrueDamage,0)
	pass


func fire_end_skill_finished():
	z_index = 0
	fire_end_effect_mask.hide()
	fire_end_release_audio.stop()
	fire_end_particle.hide()
	pass

#endregion


#region LightningSkill
func lightning_skill1_release():
	var tower_list: Array[DefenceTower]
	for area in tower_condition_area.get_overlapping_areas():
		var tower: DefenceTower = area.owner
		if tower.tower_id <= 5: tower_list.append(tower)
	if !tower_list.is_empty():
		var tower: DefenceTower = tower_list.pick_random() as DefenceTower
		tower.destroy_tower()
		summon_lightning(tower.position)
		AudioManager.instance.play_explosion_audio()
	pass


func summon_lightning(summon_pos: Vector2):
	var lightning: Line2D = lightning_scene.instantiate()
	lightning.position = summon_pos
	var explosion_effect: AnimatedSprite2D = explosion_scene.instantiate()
	explosion_effect.position = summon_pos
	var smoke_effect: AnimatedSprite2D = smoke_scene.instantiate()
	smoke_effect.position = summon_pos
	Stage.instance.bullets.add_child(lightning)
	Stage.instance.bullets.add_child(explosion_effect)
	Stage.instance.bullets.add_child(smoke_effect)
	pass

func lightning_skill2_release():
	var tower_list: Array[DefenceTower]
	for area in tower_condition_area.get_overlapping_areas():
		var tower: DefenceTower = area.owner
		tower_list.append(tower)
	if !tower_list.is_empty():
		var loop_count: int = mini(4,tower_list.size())
		tower_list.shuffle()
		for i in loop_count:
			var tower: DefenceTower = tower_list[i]
			var lock_buff: TowerLockBuff = tower_lock_buff_scene.instantiate()
			lock_buff.duration = 6
			tower.tower_buffs.add_child(lock_buff)
			summon_lightning(tower.position)
		AudioManager.instance.play_explosion_audio()
	pass


func lightning_end_skill_release():
	var rect: Rect2 = Stage.instance.stage_camera.move_limit_shape.shape.get_rect()
	var shape: CollisionShape2D = Stage.instance.stage_camera.move_limit_shape
	for i in 66:
		if enemy_state == EnemyState.DIE: return
		var summon_pos: Vector2 = Vector2(randf_range(rect.position.x,rect.end.x),randf_range(rect.position.y,rect.end.y))
		summon_pos += shape.global_position
		summon_pos.y = maxf(summon_pos.y,530)
		summon_pos = Stage.instance.get_closest_enemy_path(summon_pos).curve.get_closest_point(summon_pos)
		lightning_end_hit_area.position = summon_pos
		await get_tree().physics_frame
		await get_tree().physics_frame
		for body in lightning_end_hit_area.get_overlapping_bodies():
			var ally: Ally = body.owner
			ally.take_damage(lightning_end_skill_damage,DataProcess.DamageType.TrueDamage,0)
		summon_lightning(summon_pos)
		AudioManager.instance.play_explosion_audio()
		Stage.instance.stage_camera.shake(10)
		await get_tree().create_timer(0.1,false).timeout
	pass

#endregion


#region DarkSkill
func dark_skill1_release():
	if !ally_condition_area.has_overlapping_bodies(): return
	var dark_fog_area: SkillConditionArea2D = dark_fog_scene.instantiate()
	dark_fog_area.skill_level = 2 if is_end_step else 1
	var target_ally: Ally = ally_condition_area.get_overlapping_bodies().pick_random().owner as Ally
	dark_fog_area.position = target_ally.global_position
	Stage.instance.bullets.add_child(dark_fog_area)
	pass


func dark_skill2_release():
	if !ally_condition_area.has_overlapping_bodies(): return
	var target_ally: Ally = ally_condition_area.get_overlapping_bodies().pick_random().owner as Ally
	var dark_skill_area: Area2D = dark_skill_area_scene.instantiate()
	dark_skill_area.position = target_ally.global_position
	Stage.instance.bullets.add_child(dark_skill_area)
	pass


func dark_end_skill_release():
	var rect: Rect2 = Stage.instance.stage_camera.move_limit_shape.shape.get_rect()
	var shape: CollisionShape2D = Stage.instance.stage_camera.move_limit_shape
	for i in 10:
		if enemy_state == EnemyState.DIE: return
		var summon_pos: Vector2 = Vector2(randf_range(rect.position.x,rect.end.x),randf_range(rect.position.y,rect.end.y))
		summon_pos += shape.global_position
		summon_pos.y = maxf(summon_pos.y,530)
		summon_pos = Stage.instance.get_closest_enemy_path(summon_pos).curve.get_closest_point(summon_pos)
		var dark_damage_area: Area2D = dark_end_skill_area_scene.instantiate()
		dark_damage_area.position = summon_pos
		Stage.instance.bullets.add_child(dark_damage_area)
		await get_tree().create_timer(0.2,false).timeout
	pass

#endregion


func end_skill_release():
	var move_tween: Tween = create_tween()
	move_tween.tween_property(end_skill_effect,"position:y",end_skill_effect.position.y + 320, 0.2)
	await move_tween.finished
	end_skill_hit_area.position = end_skill_marker.global_position
	end_skill_destroy_area.position = end_skill_marker.global_position
	await get_tree().physics_frame
	await get_tree().physics_frame
	AudioManager.instance.play_explosion_audio()
	Stage.instance.stage_camera.shake(20)
	for area in end_skill_destroy_area.get_overlapping_areas():
		var tower: DefenceTower = area.owner
		var lock_buff: TowerLockBuff = tower_lock_buff_scene.instantiate()
		lock_buff.duration = end_skill_lock_duration
		tower.tower_buffs.add_child(lock_buff)
		var explosion_effect: AnimatedSprite2D = explosion_scene.instantiate()
		explosion_effect.position = tower.position
		Stage.instance.bullets.add_child(explosion_effect)
		var smoke_effect: AnimatedSprite2D = smoke_scene.instantiate()
		smoke_effect.position = tower.position
		Stage.instance.bullets.add_child(smoke_effect)
	for body in end_skill_hit_area.get_overlapping_bodies():
		var ally: Ally = body.owner
		var damage: int = end_skill_damage.get_damage()
		ally.take_damage(damage,DataProcess.DamageType.TrueDamage,0)
	var explosion_effect: AnimatedSprite2D = explosion_scene.instantiate()
	explosion_effect.position = end_skill_hit_area.global_position
	explosion_effect.scale *= 2
	Stage.instance.bullets.add_child(explosion_effect)
	var smoke_effect: AnimatedSprite2D = smoke_scene.instantiate()
	smoke_effect.position = end_skill_hit_area.global_position
	smoke_effect.scale *= 2
	Stage.instance.bullets.add_child(smoke_effect)
	end_skill_effect.hide()
	end_skill_effect.modulate.a = 0
	pass


func end_skill_prepare():
	end_skill_effect.position = enemy_sprite.global_position
	end_skill_effect.position.x -= 40
	end_skill_effect.show()
	create_tween().tween_property(end_skill_effect,"modulate:a",1,0.8)
	create_tween().tween_property(end_skill_effect,"position:y",end_skill_effect.position.y - 260, 0.8)
	pass

#endregion


func final_step_condition_process():
	if float(current_data.health) / start_data.health < 0.2 and !is_end_step:
		into_final_step()
	pass


func die(explosion: bool = false):
	super(explosion)
	Achievement.achieve_complete("Boss6Dead")
	Stage.instance.stage_camera.zoom = Vector2.ONE * 2
	Stage.instance.stage_camera.position = hurt_box.global_position
	Stage.instance.can_control = false
	Stage.instance.can_pause = false
	dialog_panel.dialog(die_text,20)
	#linked_rain_layer.translate_to_rain_step(RainSystem.RainStep.None)
	broken_audio.play()
	delay_stop_music()
	die_white_circle.show()
	die_white_circle.scale = Vector2.ZERO
	create_tween().tween_property(die_white_circle,"scale",Vector2.ONE,0.4)
	await get_tree().create_timer(1.5,false).timeout
	enemy_sprite.play()
	die_release_audio.play()
	AudioManager.instance.play_explosion_audio()
	await get_tree().create_timer(0.2,false).timeout
	create_tween().tween_property(die_white_circle,"scale",Vector2.ONE * 200, 0.4)
	await get_tree().create_timer(0.4,false).timeout
	die_white_mask.show()
	die_white_mask.modulate.a = 0
	create_tween().tween_property(die_white_mask,"modulate:a",1,1)
	await get_tree().create_timer(1,false).timeout
	Stage.instance.add_child(ending_layer_scene.instantiate())
	pass


func delay_stop_music():
	Stage.instance.preparation_music.stop()
	Stage.instance.battle_music.stop()
	Stage.instance.boss_music.stop()
	Stage.instance.on_prepare_music_stop.emit()
	Stage.instance.on_battle_music_stop.emit()
	var boss_music_player: LoopMusicPlayer = Stage.instance.music_node.get_child(-1)
	boss_music_player.set_volume(-100,2)
	pass
