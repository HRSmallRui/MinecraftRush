extends Resource
class_name BossWaveConfig

@export var enemy_pool: Array[BossWavePoolUnit]
@export var start_danger_level: int
@export var interval_update_time: float

var current_danger_level: int


func _init() -> void:
	current_danger_level = start_danger_level
	pass
