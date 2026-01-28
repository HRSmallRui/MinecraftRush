extends Hero

signal get_skill_4_linked_enemy(enemy: Enemy)

@onready var fuchen_magic_heart: Sprite2D = $UnitBody/FuchenMagicHeart
@onready var normal_attack_audio: AudioStreamPlayer = $NormalAttackAudio
@onready var teleport_audio: AudioStreamPlayer = $TeleportAudio
@onready var teleport_audio_2: AudioStreamPlayer = $TeleportAudio2
@onready var sheild: Sprite2D = $UnitBody/Sheild
@onready var skill_2_timer: Timer = $Skill2Timer
@onready var skill_2_during_timer: Timer = $Skill2DuringTimer
@onready var skill_2_audio: AudioStreamPlayer = $Skill2Audio
@onready var skill_3_condition_area: Area2D = $UnitBody/Skill3ConditionArea
@onready var skill_3_timer: Timer = $Skill3Timer
@onready var skill_4_timer: Timer = $Skill4Timer
@onready var skill_4_duration_timer: Timer = $Skill4DurationTimer
@onready var skill_4_condition_area: Area2D = $UnitBody/Skill4ConditionArea

var passive_extra_damage: int
var is_invincible: bool = false


func _ready() -> void:
	super()
	sheild.modulate.a = 0
	if skill_levels[2] > 0:
		skill_2_during_timer.wait_time = HeroSkillLibrary.hero_skill_data_library[ally_id][2].sheild_duration[skill_levels[1]-1]
	pass


func anim_offset():
	match ally_sprite.animation:
		"attack","idle":
			ally_sprite.position = Vector2(-10,-115) if ally_sprite.flip_h else Vector2(10,-115)
		"die":
			ally_sprite.position = Vector2(-75,-105) if ally_sprite.flip_h else Vector2(75,-105)
		"far_attack":
			ally_sprite.position = Vector2(5,-110) if ally_sprite.flip_h else Vector2(-10,-110) 
		"move":
			ally_sprite.position = Vector2(-5,-110) if ally_sprite.flip_h else Vector2(5,-110)
		"rebirth","skill2":
			ally_sprite.position = Vector2(10,-120) if ally_sprite.flip_h else Vector2(-10,-120)
		"skill3":
			ally_sprite.position = Vector2(-10,-115) if ally_sprite.flip_h else Vector2(5,-115)
		"skill4_end":
			ally_sprite.position = Vector2(5,-120) if ally_sprite.flip_h else Vector2(-10,-120)
		"skill4_start","skill4_loop":
			ally_sprite.position = Vector2(-15,-120) if ally_sprite.flip_h else Vector2(15,-120)
		"teleport":
			ally_sprite.position = Vector2(-45,-120) if ally_sprite.flip_h else Vector2(40,-120)
	pass


func _process(delta: float) -> void:
	super(delta)
	var target_position_x: float = 80 if ally_sprite.flip_h else -80
	fuchen_magic_heart.position.x = lerpf(fuchen_magic_heart.position.x,target_position_x,delta)
	pass


func frame_changed():
	if ally_sprite.animation == "attack" and ally_sprite.frame == 11:
		cause_damage()
	if ally_sprite.animation == "teleport" and ally_sprite.frame == 13:
		teleport_finished()
	if ally_sprite.animation == "teleport" and ally_sprite.frame == 9:
		var teleport_effect: AnimatedSprite2D = preload("res://Scenes/Effects/bullet_explosion_effect.tscn").instantiate()
		teleport_effect.modulate = Color.PURPLE
		teleport_effect.scale *= 0.5
		teleport_effect.position = global_position
		Stage.instance.bullets.add_child(teleport_effect)
		match randi_range(1,2):
			1: teleport_audio.play()
			2: teleport_audio_2.play()
	if ally_sprite.animation == "skill4_start" and ally_sprite.frame == 19:
		ally_sprite.play("skill4_loop")
		skill_4_duration_timer.start()
	pass


