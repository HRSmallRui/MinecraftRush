extends Sprite2D
class_name StopCursor

@onready var animation_player: AnimationPlayer = $AnimationPlayer


func stop():
	show()
	$AnimationPlayer.stop()
	$AnimationPlayer.play("stop")
	pass


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	hide()
	pass # Replace with function body.
