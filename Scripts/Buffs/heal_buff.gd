extends BuffClass
class_name HealBuff

@export var heal_datas: Array[int]


func _on_timer_timeout() -> void:
	var heal_data = heal_datas[buff_level-1]
	data_owner.heal(heal_data)
	pass # Replace with function body.
