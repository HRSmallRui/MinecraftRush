extends Resource
class_name DamageBlock

@export var damage_low: int
@export var damage_high: int


func get_damage() -> int:
	return randi_range(damage_low,damage_high)
