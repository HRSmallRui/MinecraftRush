extends StoryLayer


@onready var slash_audio: AudioStreamPlayer = $SlashAudio
@onready var end_audio: AudioStreamPlayer = $EndAudio
@onready var lie_audio: AudioStreamPlayer = $LieAudio
@onready var bgm: AudioStreamPlayer = $BGM


func _ready() -> void:
	super()
	slash_process()
	end_process()
	bgm_process()
	pass


func slash_process():
	await get_tree().create_timer(14).timeout
	slash_audio.play()
	await get_tree().create_timer(1).timeout
	pass


func end_process():
	await get_tree().create_timer(197).timeout
	end_audio.play()
	await end_audio.finished
	lie_audio.play()
	pass


func bgm_process():
	await get_tree().create_timer(16).timeout
	bgm.play()
	await get_tree().create_timer(196).timeout
	create_tween().tween_property(bgm,"volume_db",-100,3)
	pass


func disappear():
	super()
	Stage.instance.on_battle_music_stop.emit()
	pass
