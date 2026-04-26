extends Node2D
class_name SteveSlashEffect

@export var slash_audio_list: Array[AudioStream]

@onready var slash_anim_sprite: AnimatedSprite2D = $SlashAnimSprite
@onready var slash_audio: AudioStreamPlayer = $SlashAudio

var slash_text: String


func _ready() -> void:
	slash_anim_sprite.play("slash" + str(randi_range(1,3)))
	slash_anim_sprite.pause()
	hide()
	await get_tree().process_frame
	show()
	anim_offset()
	pass


func anim_offset():
	match slash_anim_sprite.animation:
		"slash1":
			slash_anim_sprite.position = Vector2(1,-27) if slash_anim_sprite.flip_h else Vector2(-1,-27)
			match randi_range(0,2):
				0: slash_text = "劈！"
				1: slash_text = "散！"
				2: slash_text = "罪！"
			slash_audio.stream = slash_audio_list[0]
		"slash2":
			slash_anim_sprite.position = Vector2(1,-22) if slash_anim_sprite.flip_h else Vector2(-1,-22)
			match randi_range(0,2):
				0: slash_text = "劈！"
				1: slash_text = "杀！"
				2: slash_text = "裂！"
			slash_audio.stream = slash_audio_list[1]
		"slash3":
			slash_anim_sprite.position = Vector2(-7,-22) if slash_anim_sprite.flip_h else Vector2(7,-22)
			match randi_range(0,2):
				0: slash_text = "双！"
				1: slash_text = "寂！"
				2: slash_text = "灭！"
			slash_audio.stream = slash_audio_list[2]
	pass


func slash_play():
	slash_anim_sprite.play()
	slash_audio.play()
	var summon_pos: Vector2 = position
	summon_pos.y -= 20
	summon_pos.x += -30 if slash_anim_sprite.flip_h else 30
	TextEffect.text_effect_show(slash_text,TextEffect.TextEffectType.Magic,summon_pos)
	await get_tree().create_timer(0.5,false).timeout
	var disappear_tween: Tween = create_tween()
	disappear_tween.tween_property(slash_anim_sprite,"modulate:a",0,0.4)
	await disappear_tween.finished
	queue_free()
	pass
