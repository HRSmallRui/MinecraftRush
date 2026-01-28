extends BarrackTower
class_name EpeeChurch

@export var skill1_damage_list: Array[DamageBlock]


func tower_skill_level_up(skill_id: int, skill_level: int):
	super(skill_id,skill_level)
	if skill_id == 0:
		for epee_soldier in soldier_list:
			barrack_data.damage_low = skill1_damage_list[skill_level-1].damage_low
			barrack_data.damage_high = skill1_damage_list[skill_level-1].damage_high
			epee_soldier.start_data.near_damage_low = skill1_damage_list[skill_level-1].damage_low
			epee_soldier.start_data.near_damage_high = skill1_damage_list[skill_level-1].damage_high
			epee_soldier.current_data.update_near_damage()
	pass
