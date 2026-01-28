extends MagicBall


func after_attack_process(unit: Node2D):
	super(unit)
	pass


func hit_effect():
	var witch_fog_area: SkillConditionArea2D = preload("res://Scenes/Skills/witch_fog.tscn").instantiate()
	witch_fog_area.skill_level = bullet_special_tag_levels["witch_fog"]
	witch_fog_area.position = position
	Stage.instance.bullets.add_child(witch_fog_area)
	pass
