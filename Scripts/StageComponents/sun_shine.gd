extends Node2D


@onready var emoji_music: AudioStreamPlayer = $EmojiMusic
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var click_area: Area2D = $ClickArea


func _on_click_area_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event.is_action_pressed("click"):
		Achievement.achieve_complete("SunAchieve")
		click_area.hide()
		emoji_music.play()
		animation_player.play("start")
		await animation_player.animation_finished
		animation_player.play("loop")
		await get_tree().create_timer(8,false).timeout
		create_tween().tween_property(emoji_music,"volume_db",-30,6)
	pass # Replace with function body.
