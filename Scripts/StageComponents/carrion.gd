extends Node2D

@onready var collision_shape_2d: CollisionShape2D = $ClickArea/CollisionShape2D
@onready var bottle_audio: AudioStreamPlayer = $BottleAudio
@onready var carrion_audio: AudioStreamPlayer = $CarrionAudio
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var click_count: int = 0


func _on_click_area_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event.is_action_pressed("click"):
		animation_player.play("shake")
		click_count += 1
		if click_count == 10:
			carrion_audio.play()
			click_count = 0
			Achievement.achieve_complete("CARRION")
	pass # Replace with function body.
