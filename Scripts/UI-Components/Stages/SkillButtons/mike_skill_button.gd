extends SkillButton

enum SkillElements{
	FIRE,
	WATER,
	EARTH,
	WIND
}

@export var skill_name_list: PackedStringArray
@export_multiline var skill_intro_list: PackedStringArray
@export var normal_texture_list: Array[Texture]
@export var hover_texture_list: Array[Texture]

var current_element: SkillElements
var level: int


func _ready() -> void:
	super()
	level = Stage.instance.stage_sav.hero_sav[9].skill_levels[4]
	skill_name = skill_name_list[current_element]
	skill_intro = skill_intro_list[current_element]
	texture_normal = normal_texture_list[current_element]
	texture_select = hover_texture_list[current_element]
	pass


func skill_unlease():
	super()
	if current_element == SkillElements.FIRE:
		release_fire()
	elif current_element == SkillElements.WATER:
		release_water()
	elif current_element == SkillElements.EARTH:
		release_earth()
	elif current_element == SkillElements.WIND:
		release_wind()
	var hero: Hero = Stage.instance.hero_list[0]
	hero.call_deferred("into_power_type")
	change_animation()
	pass


func change_animation():
	animation_player.play_backwards("unlock")
	await animation_player.animation_finished
	change_element()
	animation_player.play("unlock")
	pass


func change_element():
	if current_element == SkillElements.WIND:
		current_element = SkillElements.FIRE
	else:
		current_element += 1
	skill_name = skill_name_list[current_element]
	skill_intro = skill_intro_list[current_element]
	texture_normal = normal_texture_list[current_element]
	texture_select = hover_texture_list[current_element]
	normal_texture.texture = texture_normal
	hover_texture.texture = texture_select
	pass


func release_fire():
	var mouse_pos: Vector2 = Stage.instance.get_local_mouse_position()
	var fire_count: int = HeroSkillLibrary.hero_skill_data_library[9][5].fire_count[level]
	for i in fire_count:
		var fire_rock: Area2D = preload("res://Scenes/Skills/mike_fire_skill_area.tscn").instantiate()
		fire_rock.position = mouse_pos
		fire_rock.position += Vector2(randf_range(-40,40),randf_range(-28,28))
		Stage.instance.bullets.add_child(fire_rock)
		await get_tree().create_timer(0.5,false).timeout
	pass


func release_water():
	var mouse_pos: Vector2 = Stage.instance.get_local_mouse_position()
	var water_area: SkillConditionArea2D = preload("res://Scenes/Skills/mike_water_area.tscn").instantiate()
	water_area.skill_level = level
	water_area.position = mouse_pos
	Stage.instance.bullets.add_child(water_area)
	pass


func release_earth():
	var mouse_pos: Vector2 = Stage.instance.get_local_mouse_position()
	var count: int = HeroSkillLibrary.hero_skill_data_library[9][5].earth_count[level]
	for i in count:
		var earth_area: Area2D = preload("res://Scenes/Skills/mike_earth_area.tscn").instantiate()
		earth_area.position = mouse_pos
		earth_area.position += Vector2(randf_range(-40,40),randf_range(-28,28))
		Stage.instance.bullets.add_child(earth_area)
		await get_tree().create_timer(1,false).timeout
	pass


func release_wind():
	var mouse_pos: Vector2 = Stage.instance.get_local_mouse_position()
	var wind_area: SkillConditionArea2D = preload("res://Scenes/Skills/mike_wind_area.tscn").instantiate()
	wind_area.position = mouse_pos
	wind_area.skill_level = level
	Stage.instance.bullets.add_child(wind_area)
	pass
