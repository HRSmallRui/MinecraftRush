extends Hero

@export var dizness_buff_scene: PackedScene
@export var explosion_effect_scene: PackedScene
@export var smoke_effect_scene: PackedScene
@export_group("PassiveSkill","passive_skill")
@export var passive_skill_bullet_scene: PackedScene
@export var passive_skill_damage_rate: float
@export var passive_skill_broken_rate: float
@export_group("Skill1","skill1")
@export var skill1_damage_list: Array[DamageBlock]
@export var skill1_buff_duration: float
@export var skill1_buff_list: Array[PackedScene]
@export var skill1_effect_scene: PackedScene
@export var skill1_freeze_buff_scene: PackedScene
@export_group("Skill2","skill2")
@export var skill2_damage_list: Array[int]
@export var skill2_bullet_scene: PackedScene
@export_group("Skill3","skill3")
@export var skill3_bullet_count_list: Array[int]
@export var skill3_bullet_scene: PackedScene
@export_group("Skill4","skill4")
@export var skill4_first_damage_list: Array[int]
@export var skill4_effect_bullet_scene: PackedScene
@export var skill4_slow_buff_scene: PackedScene
@export var skill4_second_damage_list: Array[DamageBlock]
@export var skill4_hurt_buff_scene: PackedScene
@export var skill4_explosion_prepare_effect_scene: PackedScene

@onready var skill_1_timer: Timer = $Skill1Timer
@onready var skill_2_timer: Timer = $Skill2Timer
@onready var skill_3_timer: Timer = $Skill3Timer
@onready var skill_4_timer: Timer = $Skill4Timer
@onready var super_far_attack_marker: Marker2D = $UnitBody/SuperFarAttackMarker
@onready var super_far_attack_marker_flip: Marker2D = $UnitBody/SuperFarAttackMarkerFlip
@onready var skill_1_condition_area: Area2D = $UnitBody/Skill1ConditionArea
@onready var skill_2_condition_area: Area2D = $UnitBody/Skill2ConditionArea
@onready var skill_2_shoot_marker: Marker2D = $UnitBody/Skill2ShootMarker
@onready var skill_2_shoot_marker_flip: Marker2D = $UnitBody/Skill2ShootMarkerFlip
@onready var prepare_audio: AudioStreamPlayer = $PrepareAudio
@onready var skill_1_end_audio: AudioStreamPlayer = $Skill1EndAudio
@onready var kill_arrow_prepare_audio: AudioStreamPlayer = $KillArrowPrepareAudio
@onready var skill_1_release_audio: AudioStreamPlayer = $Skill1ReleaseAudio
@onready var skill_3_component: Node2D = $UnitBody/Skill3Component
@onready var skill_3_condition_area: Area2D = $UnitBody/Skill3ConditionArea
@onready var explosion_arrow_shoot_audio: AudioStreamPlayer = $ExplosionArrowShootAudio
@onready var explosion_arrow_prepare_audio: AudioStreamPlayer = $ExplosionArrowPrepareAudio
@onready var skill_4_attack_area: Area2D = $UnitBody/Skill4AttackArea
@onready var skill_4_marker: Marker2D = $UnitBody/Skill4Marker
@onready var skill_4_arrow_effect: Node2D = $Skill4ArrowEffect
@onready var skill_4_second_attack_area: Area2D = $UnitBody/Skill4SecondAttackArea
@onready var delay_explosion_audio: AudioStreamPlayer = $DelayExplosionAudio

var shoot_count: int
var skill1_hit_enemy_list: Array[Enemy]
var skill1_freeze_buff_list: Array[PropertyBuff]
var skill1_slash_effect_list: Array[SteveSlashEffect]
var skill2_locked_enemy: Enemy
var skill3_locked_enemy: Enemy
var skill3_locked_pos: Vector2


func _ready() -> void:
	super()
	pass


