extends PropertyBuff


func buff_start():
	super()
	var enemy: Enemy = unit
	enemy.enemy_buff_tags["witch_hurt"] = 1;
	pass


func remove_buff():
	super()
	var enemy: Enemy = unit
	enemy.enemy_buff_tags.erase("witch_hurt")
	pass
