extends Hero
class_name GoldenDiamond

signal chip_changed(chip_count: int)

@export_group("Skill1")
@export var golem_summon_count_list: Array[int]
@export var spade_golem_scene: PackedScene ##黑桃傀儡
@export var heart_golem_scene:PackedScene ##红心傀儡
@export var club_golem_scene: PackedScene ##梅花傀儡
@export var diamond_golem_scene: PackedScene ##方块傀儡
@export var golem_exist_time: float
@export_group("Skill2","skill2")
@export var skill2_during_time_list: Array[float]
@export var skill2_back_chip_rate: float
@export var skill2_tower_buff_scene: PackedScene
@export var skill2_extra_tower_buff_scene: PackedScene
@export_group("Skill3","skill3")
@export var skill3_bounty_rising_rate: float
@export var skill3_debuff_duration: float
@export var skill3_front_buff_list: Array[PackedScene]
@export var skill3_back_buff_list: Array[PackedScene]
@export_group("Skill4","skill4")
@export var skill4_buff_duration: float
@export var skill4_magician_buff_list: Array[PackedScene]
@export var skill4_queen_buff_list: Array[PackedScene]
@export var skill4_fate_buff_list: Array[PackedScene]
@export var skill4_love_buff_scene: PackedScene

@onready var passive_timer: Timer = $PassiveTimer
@onready var skill_1_timer: Timer = $Skill1Timer
@onready var skill_2_timer: Timer = $Skill2Timer
@onready var skill_3_timer: Timer = $Skill3Timer
@onready var skill_4_timer: Timer = $Skill4Timer
@onready var chip_label: Label = $HeroUI/HeroUnitButton/Panel/ChipLabel
@onready var skill_1_audio: AudioStreamPlayer = $Skill1Audio
@onready var skill_2_audio: AudioStreamPlayer = $Skill2Audio
@onready var skill_3_audio_1: AudioStreamPlayer = $Skill3Audio1
@onready var skill_3_audio_2: AudioStreamPlayer = $Skill3Audio2
@onready var skill_4_audio_1: AudioStreamPlayer = $Skill4Audio1
@onready var skill_4_audio_2: AudioStreamPlayer = $Skill4Audio2
@onready var skill_1_area: Area2D = $UnitBody/Skill1Area
@onready var skill_2_area: Area2D = $UnitBody/Skill2Area
@onready var skill_2_wait_timer: Timer = $Skill2WaitTimer
@onready var skill_3_area: Area2D = $UnitBody/Skill3Area
@onready var skill_4_area: Area2D = $UnitBody/Skill4Area

var chip: int:
	set(v):
		chip = clampi(v,0,21)
		chip_label.text = str(chip)
		chip_changed.emit(chip)
var skill2_linked_tower: DefenceTower
var skill2_cost_chip: int
var skill4_buff_list: Array[PackedScene]


func _ready() -> void:
	super()
	chip = 0
	delay_passive_timer_start()
	skill4_buff_list.append(skill4_magician_buff_list[skill_levels[4]-1])
	skill4_buff_list.append(skill4_queen_buff_list[skill_levels[4]-1])
	skill4_buff_list.append(skill4_fate_buff_list[skill_levels[4]-1])
	skill4_buff_list.append(skill4_love_buff_scene)
	pass


func _on_passive_timer_timeout() -> void:
	if ally_state != AllyState.DIE:
		chip += 1
	pass # Replace with function body.


