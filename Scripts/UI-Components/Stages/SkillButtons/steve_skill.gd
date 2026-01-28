extends SkillButton


func skill_unlease():
	super()
	var level: int = Stage.instance.stage_sav.hero_sav[0].skill_levels[4]
	var count: int = HeroSkillLibrary.hero_skill_data_library[0][5][0][level]
	var mouse_position: Vector2 = Stage.instance.get_local_mouse_position()
	for i in count:
		var buff_potion: Area2D = preload("res://Scenes/Skills/steve_buff_potion.tscn").instantiate()
		var debuff_potion: Area2D = preload("res://Scenes/Skills/steve_debuff_potion.tscn").instantiate()
		buff_potion.position = random_position(mouse_position)
		debuff_potion.position = random_position(mouse_position)
		Stage.instance.bullets.add_child(buff_potion)
		await get_tree().create_timer(0.2,false).timeout
		Stage.instance.bullets.add_child(debuff_potion)
		await get_tree().create_timer(0.2,false).timeout
	pass


func random_position(center_pos: Vector2) -> Vector2:
	return center_pos + Vector2(randf_range(-25,25),randf_range(-18,18))
	pass
