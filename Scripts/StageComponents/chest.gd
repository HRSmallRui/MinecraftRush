extends Node2D

@export var chest_count: int = 9
@export var money_min: int = 50
@export var money_max: int = 100

@onready var open_audio: AudioStreamPlayer = $OpenAudio
@onready var close_audio: AudioStreamPlayer = $CloseAudio

var click_count: int


func _on_chest_area_1_open_chest() -> void:
	open_audio.play()
	Stage.instance.current_money += randi_range(money_min,money_max)
	click_count += 1
	if click_count >= chest_count:
		Achievement.achieve_complete("Resident")
	pass # Replace with function body.
