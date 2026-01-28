extends SkillButton

@onready var navigation_agent: NavigationAgent2D = $NavigationComponent/NavigationAgent

var fire_rock_scene = preload("res://Scenes/Skills/fire_rock.tscn")


func _ready() -> void:
	super()
	var level: int = clampi(Stage.instance.stage_sav.upgrade_sav[4],0,Stage.instance.limit_tech_level)
	if level >= 5:
		cooling_time = 50
	pass


func skill_unlease_condition():
	if (Stage.instance.mouse_in_path or Stage.instance.mouse_in_fire_extra_area) and !Stage.instance.mouse_in_fire_stop_area:
		skill_unlease()
	pass


func skill_unlease():
	super()
	var level: int = clampi(Stage.instance.stage_sav.upgrade_sav[4],0,Stage.instance.limit_tech_level)
	var loop_count: int
	
	match level:
		0: loop_count = 3
		1,2: loop_count = 5
		3,4,5: loop_count = 6
	
	var mouse_position: Vector2 = Stage.instance.get_local_mouse_position()
	for i in loop_count:
		var fire_rock = fire_rock_scene.instantiate() as FirerainSkill
		fire_rock.skill_level = level
		var summon_pos = mouse_position + Vector2(randf_range(-20,20),randf_range(-20,20))
		fire_rock.position = summon_pos
		Stage.instance.bullets.add_child(fire_rock)
		await get_tree().create_timer(0.6,false).timeout
	if level >= 5:
		var map = navigation_agent.get_navigation_map()
		for i in 2:
			var random_point: Vector2 = NavigationServer2D.map_get_random_point(map,navigation_agent.navigation_layers,true)
			var fire_rock = fire_rock_scene.instantiate() as FirerainSkill
			fire_rock.skill_level = level
			fire_rock.position = random_point
			Stage.instance.bullets.add_child(fire_rock)
			await get_tree().create_timer(0.6,false).timeout
	pass
