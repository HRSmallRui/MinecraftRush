extends Enemy

@onready var summon_area_1: Area2D = $SummonArea1
@onready var summon_area_2: Area2D = $SummonArea2
@onready var summon_area_3: Area2D = $SummonArea3
@onready var summon_area_4: Area2D = $SummonArea4
@onready var summon_timer: Timer = $SummonTimer
@onready var skill_audio: AudioStreamPlayer = $SkillAudio
@onready var buy_timer: Timer = $BuyTimer

@export var skill_audio_list: Array[AudioStream]


func anim_offset():
	match enemy_sprite.animation:
		"attack","idle":
			enemy_sprite.position = Vector2(5,-90) if enemy_sprite.flip_h else Vector2(-5,-90)
		"buy":
			enemy_sprite.position = Vector2(-40,-90) if enemy_sprite.flip_h else Vector2(40,-90)
		"call":
			enemy_sprite.position = Vector2(-40,-130) if enemy_sprite.flip_h else Vector2(40,-130)
		"die":
			enemy_sprite.position = Vector2(-45,-90) if enemy_sprite.flip_h else Vector2(45,-90)
		"move_back","move_front","move_normal":
			enemy_sprite.position = Vector2(0,-85)
	pass


func frame_changed():
	if enemy_sprite.animation == "attack" and enemy_sprite.frame == 14:
		cause_damage()
	if enemy_sprite.animation == "buy" and enemy_sprite.frame == 31:
		buy_soldier()
		skill_audio.stream = skill_audio_list[randi_range(0,skill_audio_list.size()-1)]
		skill_audio.play()
	if enemy_sprite.animation == "call" and enemy_sprite.frame == 5:
		summon_skill_release()
		skill_audio.stream = skill_audio_list[randi_range(0,skill_audio_list.size()-1)]
		skill_audio.play()
	pass


func buy_soldier():
	var battle_group: Array[Ally] = current_intercepting_units.duplicate()
	var has_bought_lv3_soldier: bool
	for ally in battle_group:
		if ally.ally_group == Ally.AllyType.Soldiers:
			if ally.ally_level < 3:
				ally.disappear_kill()
				summon_soldier(ally.position)
				Stage.instance.current_money += 1
			elif ally.ally_level == 3 and !has_bought_lv3_soldier:
				ally.disappear_kill()
				summon_soldier(ally.position)
				Stage.instance.current_money += 2
				has_bought_lv3_soldier = true
	pass


func summon_soldier(target_pos: Vector2):
	var enemy_path: EnemyPath = Stage.instance.get_closest_enemy_path(target_pos)
	if enemy_path == null: return
	
	var soldier_progress: float = enemy_path.curve.get_closest_offset(target_pos)
	var soldier:Enemy = preload("res://Scenes/Enemies/enemy_27.tscn").instantiate()
	soldier.progress = soldier_progress
	soldier.bounty = 0
	enemy_path.add_child(soldier)
	soldier.enemy_sprite.flip_h = enemy_sprite.flip_h
	soldier.translate_to_new_state(EnemyState.SPECIAL)
	soldier.enemy_sprite.play("appear")
	pass


func summon_skill_release():
	if summon_area_1.has_overlapping_areas():
		summon_soldier(summon_area_1.global_position)
	if summon_area_2.has_overlapping_areas() and randf_range(0,1) < 0.5:
		summon_soldier(summon_area_2.global_position)
	if summon_area_3.has_overlapping_areas() and randf_range(0,1) < 0.25:
		summon_soldier(summon_area_3.global_position)
	if summon_area_4.has_overlapping_areas() and randf_range(0,1) < 0.1:
		summon_soldier(summon_area_4.global_position)
	pass


func move_process(delta:float):
	super(delta)
	if summon_timer.is_stopped():
		translate_to_new_state(EnemyState.SPECIAL)
		enemy_sprite.play("call")
		summon_timer.start()
	pass


func special_process():
	if enemy_sprite.animation == "idle":
		if current_intercepting_units.is_empty():
			translate_to_new_state(EnemyState.MOVE)
		else:
			translate_to_new_state(EnemyState.BATTLE)
	pass


func battle():
	if enemy_sprite.animation == "idle" and summon_timer.is_stopped() and normal_attack_timer.is_stopped() and silence_layers <= 0:
		enemy_sprite.play("call")
		normal_attack_timer.start()
		summon_timer.start()
		return
	if enemy_sprite.animation == "idle" and normal_attack_timer.is_stopped() and buy_timer.is_stopped() and can_buy() and silence_layers <= 0:
		if !current_intercepting_units.is_empty():
			if current_intercepting_units[0].ally_type == Ally.AllyType.Soldiers:
				enemy_sprite.play("buy")
				normal_attack_timer.start()
				buy_timer.start()
				return
	super()
	pass


func can_buy() -> bool:
	if current_intercepting_units.is_empty():
		return false
	else:
		for ally in current_intercepting_units:
			if ally.ally_type == Ally.AllyType.Soldiers and ally.ally_level < 4:
				return true
	
	return false
	pass
