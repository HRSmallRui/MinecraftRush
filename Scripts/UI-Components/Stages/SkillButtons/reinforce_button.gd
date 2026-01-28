extends SkillButton


var reinforce_scene: PackedScene
var destroyer_scene: PackedScene


func _enter_tree() -> void:
	var level: int = clampi(Stage.instance.stage_sav.upgrade_sav[5],0,Stage.instance.limit_tech_level)
	
	match level:
		0: ResourceLoader.load_threaded_request("res://Scenes/Allys/Reinforcements/reinforcement_lv_0.tscn")
		1: ResourceLoader.load_threaded_request("res://Scenes/Allys/Reinforcements/reinforcement_lv_1.tscn")
		2: ResourceLoader.load_threaded_request("res://Scenes/Allys/Reinforcements/reinforcement_lv_2.tscn")
		3: ResourceLoader.load_threaded_request("res://Scenes/Allys/Reinforcements/reinforcement_lv_3.tscn")
		4,5: ResourceLoader.load_threaded_request("res://Scenes/Allys/Reinforcements/reinforcement_lv_4.tscn")
	
	if level == 5: ResourceLoader.load_threaded_request("res://Scenes/Allys/Reinforcements/destroyer.tscn")
	
	await get_tree().create_timer(2).timeout
	match level:
		0: reinforce_scene = load("res://Scenes/Allys/Reinforcements/reinforcement_lv_0.tscn")
		1: reinforce_scene = load("res://Scenes/Allys/Reinforcements/reinforcement_lv_1.tscn")
		2: reinforce_scene = load("res://Scenes/Allys/Reinforcements/reinforcement_lv_2.tscn")
		3: reinforce_scene = load("res://Scenes/Allys/Reinforcements/reinforcement_lv_3.tscn")
		4,5: reinforce_scene = load("res://Scenes/Allys/Reinforcements/reinforcement_lv_4.tscn")
	
	if level == 5: destroyer_scene = load("res://Scenes/Allys/Reinforcements/destroyer.tscn")
	pass


func skill_unlease():
	super()
	#var reinforce_scene: PackedScene
	var level: int = clampi(Stage.instance.stage_sav.upgrade_sav[5],0,Stage.instance.limit_tech_level)
	#match level:
		#0: reinforce_scene = load("res://Scenes/Allys/Reinforcements/reinforcement_lv_0.tscn")
		#1: reinforce_scene = load("res://Scenes/Allys/Reinforcements/reinforcement_lv_1.tscn")
		#2: reinforce_scene = load("res://Scenes/Allys/Reinforcements/reinforcement_lv_2.tscn")
		#3: reinforce_scene = load("res://Scenes/Allys/Reinforcements/reinforcement_lv_3.tscn")
		#4,5: reinforce_scene = load("res://Scenes/Allys/Reinforcements/reinforcement_lv_4.tscn")
		
	var reinforce1: Reinforcement = reinforce_scene.instantiate()
	var reinforce2: Reinforcement = reinforce_scene.instantiate()
	allocate_ally_id(reinforce1,reinforce2)
	
	reinforce1.reinforce_partners.append(reinforce2)
	reinforce2.reinforce_partners.append(reinforce1)
	var summon_pos: Vector2 = Stage.instance.get_local_mouse_position()
	reinforce1.position = summon_pos - Vector2(15,0)
	reinforce2.position = summon_pos + Vector2(15,0)
	reinforce1.station_position = reinforce1.position
	reinforce2.station_position = reinforce2.position
	Stage.instance.allys.add_child(reinforce1)
	await get_tree().create_timer(0.4,false).timeout
	Stage.instance.allys.add_child(reinforce2)
	
	var destroyer_possible: float = 1
	if level >= 5 and randf_range(0,1) < destroyer_possible:
		await get_tree().create_timer(0.4,false).timeout
		var destroyer: Reinforcement = destroyer_scene.instantiate()
		destroyer.position = summon_pos - Vector2(0,15)
		destroyer.station_position = destroyer.position
		#reinforce1.reinforce_partners.append(destroyer)
		#reinforce2.reinforce_partners.append(destroyer)
		destroyer.reinforce_partners.append(reinforce1)
		destroyer.reinforce_partners.append(reinforce2)
		Stage.instance.allys.add_child(destroyer)
	pass


func allocate_ally_id(reinforce1: Reinforcement, reinforce2: Reinforcement):
	match randi_range(1,6):
		1:
			reinforce1.ally_id = 1
			reinforce2.ally_id = 2
		2:
			reinforce1.ally_id = 1
			reinforce2.ally_id = 3
		3:
			reinforce1.ally_id = 2
			reinforce2.ally_id = 1
		4:
			reinforce1.ally_id = 2
			reinforce2.ally_id = 3
		5:
			reinforce1.ally_id = 3
			reinforce2.ally_id = 1
		6:
			reinforce1.ally_id = 3
			reinforce2.ally_id = 2
	pass