func anim_offset():
	match ally_sprite.animation:
		"idle","attack":
			ally_sprite.position = Vector2(35,-95) if ally_sprite.flip_h else Vector2(-40,-95)
		"die":
			ally_sprite.position = Vector2(65,-85) if ally_sprite.flip_h else Vector2(-70,-85)
		"far_attack":
			ally_sprite.position = Vector2(-5,-100) if ally_sprite.flip_h else Vector2(5,-100)
		"move":
			ally_sprite.position = Vector2(-5,-100) if ally_sprite.flip_h else Vector2(5,-100)
		"rebirth":
			ally_sprite.position = Vector2(10,-135) if ally_sprite.flip_h else Vector2(-10,-135)
		"super_far_attack":
			ally_sprite.position = Vector2(-20,-95) if ally_sprite.flip_h else Vector2(20,-95)
		"skill1_start":
			ally_sprite.position = Vector2(-30,-65) if ally_sprite.flip_h else Vector2(30,-65)
		"skill1_end":
			ally_sprite.position = Vector2(-15,-80) if ally_sprite.flip_h else Vector2(10,-80)
		"skill2":
			ally_sprite.position = Vector2(-45,-120) if ally_sprite.flip_h else Vector2(40,-120)
		"skill4":
			ally_sprite.position = Vector2(-25,-100) if ally_sprite.flip_h else Vector2(25,-100)
		"skill3":
			ally_sprite.position = Vector2(0,-215)
	pass


func frame_changed():
	if ally_sprite.animation == "attack" and ally_sprite.frame == 9:
		cause_damage()
	if ally_sprite.animation == "far_attack" and ally_sprite.frame == 17:
		far_attack_frame()
		AudioManager.instance.shoot_audio_1.play()
		shoot_count += 1
	if ally_sprite.animation == "super_far_attack" and ally_sprite.frame == 26:
		AudioManager.instance.shoot_audio_2.play()
		if far_attack_target_enemy == null: return
		ally_sprite.flip_h = far_attack_target_enemy.position.x < position.x
		passive_summon_arrow()
		shoot_count = 0
	if ally_sprite.animation == "skill1_start" and ally_sprite.frame == 32:
		hide()
		ally_sprite.pause()
		skill1_release()
	if ally_sprite.animation == "skill1_start" and ally_sprite.frame == 21:
		prepare_audio.play()
	if ally_sprite.animation == "skill1_start" and ally_sprite.frame == 32:
		skill_1_release_audio.play()
	if ally_sprite.animation == "skill1_end" and ally_sprite.frame == 33:
		skill1_attack()
		skill_1_end_audio.play()
		var strength_buff: PropertyBuff = skill1_buff_list[skill_levels[1]-1].instantiate()
		strength_buff.duration = skill1_buff_duration
		buffs.add_child(strength_buff)
	if ally_sprite.animation == "skill2" and ally_sprite.frame == 36:
		AudioManager.instance.shoot_audio_2.play()
		skill2_release()
		await ally_sprite.animation_finished
		start_data.total_defence_rate = 0
		current_data.update_total_defence_rate()
	if ally_sprite.animation == "skill2" and ally_sprite.frame == 19:
		kill_arrow_prepare_audio.play(0.18)
	if ally_sprite.animation == "skill3" and ally_sprite.frame == 14:
		skill3_release()
		explosion_arrow_prepare_audio.play()
		await ally_sprite.animation_finished
		body_collision.disabled = false
		hurt_box.monitorable = false
	
	if ally_sprite.animation == "skill4" and ally_sprite.frame == 22:
		skill4_release()
		AudioManager.instance.shoot_audio_2.play()
	pass


func passive_summon_arrow():
	var target_enemy: Enemy
	if far_attack_area.has_overlapping_bodies():
		target_enemy = far_attack_area.get_overlapping_bodies()[0].owner
	else:
		target_enemy = far_attack_target_enemy
	if target_enemy == null: return
	
	ally_sprite.flip_h = target_enemy.position.x < position.x
	var summon_pos: Vector2 = super_far_attack_marker_flip.global_position if ally_sprite.flip_h else super_far_attack_marker.global_position
	var damage: int = randi_range(current_data.far_damage_low,current_data.far_damage_high)
	var target_pos: Vector2 = target_enemy.hurt_box.global_position
	target_pos += target_enemy.direction * target_enemy.current_data.unit_move_speed * 1.5
	var super_arrow: Bullet = summon_bullet(passive_skill_bullet_scene,summon_pos,target_pos,damage,DataProcess.DamageType.PhysicsDamage)
	super_arrow.broken_rate = passive_skill_broken_rate
	Stage.instance.bullets.add_child(super_arrow)
	pass


