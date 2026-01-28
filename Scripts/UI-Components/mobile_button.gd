extends TextureButton

@onready var click_audio: AudioStreamPlayer = $ClickAudio
@onready var label: Label = $Label


func _on_pressed() -> void:
	click_audio.play(0.2)
	pass # Replace with function body.


func _process(delta: float) -> void:
	if get_draw_mode() == Button.DrawMode.DRAW_PRESSED:
		self_modulate = Color.GREEN
		label.modulate = Color.WHITE
	elif get_draw_mode() == Button.DrawMode.DRAW_DISABLED:
		self_modulate = Color.GRAY * 0.6
		label.modulate = Color.WHITE * 0.6
	else:
		self_modulate = Color.WHITE
		label.modulate = Color.BLACK
	pass
