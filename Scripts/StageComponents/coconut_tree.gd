extends AnimatedSprite2D


@export var linked_rain_system: RainSystem


func _ready() -> void:
	
	pass


func _process(delta: float) -> void:
	match linked_rain_system.current_rain_step:
		0:
			speed_scale = 0
		1: 
			speed_scale = randf_range(0.4,0.6)
		2:
			speed_scale = randf_range(0.8,1.2)
		3:
			speed_scale = randf_range(1.3,1.7)
		4:
			speed_scale = randf_range(1.8,2.2)
	pass
