extends Hero

@onready var skill_1_timer: Timer = $Skill1Timer
@onready var skill_1_condition_area: Area2D = $UnitBody/Skill1ConditionArea
@onready var skill_1_audio_1: AudioStreamPlayer = $Skill1Audio1
@onready var skill_1_audio_2: AudioStreamPlayer = $Skill1Audio2
@onready var skill_2_audio: AudioStreamPlayer = $Skill2Audio
@onready var skill_2_timer: Timer = $Skill2Timer
@onready var skill_3_timer: Timer = $Skill3Timer
@onready var skill_3_audio: AudioStreamPlayer = $Skill3Audio
@onready var skill_3_condition_area: Area2D = $UnitBody/Skill3ConditionArea
@onready var skill_4_condition_area: Area2D = $UnitBody/Skill4ConditionArea
@onready var skill_4_timer: Timer = $Skill4Timer
@onready var skill_4_audio: AudioStreamPlayer = $Skill4Audio

var immune_possible: float
var skill_1_linked_enemy: Enemy
var skill_4_linked_enemy: Enemy
var is_skill4_add: bool
var skill_4_linked_enemy_path: EnemyPath


func anim_offset():
	match ally_sprite.animation:
		"attack","idle":
			ally_sprite.position = Vector2(-10,-70) if ally_sprite.flip_h else Vector2(5,-70)
		"die":
			ally_sprite.position = Vector2(55,-90) if ally_sprite.flip_h else Vector2(-60,-90)
		"move":
			ally_sprite.position = Vector2(0,-75)
		"rebirth":
			ally_sprite.position = Vector2(30,-135) if ally_sprite.flip_h else Vector2(-30,-135)
		"skill1":
			ally_sprite.position = Vector2(30,-140) if ally_sprite.flip_h else Vector2(-35,-140)
		"skill3":
			ally_sprite.position = Vector2(10,-125) if ally_sprite.flip_h else Vector2(-15,-125)
		"skill4":
			ally_sprite.position = Vector2(20,-190) if ally_sprite.flip_h else Vector2(-25,-190)
	pass


func frame_changed():
	if ally_sprite.animation == "attack" and ally_sprite.frame == 18:
		cause_damage()
	if ally_sprite.animation == "skill1" and ally_sprite.frame == 22:
		skill_1_release()
	if ally_sprite.animation == "skill3":
		if ally_sprite.frame == 12 or ally_sprite.frame == 22:
			var skill_damage_low: int = HeroSkillLibrary.hero_skill_data_library[ally_id][3].damage_low[skill_levels[3]-1]
			var skill_damage_high: int = HeroSkillLibrary.hero_skill_data_library[ally_id][3].damage_high[skill_levels[3]-1]
			var skill_damage:int = randi_range(skill_damage_low / 2, skill_damage_high / 2)
			for body in skill_3_condition_area.get_overlapping_bodies():
				var enemy: Enemy = body.owner
				enemy.take_damage(skill_damage,DataProcess.DamageType.PhysicsDamage,0,false,self,false,true)
				var dizness_buff: DiznessBuff = preload("res://Scenes/Buffs/dizness_buff.tscn").instantiate()
				dizness_buff.duration = 1
				dizness_buff.buff_tag = "alex_dizness_3"
				enemy.buffs.add_child(dizness_buff)
		if ally_sprite.frame == 12:
			skill_3_audio.play()
	if ally_sprite.animation == "skill4" and ally_sprite.frame == 35:
		skill_4_release()
	pass


func start_data_process():
	super()
	match hero_level:
		1,2,3: skill_levels[0] = 1
		4,5,6,7: skill_levels[0] = 2
		8,9,10: skill_levels[0] = 3
	immune_possible = HeroSkillLibrary.hero_skill_data_library[ally_id][0].immune_possible[skill_levels[0]-1]
	pass


func take_damage(damage: int, damage_type: DataProcess.DamageType, broken_rate: float, far_attack: bool = false, source: Node2D = null,explosion: bool = false,aoe_attack: bool = false, deadly: bool = true) -> bool:
	if !far_attack and source is Enemy:
		var enemy: Enemy = source
		if enemy.enemy_type < Enemy.EnemyType.MiniBoss:
			if randf_range(0,1) < immune_possible:
				TextEffect.text_effect_show("回避",TextEffect.TextEffectType.Magic,hurt_box.global_position)
				return false
			
	if skill_levels[2] > 0 and skill_2_timer.is_stopped():
		if current_data.health < start_data.health and ally_state != AllyState.DIE and source is Enemy:
			var sheild: PropertyBuff = preload("res://Scenes/Buffs/Alex/alex_sheild_buff.tscn").instantiate()
			skill_2_audio.play()
			skill_2_timer.start()
			sheild.duration = HeroSkillLibrary.hero_skill_data_library[ally_id][2].duration[skill_levels[2]-1]
			buffs.add_child(sheild)
			get_exp(skill2_exp_get[skill_levels[2]-1])
	return super(damage,damage_type,broken_rate,far_attack,source,explosion,aoe_attack, deadly)
	pass


