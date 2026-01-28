extends Node2D


@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var move_audio: AudioStreamPlayer = $MoveAudio
@onready var click_area: Area2D = $ClickArea


func _on_click_area_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event.is_action_pressed("click"):
		animation_player.play("leave")
		click_area.hide()
		Achievement.achieve_complete("Remilia")
	pass # Replace with function body.
