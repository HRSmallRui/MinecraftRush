extends Stage


func _hero_summon_condition():
	if stage_sav.level_sav[1][1] == 0:
		return
	super()
	pass


func wave_tip(wave_count: int):
	if wave_count == 6:
		await get_tree().create_timer(2,false).timeout
		tips_container.add_child(load("res://Scenes/UI-Components/TipButtons/ArmorTipButton.tscn").instantiate())
	pass


func win(wait_time: float = 3):
	super(wait_time)
	if current_health >= 18:
		Achievement.achieve_complete("Level1Finished")
	pass
