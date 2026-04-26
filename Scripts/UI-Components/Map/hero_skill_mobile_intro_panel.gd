extends PanelContainer
class_name HeroSkillMobileIntroPanel

@onready var skill_name_label: Label = $MarginContainer/VBoxContainer/SkillNameLabel
@onready var skill_intro_label: Label = $MarginContainer/VBoxContainer/SkillIntroLabel
@onready var black_delta_1: Sprite2D = $BlackDelta1
@onready var black_delta_2: Sprite2D = $BlackDelta2
@onready var black_delta_3: Sprite2D = $BlackDelta3
@onready var black_delta_4: Sprite2D = $BlackDelta4
@onready var black_delta_5: Sprite2D = $BlackDelta5

static var instance: HeroSkillMobileIntroPanel


func _init() -> void:
	instance = self
	pass


func _ready() -> void:
	hide()
	if OS.get_name() == "Windows":
		modulate.a = 0
	pass


func show_skill_information(check_button: HeroSkillButton):
	show()
	show_panel(check_button.skill_id,check_button.skill_level)
	black_delta_1.visible = check_button.skill_id == 1
	black_delta_2.visible = check_button.skill_id == 2
	black_delta_3.visible = check_button.skill_id == 3
	black_delta_4.visible = check_button.skill_id == 4
	black_delta_5.visible = check_button.skill_id == 5
	pass


func show_panel(skill_id: int, show_level: int):
	#print(show_level)
	skill_name_label.text = HeroHall.instance.hero_skill_intro_list[skill_id-1].skill_name
	for i in clampi(show_level+1,1,3):
		skill_name_label.text += "I"
	skill_intro_label.text = HeroHall.instance.hero_skill_intro_list[skill_id-1].skill_intro[clampi(show_level,0,2)]
	pass
