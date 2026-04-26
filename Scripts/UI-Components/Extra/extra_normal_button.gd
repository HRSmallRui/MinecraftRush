extends Button

@export var light: Light2D


func _ready() -> void:
	mouse_entered.connect(on_mouse_enter)
	mouse_exited.connect(on_mouse_out)
	light.hide()
	pass


func on_mouse_enter():
	light.show()
	pass


func on_mouse_out():
	light.hide()
	pass
