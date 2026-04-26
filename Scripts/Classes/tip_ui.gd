extends CanvasLayer
class_name TipUI

@export var can_control:bool = false

@onready var tip_close_audio: AudioStreamPlayer = $TipCloseAudio
@onready var color_rect: ColorRect = $ColorRect


func _ready() -> void:
	Stage.instance.ui_process(null)
	color_rect.modulate.a = 0
	get_tree().paused = true
	create_tween().tween_property(color_rect,"modulate:a",1,0.3)
	pass


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("escape") and can_control:
		close_page()
	pass


func close_page():
	tip_close_audio.play()
	$AnimationPlayer.play("Close")
	await $AnimationPlayer.animation_finished
	var new_tween: Tween = create_tween()
	new_tween.tween_property(color_rect,"modulate:a",0,0.3)
	await new_tween.finished
	queue_free()
	get_tree().paused = false
	pass


func _on_ok_button_pressed() -> void:
	close_page()
	pass # Replace with function body.
