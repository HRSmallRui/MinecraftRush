extends Area2D

@onready var password: AudioStreamPlayer = $Password
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D

func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event.is_action_pressed("click"):
		collision_shape_2d.disabled = true
		password.play()
		sprite_2d.scale.x = -1
	pass # Replace with function body.
