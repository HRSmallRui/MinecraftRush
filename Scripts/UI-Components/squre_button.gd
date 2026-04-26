extends TextureButton

@onready var click_audio: AudioStreamPlayer = $ClickAudio


func _on_pressed() -> void:
	click_audio.play(0.2)
	pass # Replace with function body.


func _process(delta: float) -> void:
	if get_draw_mode() == Button.DrawMode.DRAW_PRESSED:
		self_modulate = Color.GREEN
	else:
		self_modulate = Color.WHITE
	pass
