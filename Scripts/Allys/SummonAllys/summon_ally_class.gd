extends Ally
class_name SummonAlly

@export var unit_list: Array[UnitData]
@export var heal_speed_list: Array[int]

var level: int = 1


func _enter_tree() -> void:
	start_data = unit_list[level-1].duplicate()
	super()
	pass


func _ready() -> void:
	super()
	heal_speed = heal_speed_list[level-1]
	pass


func level_up():
	level += 1
	start_data = unit_list[level-1].duplicate(true)
	current_data.ready_data(start_data)
	current_data.update_data()
	heal_speed = heal_speed_list[level-1]
	if ally_state == AllyState.DIE:
		rebirth()
		rebirth_timer.stop()
	pass


func sell_ally():
	if current_intercepting_enemy != null:
		current_intercepting_enemy.current_intercepting_units.erase(self)
	queue_free()
	pass
