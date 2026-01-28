extends PropertyBuff
class_name DiznessBuff


func _buff_process(delta: float):
	if unit is Ally:
		unit.ally_sprite.play("idle")
		unit.anim_offset()
	if unit is Enemy:
		unit.enemy_sprite.play("idle")
		unit.anim_offset()
		unit.current_data.update_move_speed()
	pass