func idle_process():
	if skill_1_timer.is_stopped() and skill_levels[1] > 0 and skill1_can_release():
		skill_1_timer.start()
		translate_to_new_state(AllyState.SPECIAL)
		ally_sprite.play("skill1_start")
		body_collision.disabled = true
		hurt_box.monitorable = false
		skill1_hit_enemy_list.clear()
		return
	super()
	if shoot_count >= 2 and far_attack_area.has_overlapping_bodies() and ally_sprite.animation == "far_attack":
		far_attack_target_enemy = far_attack_area.get_overlapping_bodies()[0].owner
		far_attack_timer.start()
		translate_to_new_state(AllyState.SPECIAL)
		ally_sprite.flip_h = far_attack_target_enemy.position.x < position.x
		ally_sprite.play("super_far_attack")
		return
	if ally_state == AllyState.IDLE:
		if ally_state == AllyState.IDLE:
			if skill_3_timer.is_stopped() and skill_levels[3] > 0 and skill_3_condition_area.has_overlapping_bodies():
				skill_3_timer.start()
				translate_to_new_state(AllyState.SPECIAL)
				ally_sprite.play("skill3")
				skill3_locked_enemy = skill_3_condition_area.get_overlapping_bodies()[0].owner
				skill3_locked_pos = skill3_locked_enemy.position
				ally_sprite.flip_h = skill3_locked_enemy.position.x < position.x
				body_collision.disabled = true
				hurt_box.monitorable = false
				var move_pos: Vector2 = position
				move_pos.x += 40 if ally_sprite.flip_h else -40
				create_tween().tween_property(self,"position",move_pos,0.3)
				return
			
			if skill_4_timer.is_stopped() and skill_levels[4] > 0 and far_attack_area.get_overlapping_bodies().size() >= 3:
				skill_4_timer.start()
				translate_to_new_state(AllyState.SPECIAL)
				ally_sprite.play("skill4")
				skill_4_attack_area.position = position
				skill_4_second_attack_area.position = position
				return
			
			if skill_2_timer.is_stopped() and skill_levels[2] > 0 and skill_2_condition_area.has_overlapping_bodies():
				var target_enemy: Enemy = get_skill2_target_enemy()
				if target_enemy != null:
					skill_2_timer.start()
					translate_to_new_state(AllyState.SPECIAL)
					start_data.total_defence_rate = 1
					current_data.update_total_defence_rate()
					skill2_locked_enemy = target_enemy
					ally_sprite.play("skill2")
					ally_sprite.flip_h = target_enemy.position.x < position.x
				return
		
	pass


func skill1_release():
	for body in skill_1_condition_area.get_overlapping_bodies():
		var enemy: Enemy = body.owner
		if enemy.get_groups().has("special"): continue
		skill1_hit_enemy_list.append(enemy)
		if skill1_hit_enemy_list.size() >= 30: break
	for enemy in skill1_hit_enemy_list:
		if enemy == null: continue
		var slash_effect: SteveSlashEffect = skill1_effect_scene.instantiate()
		slash_effect.position = enemy.position
		slash_effect.position -= enemy.intercepting_marker.position/5
		Stage.instance.bullets.add_child(slash_effect)
		slash_effect.slash_anim_sprite.flip_h = enemy.enemy_sprite.flip_h
		skill1_slash_effect_list.append(slash_effect)
		var freeze_buff: PropertyBuff = skill1_freeze_buff_scene.instantiate()
		freeze_buff.duration = 0
		freeze_buff.buff_tag = "steve_freeze"
		enemy.buffs.add_child(freeze_buff)
		skill1_freeze_buff_list.append(freeze_buff)
		await get_tree().create_timer(randf_range(0.1,0.2),false).timeout
	show()
	ally_sprite.play("skill1_end")
	pass


func skill1_can_release() -> bool:
	var correct_count: int
	for body in skill_1_condition_area.get_overlapping_bodies():
		var enemy: Enemy = body.owner
		if enemy.get_groups().has("special"): continue
		correct_count += 1
	return correct_count >= 4


