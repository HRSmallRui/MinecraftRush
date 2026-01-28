extends CharacterBody2D
class_name UnitBody

@export var unit: Node2D

var unit_data: UnitData


func _enter_tree() -> void:
	position = Vector2.ZERO
	pass


func _ready() -> void:
	if unit is Enemy: unit_data = unit.current_data
	elif unit is Ally: unit_data = unit.current_data
	pass


func _process(delta: float) -> void:
	global_rotation = 0
	pass
