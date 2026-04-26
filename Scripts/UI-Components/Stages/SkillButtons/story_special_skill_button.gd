extends SkillButton

@export var skill_area_scene: PackedScene


func skill_unlease():
	super()
	var summon_pos: Vector2 = Stage.instance.get_local_mouse_position()
	var hit_area: Area2D = skill_area_scene.instantiate()
	hit_area.position = summon_pos
	Stage.instance.bullets.add_child(hit_area)
	pass
