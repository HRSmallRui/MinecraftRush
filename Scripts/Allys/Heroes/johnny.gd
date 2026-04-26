extends Hero

@onready var skill_2_timer: Timer = $Skill2Timer
@onready var skill_3_timer: Timer = $Skill3Timer
@onready var skill_4_timer: Timer = $Skill4Timer
@onready var skill_2_duration_timer: Timer = $Skill2DurationTimer
@onready var skill_3_duration_timer: Timer = $Skill3DurationTimer
@onready var skill_2_hit_audio: AudioStreamPlayer = $Skill2HitAudio
@onready var skill_2_hit_timer: Timer = $Skill2HitTimer
@onready var skill_3_hit_timer: Timer = $Skill3HitTimer
@onready var skill_2_audio: AudioStreamPlayer = $Skill2Audio
@onready var skill_3_audio: AudioStreamPlayer = $Skill3Audio
@onready var skill_4_audio: AudioStreamPlayer = $Skill4Audio
@onready var skill_2_hit_area: Area2D = $UnitBody/Skill2HitArea


func _ready() -> void:
	super()
	skill_2_timer.wait_time = HeroSkillLibrary.hero_skill_data_library[ally_id][2].CD
	skill_3_timer.wait_time = HeroSkillLibrary.hero_skill_data_library[ally_id][3].CD
	skill_4_timer.wait_time = HeroSkillLibrary.hero_skill_data_library[ally_id][4].CD
	skill_2_duration_timer.wait_time = HeroSkillLibrary.hero_skill_data_library[ally_id][2].rotation_time[skill_levels[2]-1]
	skill_3_duration_timer.wait_time = HeroSkillLibrary.hero_skill_data_library[ally_id][3].attack_time
	pass


func start_data_process():
	super()
	match hero_level:
		1,2,3,4,5,6,7,8:
			skill_levels[0] = 1
		9,10:
			skill_levels[0] = 2
	pass


func anim_offset():
	match ally_sprite.animation:
		"attack","idle":
			ally_sprite.position = Vector2(-10,-100) if ally_sprite.flip_h else Vector2(10,-100)
		"die":
			ally_sprite.position = Vector2(45,-75) if ally_sprite.flip_h else Vector2(-45,-75)
		"move":
			ally_sprite.position = Vector2(10,-85) if ally_sprite.flip_h else Vector2(-15,-85)
		"rebirth":
			ally_sprite.position = Vector2(0,-105)
		"skill2","skill2_loop":
			ally_sprite.position = Vector2(10,-110) if ally_sprite.flip_h else Vector2(-15,-110)
		"skill2_end":
			ally_sprite.position = Vector2(5,-110) if ally_sprite.flip_h else Vector2(-10,-110)
		"skill3":
			ally_sprite.position = Vector2(-35,-115) if ally_sprite.flip_h else Vector2(35,-115)
		"skill3_end":
			ally_sprite.position = Vector2(-25,-80) if ally_sprite.flip_h else Vector2(25,-80)
		"skill3_loop":
			ally_sprite.position = Vector2(-50,-80) if ally_sprite.flip_h else Vector2(45,-80)
		"skill4":
			ally_sprite.position = Vector2(-25,-125) if ally_sprite.flip_h else Vector2(25,-125)
	pass


func frame_changed():
	if ally_sprite.animation == "attack" and ally_sprite.frame == 15:
		cause_damage()
		heal_health()
	if ally_sprite.animation == "skill2" and ally_sprite.frame == 11 and ally_state != AllyState.DIE:
		ally_sprite.play("skill2_loop")
		skill_2_duration_timer.start()
		skill_2_hit_timer.start()
		skill_2_audio.play()
	if ally_sprite.animation == "skill3" and ally_sprite.frame == 17 and ally_state != AllyState.DIE:
		ally_sprite.play("skill3_loop")
		skill_3_duration_timer.start()
		skill_3_hit_timer.start()
	if ally_sprite.animation == "skill3" and ally_sprite.frame == 2:
		skill_3_audio.play()
	if ally_sprite.animation == "skill4" and ally_sprite.frame == 43:
		skill_4_audio.play()
		if current_intercepting_enemy != null:
			var dizness_buff: DiznessBuff = preload("res://Scenes/Buffs/dizness_buff.tscn").instantiate()
			dizness_buff.duration = HeroSkillLibrary.hero_skill_data_library[ally_id][4].dizness_time
			current_intercepting_enemy.buffs.add_child(dizness_buff)
			var damage_low: int = HeroSkillLibrary.hero_skill_data_library[ally_id][4].damage_low[skill_levels[4]-1]
			var damage_high: int = HeroSkillLibrary.hero_skill_data_library[ally_id][4].damage_high[skill_levels[4]-1]
			var damage: int = randi_range(damage_low,damage_high)
			TextEffect.text_effect_show("重击！",TextEffect.TextEffectType.SecKill,current_intercepting_enemy.hurt_box.global_position)
			current_intercepting_enemy.take_damage(damage,DataProcess.DamageType.PhysicsDamage,0,false,self,true,true,)
		var heal_rate: float = HeroSkillLibrary.hero_skill_data_library[ally_id][4].heal_rate[skill_levels[4]-1]
		var heal_data: int = float(start_data.health) * heal_rate
		current_data.heal(heal_data)
	pass


