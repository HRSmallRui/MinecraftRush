@tool
extends Node2D
class_name PathConfigSave

@export var ready_to_save: bool:
	set(v):
		ready_to_save = false
		save()
@export var sample_config:PathSummonList
@export_dir var path_front: String
@export var loop_count: int
@export_group("BossWave")
@export var boss_wave_template: BossWaveConfig
@export_dir var boss_wave_path_front: String
@export var boss_wave_config_ready_to_save: bool:
	set(v):
		boss_wave_config_ready_to_save = false
		save_boss_configs()


func _ready() -> void:
	if !OS.is_debug_build():
		queue_free()
	pass


func save():
	for i in loop_count:
		var file_name: String = "/path" + str(i+1) + ".res"
		ResourceSaver.save(sample_config,path_front + file_name)
	pass


func save_boss_configs():
	for i in loop_count:
		var file_name: String = "/boss_wave_path" + str(i+1) + ".res"
		ResourceSaver.save(boss_wave_template,boss_wave_path_front + file_name)
	pass
