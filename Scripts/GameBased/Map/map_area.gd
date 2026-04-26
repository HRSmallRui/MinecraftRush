extends Area2D
class_name MapArea

@export var area_text_color: Color = Color.WHITE
@export var unlocked_level: int
@export var area_name: String
@export_multiline var area_intro: String

@onready var main_map: Map = $"../../.."


func show_panel():
	await get_tree().process_frame
	if main_map.current_sav.level_sav.has(unlocked_level) and main_map.current_sav.level_sav[unlocked_level][1] >= 1:
		main_map.show_panel(area_name,area_text_color,area_intro)
	else:
		main_map.show_panel("？？？？",Color.WHITE,"未知区域")
	pass


func hide_panel():
	main_map.hide_panel()
	pass


func _ready() -> void:
	mouse_entered.connect(show_panel)
	mouse_exited.connect(hide_panel)
	pass
