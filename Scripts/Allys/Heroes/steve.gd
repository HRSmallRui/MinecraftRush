extends Hero

@onready var skill_2_timer: Timer = $Skill2Timer
@onready var skill_3_timer: Timer = $Skill3Timer
@onready var skill_4_timer: Timer = $Skill4Timer
@onready var skill_4_hit_box: Area2D = $UnitBody/Skill4HitBox
@onready var skill_4_audio: AudioStreamPlayer = $Skill4Audio
@onready var skill_3_audio: AudioStreamPlayer = $Skill3Audio


func anim_offset():
	skill_4_hit_box.position.x = -260 if ally_sprite.flip_h else 260
	match ally_sprite.animation:
		"attack","idle":
			ally_sprite.position = Vector2(15,-125) if ally_sprite.flip_h else Vector2(-20,-125)
		"die":
			ally_sprite.position = Vector2(25,-85) if ally_sprite.flip_h else Vector2(-25,-85)
		"move":
			ally_sprite.position = Vector2(-20,-85) if ally_sprite.flip_h else Vector2(20,-85)
		"skill_2":
			ally_sprite.position = Vector2(0,-90)
		"skill_3":
			ally_sprite.position = Vector2(-20,-95) if ally_sprite.flip_h else Vector2(15,-95)
		"skill_4":
			ally_sprite.position = Vector2(-10,-290) if ally_sprite.flip_h else Vector2(5,-290)
		"rebirth":
			ally_sprite.position = Vector2(-30,-135) if ally_sprite.flip_h else Vector2(30,-135)
	
	pass


func frame_changed():
	if ally_sprite.animation == "attack" and ally_sprite.frame == 16:
		cause_damage()
	elif ally_sprite.animation == "skill_2" and ally_sprite.frame == 14:
		skill_2_process()
	elif ally_sprite.animation == "skill_4" and ally_sprite.frame == 31:
		skill_4_process()
	elif ally_sprite.animation == "skill_3" and ally_sprite.frame == 33:
		after_golen_apple_eaten()
	pass


func start_data_process():
	super()
	match hero_level:
		1,2,3: skill_levels[0] = 1
		4,5,6,7: skill_levels[0] = 2
		8,9,10: skill_levels[0] = 3
	start_data.total_defence_rate = HeroSkillLibrary.hero_skill_data_library[ally_id][0][0][skill_levels[0]-1]
	if skill_levels[1] > 0:
		start_data.health += HeroSkillLibrary.hero_skill_data_library[ally_id][1][0][skill_levels[1]-1]
	pass


func battle():
	if ally_sprite.animation == "idle":
		if skill_levels[2] > 0 and skill_2_timer.is_stopped() and skill2_is_valid_to_release():
			translate_to_new_state(AllyState.SPECIAL)
			ally_sprite.play("skill_2")
			skill_2_timer.start()
			return
		if skill_levels[4] > 0 and skill_4_timer.is_stopped() and skill4_is_valid_to_release():
			translate_to_new_state(AllyState.SPECIAL)
			ally_sprite.play("skill_4")
			skill_4_timer.start()
			return
		if normal_attack_timer.is_stopped():
			ally_sprite.play("attack")
			normal_attack_timer.start()
			return
	pass


func skill_2_process():
	if current_intercepting_enemy != null:
		var enemy = current_intercepting_enemy as Enemy
		var damage_low: int = HeroSkillLibrary.hero_skill_data_library[ally_id][2][0][skill_levels[2]-1]
		var damage_high: int = HeroSkillLibrary.hero_skill_data_library[ally_id][2][1][skill_levels[2]-1]
		var damage: int = randi_range(damage_low,damage_high)
		if enemy.take_damage(damage,DataProcess.DamageType.PhysicsDamage,0.5,false,self,false):
			AudioManager.instance.battle_audio_play()
			attack_text_effect(["铮！","锵！","唰！","剁！","铛！","哐！"],TextEffect.TextEffectType.Magic)
			var broken_armor: float = HeroSkillLibrary.hero_skill_data_library[ally_id][2][2][skill_levels[2]-1]
			var broken_buff: PropertyBuff = preload("res://Scenes/Buffs/Steve/armor_broken_debuff.tscn").instantiate()
			broken_buff.buff_blocks[0].operation_data = -broken_armor
			enemy.buffs.add_child(broken_buff)
		
			get_exp(skill2_exp_get[skill_levels[2]-1])
	pass


