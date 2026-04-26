extends Area2D

@export_multiline var words_list: Array[String]

@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var sprite: AnimatedSprite2D = $Beggar/Sprite
@onready var poster: Sprite2D = $Poster
@onready var dialog_panel: DialogPanel = $Beggar/DialogPanel
@onready var beggar: Node2D = $Beggar
@onready var target_pos_marker: Marker2D = $TargetPosMarker
@onready var wind_audio: AudioStreamPlayer = $WindAudio


func _ready() -> void:
	sprite.frame_changed.connect(_on_sprite_frame_changed)
	pass


func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event.is_action_pressed("click"):
		collision_shape_2d.disabled = true
		start()
	pass # Replace with function body.


func _process(delta: float) -> void:
	match sprite.animation:
		"bark":
			sprite.position = Vector2(0,-24)
		"drag":
			sprite.position = Vector2(-8,-24)
		"look":
			sprite.position = Vector2(2,-24)
		"move":
			sprite.position = Vector2(0,-24)
	pass


func _on_sprite_frame_changed() -> void:
	if sprite.animation == "drag" and sprite.frame == 16:
		poster.hide()
	pass # Replace with function body.


func start():
	var move_tween: Tween = create_tween()
	move_tween.tween_property(beggar,"global_position",target_pos_marker.global_position,3)
	await move_tween.finished
	sprite.play("look")
	await get_tree().create_timer(2.5,false).timeout
	sprite.play("drag")
	await get_tree().create_timer(2,false).timeout
	sprite.play("bark")
	await sprite.animation_finished
	for i in words_list.size():
		dialog_panel.dialog(words_list[i],3)
		await get_tree().create_timer(3,false).timeout
	var lightning: Line2D = preload("res://Scenes/Effects/lightning.tscn").instantiate()
	lightning.position = beggar.global_position
	Stage.instance.bullets.add_child(lightning)
	sprite.modulate = Color.BLACK
	Achievement.achieve_complete("sb_beggar")
	await get_tree().create_timer(2,false).timeout
	wind_audio.play()
	create_tween().tween_property(beggar,"modulate:a",0,0.6)
	pass
