extends SkillButton

var level: int


func _ready() -> void:
	super()
	level = Stage.instance.stage_sav.hero_sav[8].skill_levels[4]
	pass

func skill_unlease():
	super()
	var johnny_area: SkillConditionArea2D = preload("res://Scenes/Skills/johnny_skill_area.tscn").instantiate()
	johnny_area.position = Stage.instance.get_local_mouse_position()
	johnny_area.skill_level = level
	Stage.instance.bullets.add_child(johnny_area)
	pass
