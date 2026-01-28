extends Node
class_name EnemyScenePreloadConfig

@export var chapter1_preload: bool
@export var chapter1_boss_preload: bool
@export var chapter2_preload: bool
@export var chapter2_boss_preload: bool
@export var chapter3_preload: bool
@export var chapter3_boss_preload: bool
@export var chapter4_hating_preload: bool ##厌国战士，厌国精英，苦力怕，厌国狂战士
@export var chapter4_illager_preload: bool ##女巫，劫掠者，卫道士，唤魔者，劫掠队长，劫掠兽，恼鬼
@export var chapter4_other_preload: bool ##史莱姆，幻翼，蜘蛛，泰坦威克斯
@export var chapter4_guardian_preload: bool ##守卫者
@export var chapter4_boss_preload: bool

@export var waiting_load_time: float = 0.1


func _ready() -> void:
	await get_tree().create_timer(waiting_load_time).timeout
	load_request_enemy_scenes()
	pass


func load_request_enemy_scenes():
	if chapter1_preload:
		ResourceLoader.load_threaded_request("res://Scenes/Enemies/enemy_0.tscn","",true,ResourceLoader.CACHE_MODE_IGNORE)
		ResourceLoader.load_threaded_request("res://Scenes/Enemies/enemy_1.tscn","",true,ResourceLoader.CACHE_MODE_IGNORE)
		ResourceLoader.load_threaded_request("res://Scenes/Enemies/enemy_2.tscn","",true,ResourceLoader.CACHE_MODE_IGNORE)
		ResourceLoader.load_threaded_request("res://Scenes/Enemies/enemy_3.tscn","",true,ResourceLoader.CACHE_MODE_IGNORE)
		ResourceLoader.load_threaded_request("res://Scenes/Enemies/enemy_4.tscn","",true,ResourceLoader.CACHE_MODE_IGNORE)
		ResourceLoader.load_threaded_request("res://Scenes/Enemies/enemy_5.tscn","",true,ResourceLoader.CACHE_MODE_IGNORE)
		ResourceLoader.load_threaded_request("res://Scenes/Enemies/enemy_6.tscn","",true,ResourceLoader.CACHE_MODE_IGNORE)
		ResourceLoader.load_threaded_request("res://Scenes/Enemies/enemy_7.tscn","",true,ResourceLoader.CACHE_MODE_IGNORE)
		ResourceLoader.load_threaded_request("res://Scenes/Enemies/enemy_8.tscn","",true,ResourceLoader.CACHE_MODE_IGNORE)
		ResourceLoader.load_threaded_request("res://Scenes/Enemies/enemy_9.tscn","",true,ResourceLoader.CACHE_MODE_IGNORE)
	if chapter1_boss_preload:
		ResourceLoader.load_threaded_request("res://Scenes/Enemies/enemy_54.tscn","",false,ResourceLoader.CACHE_MODE_IGNORE)
	if chapter2_preload:
		ResourceLoader.load_threaded_request("res://Scenes/Enemies/enemy_10.tscn","",true)
		ResourceLoader.load_threaded_request("res://Scenes/Enemies/enemy_11.tscn","",true)
		ResourceLoader.load_threaded_request("res://Scenes/Enemies/enemy_12.tscn","",true)
		ResourceLoader.load_threaded_request("res://Scenes/Enemies/enemy_13.tscn","",true)
		ResourceLoader.load_threaded_request("res://Scenes/Enemies/enemy_14.tscn","",true)
		ResourceLoader.load_threaded_request("res://Scenes/Enemies/enemy_15.tscn","",true)
		ResourceLoader.load_threaded_request("res://Scenes/Enemies/enemy_16.tscn","",true)
		ResourceLoader.load_threaded_request("res://Scenes/Enemies/enemy_17.tscn","",true)
		ResourceLoader.load_threaded_request("res://Scenes/Enemies/enemy_18.tscn","",true)
	if chapter2_boss_preload:
		ResourceLoader.load_threaded_request("res://Scenes/Enemies/enemy_55.tscn","",false,ResourceLoader.CACHE_MODE_IGNORE)
	if chapter3_preload:
		ResourceLoader.load_threaded_request("res://Scenes/Enemies/enemy_19.tscn","",true)
		ResourceLoader.load_threaded_request("res://Scenes/Enemies/enemy_20.tscn","",true)
		ResourceLoader.load_threaded_request("res://Scenes/Enemies/enemy_21.tscn","",true)
		ResourceLoader.load_threaded_request("res://Scenes/Enemies/enemy_22.tscn","",true)
		ResourceLoader.load_threaded_request("res://Scenes/Enemies/enemy_23.tscn","",true)
		ResourceLoader.load_threaded_request("res://Scenes/Enemies/enemy_24.tscn","",true)
		ResourceLoader.load_threaded_request("res://Scenes/Enemies/enemy_25.tscn","",true)
		ResourceLoader.load_threaded_request("res://Scenes/Enemies/enemy_26.tscn","",true)
		ResourceLoader.load_threaded_request("res://Scenes/Enemies/enemy_27.tscn","",true)
		ResourceLoader.load_threaded_request("res://Scenes/Enemies/enemy_28.tscn","",true)
	if chapter3_boss_preload:
		ResourceLoader.load_threaded_request("res://Scenes/Enemies/enemy_56.tscn","",true)
	if chapter4_hating_preload:
		ResourceLoader.load_threaded_request("res://Scenes/Enemies/enemy_29.tscn","",true)
		ResourceLoader.load_threaded_request("res://Scenes/Enemies/enemy_30.tscn","",true)
		ResourceLoader.load_threaded_request("res://Scenes/Enemies/enemy_31.tscn","",true)
		ResourceLoader.load_threaded_request("res://Scenes/Enemies/enemy_32.tscn","",true)
	if chapter4_illager_preload:
		ResourceLoader.load_threaded_request("res://Scenes/Enemies/enemy_33.tscn","",true)
		ResourceLoader.load_threaded_request("res://Scenes/Enemies/enemy_34.tscn","",true)
		ResourceLoader.load_threaded_request("res://Scenes/Enemies/enemy_35.tscn","",true)
		ResourceLoader.load_threaded_request("res://Scenes/Enemies/enemy_36.tscn","",true)
		ResourceLoader.load_threaded_request("res://Scenes/Enemies/enemy_37.tscn","",true)
		ResourceLoader.load_threaded_request("res://Scenes/Enemies/enemy_38.tscn","",true)
		ResourceLoader.load_threaded_request("res://Scenes/Enemies/enemy_42.tscn","",true)
	if chapter4_other_preload:
		ResourceLoader.load_threaded_request("res://Scenes/Enemies/enemy_39.tscn","",true)
		ResourceLoader.load_threaded_request("res://Scenes/Enemies/enemy_40.tscn","",true)
		ResourceLoader.load_threaded_request("res://Scenes/Enemies/enemy_41.tscn","",true)
		ResourceLoader.load_threaded_request("res://Scenes/Enemies/enemy_43.tscn","",true)
	if chapter4_guardian_preload:
		ResourceLoader.load_threaded_request("res://Scenes/Enemies/enemy_44.tscn","",true)
	pass
