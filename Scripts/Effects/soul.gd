extends MagicBall


func _ready() -> void:
	super()
	free_timer.wait_time = 0.4 / bullet_speed + 0.05
	free_timer.start()
	pass
