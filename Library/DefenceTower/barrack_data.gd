extends Resource
class_name BarrackTowerData

var tower_name: String
var tower_intro: String
var soldier_health:int
var damage_low: int
var damage_high: int
var soldier_armor: float
var rebirth_time: int
var tower_range:int

func _init(in_tower_name: String, in_tower_intro: String, max_health: int, in_damage_low: int,
in_damage_high: int, armor: float, in_rebirth_time: int, in_tower_range: int = 300) -> void:
	tower_name = in_tower_name
	tower_intro = in_tower_intro
	soldier_health = max_health
	damage_low = in_damage_low
	damage_high = in_damage_high
	soldier_armor = armor
	rebirth_time = in_rebirth_time
	tower_range = in_tower_range
	pass
