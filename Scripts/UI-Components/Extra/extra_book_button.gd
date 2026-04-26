extends Button

@export var book_config: ExtraBookConfig

@onready var text_label: Label = $TextLabel


func on_update(content_title: String):
	text_label.modulate = Color.AQUA if content_title == book_config.title else Color.WHITE
	pass


func _ready() -> void:
	text_label.text = book_config.title
	ExtraBookUI.instance.update.connect(on_update)
	pass


func _pressed() -> void:
	ExtraBookUI.instance.change_content(book_config.title,book_config.content,book_config.background_texture_path,book_config.texture_alpha)
	pass
