extends DiznessBuff


func buff_start():
	super()
	if unit is Enemy:
		unit.enemy_buff_tags["is_caging"] = true
		if unit.enemy_buff_tags.has("cage_count"): unit.enemy_buff_tags["cage_count"] += 1
		else: unit.enemy_buff_tags["cage_count"] = 1
	pass


func remove_buff():
	super()
	if unit is Enemy:
		unit.enemy_buff_tags["is_caging"] = false
	pass
