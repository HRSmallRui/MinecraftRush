extends Node2D
class_name MapPath

signal path_animation_finished

@export var end_level: int


func _ready() -> void:
	hide()
	await get_tree().process_frame
	if end_level in Map.instance.current_sav.level_sav:
		show()
		if !Map.instance.current_sav.level_sav[end_level][0]:
			for sprite: Sprite2D in get_children():
				sprite.hide()
	pass


func need_to_play_show_animation() -> bool:
	if !end_level in Map.instance.current_sav.level_sav:
		return false
	var level_is_hidden: bool = Map.instance.current_sav.level_sav[end_level][0]
	return !level_is_hidden
	pass


func path_animation_play():
	for sprite: Sprite2D in get_children():
		sprite.show()
		Map.instance.path_audio.play()
		await get_tree().create_timer(0.3).timeout
	
	path_animation_finished.emit()
	pass
