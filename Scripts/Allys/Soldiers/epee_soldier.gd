extends Soldier

@onready var skill_2_audio: AudioStreamPlayer = $Skill2Audio
@onready var rebirth_audio: AudioStreamPlayer = $RebirthAudio
@onready var skill_2_timer: Timer = $Skill2Timer
@onready var skill_3_timer: Timer = $Skill3Timer
@onready var skill_3_duration_timer: Timer = $Skill3DurationTimer
@onready var rebirth_light: PointLight2D = $UnitBody/RebirthLight
@onready var super_attack_hit_area: Area2D = $UnitBody/SuperAttackHitArea
@onready var passive_attack_area: Area2D = $UnitBody/PassiveAttackArea

var rebirth_possible: float = 0
var current_rebirth_possible: float
var rebirth_count: int


func anim_offset():
	match ally_sprite.animation:
		"attack","idle":
			ally_sprite.position = Vector2(0,-140) if ally_sprite.flip_h else Vector2(-5,-140)
		"die":
			ally_sprite.position = Vector2(-20,-80) if ally_sprite.flip_h else Vector2(15,-80)
		"move":
			ally_sprite.position = Vector2(0,-85)
		"rebirth":
			ally_sprite.position = Vector2(0,-105) if ally_sprite.flip_h else Vector2(-5,-105)
		"super_attack":
			ally_sprite.position = Vector2(15,-95) if ally_sprite.flip_h else Vector2(-15,-95)
	pass


func frame_changed():
	if ally_sprite.animation == "attack" and ally_sprite.frame == 20:
		var damage: int = randi_range(current_data.near_damage_low,current_data.near_damage_high)
		var enemy_hit_list: Array[Enemy]
		for body in passive_attack_area.get_overlapping_bodies():
			var enemy = body.owner as Enemy
			if enemy != current_intercepting_enemy: enemy_hit_list.append(enemy)
		for enemy in enemy_hit_list:
			enemy.take_damage(damage / 2,DataProcess.DamageType.PhysicsDamage,0,false,null,false,true)
		
		if current_intercepting_enemy != null:
			current_intercepting_enemy.take_damage(damage,DataProcess.DamageType.PhysicsDamage,0,false,self,false,true)
			if randf_range(0,1) < 0.1:
				attack_text_effect()
			AudioManager.instance.battle_audio_play()
	
	if ally_sprite.animation == "super_attack" and ally_sprite.frame == 20:
		var damage_low: int
		var damage_high: int
		skill_2_audio.play()
		match soldier_skill_levels[1]:
			1:
				damage_low = 75
				damage_high = 150
			2:
				damage_low = 100
				damage_high = 180
			3:
				damage_low = 130
				damage_high = 210
		var text_position: Vector2 = hurt_box.global_position - Vector2(0,10)
		text_position.x -= 10 if ally_sprite.flip_h else -10
		TextEffect.text_effect_show("重击！",TextEffect.TextEffectType.SecKill,text_position)
		for body in super_attack_hit_area.get_overlapping_bodies():
			var enemy: Enemy = body.owner
			enemy.take_damage(randi_range(damage_low,damage_high),DataProcess.DamageType.ExplodeDamage,0,false,self,true,true)
	pass


func battle():
	if ally_sprite.animation == "idle" and normal_attack_timer.is_stopped():
		if soldier_skill_levels[1] > 0 and skill_2_timer.is_stopped():
			var possible: float = 0.3
			if randf_range(0,1) < possible:
				skill_2_timer.start()
				normal_attack_timer.start()
				ally_sprite.play("super_attack")
				return
	super()
	pass


func die(explosion: bool = false):
	rebirth_light.hide()
	if explosion:
		super(explosion)
		skill_3_duration_timer.stop()
		return
	#if soldier_skill_levels[2] > 0 and skill_3_timer.is_stopped():
		#if current_intercepting_enemy != null:
			#if current_intercepting_enemy.enemy_type >= Enemy.EnemyType.MiniBoss:
				#super(explosion)
				#skill_3_duration_timer.stop()
				#return
	
	if randf_range(0,1) < current_rebirth_possible and skill_3_timer.is_stopped():
		skill_3_rebirth()
		current_rebirth_possible -= 0.2
		return
	
	super(explosion)
	skill_3_duration_timer.stop()
	current_rebirth_possible = rebirth_possible
	pass


func skill_3_rebirth():
	translate_to_new_state(AllyState.SPECIAL)
	ally_sprite.play("rebirth")
	var heal_rate: float
	match soldier_skill_levels[2]:
		1: heal_rate = 0.4
		2: heal_rate = 0.6
		3: heal_rate = 0.8
	var heal_health: int = float(start_data.health) * heal_rate
	current_data.health = heal_health
	skill_3_timer.start()
	rebirth_audio.play()
	skill_3_duration_timer.start()
	rebirth_light.show()
	var invincible_buff: PropertyBuff = preload("res://Scenes/Buffs/Allys/epee_soldier_invincible_buff.tscn").instantiate()
	invincible_buff.duration = skill_3_duration_timer.wait_time
	invincible_buff.unit = self
	buffs.add_child(invincible_buff)
	rebirth_count += 1
	if rebirth_count >= 4:
		Achievement.achieve_complete("EpeeRebirth")
	pass


func soldier_skill_level_up(skill_id: int, skill_level: int):
	super(skill_id,skill_level)
	if skill_id == 2:
		match skill_level:
			1: 
				#skill_3_duration_timer.wait_time = 2
				rebirth_possible = 0.6
			2: 
				#skill_3_duration_timer.wait_time = 4
				rebirth_possible = 0.7
			3: 
				#skill_3_duration_timer.wait_time = 6
				rebirth_possible = 0.8
		
		current_rebirth_possible = rebirth_possible
		skill_3_timer.stop()
	pass


func _on_skill_3_duration_timer_timeout() -> void:
	rebirth_light.hide()
	pass # Replace with function body.


func rebirth():
	super()
	rebirth_count = 0
	pass
