extends Control

@export var up_marker: Marker2D
@export var down_marker: Marker2D

@onready var up_button: TextureButton = $VBoxContainer/UpButton
@onready var down_button: TextureButton = $VBoxContainer/DownButton
@onready var into_button: Button = $IntoButton
@onready var animation_player: AnimationPlayer = $AnimationPlayer


func _ready() -> void:
	up_button.pressed.connect(on_up_button_pressed)
	down_button.pressed.connect(on_down_button_pressed)
	into_button.pressed.connect(on_into_button_pressed)
	pass


func on_into_button_pressed():
	if animation_player.is_playing(): return
	if into_button.text == "<":
		animation_player.play("entry")
	else:
		animation_player.play_backwards("entry")
	pass


func on_up_button_pressed():
	Stage.instance.stage_camera.position = up_marker.global_position
	pass


func on_down_button_pressed():
	Stage.instance.stage_camera.position = down_marker.global_position
	pass
