extends Node2D

@export var kong_shu_lin: Hero
@export var block_effect_scene: PackedScene
@export var skill2_area: Area2D

@onready var release_audio: AudioStreamPlayer = $ReleaseAudio
@onready var finish_audio: AudioStreamPlayer = $FinishAudio
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var slash_effect_list: Array[Sprite2D]


func _ready() -> void:
	hide()
	for child in get_children():
		if child is Sprite2D: slash_effect_list.append(child)
	pass


func _on_kong_shu_lin_skill_2_effect_release() -> void:
	position = kong_shu_lin.position
	animation_player.play("slash")
	show()
	for slash_effect: Sprite2D in slash_effect_list:
		slash_effect.hide()
	release_audio.play()
	for slash_effect: Sprite2D in slash_effect_list:
		slash_effect.show()
		await get_tree().create_timer(0.05,false).timeout
	
	await get_tree().create_timer(1.5,false).timeout
	finish_audio.play()
	hide()
	for i in 40:
		var block_particle: AnimatedSprite2D = block_effect_scene.instantiate()
		block_particle.modulate = Color.RED
		block_particle.modulate.a = 0.5
		block_particle.position = position + Vector2(randf_range(-150,150),randf_range(-120,120)) * 2
		Stage.instance.bullets.add_child(block_particle)
	kong_shu_lin.call_deferred("add_buff")
	pass # Replace with function body.
