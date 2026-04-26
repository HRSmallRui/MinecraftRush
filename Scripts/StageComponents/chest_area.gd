extends Area2D

signal open_chest

@onready var chest_sprite: AnimatedSprite2D = $ChestSprite
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D


func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event.is_action_released("click"):
		collision_shape_2d.disabled = true
		open_chest.emit()
		chest_sprite.play()
	
	pass # Replace with function body.
