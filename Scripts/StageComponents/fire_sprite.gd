extends AnimatedSprite2D


func _ready() -> void:
	frame = randi_range(0,28)
	speed_scale = randf_range(0.8,1.2)
	pass
