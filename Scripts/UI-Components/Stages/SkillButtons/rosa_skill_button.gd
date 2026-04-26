extends SkillButton

var level: int


func _ready() -> void:
	super()
	level = Stage.instance.stage_sav.hero_sav[10].skill_levels[4]
	pass


func skill_unlease():
	super()
	var offset_possible: float = 0.95
	var locked_enemy_path: EnemyPath = Stage.instance.get_closest_main_enemy_path(Stage.instance.get_local_mouse_position())
	var current_progress: float = locked_enemy_path.curve.get_closest_offset(Stage.instance.get_local_mouse_position())
	var arrow_count: int = HeroSkillLibrary.hero_skill_data_library[10][5].arrow_count[level]
	var has_offseted: bool
	for i in arrow_count:
		var arrow_area: Area2D = preload("res://Scenes/Skills/rosa_arrow_area.tscn").instantiate()
		arrow_area.position = locked_enemy_path.curve.sample_baked(current_progress)
		if randf() < offset_possible and !has_offseted:
			var v_offset: Vector2 = locked_enemy_path.curve.sample_baked_with_rotation(current_progress).y
			v_offset *= 25 if randf() < 0.5 else -25
			arrow_area.position += v_offset
			current_progress -= 2
			has_offseted = true
		else:
			has_offseted = false
			current_progress -= 4
		Stage.instance.bullets.add_child(arrow_area)
		AudioManager.instance.shoot_audio_1.play()
		await get_tree().create_timer(0.05,false).timeout
	pass
