extends Hero


const TALZIN_NEAR = preload("res://Assets/Animations/Heroes/Talzin/talzin_near.res")
const TALZIN_FAR = preload("res://Assets/Animations/Heroes/Talzin/talzin_far.res")

@onready var skill_1_timer: Timer = $Skill1Timer
@onready var skill_2_timer: Timer = $Skill2Timer
@onready var skill_1_area: Area2D = $UnitBody/Skill1Area

var skill1_locked_enemy: Enemy
var skill2_locked_enemy: Enemy


func anim_offset():
	if ally_sprite.sprite_frames == TALZIN_NEAR:
		match ally_sprite.animation:
			"attack","idle":
				ally_sprite.position = Vector2(-20,-80) if ally_sprite.flip_h else Vector2(20,-80)
			"die":
				ally_sprite.position = Vector2(60,-100) if ally_sprite.flip_h else Vector2(-60,-100)
			"translate_to_near":
				ally_sprite.position = Vector2(-10,-225) if ally_sprite.flip_h else Vector2(5,-225)
			"rebirth":
				ally_sprite.position = Vector2(20,-85) if ally_sprite.flip_h else Vector2(-20,-85)
	elif ally_sprite.sprite_frames == TALZIN_FAR:
		match ally_sprite.animation:
			"die":
				ally_sprite.position = Vector2(60,-100) if ally_sprite.flip_h else Vector2(-60,-100)
			"far_attack","idle":
				ally_sprite.position = Vector2(0,-85)
			"move":
				ally_sprite.position = Vector2(-10,-95) if ally_sprite.flip_h else Vector2(10,-95)
			"rebirth":
				ally_sprite.position = Vector2(10,-85) if ally_sprite.flip_h else Vector2(-10,-85)
			"skill1":
				ally_sprite.position = Vector2(-20,-85) if ally_sprite.flip_h else Vector2(20,-85)
			"skill2":
				ally_sprite.position = Vector2(-15,-85) if ally_sprite.flip_h else Vector2(10,-85)
			"translate_to_far":
				ally_sprite.position = Vector2(10,-85) if ally_sprite.flip_h else Vector2(-10,-85)
			"move":
				ally_sprite.position = Vector2(15,-95) if ally_sprite.flip_h else Vector2(-20,-95)
	pass


func _ready() -> void:
	ally_sprite.sprite_frames = TALZIN_FAR
	super()
	skill_1_timer.wait_time = HeroSkillLibrary.hero_skill_data_library[ally_id][1].CD
	skill_2_timer.wait_time = HeroSkillLibrary.hero_skill_data_library[ally_id][2].CD
	pass


func frame_changed():
	if ally_sprite.animation == "far_attack" and ally_sprite.frame == 26:
		far_attack_frame()
		AudioManager.instance.shoot_audio_2.play()
	if ally_sprite.animation == "attack" and ally_sprite.frame == 8:
		cause_damage()
	if ally_sprite.animation == "skill1" and ally_sprite.frame == 30:
		skill1_release()
		AudioManager.instance.shoot_audio_2.play()
	if ally_sprite.animation == "skill2" and ally_sprite.frame == 26:
		skill2_release()
		AudioManager.instance.shoot_audio_2.play()
	pass


func cause_damage(damage_type: int = 0):
	if current_intercepting_enemy == null: return
	match damage_type:
		0:
			var target_enemy: Enemy = current_intercepting_enemy
			var damage: int = randi_range(current_data.near_damage_low,current_data.near_damage_high)
			var broken_rate: float = 0 if skill_levels[3] == 0 else 1
			if current_intercepting_enemy.take_damage(damage,DataProcess.DamageType.PhysicsDamage,broken_rate,false,self):
				get_exp(int(float(damage) * exp_rate))
				if target_enemy.enemy_state != Enemy.EnemyState.DIE:
					on_normal_attack_hit(target_enemy)
				if randf_range(0,1) < 0.1:
					var text:String
					match randi_range(1,6):
						1: text = "铮！"
						2: text = "锵！"
						3: text = "唰！"
						4: text = "剁！"
						5: text = "铛！"
						6: text = "哐！"
					var show_pos: Vector2 = hurt_box.global_position - Vector2(0,10)
					show_pos += Vector2(-20,0) if ally_sprite.flip_h else Vector2(20,0)
					TextEffect.text_effect_show(text,TextEffect.TextEffectType.Barrack,show_pos)
				AudioManager.instance.battle_audio_play()
	pass


func far_attack_frame(damage_type: DataProcess.DamageType = DataProcess.DamageType.PhysicsDamage):
	if far_attack_target_enemy == null: return
	var summon_pos:Vector2 = far_attack_marker_flip.global_position if ally_sprite.flip_h else far_attack_marker.global_position
	var target_pos: Vector2 = far_attack_target_enemy.hurt_box.global_position
	target_pos += far_attack_target_enemy.direction * far_attack_target_enemy.current_data.unit_move_speed * 2
	var damage: int = randi_range(current_data.far_damage_low,current_data.far_damage_high)
	var bullet: Bullet = summon_bullet(far_attack_bullet_scene,summon_pos,target_pos,damage,damage_type)
	
	if skill_levels[4] > 0:
		var continue_count: int = HeroSkillLibrary.hero_skill_data_library[ally_id][4].penetrate_count[skill_levels[4]-1]
		bullet.bullet_special_tag_levels["continue"] = [0.2,continue_count,0.5,far_attack_bullet_scene] ##穿梭时间，继续穿梭人数，伤害倍率,场景
	
	Stage.instance.bullets.add_child(bullet)
	get_exp(int(float(damage) * exp_rate))
	pass


