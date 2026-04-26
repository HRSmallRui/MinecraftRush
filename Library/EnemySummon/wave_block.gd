@tool
extends Resource
class_name SummonWaveBlock

@export var calculate_time: bool = false:
	set(v):
		if Engine.is_editor_hint():
			calculate_time = false
			count_time()
@export var summon_list: Array[SummonBlock]


func count_time():
	var time: float
	for block in summon_list:
		if block == null: continue
		if block is WaitTimeBlock: time += block.wait_time
		else:
			time += block.time_interval * (block.summon_count-1)
	prints("经过时间：",time,"s")
	pass
