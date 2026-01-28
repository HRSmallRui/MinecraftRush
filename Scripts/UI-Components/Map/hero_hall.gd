extends Control
class_name HeroHall

signal update_hero(hero_id: int)
signal update_hero_skills
signal select_hero(hero_id: int)

@export var hero_property_block_list: Array[HeroPropertyBlock]

@onready var hero_head_textures: Panel = $HeroHeadTextures
@onready var hero_texture: TextureRect = $HeroTexture
@onready var hero_animation_player: AnimationPlayer = $HeroAnimationPlayer
@onready var level_progress_bar: TextureProgressBar = $PropertyPanel/LevelProgressBar
@onready var level_label: Label = $PropertyPanel/LevelBall/LevelLabel
@onready var skill_point_label: Label = $IntroPanel/PointPanel/SkillPointLabel
@onready var subtitle_label: Label = $PropertyPanel/NamePanel/SubtitleLabel
@onready var hero_name_label: Label = $IntroPanel/HeroNameLabel
@onready var intro_label: Label = $IntroPanel/IntroLabel
@onready var health_label: Label = $PropertyPanel/PropertyPanel/MarginContainer/Properties/Health/Panel/Label
@onready var damage_label: Label = $PropertyPanel/PropertyPanel/MarginContainer/Properties/Damage/Panel/Label
@onready var armor_label: Label = $PropertyPanel/PropertyPanel/MarginContainer/Properties/Armor/Panel/Label
@onready var cd_label: Label = $PropertyPanel/PropertyPanel/MarginContainer/Properties/CD/Panel/Label
@onready var skill_intro_panel: PanelContainer = $SkillIntroPanel
@onready var skill_name_label: Label = $SkillIntroPanel/MarginContainer/VBoxContainer/SkillNameLabel
@onready var skill_intro_label: Label = $SkillIntroPanel/MarginContainer/VBoxContainer/SkillIntroLabel
@onready var select_button: TextureButton = $SelectButton
@onready var select_audio: AudioStreamPlayer = $SelectAudio
@onready var level_up_button: TextureButton = $PropertyPanel/LevelUpButton

var current_check: int
var can_control: bool
var hero_skill_intro_list: Array[HeroSkillTextBlock]
var current_skill_points: int
var skill_levels: Array[int] = [0,0,0,0,0]
static var instance: HeroHall


func _init() -> void:
	instance = self
	pass


func _ready() -> void:
	if OS.get_name() == "Android":
		skill_intro_panel.modulate.a = 0
	
	change_hero(Map.instance.current_sav.select_hero_id)
	await $EntryAnimationPlayer.animation_finished
	can_control = true
	update_hero_skills.connect(update_skills)
	pass


func change_hero(hero_id: int):
	MobileMiddleProcess.instance.current_touch_object = null
	
	current_check = hero_id
	$HeroAnimationPlayer.stop()
	hero_animation_player.play("change")
	var hero_sav_block = Map.instance.current_sav.hero_sav[hero_id] as HeroSavBlock
	current_skill_points = hero_sav_block.current_skill_point
	skill_levels = hero_sav_block.skill_levels
	var progress_rate: float
	if hero_sav_block.hero_level == 10: progress_rate = 1
	else: progress_rate = float(hero_sav_block.hero_exp) / Hero.hero_level_xps[hero_sav_block.hero_level-1]
	create_tween().tween_property(level_progress_bar,"value",progress_rate,0.5)
	
	var property_block = hero_property_block_list[hero_id]
	subtitle_label.text = property_block.hero_subname
	hero_name_label.text = property_block.hero_name
	intro_label.text = property_block.hero_intro
	skill_point_label.text = str(current_skill_points)
	level_label.text = str(hero_sav_block.hero_level)
	var damage_texture: TextureRect = $PropertyPanel/PropertyPanel/MarginContainer/Properties/Damage/Panel/Health
	match property_block.hero_type:
		Ally.AllyGroup.Warrior:
			damage_texture.texture = load("res://Assets/Images/UI/DataUIs/damage_physics_hero.res")
		Ally.AllyGroup.Magicians:
			damage_texture.texture = load("res://Assets/Images/UI/DataUIs/damage_magic.res")
		Ally.AllyGroup.Shooters:
			damage_texture.texture = load("res://Assets/Images/UI/DataUIs/damage_bow.res")
	
	update_hero.emit(hero_id)
	
	update_health()
	update_damage()
	update_armor()
	update_speed()
	hero_texture.texture = hero_property_block_list[hero_id].hero_poster
	if hero_id == Map.instance.current_sav.select_hero_id:
		select_button.disabled = true
		select_button.button_title = "已选择"
	else:
		select_button.disabled = !Map.instance.current_sav.hero_sav[hero_id].unlocked
		select_button.button_title = "未解锁" if select_button.disabled else "选择"
	
	update_level_up_button()
	pass


func _on_finish_button_pressed() -> void:
	quit_animation()
	pass # Replace with function body.


