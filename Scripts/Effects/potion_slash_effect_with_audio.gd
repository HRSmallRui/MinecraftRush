extends AnimatedSprite2D

@export var audio_player_list: Array[AudioStreamPlayer]


func _ready() -> void:
	var audio_player: AudioStreamPlayer = audio_player_list.pick_random()
	audio_player.play()
	await audio_player.finished
	if is_playing():
		await animation_finished
	queue_free()
	pass
