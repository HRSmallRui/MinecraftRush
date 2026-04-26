extends Control
class_name UpgradeUIMobile

@export var upgrade_ui: UpgradeUI
@export var start_button: UpgradeButton

var check_button: UpgradeButton
static var instance: UpgradeUIMobile

@onready var button_level_up: TextureButton = $ButtonLevelUp
@onready var skill_sprite: Sprite2D = $SkillSprite
@onready var price_label: Label = $PriceLabel
@onready var name_label: Label = $NameLabel
@onready var intro_label: Label = $IntroLabel
@onready var check_pos: Control = $CheckPos


func _init() -> void:
	instance = self
	pass


func _ready() -> void:
	await get_tree().process_frame
	check_button = start_button
	update_check_information()
	upgrade_ui.update.connect(on_update)
	pass


func _on_button_level_up_pressed() -> void:
	upgrade_ui.level_up(check_button.skill_type,check_button.skill_level,check_button.price)
	if check_button.skill_level < 5:
		var new_button: UpgradeButton = check_button.get_parent().get_child(check_button.skill_level)
		check_button = new_button
		update_check_information()
	pass # Replace with function body.


func update_check_information():
	check_pos.position = check_button.global_position
	skill_sprite.texture = check_button.texture_normal
	price_label.text = str(check_button.price)
	name_label.text = UpgradeLibrary.skill_names[check_button.skill_type][check_button.skill_level-1]
	intro_label.text = UpgradeLibrary.skill_intros[check_button.skill_type][check_button.skill_level-1]
	button_level_up.disabled = upgrade_ui.can_use_stars < check_button.price or upgrade_ui.tech_levels[check_button.skill_type] - check_button.skill_level != -1
	pass


func on_update():
	update_check_information()
	pass
