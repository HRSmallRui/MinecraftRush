extends Button

@export var tag_type: ExtraBookUI.ExtraBookTag

@onready var text_label: Label = $TextLabel


func _on_book_ui_update_tag_list(tag: ExtraBookUI.ExtraBookTag) -> void:
	text_label.modulate = Color.AQUA if tag == tag_type else Color.WHITE
	pass # Replace with function body.


func _on_pressed() -> void:
	ExtraBookUI.instance.update_tag_list.emit(tag_type)
	pass # Replace with function body.


func _ready() -> void:
	ExtraBookUI.instance.update_tag_list.connect(_on_book_ui_update_tag_list)
	pass
