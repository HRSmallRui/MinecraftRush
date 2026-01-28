extends CanvasLayer

var can_control: bool = false


func _ready() -> void:
	get_tree().paused = true
	save_reward()
	await $AnimationPlayer.animation_finished
	$AnimationPlayer.play("diamond_show")
	await $AnimationPlayer.animation_finished
	$AnimationPlayer.play("button_show")
	await $AnimationPlayer.animation_finished
	can_control = true
	await get_tree().create_timer(2).timeout
	Stage.instance.preparation_music.play()
	pass


func save_reward():
	var key:String = str(Stage.instance.stage_count) + "_bedrock"
	if key in Stage.instance.stage_sav.level_difficulty_completed:
		if Stage.instance.stage_sav.level_difficulty_completed[key] < Stage.instance.stage_sav.difficulty:
			Stage.instance.stage_sav.level_difficulty_completed[key] = Stage.instance.stage_sav.difficulty
	else:
		Stage.instance.stage_sav.level_difficulty_completed[key] = Stage.instance.stage_sav.difficulty
	
	var stage_block = Stage.instance.stage_sav.level_sav[Stage.instance.stage_count] as Array
	if stage_block[3] > 0: return
	if stage_block[2] == 0:
		Map.level_animation_type = Map.LevelAnimationType.Campaign_Bedrock
	else:
		Map.level_animation_type = Map.LevelAnimationType.Diamond_Bedrock
	Map.animation_stage_count = Stage.instance.stage_count
	
	Stage.instance.stage_sav.level_sav[Stage.instance.stage_count][3] = 1
	Stage.instance.stage_sav.total_stars += 1
	Stage.instance.stage_sav.can_use_stars += 1
	Stage.instance.stage_sav.total_bedrocks += 1
	Global.sav_game_sav(Stage.instance.stage_sav)
	print(Map.level_animation_type)
	print(Map.animation_stage_count)
	pass


func _on_restart_button_pressed() -> void:
	get_tree().reload_current_scene()
	pass # Replace with function body.


func _on_finish_button_pressed() -> void:
	Global.change_scene("res://Scenes/GameBased/main_map.tscn")
	pass # Replace with function body.


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("escape") and can_control:
		_on_finish_button_pressed()
	pass
