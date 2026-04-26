extends Resource
class_name BasedTowerData

var tower_name:String
var tower_intro:String
var damage_low:int
var damage_high: int
var attack_speed: float
var tower_range: int

func _init(in_tower_name:String,in_tower_intro: String,in_damage_low:int,in_damage_high:int,in_attack_speed:float,in_tower_range:int) -> void:
	tower_name = in_tower_name
	tower_intro = in_tower_intro
	damage_low = in_damage_low
	damage_high = in_damage_high
	attack_speed = in_attack_speed
	tower_range = in_tower_range
	pass