func anim_offset():
	match ally_sprite.animation:
		"idle","attack":
			ally_sprite.position = Vector2(-10,-80) if ally_sprite.flip_h else Vector2(5,-80)
		"die":
			ally_sprite.position = Vector2(-65,-85) if ally_sprite.flip_h else Vector2(-70,-85)
		"far_attack":
			ally_sprite.position = Vector2(45,-90) if ally_sprite.flip_h else Vector2(-50,-90)
		"move":
			ally_sprite.position = Vector2(10,-80) if ally_sprite.flip_h else Vector2(-15,-80)
		"rebirth":
			ally_sprite.position = Vector2(0,-85)
		"skill1":
			ally_sprite.position = Vector2(-10,-80) if ally_sprite.flip_h else Vector2(10,-80)
		"skill2":
			ally_sprite.position = Vector2(-5,-130) if ally_sprite.flip_h else Vector2(5,-130)
		"skill3":
			ally_sprite.position = Vector2(5,-120) if ally_sprite.flip_h else Vector2(-10,-120)
		"skill4":
			ally_sprite.position = Vector2(10,-90) if ally_sprite.flip_h else Vector2(-5,-90)
	pass


func frame_changed():
	if ally_sprite.animation == "attack" and ally_sprite.frame == 11:
		cause_damage()
	if ally_sprite.animation == "far_attack" and ally_sprite.frame == 13:
		far_attack_frame(DataProcess.DamageType.MagicDamage)
		AudioManager.instance.magic_shot_audio.play()
	if ally_sprite.animation == "skill1" and ally_sprite.frame == 9:
		skill_1_audio.play()
		summon_golems()
	if ally_sprite.animation == "skill2" and ally_sprite.frame == 13:
		if skill2_linked_tower == null:
			skill_2_timer.stop()
			chip += 1
			return
		skill_2_audio.play()
		var during_time: float = skill2_during_time_list[skill_levels[2]-1]
		var tower_buff: TowerBuff = skill2_tower_buff_scene.instantiate()
		tower_buff.duration = during_time
		skill2_linked_tower.tower_buffs.add_child(tower_buff)
		skill_2_wait_timer.wait_time = during_time
		skill_2_wait_timer.start()
		skill2_cost_chip = 1
		if chip >= 10:
			var loop_count: int = mini(randi_range(0,5),chip)
			for i in loop_count:
				var extra_buff: TowerBuff = skill2_extra_tower_buff_scene.instantiate()
				extra_buff.duration = during_time
				skill2_linked_tower.tower_buffs.add_child(extra_buff)
				skill2_cost_chip += 1
		
	if ally_sprite.animation == "skill3":
		if ally_sprite.frame == 12:
			skill_3_audio_1.play()
		if ally_sprite.frame == 35:
			skill_3_audio_2.play()
			var target_enemy_list: Array[Enemy]
			for body in skill_3_area.get_overlapping_bodies():
				var enemy: Enemy = body.owner
				if !enemy.get_groups().has("boss"): target_enemy_list.append(enemy)
			var type: int = randi_range(0,1)
			if chip >= 10 and randf() < 0.5:
				chip -= 1
				type = 2
			skill3_add_buff(type,target_enemy_list)
			chip += mini(target_enemy_list.size() / 5, 3)
	
	if ally_sprite.animation == "skill4":
		if ally_sprite.frame == 20:
			skill_4_audio_1.play()
		if ally_sprite.frame == 37:
			skill_4_audio_2.play()
			var ally_list: Array[Ally]
			for body in skill_4_area.get_overlapping_bodies():
				var ally: Ally = body.owner
				ally_list.append(ally)
			skill4_add_buff(ally_list)
			chip += mini(ally_list.size() / 4, 3)
	pass


func delay_passive_timer_start():
	await Stage.instance.wave_summon
	passive_timer.start()
	pass


func die(explosion: bool):
	super(explosion)
	chip = 0
	pass


func rebirth():
	super()
	chip = randi_range(1,4)
	pass


