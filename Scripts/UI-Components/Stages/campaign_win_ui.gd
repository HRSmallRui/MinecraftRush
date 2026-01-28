extends CanvasLayer

var can_control: bool = false


func _ready() -> void:
	hero_unlock_check()
	get_tree().paused = true
	await $AnimationPlayer.animation_finished
	var health: int = Stage.instance.current_health
	if health >= 18: star_3_animation()
	elif health >= 5: star_2_animation()
	else: star_1_animation()
	pass


func star_3_animation():
	save_reward(3)
	$AnimationPlayer.play("center_star")
	await $AnimationPlayer.animation_finished
	$AnimationPlayer.play("left_star")
	await $AnimationPlayer.animation_finished
	$AnimationPlayer.play("right_star")
	await $AnimationPlayer.animation_finished
	$AnimationPlayer.play("button_show")
	stage_continue()
	pass


func star_2_animation():
	save_reward(2)
	$AnimationPlayer.play("left_star")
	await $AnimationPlayer.animation_finished
	$AnimationPlayer.play("right_star")
	await $AnimationPlayer.animation_finished
	$AnimationPlayer.play("button_show")
	stage_continue()
	pass


func star_1_animation():
	save_reward(1)
	$AnimationPlayer.play("center_star")
	await $AnimationPlayer.animation_finished
	$AnimationPlayer.play("button_show")
	stage_continue()
	pass


func stage_continue():
	can_control = true
	await get_tree().create_timer(2).timeout
	Stage.instance.preparation_music.play()
	pass


func _on_finish_button_pressed() -> void:
	Global.change_scene("res://Scenes/GameBased/main_map.tscn")
	pass # Replace with function body.


func _on_restart_button_pressed() -> void:
	get_tree().reload_current_scene()
	pass # Replace with function body.


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("escape") and can_control:
		_on_finish_button_pressed()
	pass


func save_reward(star_count: int):
	var key:String = str(Stage.instance.stage_count) + "_campaign"
	if key in Stage.instance.stage_sav.level_difficulty_completed:
		if Stage.instance.stage_sav.level_difficulty_completed[key] < Stage.instance.stage_sav.difficulty:
			Stage.instance.stage_sav.level_difficulty_completed[key] = Stage.instance.stage_sav.difficulty
	else:
		Stage.instance.stage_sav.level_difficulty_completed[key] = Stage.instance.stage_sav.difficulty
	
	var stage_block = Stage.instance.stage_sav.level_sav[Stage.instance.stage_count] as Array
	var append_stars: int = 0
	match stage_block[1]:
		0:
			match star_count:
				1: 
					Map.level_animation_type = Map.LevelAnimationType.Campaign0_1
					append_stars = 1
				2: 
					Map.level_animation_type = Map.LevelAnimationType.Campaign0_2
					append_stars = 2
				3: 
					Map.level_animation_type = Map.LevelAnimationType.Campaign0_3
					append_stars = 3
		1:
			match star_count:
				1: return
				2: 
					Map.level_animation_type = Map.LevelAnimationType.Campaign1_2
					append_stars = 1
				3: 
					Map.level_animation_type = Map.LevelAnimationType.Campaign1_3
					append_stars = 2
		2:
			match star_count:
				1: return
				2: return
				3: 
					Map.level_animation_type = Map.LevelAnimationType.Campaign2_3
					append_stars = 1
		3: return
	
	Map.animation_stage_count = Stage.instance.stage_count
	Stage.instance.stage_sav.level_sav[Stage.instance.stage_count][1] = star_count
	Stage.instance.stage_sav.total_stars += append_stars
	Stage.instance.stage_sav.can_use_stars += append_stars
	Global.sav_game_sav(Stage.instance.stage_sav)
	print(Map.level_animation_type)
	print(Map.animation_stage_count)
	pass


func hero_unlock_check():
	var hero_list: Array[HeroSavBlock] = Stage.instance.stage_sav.hero_sav
	match Stage.instance.stage_count:
		3: hero_list[1].unlocked = true #Fuchen
		6: hero_list[2].unlocked = true #Alex
		8: hero_list[3].unlocked = true #Talzin
		9: hero_list[4].unlocked = true #Robort
		12: hero_list[7].unlocked = true #Salem
		14: hero_list[8].unlocked = true #Johnny
	
	Global.sav_game_sav(Stage.instance.stage_sav)
	pass
