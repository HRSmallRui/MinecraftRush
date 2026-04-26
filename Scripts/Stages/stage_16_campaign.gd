extends Stage

@onready var lilies: Node2D = $Background/Lilies


func wave_tip(wave_count: int):
	match wave_count:
		2:
			var lily_button = preload("res://Scenes/UI-Components/TipButtons/LilyTipButton.tscn").instantiate()
			tips_container.add_child(lily_button)
	pass


func win(wait_time: float = 3):
	super(wait_time)
	for lily: Node2D in lilies.get_children():
		if !lily.visible: return
	Achievement.achieve_complete("Chapter5Lily")
	pass
