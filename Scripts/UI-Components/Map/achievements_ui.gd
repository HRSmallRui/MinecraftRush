extends Control
class_name AchievementUI

var can_control: bool = false


func _ready() -> void:
	await $AnimationPlayer.animation_finished
	can_control = true
	pass


func _on_exit_button_pressed() -> void:
	$AnimationPlayer.play("Exit")
	await $AnimationPlayer.animation_finished
	queue_free()
	Map.instance.can_control = true
	pass # Replace with function body.


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("escape") and can_control:
		_on_exit_button_pressed()
	pass
