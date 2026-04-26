extends Node

signal done

var scene_path: String
var update:float = 0
var progress: Array

@onready var progress_bar: ProgressBar = $"../CanvasLayer/ProgressBar"


func _ready() -> void:
	set_process(false)
	pass


func _process(delta: float) -> void:
	ResourceLoader.load_threaded_get_status(scene_path,progress)
	if progress[0] > update:
		update = progress[0]
	if progress_bar.value < update:
		progress_bar.value = lerp(progress_bar.value,update,delta)
	if progress_bar.value > 0.99:
		done.emit()
		set_process(false)
	pass
