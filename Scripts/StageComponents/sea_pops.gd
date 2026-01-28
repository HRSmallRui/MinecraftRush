extends Node2D


func _ready() -> void:
	for lake_pop: AnimatedSprite2D in get_children():
		lake_pop.speed_scale = randf_range(0.8,1.2)
	pass
