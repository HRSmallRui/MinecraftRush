@tool
extends TextureButton

@export var button_title: String = "开始"

@onready var button_title_label: Label = $ButtonTitleLabel
@onready var click_audio: AudioStreamPlayer = $ClickAudio


func _ready() -> void:
	if OS.get_name() == "Android":
		texture_hover = texture_normal
	pass


func _process(delta: float) -> void:
	if get_draw_mode() == DrawMode.DRAW_NORMAL:
		button_title_label.modulate = Color.WHITE
	elif get_draw_mode() == DrawMode.DRAW_HOVER:
		button_title_label.modulate = Color.YELLOW
	elif get_draw_mode() == DrawMode.DRAW_DISABLED:
		button_title_label.modulate = Color.GRAY
	elif get_draw_mode() == DrawMode.DRAW_PRESSED:
		button_title_label.modulate = Color.WHITE
	
	button_title_label.text = button_title
	pass


func _on_pressed() -> void:
	click_audio.play(0.2)
	pass # Replace with function body.
