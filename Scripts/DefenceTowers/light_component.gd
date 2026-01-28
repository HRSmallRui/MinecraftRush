extends PointLight2D


func _ready() -> void:
	energy = 0
	pass


func _process(delta: float) -> void:
	energy = 1.5 if Stage.instance.is_dark_time else 0
	pass
