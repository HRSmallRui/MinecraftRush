extends Sprite2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var kabi_button: Button = $KabiButton


func _ready() -> void:
	kabi_button.pressed.connect(button_pressed)
	pass


func button_pressed():
	animation_player.play("KabiAnimation")
	pass
