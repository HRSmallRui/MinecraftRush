extends Node2D
class_name Map

signal difficulty_select_finished
signal level_access_finished
signal path_animation_finished
signal show_hidden_level_finished

enum CurrentUI{
	None,
	Difficulty,
	Option,
	
}

enum LevelAnimationType{
	Campaign0_1,
	Campaign0_2,
	Campaign0_3,
	Campaign1_2,
	Campaign1_3,
	Campaign2_3,
	Campaign_Diamond,
	Campaign_Bedrock,
	Diamond_Bedrock,
	Bedrock_Diamond
}

@export var can_control: bool
@export var hero_hall_scene: PackedScene
@export var upgrade_ui_scene: PackedScene
@export var seen_book_scene: PackedScene
@export var achievement_scene: PackedScene
@export var ready_to_fight_scene: PackedScene
@export var upgrade_ui_mobile_scene: PackedScene
@export var seen_book_mobile_scene: PackedScene
@export var difficulty_selection_scene: PackedScene

@onready var level_panel: Panel = $MapUI/LevelPanel
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var flags: Node2D = $Flags
@onready var paths: Node2D = $Paths
@onready var path_audio: AudioStreamPlayer = $PathAudio
@onready var camera: Camera2D = $Camera2D
@onready var star_label: Label = $MapUI/StarPanel/StarLabel
@onready var hero_hall_head_tex: Sprite2D = $MapUI/ButtonGroups/HeroHallButton/HeadTex
@onready var button_groups: Control = $MapUI/ButtonGroups
@onready var star_panel: Panel = $MapUI/StarPanel

#var difficulty_selection: PackedScene = preload("res://Scenes/UI-Components/Map/difficulty_selection.tscn")
var current_sav: GameSaver
static var instance: Map
static var level_animation_type: LevelAnimationType
static var animation_stage_count: int = 0


func _init() -> void:
	instance = self
	current_sav = Global.get_game_sav()
	if current_sav == null:
		current_sav = GameSaver.new()
		Global.sav_game_sav(current_sav)
	pass


func _ready() -> void:
	if OS.get_name() == "Android":
		camera.zoom *= 1.5
		button_groups.scale *= 1.2
		star_panel.scale *= 1.25
	update_check()
	update_hero_hall()
	achievement_process()
	star_label.text = str(current_sav.total_stars) + " / " + str(Global.total_stars)
	if !current_sav.has_selected_difficulty:
		await get_tree().create_timer(0.2).timeout
		dif_ready_to_select()
		await difficulty_select_finished
	await get_tree().create_timer(1).timeout
	if animation_stage_count != 0:
		level_access_process()
		await level_access_finished
	path_show()
	await path_animation_finished
	
	show_hidden_level()
	pass


func update_check():
	for i in HeroSavBlock.hero_sav_block_library:
		if i+1 > current_sav.hero_sav.size():
			current_sav.hero_sav.append(HeroSavBlock.hero_sav_block_library[i])
	current_sav.hero_sav[0].unlocked = true
	
	Global.sav_game_sav(current_sav)
	pass


func _process(delta: float) -> void:
	if OS.get_name() == "Android":
		hide_panel()
	pass


func show_panel(area_name: String,area_color: Color,area_intro: String):
	if !can_control:
		level_panel.hide()
		return
	level_panel.show()
	level_panel.update_status(area_name,area_color,area_intro)
	pass


func hide_panel():
	level_panel.hide()
	pass


func _on_option_button_pressed() -> void:
	option_enter()
	pass # Replace with function body.


func option_enter():
	animation_player.play("OptionEnter")
	pass


func _on_finish_button_pressed() -> void:
	option_quit()
	pass # Replace with function body.


func option_quit():
	animation_player.play("OptionExit")
	pass


func _on_exit_button_pressed() -> void:
	can_control = false
	var back_path: String
	if OS.get_name() == "Android":
		back_path = "res://Scenes/GameBased/main_title_mobile.tscn"
	else:
		back_path = "res://Scenes/GameBased/main_title.tscn"
	Global.change_scene(back_path)
	pass # Replace with function body.


func _on_difficulty_button_pressed() -> void:
	animation_player.play("OptionExit")
	await get_tree().create_timer(0.4).timeout
	dif_ready_to_select()
	pass # Replace with function body.


func dif_ready_to_select():
	hide_panel()
	$MapUI.add_child(difficulty_selection_scene.instantiate())
	can_control = false
	pass


func _on_hero_hall_button_pressed() -> void:
	hide_panel()
	$MapUI.add_child(hero_hall_scene.instantiate())
	can_control = false
	pass # Replace with function body.


