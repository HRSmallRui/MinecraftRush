extends ShooterBullet


func enemy_take_damage(enemy: Enemy):
	super(enemy)
	var alex_lighting_area: SkillConditionArea2D = preload("res://Scenes/Skills/alex_lighting_area.tscn").instantiate()
	alex_lighting_area.skill_level = special_skill_level
	alex_lighting_area.position = enemy.position
	Stage.instance.add_child(alex_lighting_area)
	pass
