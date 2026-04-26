extends Node2D

@onready var path_area: Area2D = $PathArea


func _ready() -> void:
	await get_tree().physics_frame
	await get_tree().physics_frame
	if !path_area.has_overlapping_areas():
		hide()
	pass
