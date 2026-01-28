extends Resource
class_name NormalTowerData

@export var damage_low: int
@export var damage_high: int
@export var attack_speed: float

var start_data: NormalTowerData


func ready_data(data: NormalTowerData):
	damage_low = data.damage_low
	damage_high = data.damage_high
	attack_speed = data.attack_speed
	pass


func update_damage():
	damage_low = start_data.damage_low
	damage_high = start_data.damage_high
	pass
