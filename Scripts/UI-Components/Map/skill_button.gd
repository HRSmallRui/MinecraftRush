extends TextureButton
class_name UpgradeButton

enum SkillType{
	Archer,
	Barrack,
	Magic,
	Bombard,
	Firerain,
	Reinforce
}

@export var skill_type: SkillType
@export var skill_level: int = 1

@onready var light: Sprite2D = $Light
@onready var bar: Panel = $Bar
@onready var star: Sprite2D = $Bar/Star
@onready var price_label: Label = $Bar/PriceLabel
@onready var upgrade_ui: UpgradeUI = $"../../.."

var price: int
var normal_star_texture = load("res://Assets/Images/UI/nether-star.png") as Texture
var disabled_star_texture = load("res://Assets/Images/UI/nether-star-no.png") as Texture

var normal_texture: Texture
var disabled_texture: Texture


func _ready() -> void:
	normal_texture = texture_normal
	disabled_texture = texture_disabled
	
	price = UpgradeLibrary.skill_prices[skill_type][skill_level-1]
	price_label.text = str(price)
	upgrade_ui.update.connect(update)
	if OS.get_name() == "Android":
		texture_hover = null
		texture_pressed = null
	pass


func _on_mouse_entered() -> void:
	upgrade_ui.show_panel(skill_type,skill_level)
	pass # Replace with function body.


func _on_mouse_exited() -> void:
	upgrade_ui.hide_panel()
	pass # Replace with function body.


func _process(delta: float) -> void:
	if OS.get_name() == "Android":
		return
	if get_draw_mode() == DrawMode.DRAW_HOVER:
		self_modulate = Color.WHITE if light.visible else Color.WHITE * 1.5
	else:
		self_modulate = Color.WHITE
	pass


func update():
	
	if OS.get_name() == "Android":
		var type_level = upgrade_ui.tech_levels[skill_type]
		var no: bool = skill_level - type_level > 1 or (upgrade_ui.can_use_stars < price and type_level < skill_level)
		texture_normal = disabled_texture if no else normal_texture
		light.visible = type_level >= skill_level
		bar.visible = !light.visible
		price_label.modulate = Color.GRAY if no else Color.YELLOW
		star.texture = disabled_star_texture if no else normal_star_texture
		return
	
	var type_level = upgrade_ui.tech_levels[skill_type]
	light.visible = type_level >= skill_level
	disabled = skill_level - type_level > 1 or (upgrade_ui.can_use_stars < price and type_level < skill_level)
	bar.visible = !light.visible
	price_label.modulate = Color.GRAY if disabled else Color.YELLOW
	star.texture = disabled_star_texture if disabled else normal_star_texture
	pass


func _pressed() -> void:
	if OS.get_name() == "Android":
		UpgradeUIMobile.instance.check_button = self
		UpgradeUIMobile.instance.update_check_information()
		return
	
	if light.visible: return
	upgrade_ui.level_up(skill_type,skill_level,price)
	pass
