extends SkillButton

var level: int


func _ready() -> void:
	super()
	level = Stage.instance.stage_sav.hero_sav[2].skill_levels[4]
	pass


func skill_unlease():
	super()
	var skill_area: SkillConditionArea2D = preload("res://Scenes/Skills/alex_skill_area.tscn").instantiate()
	skill_area.skill_level = level
	skill_area.position = Stage.instance.get_local_mouse_position()
	Stage.instance.bullets.add_child(skill_area)
	pass