func skill1_attack():
	body_collision.disabled = false
	hurt_box.monitorable = true
	var damage_block: DamageBlock = skill1_damage_list[skill_levels[1]-1]
	for i in skill1_hit_enemy_list.size():
		var enemy: Enemy = skill1_hit_enemy_list[i]
		var slash_effect: SteveSlashEffect = skill1_slash_effect_list[i]
		var freeze_buff: PropertyBuff = skill1_freeze_buff_list[i]
		if enemy != null:
			var damage: int = randi_range(damage_block.damage_low,damage_block.damage_high)
			enemy.take_damage(damage,DataProcess.DamageType.TrueDamage,0,false,null,true,false)
		slash_effect.slash_play()
		if freeze_buff != null:
			freeze_buff.remove_buff()
		await get_tree().create_timer(randf_range(0.1,0.2),false).timeout
	skill1_hit_enemy_list.clear()
	skill1_freeze_buff_list.clear()
	skill1_slash_effect_list.clear()
	pass


func get_skill2_target_enemy() -> Enemy:
	var target_enemy_list: Array[Enemy]
	for body in skill_2_condition_area.get_overlapping_bodies():
		var enemy: Enemy = body.owner
		target_enemy_list.append(enemy)
	if target_enemy_list.is_empty(): return null
	var back_eneemy: Enemy = target_enemy_list[0]
	for enemy in target_enemy_list:
		if enemy.current_data.health > back_eneemy.current_data.health: back_eneemy = enemy
	return back_eneemy


func skill2_release():
	if skill_2_condition_area.has_overlapping_bodies():
		skill2_locked_enemy = get_skill2_target_enemy()
	if skill2_locked_enemy == null: return
	ally_sprite.flip_h = skill2_locked_enemy.position.x < position.x
	var explsion_effect: AnimatedSprite2D = explosion_effect_scene.instantiate()
	explsion_effect.position = skill_2_shoot_marker_flip.global_position if ally_sprite.flip_h else skill_2_shoot_marker.global_position
	Stage.instance.bullets.add_child(explsion_effect)
	var summon_pos: Vector2 = explsion_effect.position
	var target_pos: Vector2 = skill2_locked_enemy.hurt_box.global_position
	var damage: int = skill2_damage_list[skill_levels[2]-1]
	var bullet: Bullet = summon_bullet(skill2_bullet_scene,summon_pos,target_pos,damage,DataProcess.DamageType.TrueDamage)
	Stage.instance.bullets.add_child(bullet)
	pass


func battle():
	if ally_sprite.animation == "idle":
		if skill_1_timer.is_stopped() and skill_levels[1] > 0:
			skill_1_timer.start()
			translate_to_new_state(AllyState.SPECIAL)
			ally_sprite.play("skill1_start")
			body_collision.disabled = true
			hurt_box.monitorable = false
			if current_intercepting_enemy != null:
				current_intercepting_enemy.current_intercepting_units.erase(self)
			current_intercepting_enemy = null
			return
		if skill_3_timer.is_stopped() and skill_levels[3] > 0:
			skill_3_timer.start()
			translate_to_new_state(AllyState.SPECIAL)
			ally_sprite.play("skill3")
			skill3_locked_pos = position
			if current_intercepting_enemy != null:
				current_intercepting_enemy.current_intercepting_units.erase(self)
				skill3_locked_enemy = current_intercepting_enemy
				skill3_locked_pos = current_intercepting_enemy.position
			current_intercepting_enemy = null
			hurt_box.monitorable = false
			body_collision.disabled = true
			var move_pos: Vector2 = position
			move_pos.x += 40 if ally_sprite.flip_h else -40
			create_tween().tween_property(self,"position",move_pos,0.3)
			return
		if skill_4_timer.is_stopped() and skill_levels[4] > 0 and far_attack_area.get_overlapping_bodies().size() >= 3:
			skill_4_timer.start()
			translate_to_new_state(AllyState.SPECIAL)
			ally_sprite.play("skill4")
			skill_4_attack_area.position = position
			skill_4_second_attack_area.position = position
	super()
	pass


func skill3_release():
	var arrow_count: int = skill3_bullet_count_list[skill_levels[3]-1]
	for i in arrow_count:
		var target_pos: Vector2 = skill3_locked_pos
		if skill3_locked_enemy != null: target_pos = skill3_locked_enemy.position
		var radius: float = 75 * 2
		var offset_pos: Vector2 = Vector2(randf_range(-1,1),randf_range(-1,1)).normalized() * radius * randf()
		offset_pos.y *= 0.7
		target_pos += offset_pos
		summon_explosion_arrow(target_pos,0.5)
		await get_tree().create_timer(randf_range(0.05,0.1),false).timeout
	pass


