extends SkillButton

@export var release_scene: PackedScene

var skill_level: int


func _ready() -> void:
	super()
	skill_level = Stage.instance.stage_sav.hero_sav[5].skill_levels[4]
	pass


func skill_unlease():
	super()
	var summon_pos: Vector2 = Stage.instance.get_local_mouse_position()
	var release_area: SkillConditionArea2D = release_scene.instantiate()
	release_area.position = summon_pos
	release_area.skill_level = skill_level
	Stage.instance.bullets.add_child(release_area)
	pass
