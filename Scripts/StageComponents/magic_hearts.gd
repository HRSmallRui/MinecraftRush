extends Node2D

var click_count: int
@onready var magic_audio: AudioStreamPlayer = $MagicAudio


func _on_magic_heart_click_area_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event.is_action_pressed("click"):
		var anim_player: AnimationPlayer = $MagicHeartClickArea/AnimationPlayer
		var shape: CollisionShape2D = $MagicHeartClickArea/CollisionShape2D
		anim_player.play("disappear")
		shape.disabled = true
		click_count += 1
		magic_audio.play()
		if click_count == 3:
			await get_tree().create_timer(0.8,false).timeout
			Achievement.achieve_complete("PrayEvil")
	pass # Replace with function body.


func _on_magic_heart_click_area_2_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event.is_action_pressed("click"):
		var anim_player: AnimationPlayer = $MagicHeartClickArea2/AnimationPlayer
		var shape: CollisionShape2D = $MagicHeartClickArea2/CollisionShape2D
		anim_player.play("disappear")
		shape.disabled = true
		click_count += 1
		magic_audio.play()
		if click_count == 3:
			await get_tree().create_timer(0.8,false).timeout
			Achievement.achieve_complete("PrayEvil")
	pass # Replace with function body.


func _on_magic_heart_click_area_3_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event.is_action_pressed("click"):
		var anim_player: AnimationPlayer = $MagicHeartClickArea3/AnimationPlayer
		var shape: CollisionShape2D = $MagicHeartClickArea3/CollisionShape2D
		anim_player.play("disappear")
		shape.disabled = true
		click_count += 1
		magic_audio.play()
		if click_count == 3:
			await get_tree().create_timer(0.8,false).timeout
			Achievement.achieve_complete("PrayEvil")
	pass # Replace with function body.