func summon_explosion_arrow(target_pos: Vector2, wait_time: float):
	var summon_pos: Vector2 = skill_3_component.global_position
	summon_pos += Vector2(randf_range(-1,1),randf_range(-1,1)).normalized() * 10 * randf_range(0.5,1)
	var explosion_arrow: Bullet = summon_bullet(skill3_bullet_scene,summon_pos,target_pos,0,DataProcess.DamageType.PhysicsDamage)
	Stage.instance.bullets.add_child(explosion_arrow)
	explosion_arrow.process_mode = Node.PROCESS_MODE_DISABLED
	var move_pos: Vector2 = explosion_arrow.global_position
	move_pos += (target_pos - explosion_arrow.global_position).normalized() * -60
	create_tween().tween_property(explosion_arrow,"position",move_pos,0.3)
	create_tween().tween_property(explosion_arrow,"scale",Vector2.ONE * 2,0.3)
	await get_tree().create_timer(wait_time,false).timeout
	explosion_arrow.process_mode = Node.PROCESS_MODE_INHERIT
	explosion_arrow_shoot_audio.play()
	pass


func skill4_release():
	skill_4_arrow_effect.position = skill_4_marker.global_position
	skill_4_arrow_effect.show()
	var move_tween: Tween = create_tween()
	var target_pos: Vector2 = skill_4_arrow_effect.position + Vector2(0,-500)
	move_tween.tween_property(skill_4_arrow_effect,"position",target_pos,0.3)
	await move_tween.finished
	skill_4_arrow_effect.hide()
	var target_pos_list: PackedVector2Array
	var radius: float = 75 * 4
	for i in 36:
		var now_target_pos: Vector2 = Vector2(randf_range(-1,1),randf_range(-1,1)).normalized() * radius * randf()
		now_target_pos.y *= 0.7
		now_target_pos += skill_4_attack_area.global_position
		target_pos_list.append(now_target_pos)
	for bullet_target_pos in target_pos_list:
		var bullet: Bullet = skill4_effect_bullet_scene.instantiate()
		bullet.position = skill_4_arrow_effect.global_position
		bullet.target_position = bullet_target_pos
		bullet.bullet_speed = randf_range(1,1.5)
		Stage.instance.bullets.add_child(bullet)
	await get_tree().create_timer(0.4,false).timeout
	for body in skill_4_attack_area.get_overlapping_bodies():
		var enemy: Enemy = body.owner
		var damage: int = skill4_first_damage_list[skill_levels[4]-1]
		enemy.take_damage(damage,DataProcess.DamageType.PhysicsDamage,0,true,null,false,true)
		var slow_buff: PropertyBuff = skill4_slow_buff_scene.instantiate()
		enemy.buffs.add_child(slow_buff)
	delay_explosion_damage(target_pos_list)
	delay_explosion_audio.play()
	for pos in target_pos_list:
		var effect: Node2D = skill4_explosion_prepare_effect_scene.instantiate()
		effect.position = pos
		var target_scale: Vector2 = effect.scale
		effect.scale = Vector2.ZERO
		Stage.instance.bullets.add_child(effect)
		create_tween().tween_property(effect,"scale",target_scale,0.2)
		get_tree().create_timer(0.25,false).timeout.connect(func():effect.queue_free())
		await get_tree().create_timer(0.03,false).timeout
	pass


func delay_explosion_damage(explosion_pos_list: PackedVector2Array):
	await get_tree().create_timer(1.5,false).timeout
	var damage_block: DamageBlock = skill4_second_damage_list[skill_levels[4]-1]
	for body in skill_4_second_attack_area.get_overlapping_bodies():
		var enemy: Enemy = body.owner
		var damage: int = randi_range(damage_block.damage_low,damage_block.damage_high)
		enemy.take_damage(damage,DataProcess.DamageType.ExplodeDamage,0,false,null,true,true)
		var hurt_buff: PropertyBuff = skill4_hurt_buff_scene.instantiate()
		enemy.buffs.add_child(hurt_buff)
	for pos in explosion_pos_list:
		var explosion_effect: AnimatedSprite2D = explosion_effect_scene.instantiate()
		explosion_effect.position = pos
		var smoke_effect: AnimatedSprite2D = smoke_effect_scene.instantiate()
		smoke_effect.position = pos
		Stage.instance.bullets.add_child(smoke_effect)
		Stage.instance.bullets.add_child(explosion_effect)
	AudioManager.instance.play_explosion_audio()
	pass
