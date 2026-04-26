extends Control
class_name ExtraBookUI

signal update(content: String)
signal update_tag_list(tag: ExtraBookTag)

enum ExtraBookTag{
	Areas,
	Arts,
	Countries,
	Families,
	Others
}

static var instance: ExtraBookUI

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var title_label: Label = $HBoxContainer/IntroPanel/VBoxContainer/TitleLabel
@onready var content_label: Label = $HBoxContainer/IntroPanel/VBoxContainer/ContentScrollContainer/ContentLabel
@onready var content_scroll_container: ScrollContainer = $HBoxContainer/IntroPanel/VBoxContainer/ContentScrollContainer
@onready var show_texture: TextureRect = $HBoxContainer/IntroPanel/ShowTexture
@onready var area_slot: ScrollContainer = $HBoxContainer/TagSlot/AreaSlot
@onready var country_slot: ScrollContainer = $HBoxContainer/TagSlot/CountrySlot
@onready var family_slot: ScrollContainer = $HBoxContainer/TagSlot/FamilySlot
@onready var otehr_slot: ScrollContainer = $HBoxContainer/TagSlot/OtehrSlot
@onready var art_slot: ScrollContainer = $HBoxContainer/TagSlot/ArtSlot
@onready var back_button: Button = $BackButton


func _init() -> void:
	instance = self
	pass


func _ready() -> void:
	update.emit("野区其一")
	update_tag_list.emit(ExtraBookTag.Areas)
	pass


func _input(event: InputEvent) -> void:
	if ExtraContent.instance.can_control and event.is_action_released("escape"):
		back()
	pass


func change_content(title: String, content: String, texture_path: String,show_alpha: float):
	title_label.text = title
	content_label.text = content
	content_scroll_container.scroll_vertical = 0
	if texture_path != "":
		show_texture.texture = load(texture_path)
	else:
		show_texture.texture = null
	show_texture.modulate.a = show_alpha
	update.emit(title)
	pass


func _on_update_tag_list(tag: ExtraBookUI.ExtraBookTag) -> void:
	area_slot.visible = tag == ExtraBookTag.Areas
	country_slot.visible = tag == ExtraBookTag.Countries
	family_slot.visible = tag == ExtraBookTag.Families
	otehr_slot.visible = tag == ExtraBookTag.Others
	art_slot.visible = tag == ExtraBookTag.Arts
	pass # Replace with function body.


func _on_back_button_pressed() -> void:
	back()
	ExtraContent.instance.back()
	back_button.mouse_filter = Control.MOUSE_FILTER_IGNORE
	pass # Replace with function body.


func back():
	animation_player.play_backwards("appear")
	await animation_player.animation_finished
	queue_free()
	pass
