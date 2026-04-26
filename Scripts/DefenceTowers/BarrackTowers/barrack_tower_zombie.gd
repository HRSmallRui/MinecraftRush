extends BarrackTower


func tower_skill_level_up(skill_id: int, skill_level: int):
	super(skill_id,skill_level)
	if skill_id == 1:
		var damage_low: int
		var damage_high: int
		match skill_level:
			1:
				damage_low = 9
				damage_high = 18
			2:
				damage_low = 10
				damage_high = 20
		barrack_data.damage_low = damage_low
		barrack_data.damage_high = damage_high
		barrack_data.armor += 0.05
		for soldier in soldier_list:
			soldier.start_data.armor += 0.05
			soldier.current_data.update_armor()
			soldier.start_data.near_damage_low = damage_low
			soldier.start_data.near_damage_high = damage_high
			soldier.current_data.update_near_damage()
	pass
