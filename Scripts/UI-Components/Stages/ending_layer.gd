extends StoryLayer

@export var ending_layer_scene: PackedScene

@onready var video_stream_player: VideoStreamPlayer = $VideoStreamPlayer
@onready var bgm: AudioStreamPlayer = $BGM
@onready var color_rect: ColorRect = $ColorRect
@onready var first_music: AudioStreamPlayer = $FirstMusic


func _ready() -> void:
	super()
	var health_count: int = Stage.instance.current_health
	if health_count >= 18:
		save_reward(3)
	elif health_count >= 5:
		save_reward(2)
	else:
		save_reward(1)
	
	color_rect.modulate.a = 0
	await get_tree().create_timer(1).timeout
	create_tween().tween_property(color_rect,"modulate:a",1,1)
	
	await get_tree().create_timer(1).timeout
	first_music.volume_db = -100
	create_tween().tween_property(first_music,"volume_db",0,1)
	first_music.play(4.4)
	
	await get_tree().create_timer(22).timeout
	create_tween().tween_property(first_music,"volume_db",-100,4)
	await get_tree().create_timer(4).timeout
	video_stream_player.play()
	bgm.play()
	await video_stream_player.finished
	disappear()
	Achievement.achieve_complete("MAIN_END")
	pass


func disappear():
	var disappear_time: float = 0.5
	create_tween().tween_property(subtitle,"modulate:a",0,disappear_time)
	await get_tree().create_timer(disappear_time,process_mode == ProcessMode.PROCESS_MODE_ALWAYS).timeout
	queue_free()
	get_tree().current_scene.add_child(ending_layer_scene.instantiate())
	pass


func save_reward(star_count: int):
	Stage.instance.stage_sav.hero_sav[11].unlocked = true
	Global.get_user_sav().extra_property["extra_unlock"] = true
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
