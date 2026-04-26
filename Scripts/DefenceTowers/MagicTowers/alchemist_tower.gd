extends MagicTower
class_name AlchemistTower


@onready var skill_1_timer: Timer = $Skill1Timer
@onready var skill_2_condition_area: Area2D = $Skill2ConditionArea
@onready var skill_2_dot_timer: Timer = $Skill2DotTimer



func _ready() -> void:
	super()
	await get_tree().process_frame
	skill_2_condition_area.scale = tower_area.scale
	pass


func fighting_process():
	if tower_skill_levels[0] > 0 and skill_1_timer.is_stopped() and tower_area.has_overlapping_bodies() and normal_attack_timer.is_stopped():
		var skill1_enemy: Enemy = get_valid_skill1_enemy()
		#print(skill1_enemy)
		if skill1_enemy != null:
			skill_1_timer.start()
			normal_attack_timer.start()
			magician.play("skill1_front") if skill1_enemy.position.y > position.y else magician.play("skill1_back")
			return
	super()
	pass


func get_valid_skill1_enemy() -> Enemy:
	var enemy_list: Array[Enemy]
	for body in tower_area.get_overlapping_bodies():
		var enemy: Enemy = body.owner
		if "special" in enemy.get_groups(): continue
		if "boss" in enemy.get_groups(): continue
		if enemy.unit_body.get_collision_layer_value(7): continue
		enemy_list.append(enemy)
	if enemy_list.is_empty(): return null
	var back_enemy: Enemy = enemy_list[0]
	for enemy in enemy_list:
		if enemy.bounty > back_enemy.bounty: back_enemy = enemy
	return back_enemy
	pass


func get_valid_skill2_allys() -> Array[Ally]:
	var ally_list: Array[Ally]
	for body in skill_2_condition_area.get_overlapping_bodies():
		var ally: Ally = body.owner
		ally_list.append(ally)
	if ally_list.size() <= 5: return ally_list
	for ally in ally_list:
		if ally.ally_buff_tags.has("alchemist_support"): ally_list.erase(ally)
		if ally_list.size() <= 5: break
	if ally_list.size() <= 5: return ally_list
	ally_list.resize(5)
	return ally_list
	pass


func tower_skill_level_up(skill_id: int, skill_level: int):
	super(skill_id,skill_level)
	if skill_id == 1 and skill_level == 1:
		skill_2_dot_timer.start()
	pass


func _on_skill_2_dot_timer_timeout() -> void:
	for body in skill_2_condition_area.get_overlapping_bodies():
		var ally: Ally = body.owner
		var heal_buff: HealBuff = preload("res://Scenes/Buffs/TowerBuffs/Alchemist/alchemist_heal_buff.tscn").instantiate()
		heal_buff.buff_level = tower_skill_levels[1]
		var support_buff: PropertyBuff
		match tower_skill_levels[1]:
			1: support_buff = preload("res://Scenes/Buffs/TowerBuffs/Alchemist/alchemist_support_buff_lv1.tscn").instantiate()
			2: support_buff = preload("res://Scenes/Buffs/TowerBuffs/Alchemist/alchemist_support_buff_lv2.tscn").instantiate()
			3: support_buff = preload("res://Scenes/Buffs/TowerBuffs/Alchemist/alchemist_support_buff_lv3.tscn").instantiate()
		ally.buffs.add_child(support_buff)
		ally.buffs.add_child(heal_buff)
	pass # Replace with function body.
