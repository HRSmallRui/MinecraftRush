extends StoryLayer

@onready var ending_back: AudioStreamPlayer = $EndingBack


func disappear():
	super()
	create_tween().tween_property(ending_back,"volume_db",-100,1)
	await get_tree().create_timer(0.2).timeout
	Global.change_scene("res://Scenes/GameBased/main_map.tscn")
	pass