func idle_process():
	if skill_1_timer.is_stopped() and skill_1_area.has_overlapping_bodies() and skill_levels[1] > 0 and chip >= 2:
		skill_1_timer.start()
		chip -= 1
		translate_to_new_state(AllyState.SPECIAL)
		ally_sprite.play("skill1")
		return
	if skill_4_timer.is_stopped() and skill_4_area.get_overlapping_bodies().size() >= 4 and skill_levels[4] > 0 and chip >= 1 and far_attack_area.has_overlapping_bodies():
		skill_4_timer.start()
		chip -= 1
		translate_to_new_state(AllyState.SPECIAL)
		ally_sprite.play("skill4")
		return
	super()
	if ally_state != AllyState.IDLE: return
	if skill_2_timer.is_stopped() and skill_2_area.has_overlapping_areas() and skill_levels[2] > 0 and chip >= 1:
		var tower_list: Array[DefenceTower]
		for area in skill_2_area.get_overlapping_areas():
			var tower: DefenceTower = area.owner
			if tower.tower_type != DefenceTower.TowerType.Barrack: tower_list.append(tower)
		if !tower_list.is_empty():
			skill2_linked_tower = tower_list.pick_random() as DefenceTower
			translate_to_new_state(AllyState.SPECIAL)
			ally_sprite.play("skill2")
			skill_2_timer.start()
			chip -= 1
			return
	if skill_3_timer.is_stopped() and far_attack_area.get_overlapping_bodies().size() >= 3 and skill_levels[3] > 0 and chip >= 1:
		skill_3_timer.start()
		chip -= 1
		translate_to_new_state(AllyState.SPECIAL)
		ally_sprite.play("skill3")
		return
	pass


func battle():
	if ally_sprite.animation == "idle":
		if skill_1_timer.is_stopped() and skill_levels[1] > 0 and chip >= 2:
			translate_to_new_state(AllyState.SPECIAL)
			chip -= 1
			skill_1_timer.start()
			ally_sprite.play("skill1")
			normal_attack_timer.start()
			return
		if skill_3_timer.is_stopped() and skill_levels[3] > 0 and chip >= 1:
			translate_to_new_state(AllyState.SPECIAL)
			chip -= 1
			skill_3_timer.start()
			ally_sprite.play("skill3")
			return
		if skill_4_timer.is_stopped() and skill_levels[4] > 0 and chip >= 1 and skill_4_area.get_overlapping_bodies().size() >= 4:
			translate_to_new_state(AllyState.SPECIAL)
			chip -= 1
			skill_4_timer.start()
			ally_sprite.play("skill4")
			return
	super()
	pass


func _on_skill_2_wait_timer_timeout() -> void:
	if ally_state == AllyState.DIE or skill2_linked_tower == null: return
	var back_chip: int = snappedf(float(skill2_cost_chip) * skill2_back_chip_rate, 1)
	chip += back_chip
	pass # Replace with function body.


func skill3_add_buff(type: int, target_enemy_list: Array[Enemy]):
	var buff_scene_list: Array[PackedScene]
	if type == 0 or type == 2:
		buff_scene_list.append(skill3_front_buff_list[skill_levels[3]-1])
	if type == 1 or type == 2:
		buff_scene_list.append(skill3_back_buff_list[skill_levels[3]-1])
	for enemy in  target_enemy_list:
		enemy.bounty += float(enemy.bounty) * skill3_bounty_rising_rate
		for buff_scene in buff_scene_list:
			var buff: PropertyBuff = buff_scene.instantiate()
			buff.duration = skill3_debuff_duration
			enemy.buffs.add_child(buff)
	pass


func skill4_add_buff(ally_list: Array[Ally]):
	for ally in ally_list:
		var random_buff_scene: PackedScene = skill4_buff_list.pick_random() as PackedScene
		var buff: BuffClass = random_buff_scene.instantiate()
		buff.duration = skill4_buff_duration
		ally.buffs.add_child(buff)
	pass


func summon_golems():
	var summon_count: int = golem_summon_count_list[skill_levels[1]-1]
	var golem_scene: PackedScene
	match randi_range(1,4):
		1: golem_scene = spade_golem_scene
		2: golem_scene = heart_golem_scene
		3: golem_scene = club_golem_scene
		4: golem_scene = diamond_golem_scene
	for i in summon_count:
		var golem: SummonAlly = golem_scene.instantiate()
		golem.position = position + Vector2(randf_range(-1,1) * 10, randf_range(-1,1) * 10)
		Stage.instance.allys.add_child(golem)
	pass
