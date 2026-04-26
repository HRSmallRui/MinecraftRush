extends Area2D

@onready var nose_audio: AudioStreamPlayer = $NoseAudio

var click_count: int = 0
var click_disabled: bool = false


func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event.is_action_pressed("click"):
		if click_count == 10:
			click_disabled = true
			Achievement.achieve_complete("Freddy")
		if !click_disabled:
			nose_audio.play()
			click_count += 1
	pass # Replace with function body.
