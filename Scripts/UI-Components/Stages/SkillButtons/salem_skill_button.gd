extends SkillButton

var level: int


func _ready() -> void:
	super()
	level = Stage.instance.stage_sav.hero_sav[7].skill_levels[4]
	pass


func skill_unlease():
	super()
	var undead_knight: SummonAlly = preload("res://Scenes/Allys/SummonAllys/undead_knight.tscn").instantiate()
	undead_knight.position = Stage.instance.get_local_mouse_position()
	undead_knight.level = level+1
	Stage.instance.allys.add_child(undead_knight)
	pass
