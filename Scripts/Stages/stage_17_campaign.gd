extends Stage


func _ready() -> void:
	super()
	#await get_tree().create_timer(1,false).timeout
	#$Enemies/EnemyPath7.add_child(preload("res://Scenes/Enemies/enemy_58.tscn").instantiate())
	pass


func win(wait_time: float = 3):
	if is_win: return
	is_win = true
	await get_tree().create_timer(2,false).timeout
	create_tween().tween_property(boss_music,"volume_db",-100,2)
	await get_tree().create_timer(wait_time,false).timeout
	battle_music.stop()
	boss_music.stop()
	var story_layer: StoryLayer = preload("res://Scenes/Stages/Stage17/stage_17_story_layer.tscn").instantiate()
	add_child(story_layer)
	pass
