extends Hero

@export_group("Skill1")
@export var skill1_damage: int
@export var skill1_bullet_scene: PackedScene
@export var skill1_dizness_time: float
@export_group("Skill2")
@export var skill2_attack_effect_scene: PackedScene
@export var circle_shape: CircleShape2D
@export var skill2_damage_block: DamageBlock
@export_group("Skill3")
@export var skill3_damage: int

@onready var skill_1_timer: Timer = $Skill1Timer
@onready var skill_2_timer: Timer = $Skill2Timer
@onready var skill_3_timer: Timer = $Skill3Timer
@onready var skill_3_condition_area: Area2D = $UnitBody/Skill3ConditionArea
@onready var skill_2_condition_area: Area2D = $UnitBody/Skill2ConditionArea
@onready var skill_2_attack_area: Area2D = $UnitBody/Skill2AttackArea
@onready var sec_kill_sprite: Sprite2D = $SecKillSprite
@onready var preparation_audio: AudioStreamPlayer = $PreparationAudio
@onready var sec_kill_audio: AudioStreamPlayer = $SecKillAudio

var skill3_locked_enemy: Enemy


func anim_offset():
	match ally_sprite.animation:
		"attack","idle":
			ally_sprite.position = Vector2(5,-125) if ally_sprite.flip_h else Vector2(-5,-125)
		"die":
			ally_sprite.position = Vector2(100,-105) if ally_sprite.flip_h else Vector2(-100,-105)
		"far_attack","skill1":
			ally_sprite.position = Vector2(-10,-100) if ally_sprite.flip_h else Vector2(10,-100)
		"move":
			ally_sprite.position = Vector2(20,-105) if ally_sprite.flip_h else Vector2(-20,-105)
		"skill2":
			ally_sprite.position = Vector2(0,-115) if ally_sprite.flip_h else Vector2(-5,-115)
		"skill3":
			ally_sprite.position = Vector2(0,-140) if ally_sprite.flip_h else Vector2(-5,-140)
		"rebirth":
			ally_sprite.position = Vector2(15,-115) if ally_sprite.flip_h else Vector2(-15,-115)
	pass


func frame_changed():
	if ally_sprite.animation == "attack" and ally_sprite.frame == 14:
		cause_damage()
	if ally_sprite.animation == "far_attack" and ally_sprite.frame == 15:
		far_attack_frame()
		AudioManager.instance.shoot_audio_1.play()
	
	if ally_sprite.animation == "skill3" and ally_sprite.frame == 22:
		sec_kill_sprite.hide()
		if skill3_locked_enemy != null:
			var show_text: String
			AudioManager.instance.shoot_audio_2.play()
			if skill3_locked_enemy.enemy_state != Enemy.EnemyState.DIE:
				if skill3_locked_enemy.enemy_type >= Enemy.EnemyType.Super:
					skill3_locked_enemy.take_damage(skill3_damage,DataProcess.DamageType.TrueDamage,0,true,null,true,false)
					show_text = "重创！"
				else:
					skill3_locked_enemy.sec_kill(true)
					show_text = "秒杀！"
				sec_kill_audio.play()
				TextEffect.text_effect_show(show_text,TextEffect.TextEffectType.SecKill,skill3_locked_enemy.hurt_box.global_position + Vector2(randf_range(-20,20),randf_range(-30,-10)))
	
	if ally_sprite.animation == "skill1" and ally_sprite.frame == 15 and far_attack_target_enemy != null:
		if far_attack_target_enemy == null: return
		AudioManager.instance.shoot_audio_1.play()
		var summon_pos: Vector2 = far_attack_marker_flip.global_position if ally_sprite.flip_h else far_attack_marker.global_position
		var target_pos: Vector2 = far_attack_target_enemy.hurt_box.global_position
		target_pos += far_attack_target_enemy.direction * far_attack_target_enemy.current_data.unit_move_speed * 2
		var bullet: Bullet = summon_bullet(skill1_bullet_scene,summon_pos,target_pos,skill1_damage,DataProcess.DamageType.PhysicsDamage)
		bullet.broken_rate = 1
		Stage.instance.bullets.add_child(bullet)
	pass


