extends Node2D

@onready var cage_audio: AudioStreamPlayer = $CageAudio
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var timer: Timer = $Timer


func _ready() -> void:
	timer.start()
	await timer.timeout
	animation_player.play("disappear")
	await animation_player.animation_finished
	queue_free()
	pass