func skill_4_process():
	skill_4_audio.play(0.1)
	var has_sec_killed: bool = false
	var in_area_enemy_list: Array[Enemy]
	for hurt_box: HurtBox in skill_4_hit_box.get_overlapping_areas():
		var unit = hurt_box.owner
		if unit is Enemy: in_area_enemy_list.append(unit)
	
	var damage: int = HeroSkillLibrary.hero_skill_data_library[ally_id][4][0][skill_levels[4]-1]
	for enemy in in_area_enemy_list:
		enemy.take_damage(damage,DataProcess.DamageType.ExplodeDamage,0,false,self,true,true)
		get_exp(skill4_exp_get[skill_levels[4]-1])
		
	for enemy in in_area_enemy_list:
		if enemy.enemy_state != Enemy.EnemyState.DIE and enemy.enemy_type < Enemy.EnemyType.Super:
			var kill_rate: float = HeroSkillLibrary.hero_skill_data_library[ally_id][4][2][skill_levels[4]-1]
			var health_rate: float = float(enemy.current_data.health) / enemy.start_data.health
			if health_rate <= kill_rate: enemy.sec_kill(true)
			if enemy.enemy_state == Enemy.EnemyState.DIE and !has_sec_killed:
				has_sec_killed = true
				TextEffect.text_effect_show("秒杀",TextEffect.TextEffectType.SecKill,enemy.global_position + Vector2(0,-30))
	
	if in_area_enemy_list.size() > 0 and !has_sec_killed:
		TextEffect.text_effect_show("重创！",TextEffect.TextEffectType.SecKill,(global_position + skill_4_hit_box.global_position)/2 + Vector2(0,-30))
	
	for enemy in in_area_enemy_list:
		if enemy.enemy_state == Enemy.EnemyState.DIE: continue
		var blood_buff: BuffClass = preload("res://Scenes/Buffs/Steve/steve_blood_buff.tscn").instantiate()
		blood_buff.duration = HeroSkillLibrary.hero_skill_data_library[ally_id][4][1][skill_levels[4]-1]
		enemy.buffs.add_child(blood_buff)
	pass


func golden_apple():
	translate_to_new_state(AllyState.SPECIAL)
	ally_sprite.play("skill_3")
	skill_3_audio.play()
	pass


func _process(delta: float) -> void:
	if ally_state != AllyState.MOVE and ally_state != AllyState.DIE and ally_sprite.animation == "idle":
		if skill_levels[3] > 0:
			var health_rate = float(current_data.health) / start_data.health
			if health_rate < 0.2 and skill_3_timer.is_stopped():
				skill_3_timer.start()
				golden_apple()
				return
	super(delta)
	pass


func after_golen_apple_eaten():
	var heal_data: int = HeroSkillLibrary.hero_skill_data_library[ally_id][3][0][skill_levels[3]-1]
	current_data.heal(heal_data)
	get_exp(skill3_exp_get[skill_levels[3]-1])
	var heal_buff: HealBuff = preload("res://Scenes/Buffs/Steve/steve_golen_apple_heal_buff.tscn").instantiate()
	heal_buff.duration = HeroSkillLibrary.hero_skill_data_library[ally_id][3][1][skill_levels[3]-1]
	buffs.add_child(heal_buff)
	pass


func skill4_is_valid_to_release() -> bool:
	if skill_4_hit_box.get_overlapping_bodies().size() >= 4:
		return true
	var damage: int = HeroSkillLibrary.hero_skill_data_library[ally_id][4][0][skill_levels[4]-1]
	damage *= 0.75
	for body in skill_4_hit_box.get_overlapping_bodies():
		var enemy: Enemy = body.owner
		if enemy.current_data.health > damage: return true
	return false
	pass


func skill2_is_valid_to_release() -> bool:
	if current_intercepting_enemy == null: return false
	if current_intercepting_enemy.current_data.armor > 0: return true
	return false
	pass
