extends Enemy

@onready var attack_area: Area2D = $UnitBody/AttackArea
@onready var attack_audio: AudioStreamPlayer = $AttackAudio
@onready var skill_1_audio: AudioStreamPlayer = $Skill1Audio
@onready var skill_2_audio: AudioStreamPlayer = $Skill2Audio
@onready var bite_audio: AudioStreamPlayer = $BiteAudio
@onready var skill_1_timer: Timer = $Skill1Timer
@onready var skill_2_timer: Timer = $Skill2Timer
@onready var boss_ui: BossUI = $BossUI


func anim_offset():
	match enemy_sprite.animation:
		"attack","idle":
			enemy_sprite.position = Vector2(-185,-755) if enemy_sprite.flip_h else Vector2(185,-755)
		"die":
			enemy_sprite.position = Vector2(-410,-305) if enemy_sprite.flip_h else Vector2(410,-305)
		"move_back","move_front":
			enemy_sprite.position = Vector2(-25,-350) if enemy_sprite.flip_h else Vector2(30,-350)
		"move_normal":
			enemy_sprite.position = Vector2(-25,-425) if enemy_sprite.flip_h else Vector2(25,-425)
		"skill1":
			enemy_sprite.position = Vector2(-55,-675) if enemy_sprite.flip_h else Vector2(55,-675)
		"skill2":
			enemy_sprite.position = Vector2(75,-625) if enemy_sprite.flip_h else Vector2(-75,-625)
	pass


func frame_changed():
	if enemy_sprite.animation == "attack":
		if enemy_sprite.frame == 8 or enemy_sprite.frame == 23:
			attack_audio.play()
			var damage: int = float(randi_range(current_data.near_damage_low,current_data.near_damage_high)) / 2
			for body in attack_area.get_overlapping_bodies():
				var ally: Ally = body.owner
				ally.take_damage(damage,DataProcess.DamageType.ExplodeDamage,0,false,self,false,true)
	
	if enemy_sprite.animation == "skill1" and enemy_sprite.frame == 12:
		attack_audio.play()
		skill_1_audio.play()
		var ally_list: Array[Ally]
		for body in attack_area.get_overlapping_bodies():
			var ally: Ally = body.owner
			ally_list.append(ally)
		var damage_low: int = 600
		var damage_high: int = 800
		for ally in ally_list:
			var damage: int = randi_range(damage_low,damage_high)
			ally.take_damage(damage,DataProcess.DamageType.ExplodeDamage,0,false,self,false,true,)
			if ally.ally_state == Ally.AllyState.DIE:
				current_data.heal(ally.start_data.health)
	
	if enemy_sprite.animation == "skill2" and enemy_sprite.frame == 9:
		skill_2_audio.play()
		current_data.heal(400)
		var seckill_possible: float = 0.4
		if attack_area.get_overlapping_bodies().size() > 0 and randf_range(0,1) < seckill_possible:
			var kill_list: Array[Ally]
			for body in attack_area.get_overlapping_bodies():
				var ally: Ally = body.owner
				kill_list.append(ally)
			
			var kill_position: Vector2 = kill_list[0].hurt_box.global_position
			TextEffect.text_effect_show("秒杀！",TextEffect.TextEffectType.SecKill,kill_position + Vector2(randf_range(-10,10),randf_range(-10,10)))
			for ally in kill_list:
				if "god" in ally.get_groups(): continue
				ally.sec_kill(false)
			current_data.heal(200)
		else:
			var hurt_list: Array[Ally]
			for body in attack_area.get_overlapping_bodies():
				var ally: Ally = body.owner
				hurt_list.append(ally)
			var damage: int = 350
			var broken_rate: float = 0.8
			for ally in hurt_list:
				ally.take_damage(damage,DataProcess.DamageType.PhysicsDamage,broken_rate,false,self,false,true)
	pass


func battle():
	if enemy_sprite.animation == "idle":
		if skill_1_timer.is_stopped():
			skill_1_timer.start()
			enemy_sprite.play("skill1")
			return
		if skill_2_timer.is_stopped():
			skill_2_timer.start()
			enemy_sprite.play("skill2")
			bite_audio.play()
			return
	super()
	pass


func translate_to_new_state(new_state: EnemyState):
	super(new_state)
	if new_state == EnemyState.DIE:
		Achievement.achieve_complete("Boss3Dead")
	pass


func boss_music_play():
	super()
	Stage.instance.is_special_wave = true
	boss_ui.health_bar.value = 0
	boss_ui.process_mode = Node.PROCESS_MODE_INHERIT
	pass


func die_blood(blood_packed_scene: PackedScene = preload("res://Scenes/Effects/blood.tscn")):
	var blood = blood_packed_scene.instantiate() as Sprite2D
	blood.position = position
	blood.scale *= 3
	Stage.instance.bullets.add_child(blood)
	pass
