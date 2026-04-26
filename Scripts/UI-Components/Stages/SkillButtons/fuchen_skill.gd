extends SkillButton


func skill_unlease_condition():
	if Stage.instance.mouse_in_path and !Stage.instance.mouse_in_fire_stop_area:
		skill_unlease()
	pass


func skill_unlease():
	super()
	var level: int = Stage.instance.stage_sav.hero_sav[1].skill_levels[4]
	var count: int = HeroSkillLibrary.hero_skill_data_library[1][5].count[level]
	var mouse_position: Vector2 = Stage.instance.get_local_mouse_position()
	for i in count:
		await get_tree().create_timer(0.2,false).timeout
		var ray: Area2D = preload("res://Scenes/Skills/fuchen_destroy_rat_area.tscn").instantiate()
		ray.position = random_position(mouse_position)
		Stage.instance.bullets.add_child(ray)
	pass


func random_position(center_pos: Vector2) -> Vector2:
	return center_pos + Vector2(randf_range(-50,50),randf_range(-50,50))
	pass