func _on_upgrade_button_pressed() -> void:
	hide_panel()
	can_control = false
	#$MapUI.add_child(upgrade_ui_mobile.instantiate())
	if OS.get_name() == "Android":
		$MapUI.add_child(upgrade_ui_mobile_scene.instantiate())
	else:
		$MapUI.add_child(upgrade_ui_scene.instantiate())
	pass # Replace with function body.


func _on_seen_book_button_pressed() -> void:
	hide_panel()
	can_control = false
	#$MapUI.add_child(seen_book_ui.instantiate())
	if OS.get_name() == "Android":
		$MapUI.add_child(seen_book_mobile_scene.instantiate())
	else:
		$MapUI.add_child(seen_book_scene.instantiate())
	pass # Replace with function body.


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("escape") and can_control:
		option_enter()
	pass


func _on_achievement_button_pressed() -> void:
	hide_panel()
	can_control = false
	$MapUI.add_child(achievement_scene.instantiate())
	pass # Replace with function body.


func open_fight_ui(stage_level: int):
	var fight_ui: ReadyToFightUI = ready_to_fight_scene.instantiate()
	fight_ui.stage_level = stage_level
	can_control = false
	$MapUI.add_child(fight_ui)
	pass


func flags_update():
	
	pass


func show_path():
	
	pass


func show_flags():
	
	pass


func level_access_process():
	if animation_stage_count == 0:
		await get_tree().create_timer(0.01).timeout
		level_access_finished.emit()
	else:
		var flag: LevelFlag = flags.get_child(animation_stage_count-1)
		flag.flag_reward_animation()
		await flag.flag_access_animation_finished
		level_access_finished.emit()
	pass


func path_show():
	for path: MapPath in paths.get_children():
		if path.need_to_play_show_animation():
			path.path_animation_play()
			await path.path_animation_finished
	await get_tree().create_timer(0.01).timeout
	path_animation_finished.emit()
	pass


func show_hidden_level():
	for flag: LevelFlag in flags.get_children():
		flag.show_from_hidden()
		await flag.show_finished
	pass


func update_hero_hall():
	var texture: Texture2D
	match current_sav.select_hero_id:
		0: texture = load("res://Assets/Images/UI/HeroHall/HeadTexs/Steve.png")
		1: texture = load("res://Assets/Images/UI/HeroHall/HeadTexs/Fuchen.png")
		2: texture = load("res://Assets/Images/UI/HeroHall/HeadTexs/艾利克斯.png")
		3: texture = load("res://Assets/Images/UI/HeroHall/HeadTexs/塔尔辛.png")
		4: texture = load("res://Assets/Images/UI/HeroHall/HeadTexs/鲁伯特.png")
		5: texture = load("res://Assets/Images/UI/HeroHall/HeadTexs/空树林.png")
		6: texture = load("res://Assets/Images/UI/HeroHall/HeadTexs/金钻.png")
		9: texture = load("res://Assets/Images/UI/HeroHall/HeadTexs/Mike.png")
		7: texture = load("res://Assets/Images/UI/HeroHall/HeadTexs/塞勒姆.png")
		8: texture = load("res://Assets/Images/UI/HeroHall/HeadTexs/乔尼.png")
		9: texture = load("res://Assets/Images/UI/HeroHall/HeadTexs/Mike.png")
		10: texture = load("res://Assets/Images/UI/HeroHall/HeadTexs/蔷薇.png")
		11: texture = load("res://Assets/Images/UI/HeroHall/HeadTexs/史蒂夫SP.png")
	
	hero_hall_head_tex.texture = texture
	pass


func achievement_process():
	campaign_finish()
	diamond_finish()
	bedrock_finish()
	pass


func campaign_finish():
	if current_sav.compeleted_keywords.has("campaign_end"): return
	for i in 20:
		var keyword: String = str(i+1) + "_campaign"
		#print(keyword)
		if !current_sav.level_difficulty_completed.has(keyword): return
	current_sav.compeleted_keywords.append("campaign_end")
	Global.sav_game_sav(current_sav)
	pass


func diamond_finish():
	if current_sav.compeleted_keywords.has("diamond!"): return
	for i in 20:
		if i+1 in ReadyToFightUI.no_challenge_levels: continue
		var keyword: String = str(i+1) + "_diamond"
		#print(keyword)
		if !current_sav.level_difficulty_completed.has(keyword): return
	current_sav.compeleted_keywords.append("diamond!")
	Global.sav_game_sav(current_sav)
	pass


func bedrock_finish():
	if current_sav.compeleted_keywords.has("bedrock"): return
	for i in 20:
		if i+1 in ReadyToFightUI.no_challenge_levels: continue
		var keyword: String = str(i+1) + "_bedrock"
		#print(keyword)
		if !current_sav.level_difficulty_completed.has(keyword): return
	current_sav.compeleted_keywords.append("bedrock")
	Global.sav_game_sav(current_sav)
	pass
