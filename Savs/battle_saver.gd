extends Resource
class_name BattleSaver

@export var stage_money: int
@export var stage_wave: int
@export var stage_health: int

@export_group("arrays")
@export var enemy_path_groups: Array[PackedScene]
@export var ally_group: Array[PackedScene]
@export var tower_group: Array[PackedScene]
@export var bullet_group: Array[PackedScene]

@export_group("")
@export var next_wave_time: float
@export var next_wave_during_time: float
