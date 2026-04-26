extends AnimatedSprite2D

@export var show_on_raining_step: RainSystem.RainStep
@export var linked_rain_system: RainSystem


func _ready() -> void:
	speed_scale = randf_range(0.8,1.4)
	pass


func _process(delta: float) -> void:
	visible = linked_rain_system.current_rain_step >= show_on_raining_step
	pass
