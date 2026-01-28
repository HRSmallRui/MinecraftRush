extends Node

enum VersionType{
	Release,
	Demo,
	Alpha,
	Beta,
	Dev
}


@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var progress_bar: ProgressBar = $CanvasLayer/ProgressBar
@onready var tip_panel: Panel = $CanvasLayer/TipPanel
@onready var tip_label: Label = $CanvasLayer/TipPanel/TipLabel

@export_multiline var tip_text_list: Array[String]
@export var time_scale: float = 1:
	set(v):
		time_scale = v
		Engine.time_scale = time_scale

@export var total_level_count: int = 20
@export var version_text: String
@export var current_version_type: VersionType
@export var total_stars: int
#user_sav_path
#user://UserSav.tres
#res://Savs/UserSav.tres

#game_sav_path
#user://Sav
#res://Savs/Sav
var current_sav_slot: int = 1


func start_load():
	preload("res://Scenes/DefenceTowers/ArcherTowers/archer_tower_lv_1.tscn")
	preload("res://Scenes/DefenceTowers/BarrackTowers/barrack_tower_lv_1.tscn")
	preload("res://Scenes/DefenceTowers/MagicTower/magic_tower_lv_1.tscn")
	preload("res://Scenes/DefenceTowers/BombardTowers/bombard_tower_lv_1.tscn")
	preload("res://Scenes/DefenceTowers/ArcherTowers/archer_tower_lv_2.tscn")
	preload("res://Scenes/DefenceTowers/BarrackTowers/barrack_tower_lv_2.tscn")
	preload("res://Scenes/DefenceTowers/MagicTower/magic_tower_lv_2.tscn")
	preload("res://Scenes/DefenceTowers/BombardTowers/bombard_tower_lv_2.tscn")
	preload("res://Scenes/DefenceTowers/ArcherTowers/archer_tower_lv_3.tscn")
	preload("res://Scenes/DefenceTowers/BarrackTowers/barrack_tower_lv_3.tscn")
	preload("res://Scenes/DefenceTowers/MagicTower/magic_tower_lv_3.tscn")
	preload("res://Scenes/DefenceTowers/BombardTowers/bombard_tower_lv_3.tscn")
	
	#preload("res://Scenes/DefenceTowers/BarrackTowers/royal_guard_palace.tscn")
	#preload("res://Scenes/DefenceTowers/MagicTower/protector_church.tscn")
	#preload("res://Scenes/DefenceTowers/ArcherTowers/stone_tower.tscn")
	#
	#preload("res://Scenes/DefenceTowers/BombardTowers/operator_turret.tscn")
	#preload("res://Scenes/DefenceTowers/ArcherTowers/desert_sentry_tower.tscn")
	#preload("res://Scenes/DefenceTowers/BarrackTowers/epee_church.tscn")
	#preload("res://Scenes/DefenceTowers/BombardTowers/nuclear_turret.tscn")
	#
	#preload("res://Scenes/DefenceTowers/MagicTower/witch_tower.tscn")
	#preload("res://Scenes/DefenceTowers/MagicTower/alchemist_tower.tscn")
	#preload("res://Scenes/DefenceTowers/BarrackTowers/medical_guard_camp.tscn")
	#preload("res://Scenes/DefenceTowers/ArcherTowers/sentry_tower.tscn")
	pass


func _ready() -> void:
	progress_bar.hide()
	tip_panel.hide()
	
	AudioServer.set_bus_volume_db(1,get_user_sav().user_music_volume)
	AudioServer.set_bus_volume_db(2,get_user_sav().user_sound_volume)
	pass


func get_user_sav() -> UserSaver:
	var user_sav_path = "res://Savs/UserSav.res" if OS.is_debug_build() else "user://UserSav.res"
	if OS.get_name() == "Android" : user_sav_path = OS.get_user_data_dir() + "UserSav.res"
	if not load(user_sav_path): return null
	return load(user_sav_path) as UserSaver
	pass


func get_game_sav(sav_slot: int = current_sav_slot) -> GameSaver:
	var game_sav_path_front = "res://Savs/Sav" if OS.is_debug_build() else "user://Sav"
	if OS.get_name() == "Android" : game_sav_path_front = OS.get_user_data_dir() + "Sav"
	var game_sav_path = game_sav_path_front + str(sav_slot) + ".tres"
	return load(game_sav_path) as GameSaver
	pass


func sav_user_sav(user_sav: UserSaver):
	var user_sav_path: String = "res://Savs/UserSav.res" if OS.is_debug_build() else "user://UserSav.res"
	if OS.get_name() == "Android": user_sav_path = OS.get_user_data_dir() + "UserSav.res"
	ResourceSaver.save(user_sav,user_sav_path)
	pass


func sav_game_sav(game_sav: GameSaver, sav_slot = current_sav_slot):
	var game_sav_path_front = "res://Savs/Sav" if OS.is_debug_build() else "user://Sav"
	if OS.get_name() == "Android": game_sav_path_front = OS.get_user_data_dir() + "Sav"
	var game_sav_path = game_sav_path_front + str(sav_slot) + ".tres"
	game_sav.last_sav_time = Time.get_datetime_string_from_system(false,true)
	ResourceSaver.save(game_sav,game_sav_path)
	pass


func get_game_sav_path(sav_slot: int = current_sav_slot) -> String:
	var game_sav_path_front = "res://Savs/Sav" if OS.is_debug_build() else "user://Sav"
	if OS.get_name() == "Android": game_sav_path_front = OS.get_user_data_dir() + "Sav"
	var game_sav_path = game_sav_path_front + str(sav_slot) + ".tres"
	return game_sav_path
	pass


func change_scene(scene_path: String):
	get_tree().paused = true
	animation_player.play("close")
	await animation_player.animation_finished
	get_tree().change_scene_to_file("res://Scenes/GameBased/changer.tscn")
	progress_bar.value = 0
	progress_bar.show()
	progress_bar.modulate.a = 0
	tip_panel.show()
	tip_panel.modulate.a = 0
	tip_label.text = tip_text_list[randi_range(0,tip_text_list.size()-1)]
	create_tween().tween_property(progress_bar,"modulate:a",1,0.3)
	create_tween().tween_property(tip_panel,"modulate:a",1,0.5)
	await get_tree().create_timer(0.5,true).timeout
	get_tree().paused = false
	ResourceLoader.load_threaded_request(scene_path,"",false,ResourceLoader.CACHE_MODE_IGNORE)
	$SceneChanger.scene_path = scene_path
	$SceneChanger.set_process(true)
	$SceneChanger.update = 0
	await $SceneChanger.done
	create_tween().tween_property(progress_bar,"modulate:a",0,0.3)
	create_tween().tween_property(tip_panel,"modulate:a",0,0.5)
	await get_tree().create_timer(0.5,true).timeout
	progress_bar.hide()
	animation_player.play("open")
	get_tree().change_scene_to_packed(ResourceLoader.load_threaded_get(scene_path))
	pass


func get_version_back_words() -> String:
	var back_words: String
	match current_version_type:
		VersionType.Demo:
			back_words = ".DEMO"
		VersionType.Alpha:
			back_words = ".ALPHA"
		VersionType.Beta:
			back_words = ".BETA"
		VersionType.Dev:
			back_words = ".DEV"
	return back_words
	pass
