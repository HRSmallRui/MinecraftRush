extends SkillButton

@export var skill_name_list: Array[String]
@export_multiline var skill_intro_list: Array[String]
@export var skill_duration: float
@export_group("Stage1","stage1")
@export var stage1_enemy_buff_list: Array[PackedScene]
@export_group("Stage2","stage2")
@export var stage2_dizness_buff_scene: PackedScene
@export var stage2_dizness_duration: float
@export var stage2_damage_list: Array[int]
@export_group("Stage3","stage3")
@export var stage3_tower_buff_list: Array[PackedScene]
@export var stage3_ally_buff_list: Array[PackedScene]
@export var stage3_heal_buff_scene: PackedScene
@export_group("Stage4","stage4")
@export var stage4_teleport_length: float
@export var stage4_enemy_buff_scene: PackedScene
@export var stage4_invincible_buff_scene: PackedScene
@export_group("")
@export var teleport_effect_scene: PackedScene

@onready var unlease_audio: AudioStreamPlayer = $UnleaseAudio
@onready var teleport_audio: AudioStreamPlayer = $TeleportAudio
@onready var enemy_condition_area: Area2D = $EnemyConditionArea
@onready var collision_shape_2d: CollisionShape2D = $EnemyConditionArea/CollisionShape2D

var linked_hero: GoldenDiamond
var chip_level: int:
	set(v):
		chip_level = v
		skill_name = skill_name_list[chip_level-1]
		skill_intro = skill_intro_list[chip_level-1]
var skill_level: int
var is_allowed_to_unlease: bool


func _ready() -> void:
	super()
	skill_level = Stage.instance.stage_sav.hero_sav[6].skill_levels[4]
	on_chip_changed(0)
	remove_child(enemy_condition_area)
	Stage.instance.bullets.add_child(enemy_condition_area)
	var target_collision: CollisionShape2D = Stage.instance.click_area.get_child(0)
	collision_shape_2d.position = target_collision.position
	collision_shape_2d.shape = target_collision.shape
	await get_tree().create_timer(0.2,false).timeout
	linked_hero = Stage.instance.hero_list[0]
	linked_hero.chip_changed.connect(on_chip_changed)
	linked_hero.ally_dead.connect(on_hero_dead)
	linked_hero.ally_rebirth.connect(on_hero_rebirth)
	pass

func on_chip_changed(chip: int):
	is_allowed_to_unlease = chip > 0
	if chip <= 5:
		chip_level = 1
	elif chip <= 10:
		chip_level = 2
	elif chip <= 18:
		chip_level = 3
	else:
		chip_level = 4
	pass


func on_hero_dead():
	if Stage.instance.information_bar.current_check_member == self:
		Stage.instance.ui_process(null)
	animation_player.play_backwards("unlock")
	translate_to_state(ButtonState.Disabled)
	pass


func on_hero_rebirth():
	animation_player.play("unlock")
	button_state = ButtonState.Cooling
	pass


func skill_unlease():
	super()
	unlease_audio.play()
	var enemy_list: Array[Enemy]
	for area in enemy_condition_area.get_overlapping_areas():
		var enemy: Enemy = area.owner
		enemy_list.append(enemy)
	if chip_level >= 4: stage4_effect(enemy_list)
	if chip_level >= 3: stage3_effect(enemy_list)
	if chip_level >= 2: stage2_effect(enemy_list)
	stage1_effect(enemy_list)
	linked_hero.chip = 0
	pass


func skill_unlease_condition():
	if is_allowed_to_unlease and linked_hero.chip > 0:
		skill_unlease()
	pass


func stage1_effect(enemy_list: Array[Enemy]):
	var debuff_scene: PackedScene = stage1_enemy_buff_list[skill_level]
	for enemy in enemy_list:
		var debuff: PropertyBuff = debuff_scene.instantiate()
		debuff.duration = skill_duration
		enemy.buffs.add_child(debuff)
	pass


func stage2_effect(enemy_list: Array[Enemy]):
	for enemy in enemy_list:
		var dizness_buff: DiznessBuff = stage2_dizness_buff_scene.instantiate()
		dizness_buff.duration = stage2_dizness_duration
		enemy.buffs.add_child(dizness_buff)
		enemy.take_damage(stage2_damage_list[skill_level],DataProcess.DamageType.TrueDamage,0,false)
	pass


func stage3_effect(enemy_list: Array[Enemy]):
	for tower:DefenceTower in Stage.instance.towers.get_children():
		if tower.tower_level > 0 and tower.tower_type != DefenceTower.TowerType.Barrack and tower.tower_type != DefenceTower.TowerType.Based:
			var tower_buff: TowerBuff = stage3_tower_buff_list[skill_level].instantiate()
			tower_buff.duration = skill_duration
			tower.tower_buffs.add_child(tower_buff)
	
	for ally in Stage.instance.allys.get_children():
		if ally is Ally:
			if ally.ally_state != Ally.AllyState.DIE:
				var ally_buff: PropertyBuff = stage3_ally_buff_list[skill_level].instantiate()
				ally_buff.duration = skill_duration
				ally.buffs.add_child(ally_buff)
				var heal_buff: HealBuff = stage3_heal_buff_scene.instantiate()
				heal_buff.buff_level = skill_level + 1
				heal_buff.duration = skill_duration
				ally.buffs.add_child(heal_buff)
	pass


func stage4_effect(enemy_list: Array[Enemy]):
	if !enemy_list.is_empty():
		teleport_audio.play()
	for enemy in enemy_list:
		if enemy.enemy_type >= Enemy.EnemyType.MiniBoss or enemy.enemy_state == Enemy.EnemyState.DIE: continue
		enemy.progress -= stage4_teleport_length
		var teleport_effect: AnimatedSprite2D = teleport_effect_scene.instantiate()
		teleport_effect.modulate = Color.PURPLE
		teleport_effect.position = enemy.hurt_box.global_position
		Stage.instance.bullets.add_child(teleport_effect)
	for enemy in enemy_list:
		var enemy_buff: PropertyBuff = stage4_enemy_buff_scene.instantiate()
		enemy_buff.duration = skill_duration
		enemy.buffs.add_child(enemy_buff)
	var invincible_buff: PropertyBuff = stage4_invincible_buff_scene.instantiate()
	invincible_buff.duration = skill_duration
	linked_hero.buffs.add_child(invincible_buff)
	pass
