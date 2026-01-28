extends PanelContainer
class_name DialogPanel

@onready var dialog_label: Label = $MarginContainer/DialogLabel


func _ready() -> void:
	hide()
	pass


func dialog(dialog_text: String,existing_time: float):
	show()
	dialog_label.text = dialog_text
	dialog_label.visible_ratio = 0
	var tween_time: float = float(dialog_text.length()) / 20
	create_tween().tween_property(dialog_label,"visible_ratio",1,tween_time)
	await get_tree().create_timer(existing_time,false).timeout
	hide()
	dialog_label.visible_ratio = 0
	pass
