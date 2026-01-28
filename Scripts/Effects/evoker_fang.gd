extends Node2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D


func _ready() -> void:
	await animated_sprite_2d.animation_finished
	hide()
	await get_tree().create_timer(2,false).timeout
	queue_free()
	pass
