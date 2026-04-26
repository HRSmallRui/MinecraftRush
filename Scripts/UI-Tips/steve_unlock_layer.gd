extends CanvasLayer

@onready var close_button: TextureButton = $CloseButton
@onready var animation_player: AnimationPlayer = $AnimationPlayer


func _ready() -> void:
	get_tree().paused = true
	pass


func _on_close_button_pressed() -> void:
	close_button.disabled = true
	var disappear_tween: Tween = create_tween()
	animation_player.play_backwards("entry")
	await animation_player.animation_finished
	queue_free()
	get_tree().paused = false
	pass # Replace with function body.
