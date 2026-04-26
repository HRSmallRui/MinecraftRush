@tool
extends SummonBlock
class_name WaitTimeBlock

@export var get_random_wait_time: bool = false:
	set(v):
		if Engine.is_editor_hint():
			get_random_wait_time = false
			var random_time: float = randi_range(4,12)
			wait_time += random_time

@export var wait_time: float
