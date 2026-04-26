extends PanelContainer
class_name WavePanel

@onready var information_label: Label = $MarginContainer/VBoxContainer/InformationLabel
@onready var animation_player: AnimationPlayer = $AnimationPlayer


func _enter_tree() -> void:
	modulate.a = 0
	pass


func update_wave_text(information: String):
	information_label.text = information
	pass


func show_panel():
	animation_player.speed_scale = 1
	animation_player.play("panel_animation")
	pass


func hide_panel():
	animation_player.speed_scale = -1
	animation_player.play("panel_animation")
	pass