func idle_process():
	super()
	if ally_state == AllyState.IDLE:
		if far_attack_area.has_overlapping_bodies() and skill_1_timer.is_stopped():
			skill_1_timer.start()
			translate_to_new_state(AllyState.SPECIAL)
			far_attack_target_enemy = get_skill1_enemy()
			ally_sprite.flip_h = far_attack_target_enemy.position.x < position.x
			ally_sprite.play("skill1")
			return
		
		if skill_3_condition_area.has_overlapping_bodies() and skill_3_timer.is_stopped():
			skill3_locked_enemy = get_highest_health_enemy()
			if skill3_locked_enemy != null:
				skill_3_timer.start()
				translate_to_new_state(AllyState.SPECIAL)
				ally_sprite.play("skill3")
				ally_sprite.flip_h = skill3_locked_enemy.position.x < position.x
				preparation_audio.play()
				sec_kill_sprite.show()
				return
		
		if skill_2_condition_area.get_overlapping_bodies().size() >= 3 and skill_2_timer.is_stopped():
			translate_to_new_state(AllyState.SPECIAL)
			skill_2_timer.start()
			ally_sprite.play("skill2")
			delay_skill2_release()
			return
	pass


func get_highest_health_enemy() -> Enemy:
	var target_enemy_list: Array[Enemy]
	for body in skill_3_condition_area.get_overlapping_bodies():
		var enemy: Enemy = body.owner
		target_enemy_list.append(enemy)
	if target_enemy_list.is_empty(): return null
	var back_enemy: Enemy = target_enemy_list[0]
	for enemy in target_enemy_list:
		if enemy.start_data.health > back_enemy.start_data.health: back_enemy = enemy
		elif enemy.start_data.health == back_enemy.start_data.health and enemy.current_data.health > back_enemy.current_data.health:
			back_enemy = enemy
	
	return back_enemy


func translate_to_new_state(new_state: AllyState):
	super(new_state)
	sec_kill_sprite.hide()
	pass


func _process(delta: float) -> void:
	super(delta)
	if skill3_locked_enemy != null:
		sec_kill_sprite.global_position = skill3_locked_enemy.hurt_box.global_position
	else:
		sec_kill_sprite.hide()
	pass


func get_skill1_enemy() -> Enemy:
	var target_enemy_list: Array[Enemy]
	for body in far_attack_area.get_overlapping_bodies():
		var enemy: Enemy = body.owner
		target_enemy_list.append(enemy)
	if target_enemy_list.is_empty(): return null
	var back_enemy: Enemy = target_enemy_list[0]
	for enemy in target_enemy_list:
		if enemy.current_data.health > back_enemy.current_data.health: back_enemy = enemy
	return back_enemy


func delay_skill2_release():
	skill_2_attack_area.position = skill_2_condition_area.global_position
	await get_tree().create_timer(0.8,false).timeout
	delay_skill2_damage()
	for i in 80:
		var bullet: Bullet = skill2_attack_effect_scene.instantiate()
		bullet.position = skill_2_attack_area.position
		var direction: Vector2 = Vector2(randf_range(-1,1),randf_range(-1,1)).normalized()
		direction.y *= 0.7
		direction *= circle_shape.radius * skill_2_attack_area.scale.length()
		bullet.position += direction * randf()
		bullet.target_position = bullet.position
		bullet.position += Vector2(randf_range(-20,20),randf_range(-400,-300))
		Stage.instance.bullets.add_child(bullet)
		bullet.hit_box.monitoring = false
		AudioManager.instance.shoot_audio_1.play()
		await get_tree().create_timer(0.01,false,true).timeout
	pass


func delay_skill2_damage():
	for body in skill_2_attack_area.get_overlapping_bodies():
		var enemy: Enemy = body.owner
		var damage: int = randi_range(skill2_damage_block.damage_low,skill2_damage_block.damage_high)
		enemy.take_damage(damage,DataProcess.DamageType.PhysicsDamage,0,true,null,false,true)
	pass