func skill_1_release():
	if skill_1_linked_enemy == null:
		skill_1_timer.stop()
		translate_to_new_state(AllyState.IDLE)
		return
	elif skill_1_linked_enemy.enemy_state == Enemy.EnemyState.DIE:
		if skill_1_condition_area.has_overlapping_bodies():
			skill_1_linked_enemy = skill_1_condition_area.get_overlapping_bodies()[0].owner
		else:
			skill_1_timer.stop()
			translate_to_new_state(AllyState.IDLE)
			return
	match randi_range(0,1):
		0: skill_1_audio_1.play()
		1: skill_1_audio_2.play()
	var lighting_bullet: Bullet = preload("res://Scenes/Bullets/alex_skill1_bullet.tscn").instantiate()
	lighting_bullet.special_skill_level = skill_levels[1]
	var damage: int = randi_range(2 * current_data.near_damage_low, 2 * current_data.near_damage_high)
	lighting_bullet.damage = damage
	lighting_bullet.position = far_attack_marker_flip.global_position if ally_sprite.flip_h else far_attack_marker.global_position
	lighting_bullet.target_position = skill_1_linked_enemy.hurt_box.global_position
	lighting_bullet.target_position += skill_1_linked_enemy.direction * skill_1_linked_enemy.current_data.unit_move_speed * 2
	lighting_bullet.source = self
	Stage.instance.bullets.add_child(lighting_bullet)
	get_exp(skill1_exp_get[skill_levels[1]-1])
	pass


func idle_process():
	super()
	if ally_state != AllyState.IDLE: return
	if skill_levels[1] > 0 and skill_1_timer.is_stopped() and skill_1_condition_area.has_overlapping_bodies():
		skill_1_linked_enemy = skill_1_condition_area.get_overlapping_bodies()[0].owner
		translate_to_new_state(AllyState.SPECIAL)
		ally_sprite.play("skill1")
		skill_1_timer.start()
		ally_sprite.flip_h = skill_1_linked_enemy.global_position.x < global_position.x
		anim_offset()
		return
	if skill_levels[4] > 0 and skill_4_timer.is_stopped() and skill_4_condition_area.has_overlapping_bodies():
		skill_4_linked_enemy = skill_4_condition_area.get_overlapping_bodies()[0].owner
		translate_to_new_state(AllyState.SPECIAL)
		ally_sprite.play("skill4")
		
		var enemy_path: EnemyPath = skill_4_linked_enemy.get_parent()
		skill_4_linked_enemy_path = enemy_path
		var self_progress: float = enemy_path.curve.get_closest_offset(position)
		var watched_point: Vector2
		if skill_4_linked_enemy.progress > self_progress:
			watched_point = enemy_path.curve.sample_baked(self_progress + 1)
			is_skill4_add = true
		else:
			watched_point = enemy_path.curve.sample_baked(self_progress - 1)
			is_skill4_add = false
		ally_sprite.flip_h = skill_4_linked_enemy.position.x < position.x
		
		skill_4_timer.start()
		anim_offset()
		skill_3_audio.play()
		return
	pass


func battle():
	if ally_sprite.animation == "idle":
		if skill_levels[1] > 0 and skill_1_timer.is_stopped() and skill_1_condition_area.has_overlapping_bodies():
			skill_1_linked_enemy = skill_1_condition_area.get_overlapping_bodies()[0].owner
			translate_to_new_state(AllyState.SPECIAL)
			ally_sprite.play("skill1")
			skill_1_timer.start()
			ally_sprite.flip_h = skill_1_linked_enemy.global_position.x < global_position.x
			anim_offset()
			return
		
		if skill_levels[3] > 0 and skill_3_timer.is_stopped() and skill_3_condition_area.get_overlapping_bodies().size() >= 2:
			skill_3_release()
			skill_3_timer.start()
			return
		
		if skill_levels[4] > 0 and skill_4_timer.is_stopped() and skill_4_condition_area.has_overlapping_bodies():
			skill_4_linked_enemy = skill_4_condition_area.get_overlapping_bodies()[0].owner
			translate_to_new_state(AllyState.SPECIAL)
			ally_sprite.play("skill4")
			
			var enemy_path: EnemyPath = skill_4_linked_enemy.get_parent()
			skill_4_linked_enemy_path = enemy_path
			var self_progress: float = enemy_path.curve.get_closest_offset(position)
			var watched_point: Vector2
			if skill_4_linked_enemy.progress > self_progress:
				watched_point = enemy_path.curve.sample_baked(self_progress + 1)
				is_skill4_add = true
			else:
				watched_point = enemy_path.curve.sample_baked(self_progress - 1)
				is_skill4_add = false
			#ally_sprite.flip_h = skill_4_linked_enemy.position.x < position.x
			
			skill_4_timer.start()
			anim_offset()
			skill_3_audio.play()
			return
	super()
	pass


func skill_3_release():
	translate_to_new_state(AllyState.SPECIAL)
	ally_sprite.play("skill3")
	pass


func skill_4_release():
	skill_4_audio.play()
	var skill_area_scene: PackedScene = preload("res://Scenes/Skills/alex_skill_4_area.tscn")
	var interval_length: float = 30
	var progress: float = skill_4_linked_enemy_path.curve.get_closest_offset(position)
	var offset_direction: Vector2 = position - skill_4_linked_enemy_path.curve.get_closest_point(position)
	#print(offset_direction)
	for i in 12:
		if is_skill4_add:
			progress += interval_length
		else:
			progress -= interval_length
		if progress > skill_4_linked_enemy_path.curve.get_baked_length() or progress < 0:
			break
		
		var skill_area: SkillConditionArea2D = skill_area_scene.instantiate()
		skill_area.position = skill_4_linked_enemy_path.curve.sample_baked(progress)
		var weight: float = clampf(sqrt((float(i)+1) / 12),0,1)
		skill_area.position += Vector2(lerpf(offset_direction.x,0,weight),lerpf(offset_direction.y,0,weight))
		#print((float(i)+1) / 12)
		#print(Vector2(lerpf(offset_direction.x,0,(float(i)+1) / 12),lerpf(offset_direction.y,0,(float(i)+1) / 12)))
		Stage.instance.bullets.add_child(skill_area)
		await get_tree().create_timer(0.1,false).timeout
	pass
