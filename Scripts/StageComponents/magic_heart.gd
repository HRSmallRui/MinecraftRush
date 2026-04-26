extends Node2D

@onready var animation_player: AnimationPlayer = $MagicHeartClickArea/AnimationPlayer
@onready var animation_player_2: AnimationPlayer = $MagicHeartClickArea2/AnimationPlayer2

var click_count: int


func _on_magic_heart_click_area_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event.is_action_pressed("click") and !animation_player.is_playing():
		animation_player.play("green")
		click_count += 1
		await animation_player.animation_finished
		if click_count >= 2:
			on_complete()
	pass # Replace with function body.


func _on_magic_heart_click_area_2_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event.is_action_pressed("click") and !animation_player_2.is_playing():
		animation_player_2.play("green")
		click_count += 1
		await animation_player_2.animation_finished
		if click_count >= 2:
			on_complete()
	pass # Replace with function body.


func on_complete():
	Achievement.achieve_complete("PrayGame2")
	pass
