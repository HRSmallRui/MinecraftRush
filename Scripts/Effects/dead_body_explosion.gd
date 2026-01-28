extends AnimatedSprite2D

@onready var dead_body_explosion_audio: AudioStreamPlayer = $DeadBodyExplosionAudio


func _ready() -> void:
	await dead_body_explosion_audio.finished
	queue_free()
	pass
