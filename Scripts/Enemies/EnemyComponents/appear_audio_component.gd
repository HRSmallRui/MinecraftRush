extends Node

@export var appear_audio_list: Array[AudioStream]

@onready var appear_audio_player: AudioStreamPlayer = $AppearAudioPlayer


func _ready() -> void:
	if appear_audio_list.size() == 0: return
	var audio_id: int = randi_range(0,appear_audio_list.size()-1)
	var registor_stream: AudioStream = appear_audio_list[audio_id]
	if registor_stream in AudioManager.instance.registor_enemy_entry_stream_list:
		if randf_range(0,1) < 0.2:
			entry_audio_play(audio_id)
	else:
		entry_audio_play(audio_id)
		AudioManager.instance.entry_stream_registor(registor_stream)
	pass


func entry_audio_play(audio_id: int):
	appear_audio_player.stream = appear_audio_list[audio_id]
	appear_audio_player.play()
	pass
