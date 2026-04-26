extends RainSystem


func wave_step(wave_count: int):
	super(wave_count)
	await get_tree().create_timer(60,false).timeout
	translate_to_rain_step(RainStep.None)
	pass
