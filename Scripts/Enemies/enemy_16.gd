extends Enemy

@export var attack_stream_list: Array[AudioStream]
@onready var attack_audio: AudioStreamPlayer = $AttackAudio


func anim_offset():
	match enemy_sprite.animation:
		"attack","idle":
			enemy_sprite.position = Vector2(0,-40)
		"die":
			enemy_sprite.position = Vector2(0,-35)
		"move_back","move_front","move_normal":
			enemy_sprite.position = Vector2(0,-45)
	pass


func frame_changed():
	if enemy_sprite.animation == "attack" and enemy_sprite.frame == 15:
		cause_damage()
	if enemy_sprite.animation == "attack" and enemy_sprite.frame == 1:
		var attack_stream: AudioStream = attack_stream_list[randi_range(0,attack_stream_list.size()-1)]
		attack_audio.stream = attack_stream
		attack_audio.play()
	pass
