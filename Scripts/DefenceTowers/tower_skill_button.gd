extends TextureButton
class_name TowerSkillButton

@export var linked_tower:DefenceTower
@export var skill_name: String
@export var skill_id: int
@export var skill_prices: Array[int]
@export_multiline var skill_intro: PackedStringArray
@export_multiline var skill_words: String

@onready var skill_point_container: Sprite2D = $SkillPointContainer
@onready var skill_point_1: Sprite2D = $SkillPointContainer/SkillPoint1
@onready var skill_point_container_2: Sprite2D = $SkillPointContainer2
@onready var skill_point_2: Sprite2D = $SkillPointContainer2/SkillPoint2
@onready var skill_point_container_3: Sprite2D = $SkillPointContainer3
@onready var skill_point_3: Sprite2D = $SkillPointContainer3/SkillPoint3
@onready var panel: Panel = $Panel
@onready var price_label: Label = $Panel/PriceLabel
@onready var click_audio: AudioStreamPlayer = $ClickAudio

var gray_disabled_texture: Texture


func update_skill_level():
	var skill_level: int = linked_tower.tower_skill_levels[skill_id]
	skill_point_1.visible = skill_level >=1
	skill_point_2.visible = skill_level >= 2
	skill_point_3.visible = skill_level >= 3
	
	if skill_level >= skill_prices.size():
		panel.hide()
		texture_disabled = texture_normal
		disabled = true
		set_process(false)
	else:
		panel.show()
		price_label.text = str(skill_prices[skill_level])
		texture_disabled = gray_disabled_texture
		set_process(true)
	pass


func _ready() -> void:
	skill_prices = skill_prices.duplicate()
	if linked_tower is BombardTower:
		var level: int = clampi(Stage.instance.stage_sav.upgrade_sav[3],0,Stage.instance.limit_tech_level)
		if level >= 3:
			for i in skill_prices.size():
				skill_prices[i] = int(skill_prices[i] * 0.8)
			#print(skill_prices)
	
	gray_disabled_texture = texture_disabled
	skill_point_container_2.visible = skill_prices.size() >= 2
	skill_point_container_3.visible = skill_prices.size() >= 3
	update_skill_level()
	pass


func _process(delta: float) -> void:
	var skill_level: int = linked_tower.tower_skill_levels[skill_id]
	disabled = Stage.instance.current_money < skill_prices[skill_level]
	price_label.modulate = Color.GRAY if disabled else Color.YELLOW
	pass


func _on_mouse_entered() -> void:
	update_skill_intro()
	
	linked_tower.tower_panel_ui.show_panel(4,0)
	pass # Replace with function body.


func _on_mouse_exited() -> void:
	linked_tower.tower_panel_ui.hide_panel()
	pass # Replace with function body.


func _on_pressed() -> void:
	
	if OS.get_name() == "Android":
		if MobileMiddleProcess.instance.current_touch_object != self:
			MobileMiddleProcess.instance.current_touch_object = self
			return
	
	var skill_level: int = linked_tower.tower_skill_levels[skill_id]
	if Stage.instance.current_money < skill_prices[skill_level]: return
	
	Stage.instance.current_money -= skill_prices[skill_level]
	linked_tower.tower_skill_level_up(skill_id,skill_level+1)
	linked_tower.tower_value += skill_prices[skill_level]
	update_skill_level()
	update_skill_intro()
	click_audio.play(0.07)
	pass # Replace with function body.


func update_skill_intro():
	var skill_level: int = linked_tower.tower_skill_levels[skill_id]
	var show_level: int
	if skill_level >= skill_prices.size():
		show_level = skill_level
	else:
		show_level = skill_level+1
	
	linked_tower.tower_panel_ui.name_label.text = skill_name
	for i in show_level:
		linked_tower.tower_panel_ui.name_label.text += "I"
	linked_tower.tower_panel_ui.intro_label.text = skill_intro[show_level-1]
	linked_tower.tower_panel_ui.skill_words.text = skill_words
	pass
