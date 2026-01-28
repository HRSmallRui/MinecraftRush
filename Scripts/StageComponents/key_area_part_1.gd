extends Area2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var label: Label = $CanvasLayer/Label


func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event.is_action_pressed("click") and label.visible_ratio == 0:
		animation_player.play("show_word")
		await animation_player.animation_finished
		await get_tree().create_timer(1,false).timeout
		label.visible_ratio = 0
	pass # Replace with function body.