func start_data_process():
	super()
	match hero_level:
		1,2,3: skill_levels[0] = 1
		4,5,6,7,8: skill_levels[0] = 2
		9,10: skill_levels[0] = 3
	passive_extra_damage = HeroSkillLibrary.hero_skill_data_library[ally_id][0].extra_damage[skill_levels[0]-1]
	
	if skill_levels[1] > 0:
		var plus_damage: int = HeroSkillLibrary.hero_skill_data_library[ally_id][1].upgrade_damage[skill_levels[1]-1]
		start_data.far_damage_low += plus_damage
		start_data.far_damage_high += plus_damage
	pass


func cause_damage(damage_type: int = 0):
	if current_intercepting_enemy == null: return
	match damage_type:
		0:
			var damage: int = randi_range(current_data.near_damage_low,current_data.near_damage_high)
			current_intercepting_enemy.take_damage(damage,DataProcess.DamageType.PhysicsDamage,0,false,self)
			if current_intercepting_enemy != null:
				current_intercepting_enemy.take_damage(passive_extra_damage,DataProcess.DamageType.MagicDamage,0,false,self)
			get_exp(int(float(damage) * exp_rate))
			get_exp(int(float(passive_extra_damage) * exp_rate))
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
				TextEffect.text_effect_show(text,TextEffect.TextEffectType.Magic,show_pos)
			normal_attack_audio.play()
	pass


func idle_process():
	if waiting_to_move:
		waiting_to_move = false
		move(next_move_position)
		return
	if ally_state != AllyState.IDLE: return
	if ally_sprite.animation == "idle":
		if health_bar.value < 0.5 and skill_levels[2] > 0 and skill_2_timer.is_stopped():
			skill2_release()
			return
		if skill_levels[3] > 0 and skill_3_timer.is_stopped():
			if skill_3_condition_area.get_overlapping_bodies().size() >= 4:
				skill_3_release()
				return
		if skill_levels[4] > 0 and skill_4_timer.is_stopped():
			if skill_4_condition_area.get_overlapping_bodies().size() >= 2:
				skill_4_release()
				return
	super()
	pass


func skill2_release():
	get_exp(skill2_exp_get[skill_levels[2]-1])
	skill_2_audio.play()
	skill_2_timer.start()
	translate_to_new_state(AllyState.SPECIAL)
	ally_sprite.play("skill2")
	create_tween().tween_property(sheild,"modulate:a",1,0.5)
	skill_2_during_timer.start()
	is_invincible = true
	await skill_2_during_timer.timeout
	is_invincible = false
	create_tween().tween_property(sheild,"modulate:a",0,0.5)
	pass


func battle():
	super()
	if ally_sprite.animation == "idle":
		if health_bar.value < 0.5 and skill_levels[2] > 0 and skill_2_timer.is_stopped():
			skill2_release()
			return
	pass


func take_damage(damage: int, damage_type: DataProcess.DamageType, broken_rate: float, far_attack: bool = false, source: Node2D = null,explosion: bool = false,aoe_attack: bool = false, deadly: bool = true) -> bool:
	if is_invincible:
		return false
	return super(damage,damage_type,broken_rate,far_attack,source,explosion,aoe_attack, deadly)
	pass


func skill_3_release():
	skill_3_timer.start()
	ally_sprite.play("skill3")
	translate_to_new_state(AllyState.SPECIAL)
	pass


func skill_4_release():
	skill_4_timer.start()
	ally_sprite.play("skill4_start")
	translate_to_new_state(AllyState.SPECIAL)
	get_skill_4_linked_enemy.emit(far_attack_area.get_overlapping_bodies()[0].owner)
	pass


func die(explosion: bool):
	super(explosion)
	if !skill_4_duration_timer.is_stopped():
		skill_4_duration_timer.stop()
		skill_4_duration_timer.timeout.emit()
	pass


func move(target_pos:Vector2):
	if ally_sprite.animation == "skill4_loop" and ally_state != AllyState.DIE:
		translate_to_new_state(AllyState.IDLE)
		skill_4_duration_timer.stop()
		skill_4_duration_timer.timeout.emit()
	super(target_pos)
	pass
