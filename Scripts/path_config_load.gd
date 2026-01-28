@tool
extends Node
class_name PathConfigLoadProcess

@export var ready_to_load: bool:
	set(v):
		ready_to_load = false
		loading()
@export var enemy_parent_node: Node2D
@export_dir var config_path_front: String
@export var loading_count: int

@export_group("BOSS")
@export_dir var boss_wave_config_path_front: String
@export var boss_ready_to_loading: bool:
	set(v):
		boss_ready_to_loading = false
		boss_loading()
@export var clear_boss_wave_configs: bool:
	set(v):
		clear_boss_wave_configs = false
		for i in loading_count:
			var current_path: EnemyPath = enemy_parent_node.get_child(i)
			current_path.boss_wave_config = null


func loading():
	for i in loading_count:
		var current_config_path: String = config_path_front + "/path" + str(i+1) + ".res"
		var config: PathSummonList = load(current_config_path)
		var current_path: EnemyPath = enemy_parent_node.get_child(i)
		current_path.path_summon_config = config
	pass


func _ready() -> void:
	if !OS.is_debug_build():
		queue_free()
	pass


func boss_loading():
	for i in loading_count:
		var current_config_path: String = boss_wave_config_path_front + "/boss_wave_path" + str(i+1) + ".res"
		var config: BossWaveConfig = load(current_config_path)
		var current_path: EnemyPath = enemy_parent_node.get_child(i)
		current_path.boss_wave_config = config
	pass
