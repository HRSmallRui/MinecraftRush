extends TextureProgressBar

enum SkillType{
	Archer,
	Barrack,
	Magic,
	Bombard,
	Firerain,
	Reinforce
}
@export var skill_type: SkillType

@onready var upgrade_ui: UpgradeUI = $"../.."

var first: bool = true


func _ready() -> void:
	upgrade_ui.update.connect(update)
	upgrade_ui.quit.connect(quit)
	pass


func update():
	if first:
		await get_tree().create_timer(0.7).timeout
		first = false
	create_tween().tween_property(self,"value",float(upgrade_ui.tech_levels[skill_type]),0.4)
	pass


func quit():
	create_tween().tween_property(self,"modulate:a",0,0.3)
	pass
