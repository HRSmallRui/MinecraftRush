extends Resource
class_name GameSaver

enum Difficulty{
	EASY,
	NORMAL,
	HARD
}

@export_group("基础配置")
@export var difficulty: Difficulty
@export var last_sav_time: String
@export var total_stars: int
@export var total_diamonds: int
@export var total_bedrocks: int
@export var has_selected_difficulty: bool
@export_group("英雄相关")
@export var select_hero_id: int = 0
@export var hero_sav: Array[HeroSavBlock] = [
	HeroSavBlock.new(1,0,true)
]
@export_group("关卡")
@export var level_sav = {
	1: [false,0,0,0] #[是否已经出现，战役模式分数，英雄模式分数，钢铁模式分数]
}
@export var level_difficulty_completed: Dictionary = {
	
}

@export var challenge_mode_tip: bool = false
@export var challenge_level_tip: bool = false
@export var upgrade_sav: Array[int] = [0,0,0,0,0,0]
@export var can_use_stars: int = 0
@export var tower_unlock_sav: Array = [
	[true,false,false,false,false,false],
	[true,false,false,false,false,false],
	[true,false,false,false,false,false],
	[true,false,false,false,false,false]
]
@export var enemy_unlock_sav: Dictionary = {
	0: false
}
@export_group("成就")
@export var compeleted_keywords: Array[String] = []
@export var number_count_achievements: Dictionary = {
	
}
@export var property_bus: Dictionary = {}


func _init() -> void:
	last_sav_time = Time.get_datetime_string_from_system(false,true)
	pass
