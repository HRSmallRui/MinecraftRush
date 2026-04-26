extends Node
class_name LoopMusicPlayer

enum MusicMode{
	PREPARE,
	BATTLE,
	BOSS
}

@export var music_mode: MusicMode
@export var music_list: Array[AudioStreamPlayer]
@export var next_wait_time: Array[float]

@onready var wait_timer: Timer = $WaitTimer

var current_id: int = 0


func _ready() -> void:
	match music_mode:
		MusicMode.PREPARE:
			Stage.instance.on_prepare_music_playing.connect(play_music)
			Stage.instance.on_prepare_music_stop.connect(stop_music)
		MusicMode.BATTLE:
			Stage.instance.on_battle_music_playing.connect(play_music)
			Stage.instance.on_battle_music_stop.connect(stop_music)
		MusicMode.BOSS:
			Stage.instance.on_boss_music_playing.connect(play_music)
			Stage.instance.on_boss_music_stop.connect(stop_music)
	pass


func _on_wait_timer_timeout() -> void:
	current_id += 1
	music_list[current_id].play()
	if current_id >= next_wait_time.size():
		wait_timer.stop()
		return
	wait_timer.wait_time = next_wait_time[current_id]
	wait_timer.start()
	pass # Replace with function body.


func play_music():
	current_id = 0
	wait_timer.wait_time = next_wait_time[current_id]
	wait_timer.start()
	music_list[current_id].play()
	pass


func stop_music():
	for audio_player: AudioStreamPlayer in music_list:
		audio_player.stop()
	wait_timer.stop()
	pass


func set_volume(target_volume: float, processing_time: float):
	for stream_player in music_list:
		create_tween().tween_property(stream_player,"volume_db",target_volume,processing_time)
	pass