func heal_health():
	var heal_data: int
	if skill_levels[1] == 0: heal_data = 0
	else: 
		heal_data = HeroSkillLibrary.hero_skill_data_library[ally_id][1].heal_health[skill_levels[1]-1]
		get_exp(skill1_exp_get[skill_levels[1]-1])
	current_data.heal(heal_data)
	pass


func on_normal_attack_hit(target_enemy: Enemy):
	if target_enemy.enemy_type >= Enemy.EnemyType.MiniBoss: return
	var broken_armor: float = HeroSkillLibrary.hero_skill_data_library[ally_id][0].broken_armor[skill_levels[0]-1]
	target_enemy.start_data.armor -= broken_armor
	target_enemy.current_data.update_armor()
	pass


func _on_skill_2_duration_timer_timeout() -> void:
	skill_2_audio.stop()
	skill_2_hit_timer.stop()
	if ally_state != AllyState.DIE:
		ally_sprite.play("skill2_end")
	pass # Replace with function body.


func _on_skill_3_duration_timer_timeout() -> void:
	skill_3_hit_timer.stop()
	skill_3_audio.stop()
	if ally_state != AllyState.DIE:
		ally_sprite.play("skill3_end")
	pass # Replace with function body.


func _on_skill_2_hit_timer_timeout() -> void:
	if skill_2_hit_area.has_overlapping_bodies():
		skill_2_hit_audio.play()
	for body in skill_2_hit_area.get_overlapping_bodies():
		var enemy: Enemy = body.owner
		var damage: int = HeroSkillLibrary.hero_skill_data_library[ally_id][2].damage
		enemy.take_damage(damage,DataProcess.DamageType.PhysicsDamage,0,false,self,false,true,)
		heal_health()
	pass # Replace with function body.


func _on_skill_3_hit_timer_timeout() -> void:
	if current_intercepting_enemy != null:
		var dizness_buff: DiznessBuff = preload("res://Scenes/Buffs/dizness_buff.tscn").instantiate()
		dizness_buff.duration = 0.2
		var damage: int = HeroSkillLibrary.hero_skill_data_library[ally_id][3].damage[skill_levels[3]-1]
		if current_intercepting_enemy.enemy_type < Enemy.EnemyType.MiniBoss:
			current_intercepting_enemy.buffs.add_child(dizness_buff)
		current_intercepting_enemy.take_damage(damage,DataProcess.DamageType.TrueDamage,0,false,self,false,true,)
		heal_health()
	pass # Replace with function body.


func die(explsion: bool = false):
	skill_2_duration_timer.stop()
	skill_3_duration_timer.stop()
	skill_2_hit_timer.stop()
	skill_3_hit_timer.stop()
	super(explsion)
	pass


func battle():
	if ally_sprite.animation == "idle":
		if skill_levels[2] > 0 and skill_2_timer.is_stopped() and skill_2_hit_area.get_overlapping_bodies().size() >= 3:
			translate_to_new_state(AllyState.SPECIAL)
			ally_sprite.play("skill2")
			skill_2_timer.start()
			get_exp(skill2_exp_get[skill_levels[2]-1])
			return
		if skill_levels[3] > 0 and skill_3_timer.is_stopped() and current_intercepting_enemy != null:
			if current_intercepting_enemy.current_data.health > 100:
				translate_to_new_state(AllyState.SPECIAL)
				ally_sprite.play("skill3")
				skill_3_timer.start()
				get_exp(skill2_exp_get[skill_levels[3]-1])
				return
		if skill_levels[4] > 0 and skill_4_timer.is_stopped() and current_intercepting_enemy != null:
			if current_intercepting_enemy.current_data.health > 150:
				ally_sprite.play("skill4")
				translate_to_new_state(AllyState.SPECIAL)
				skill_4_timer.start()
				get_exp(skill2_exp_get[skill_levels[4]-1])
				return
	super()
	pass


func move(target_pos:Vector2):
	if ally_sprite.animation == "skill2_loop":
		skill_2_duration_timer.stop()
		_on_skill_2_duration_timer_timeout()
	if ally_sprite.animation == "skill3_loop":
		skill_3_duration_timer.stop()
		_on_skill_3_duration_timer_timeout()
	super(target_pos)
	pass


func take_damage(damage: int, damage_type: DataProcess.DamageType, broken_rate: float, far_attack: bool = false, source: Node2D = null,explosion: bool = false,aoe_attack: bool = false, deadly: bool = true) -> bool:
	if far_attack and ally_sprite.animation == "skill2_loop":
		return false
	return super(damage,damage_type,broken_rate,far_attack,source,explosion,aoe_attack,deadly)
	pass


func level_up():
	var current_animation: StringName = ally_sprite.animation
	super()
	if "skill" in current_animation:
		ally_sprite.play(current_animation)
	pass
