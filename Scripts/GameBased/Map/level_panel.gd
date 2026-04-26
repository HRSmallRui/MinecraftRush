extends Panel

@onready var name_label: Label = $Label
@onready var intro_label: Label = $Intro


func _ready() -> void:
	hide()
	pass


func _process(delta: float) -> void:
	position = get_global_mouse_position()
	position.x += 20 if get_global_mouse_position().x < 960 else -280
	position.y += 20 if get_global_mouse_position().y < 540 else -150
	pass


func update_status(area_name:String,area_color: Color,area_intro: String):
	name_label.text = area_name
	name_label.modulate = area_color
	intro_label.text = area_intro
	pass
