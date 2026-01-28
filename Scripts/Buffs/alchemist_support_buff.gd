extends PropertyBuff


func buff_start():
	super()
	var ally: Ally = unit
	ally.ally_buff_tags["alchemist_support"] = buff_level
	pass


func remove_buff():
	super()
	var ally: Ally = unit
	ally.ally_buff_tags.erase("alchemist_support")
	pass
