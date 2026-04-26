extends Area2D

@onready var kinito: Node2D = $Kinito
@onready var fuck_down_audio: AudioStreamPlayer = $FuckDownAudio
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var shadow: Sprite2D = $Shadow

var is_deleting: bool


func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event.is_action_pressed("click"):
		collision_shape_2d.disabled = true
		is_deleting = true
		fuck_down_audio.play()
		var disappear_tween: Tween = create_tween()
		disappear_tween.tween_property(self,"modulate:a",0,1.2)
		shadow.hide()
		await disappear_tween.finished
		Achievement.achieve_complete("kinito_pet")
		create_tween().tween_property(fuck_down_audio,"volume_db",-200,0.5)
	pass # Replace with function body.


func _process(delta: float) -> void:
	if is_deleting:
		kinito.scale = Vector2(randf_range(0.4,5),randf_range(0.2,3))
	pass
