extends Node2D
class_name TowerBuff

enum TowerPropertyType{
	Damage,
	AttackRange,
	AttackSpeed
}


enum OperationType{
	Add,
	Multiply
}

@export var buff_blocks: Array[TowerPropertyBuffBlock]
@export var duration: float
@export var buff_level: int = 1
@export var can_be_overlay: bool
@export var immune_groups: Array[StringName]
@export var valid_tower_types: Array[bool] = [true,true,true,true]
@export var buff_tag: String

@onready var buff_timer: Timer = $BuffTimer

var tower: DefenceTower


func _ready() -> void:
	if duration > 0:
		buff_timer.wait_time = duration
		buff_timer.start()
	if !can_be_overlay:
		for buff: TowerBuff in get_parent().get_children():
			if buff.buff_tag == buff_tag and buff != self:
				buff.remove_buff()
	
	tower = get_parent().get_parent()
	if !valid_tower_types[tower.tower_type]:
		queue_free()
		return
	
	buff_start()
	pass


func remove_buff():
	set_process(false)
	remove_buff_blocks()
	queue_free()
	pass


func _on_buff_timer_timeout() -> void:
	remove_buff()
	pass # Replace with function body.


func buff_start():
	add_buff_blocks()
	pass


func add_buff_blocks():
	for buff_block in buff_blocks:
		if buff_block.tower_property_type == TowerPropertyType.Damage:
			tower.tower_damage_buffs.append(buff_block)
		elif buff_block.tower_property_type == TowerPropertyType.AttackRange:
			tower.tower_attack_speed_buffs.append(buff_block)
		elif buff_block.tower_property_type == TowerPropertyType.AttackSpeed:
			tower.tower_attack_speed_buffs.append(buff_block)
	tower.update_tower_data()
	pass


func remove_buff_blocks():
	for buff_block in buff_blocks:
		if buff_block.tower_property_type == TowerPropertyType.Damage:
			tower.tower_damage_buffs.erase(buff_block)
		elif buff_block.tower_property_type == TowerPropertyType.AttackRange:
			tower.tower_attack_speed_buffs.erase(buff_block)
		elif buff_block.tower_property_type == TowerPropertyType.AttackSpeed:
			tower.tower_attack_speed_buffs.erase(buff_block)
	tower.update_tower_data()
	pass