func on_normal_attack_hit(target_enemy: Enemy):
	var broken_buff: PropertyBuff = preload("res://Scenes/Buffs/Talzin/talzin_broken_armor.tscn").instantiate()
	var broken_data: float
	match skill_levels[3]:
		1: broken_data = -0.01
		2: broken_data = -0.02
		3: broken_data = -0.03
	broken_buff.buff_blocks[0].operation_data = broken_data
	target_enemy.buffs.add_child(broken_buff)
	pass


func battle_process():
	if ally_sprite.sprite_frames == TALZIN_FAR:
		translate_to_new_state(AllyState.SPECIAL)
		ally_sprite.sprite_frames = TALZIN_NEAR
		ally_sprite.play("translate_to_near")
		return
	super()
	pass


func move_back():
	if ally_sprite.sprite_frames == TALZIN_NEAR:
		translate_to_new_state(AllyState.SPECIAL)
		ally_sprite.sprite_frames = TALZIN_FAR
		ally_sprite.play("translate_to_far")
		return
	super()
	pass


func move(target_pos:Vector2):
	if ally_sprite.sprite_frames == TALZIN_NEAR:
		translate_to_new_state(AllyState.SPECIAL)
		if current_intercepting_enemy != null:
			current_intercepting_enemy.current_intercepting_units.erase(self)
		current_intercepting_enemy = null
		ally_sprite.sprite_frames = TALZIN_FAR
		ally_sprite.play("translate_to_far")
		#await get_tree().process_frame
		#Stage.instance.stop.animation_player.stop()
		#Stage.instance.stop.hide()
		#await ally_sprite.animation_finished
		#if ally_state == AllyState.DIE: return
	super(target_pos)
	pass


func idle_process():
	if skill_levels[1] > 0 and skill_1_timer.is_stopped() and far_attack_timer.is_stopped():
		var enemy:Enemy = skill1_can_be_released()
		if enemy != null:
			skill1_locked_enemy = enemy
			translate_to_new_state(AllyState.SPECIAL)
			ally_sprite.flip_h = enemy.position.x < position.x
			ally_sprite.play("skill1")
			skill_1_timer.start()
			far_attack_timer.start()
			return
	if skill_levels[2] > 0 and skill_2_timer.is_stopped() and far_attack_timer.is_stopped() and far_attack_area.has_overlapping_bodies():
		var enemy: Enemy = far_attack_area.get_overlapping_bodies()[0].owner
		skill2_locked_enemy = enemy
		translate_to_new_state(AllyState.SPECIAL)
		ally_sprite.flip_h = enemy.position.x < position.x
		ally_sprite.play("skill2")
		skill_2_timer.start()
		far_attack_timer.start()
		return
	super()
	pass


func skill1_can_be_released() -> Enemy:
	var enemy_list: Array[Enemy]
	for body in skill_1_area.get_overlapping_bodies():
		var enemy: Enemy = body.owner
		if enemy.enemy_type < Enemy.EnemyType.Super:
			enemy_list.append(enemy)
	if enemy_list.is_empty():
		return null
	else:
		var back_enemy: Enemy = enemy_list[0]
		for enemy in enemy_list:
			if back_enemy.current_data.health < enemy.current_data.health:
				back_enemy = enemy
		
		return back_enemy
	pass


func skill1_release():
	if skill1_locked_enemy == null:
		var enemy: Enemy = skill1_can_be_released()
		if enemy == null: return
		else:
			skill1_locked_enemy = enemy
			ally_sprite.flip_h = enemy.position.x < position.x
	if skill1_locked_enemy.enemy_state == Enemy.EnemyState.DIE:
		var enemy: Enemy = skill1_can_be_released()
		if enemy == null: return
		else:
			skill1_locked_enemy = enemy
			ally_sprite.flip_h = enemy.position.x < position.x
	var target_pos: Vector2 = skill1_locked_enemy.hurt_box.global_position
	var summon_pos: Vector2 = far_attack_marker_flip.global_position if ally_sprite.flip_h else far_attack_marker.global_position
	var damage: int = randi_range(current_data.far_damage_low,current_data.far_damage_high)
	var bullet = summon_bullet(preload("res://Scenes/Bullets/talzin_kill_arrow.tscn"),summon_pos,target_pos,damage,DataProcess.DamageType.PhysicsDamage) as PercentageDamageBullet
	bullet.percentage_rate = HeroSkillLibrary.hero_skill_data_library[ally_id][1].damage_percentage[skill_levels[1]-1]
	Stage.instance.bullets.add_child(bullet)
	get_exp(skill1_exp_get[skill_levels[1]-1])
	pass


func skill2_release():
	if skill2_locked_enemy == null: return
	var target_pos: Vector2 = skill2_locked_enemy.hurt_box.global_position
	var summon_pos: Vector2 = far_attack_marker_flip.global_position if ally_sprite.flip_h else far_attack_marker.global_position
	var damage: int = randi_range(current_data.far_damage_low,current_data.far_damage_high)
	var bullet: Bullet = summon_bullet(preload("res://Scenes/Bullets/talzin_poison_arrow.tscn"),summon_pos,target_pos,damage,DataProcess.DamageType.PhysicsDamage)
	bullet.special_skill_level = skill_levels[2]
	Stage.instance.bullets.add_child(bullet)
	get_exp(skill2_exp_get[skill_levels[1]-1])
	pass