func quit_animation():
	can_control = false
	$EntryAnimationPlayer.play("Exit")
	await $EntryAnimationPlayer.animation_finished
	Map.instance.can_control = true
	queue_free()
	pass


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("escape") and can_control:
		quit_animation()
	pass


func update_health():
	var hero_level = Map.instance.current_sav.hero_sav[current_check].hero_level
	var max_health: int = hero_property_block_list[current_check].max_healths[hero_level-1]
	match current_check:
		0:
			if skill_levels[0] > 0: max_health += HeroSkillLibrary.hero_skill_data_library[0][1][0][skill_levels[0]-1]
	health_label.text = str(max_health)
	pass


func update_damage():
	var hero_level = Map.instance.current_sav.hero_sav[current_check].hero_level
	var damage_low: int
	var damage_high: int
	var property_block = hero_property_block_list[current_check] as HeroPropertyBlock
	if property_block.hero_type == Ally.AllyGroup.Warrior:
		damage_low = property_block.damage_nears[hero_level-1].damage_low
		damage_high = property_block.damage_nears[hero_level-1].damage_high
	else:
		damage_low = property_block.damage_fars[hero_level-1].damage_low
		damage_high = property_block.damage_fars[hero_level-1].damage_high
	
	match current_check:
		1:
			if skill_levels[0] > 0:
				damage_low += HeroSkillLibrary.hero_skill_data_library[1][1].upgrade_damage[skill_levels[0]-1]
				damage_high += HeroSkillLibrary.hero_skill_data_library[1][1].upgrade_damage[skill_levels[0]-1]
		4:
			if skill_levels[3] > 0:
				damage_low += HeroSkillLibrary.hero_skill_data_library[4][4].upgrade_damage[skill_levels[3]-1]
				damage_high += HeroSkillLibrary.hero_skill_data_library[4][4].upgrade_damage[skill_levels[3]-1]
	
	damage_label.text = str(damage_low) + " - " + str(damage_high)
	pass


func update_armor():
	var hero_level = Map.instance.current_sav.hero_sav[current_check].hero_level
	var property_block = hero_property_block_list[current_check] as HeroPropertyBlock
	var armor: float = property_block.armors[hero_level-1]
	armor_label.text = DataProcess.defence_to_string(armor)
	pass


func update_speed():
	var attack_speed: float
	var property_block = hero_property_block_list[current_check] as HeroPropertyBlock
	if property_block.hero_type == Ally.AllyGroup.Warrior:
		attack_speed = property_block.damage_near_speed
	else:
		attack_speed = property_block.damage_far_speed
	
	cd_label.text = DataProcess.attack_speed_to_string(attack_speed)
	pass


func show_panel(skill_id: int, show_level: int):
	skill_intro_panel.show()
	skill_name_label.text = hero_skill_intro_list[skill_id-1].skill_name
	for i in show_level:
		skill_name_label.text += "I"
	skill_intro_label.text = hero_skill_intro_list[skill_id-1].skill_intro[show_level-1]
	pass


func hide_panel():
	skill_intro_panel.hide()
	pass


func update_skills():
	var sav_block: HeroSavBlock = Map.instance.current_sav.hero_sav[current_check]
	current_skill_points = sav_block.current_skill_point
	skill_point_label.text = str(current_skill_points)
	update_health()
	update_damage()
	update_armor()
	update_speed()
	pass


func _on_reset_button_pressed() -> void:
	var sav_block: HeroSavBlock = Map.instance.current_sav.hero_sav[current_check]
	sav_block.skill_levels = [0,0,0,0,0]
	sav_block.current_skill_point = (sav_block.hero_level-1) * 4
	skill_levels = sav_block.skill_levels
	current_skill_points = sav_block.current_skill_point
	skill_point_label.text = str(current_skill_points)
	Global.sav_game_sav(Map.instance.current_sav)
	update_hero_skills.emit()
	pass # Replace with function body.


func _on_select_button_pressed() -> void:
	select_hero.emit(current_check)
	select_audio.play()
	select_button.disabled = true
	select_button.button_title = "已选择"
	Map.instance.current_sav.select_hero_id = current_check
	Global.sav_game_sav(Map.instance.current_sav)
	Map.instance.update_hero_hall()
	$AnimationPlayer.play("change")
	pass # Replace with function body.


func _on_level_up_button_pressed() -> void:
	select_audio.play()
	var hero_sav: HeroSavBlock = Map.instance.current_sav.hero_sav[current_check]
	hero_sav.hero_level += 1
	hero_sav.current_skill_point += 4
	change_hero(current_check)
	pass # Replace with function body.


func update_level_up_button():
	var limit_level: int
	level_up_button.disabled = true
	level_up_button.modulate.a = 0.4
	if !Map.instance.current_sav.hero_sav[current_check].unlocked:
		return
	var level_sav: Dictionary = Map.instance.current_sav.level_sav
	if level_sav.has(5): limit_level = 5
	if level_sav.has(8): limit_level = 7
	if level_sav.has(12): limit_level = 10
	
	if Map.instance.current_sav.hero_sav[current_check].hero_level < limit_level:
		level_up_button.disabled = false
		level_up_button.modulate.a = 1
	pass
