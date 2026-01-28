extends StoryLayer


@onready var chapter_4_final_boss_start: AudioStreamPlayer = $Chapter4FinalBossStart
@onready var chapter_4_final_boss_loop: AudioStreamPlayer = $Chapter4FinalBossLoop


func _ready() -> void:
	super()
	back()
	stop_music()
	await get_tree().create_timer(42.5).timeout
	chapter_4_final_boss_start.play()
	await get_tree().create_timer(30.4 / 0.9).timeout
	chapter_4_final_boss_loop.play()
	pass


func back():
	await get_tree().create_timer(136).timeout
	var health: int = Stage.instance.current_health
	if health >= 18:
		save_reward(3)
	elif health >= 5:
		save_reward(2)
	else:
		save_reward(1)
	Global.change_scene("res://Scenes/GameBased/main_map.tscn")
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


func stop_music():
	await get_tree().create_timer(134).timeout
	create_tween().tween_property(chapter_4_final_boss_loop,"volume_db",-70,2)
	pass
