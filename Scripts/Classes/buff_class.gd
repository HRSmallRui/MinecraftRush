extends Node2D
class_name BuffClass

signal buff_time_out

enum BuffType{
	Buff, ##正面buff
	Debuff ##负面buff
}

@export var buff_type: BuffType ##buff类型
@export var duration: float ##持续时间
@export var buff_level: int = 1 ##buff等级
@export var can_be_overlay: bool ##可叠加buff
@export var buff_tag: String ##buff标签
@export var data_owner: UnitData
@export var immune_groups: Array[String] ##免疫该buff的单位分组

var buff_timer: float
var unit: Node2D


func _ready() -> void:
	data_owner = get_parent().get_parent().get_parent().current_data
	unit = data_owner.owner
	if buff_condition():
		queue_free()
		return
	
	if !can_be_overlay:
		for buff: BuffClass in get_parent().get_children():
			if buff.buff_tag == buff_tag and buff != self:
				buff.remove_buff()
	
	data_owner = get_parent().get_parent().get_parent().current_data
	unit = data_owner.owner
	buff_start()
	pass


func buff_start():
	
	pass


func remove_buff():
	set_process(false)
	queue_free()
	pass


func _process(delta: float) -> void:
	if duration > 0:
		buff_timer += delta
		if buff_timer >= duration:
			buff_time_out.emit()
			remove_buff()
			return
	_buff_process(delta)
	pass


func _buff_process(delta: float):
	
	pass


func buff_condition() -> bool:
	var unit_groups = unit.get_groups() as Array[String]
	for group in unit_groups:
		if group in immune_groups: return true
	if unit is Ally:
		if unit.ally_state == Ally.AllyState.DIE: return true
	elif unit is Enemy:
		if unit.enemy_state == Enemy.EnemyState.DIE: return true
	
	return false
	pass
