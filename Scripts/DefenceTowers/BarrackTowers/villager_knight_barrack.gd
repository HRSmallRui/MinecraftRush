extends BarrackTower

@export var skill_damage_list: Array[DamageBlock]


func tower_skill_level_up(skill_id: int, skill_level: int):
	super(skill_id,skill_level)
	if skill_id == 0:
		barrack_data.armor += 0.1
		for soldier in soldier_list:
			soldier.start_data.armor = barrack_data.armor
			soldier.current_data.update_armor()
	if skill_id == 1:
		var damage_block: DamageBlock = skill_damage_list[tower_skill_levels[1]-1]
		barrack_data.damage_low = damage_block.damage_low
		barrack_data.damage_high = damage_block.damage_high
		for soldier in soldier_list:
			soldier.start_data.near_damage_low = barrack_data.damage_low
			soldier.start_data.near_damage_high = barrack_data.damage_high
			soldier.current_data.update_near_damage()
	pass
