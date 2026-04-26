extends Stage

@export var rain_system: RainSystem


func win(wait_time: float = 6):
	super(wait_time)
	await get_tree().create_timer(2,false).timeout
	rain_system.translate_to_rain_step(RainSystem.RainStep.None)
	pass
