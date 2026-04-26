extends Timer
class_name OneShotTimer


func _ready() -> void:
	await timeout
	queue_free()
	pass
