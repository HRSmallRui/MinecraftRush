extends Area2D

enum CrayonColor{
	Yellow,
	Blue,
	Red
}

@export var crayon_color: CrayonColor

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var pick_crayon_audio: AudioStreamPlayer = $PickCrayonAudio
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D


func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event.is_action_pressed("click"):
		pick_crayon_audio.play(0.08)
		collision_shape_2d.disabled = true
		create_tween().tween_property(self,"modulate:a",0,0.5)
		var keywords: String = "Crayon"
		match crayon_color:
			CrayonColor.Yellow:
				keywords += "Yellow"
			CrayonColor.Blue:
				keywords += "Blue"
			CrayonColor.Red:
				keywords += "Red"
		Achievement.add_achieve_temp_value(keywords)
		var temp: Array = Achievement.get_achieve_temp()
		if temp.has("CrayonYellow") and temp.has("CrayonBlue") and temp.has("CrayonRed"):
			Achievement.achieve_complete("Primary")
	pass # Replace with function body.
