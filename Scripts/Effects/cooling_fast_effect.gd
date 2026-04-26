extends Node2D
class_name CoolingFastEffect

@export var cooling_data: float

@onready var cooling_label: Label = $CoolingLabel


func _ready() -> void:
	cooling_label.text = "-" + str(cooling_data) + "s"
	create_tween().tween_property(self,"position",position - Vector2(0,60),0.8)
	create_tween().tween_property(self,"modulate:a",0,0.9)
	await get_tree().create_timer(0.9,false).timeout
	queue_free()
	pass
