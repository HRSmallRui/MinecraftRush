extends Control

enum TagType{
	Towers,
	Enemies
}

@export var tag_type: TagType

@onready var tag_button: TextureButton = $TagButton
@onready var tag_label: Label = $TagLabel
@onready var seen_book_ui: SeenBookUI = $".."


func _ready() -> void:
	seen_book_ui.update.connect(update)
	pass


func _process(delta: float) -> void:
	if tag_button.get_draw_mode() == Button.DrawMode.DRAW_NORMAL or tag_button.get_draw_mode() == Button.DrawMode.DRAW_PRESSED:
		tag_button.modulate = Color.WHITE
		tag_label.modulate = Color.BLACK
	elif tag_button.get_draw_mode() == Button.DrawMode.DRAW_HOVER:
		tag_button.modulate = Color.WHITE * 1.5
		tag_label.modulate = Color.BLUE if tag_type == TagType.Towers else Color.RED
	elif tag_button.get_draw_mode() == Button.DrawMode.DRAW_DISABLED:
		tag_button.modulate = Color.WHITE
		tag_label.modulate = Color.WHITE
	pass


func _on_tag_button_pressed() -> void:
	if tag_type == TagType.Towers: seen_book_ui.change_check_id(SeenBookUI.CheckType.Archers,0)
	else: seen_book_ui.change_check_id(SeenBookUI.CheckType.Enemies,0)
	$ChangeAudio.play()
	pass # Replace with function body.


func update(check_type,check_id):
	if tag_type == TagType.Towers:
		tag_button.disabled = check_type < 4
	else:
		tag_button.disabled = check_type == 4
	pass
