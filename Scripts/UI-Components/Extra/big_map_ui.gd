extends Control
class_name BigMapUI

@onready var back_button: Button = $BackButton
@onready var animation_player: AnimationPlayer = $AnimationPlayer


func _on_back_button_pressed() -> void:
	back()
	ExtraContent.instance.back()
	back_button.mouse_filter = Control.MOUSE_FILTER_IGNORE
	pass # Replace with function body.


func back():
	animation_player.play_backwards("appear")
	await animation_player.animation_finished
	queue_free()
	pass


func _input(event: InputEvent) -> void:
	if ExtraContent.instance.can_control and event.is_action_released("escape"):
		back()
	pass
