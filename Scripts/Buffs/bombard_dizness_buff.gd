extends PropertyBuff
class_name DiznessBuff


func _buff_process(delta: float):
	if unit is Ally:
		unit.ally_sprite.play("idle")
		unit.anim_offset()
		unit.translate_to_new_state(Ally.AllyState.SPECIAL)
	if unit is Enemy:
		unit.enemy_sprite.play("idle")
		unit.anim_offset()
		unit.current_data.update_move_speed()
	pass


func remove_buff():
	super()
	if unit is Ally:
		if unit.current_intercepting_enemy == null:
			unit.move_back()
		else:
			unit.translate_to_new_state(Ally.AllyState.BATTLE)
	pass
