extends Control
class_name ReadyToFightUI

static var no_challenge_levels: Array[int] = [
	15
]

@onready var intro_label: Label = $Control/Intro/IntroLabel
@onready var title_label: Label = $Control/TitleLabel
@onready var intro: Control = $Control/Intro
@onready var diamond_slot: Control = $Control/DiamondSlot
@onready var bedrock_slot: Control = $Control/BedrockSlot
@onready var view_texture: TextureRect = $Control/ViewTexture
@onready var campaign_mode_button: Button = $Control/ModeSelect/Campaign/ModeButton
@onready var diamond_mode_button: Button = $Control/ModeSelect/Diamond/ModeButton
@onready var bedrock_mode_button: Button = $Control/ModeSelect/Bedrock/ModeButton
@onready var difficulty_label: Label = $Control/ViewTexture/DifficultyLabel
@onready var diamond: Control = $Control/ModeSelect/Diamond
@onready var bedrock: Control = $Control/ModeSelect/Bedrock

@export var stage_level: int

var clampy_max: float = 5
var clampy_min: float
var is_dragging: bool = false
var can_control: bool = false
var current_mode: int = 0
var campaign_path: String
var diamond_path: String
var bedrock_path: String


func _ready() -> void:
	mode_unlocked_condition()
	mode_win_condition()
	show_difficulty_complete(stage_level,current_mode)
	
	diamond.visible = !stage_level in no_challenge_levels
	bedrock.visible = !stage_level in no_challenge_levels
	
	intro_label.text = StageStoryLibrary.stage_informations[stage_level-1]
	title_label.text = StageStoryLibrary.stage_name[stage_level-1]
	view_texture.texture = load("res://Assets/Images/Stages/Stage" + str(stage_level) + "/stage" + str(stage_level) + "-view.png")
	
	await get_tree().process_frame
	var level = (intro_label.size.y - 504) / 88
	if level <= 0: clampy_min = clampy_max
	else: clampy_min = 5 - level * 34
	intro_label.position.y = 5
	
	await $AnimationPlayer.animation_finished
	can_control = true
	
	var limit_level: int = StageLimitLibrary.limit_tech_levels[stage_level-1]
	$Control/DiamondSlot/LevelLimit/IntroLabel.text = "限制科技等级" + str(limit_level) + "级"
	$Control/BedrockSlot/LevelLimit/IntroLabel.text = "限制科技等级" + str(limit_level) + "级"
	bedrock_tower_limit()
	
	campaign_path = "res://Scenes/Stages/Stage" + str(stage_level) + "/stage_" + str(stage_level) + "_campaign.tscn"
	diamond_path = "res://Scenes/Stages/Stage" + str(stage_level) + "/stage_" + str(stage_level) + "_diamond.tscn"
	bedrock_path = "res://Scenes/Stages/Stage" + str(stage_level) + "/stage_" + str(stage_level) + "_bedrock.tscn"
	
	
	pass


func _on_intro_gui_input(event: InputEvent) -> void:
	if event is InputEventScreenDrag:
		intro_label.position.y += event.relative.y
		is_dragging = true
	elif event.is_action_pressed("scroll_up") or event.is_action_pressed("scroll_down"):
		intro_label.position.y += Input.get_axis("scroll_down","scroll_up") * 10
		is_dragging = true
	else:
		is_dragging = false
	
	intro_label.position.y = clampf(intro_label.position.y,clampy_min - 160,clampy_max + 160)
	pass # Replace with function body.


func _process(delta: float) -> void:
	var rate: float = 5
	if intro_label.position.y < clampy_min:
		intro_label.position.y = lerpf(intro_label.position.y,clampy_min,delta * rate)
	elif intro_label.position.y > clampy_max:
		intro_label.position.y = lerpf(intro_label.position.y,clampy_max,delta * rate)
	pass


func _input(event: InputEvent) -> void:
	if can_control and event.is_action_pressed("escape"):
		quit()
	pass


func quit():
	can_control = false
	$AnimationPlayer.play("hide")
	await $AnimationPlayer.animation_finished
	queue_free()
	Map.instance.can_control = true
	pass


func _on_close_button_pressed() -> void:
	quit()
	pass # Replace with function body.


func change_mode(game_mode: int):
	intro.visible = game_mode == 0
	diamond_slot.visible = game_mode == 1
	bedrock_slot.visible = game_mode == 2
	current_mode = game_mode
	show_difficulty_complete(stage_level,current_mode)
	pass


func bedrock_tower_limit():
	var archer:TextureRect = $Control/BedrockSlot/TowerTypes/Archer/TextureRect
	var barrack: TextureRect = $Control/BedrockSlot/TowerTypes/Barrack/TextureRect
	var magic: TextureRect = $Control/BedrockSlot/TowerTypes/Magic/TextureRect
	var bombard: TextureRect = $Control/BedrockSlot/TowerTypes/Bombard/TextureRect
	tower_icon_color(archer,StageLimitLibrary.can_use_tower_type[stage_level-1][0])
	tower_icon_color(barrack,StageLimitLibrary.can_use_tower_type[stage_level-1][1])
	tower_icon_color(magic,StageLimitLibrary.can_use_tower_type[stage_level-1][2])
	tower_icon_color(bombard,StageLimitLibrary.can_use_tower_type[stage_level-1][3])
	pass


func tower_icon_color(texturerect: TextureRect,is_available: bool):
	texturerect.modulate = Color.WHITE if is_available else Color.BLACK
	pass


func _on_start_button_pressed() -> void:
	match current_mode:
		0:
			Global.change_scene(campaign_path)
		1:
			Global.change_scene(diamond_path)
		2:
			Global.change_scene(bedrock_path)
	
	match Map.instance.current_sav.select_hero_id:
		0: ResourceLoader.load_threaded_request("res://Scenes/Allys/Heroes/steve.tscn","",false,ResourceLoader.CACHE_MODE_IGNORE)
		1: ResourceLoader.load_threaded_request("res://Scenes/Allys/Heroes/fuchen.tscn","",false,ResourceLoader.CACHE_MODE_IGNORE)
		2: ResourceLoader.load_threaded_request("res://Scenes/Allys/Heroes/alex.tscn","",false,ResourceLoader.CACHE_MODE_IGNORE)
		3: ResourceLoader.load_threaded_request("res://Scenes/Allys/Heroes/talzin.tscn","",false,ResourceLoader.CACHE_MODE_IGNORE)
		4: ResourceLoader.load_threaded_request("res://Scenes/Allys/Heroes/robort.tscn","",false,ResourceLoader.CACHE_MODE_IGNORE)
		7: ResourceLoader.load_threaded_request("res://Scenes/Allys/Heroes/salem.tscn","",false,ResourceLoader.CACHE_MODE_IGNORE)
		8: ResourceLoader.load_threaded_request("res://Scenes/Allys/Heroes/johnny.tscn","",false,ResourceLoader.CACHE_MODE_IGNORE)
		9: ResourceLoader.load_threaded_request("res://Scenes/Allys/Heroes/mike_smith.tscn","",false,ResourceLoader.CACHE_MODE_IGNORE)
	pass # Replace with function body.


func mode_unlocked_condition():
	diamond_mode_button.disabled = Map.instance.current_sav.level_sav[stage_level][1] < 3
	bedrock_mode_button.disabled = diamond_mode_button.disabled
	diamond_mode_button.call_deferred("game_mode_select")
	bedrock_mode_button.call_deferred("game_mode_select")
	pass


func mode_win_condition():
	
	pass


func show_difficulty_complete(stage_count: int, stage_mode: int):
	var difficulty_sav: Dictionary = Map.instance.current_sav.level_difficulty_completed
	var key: String = str(stage_count) + "_"
	match stage_mode:
		0: key += "campaign"
		1: key += "diamond"
		2: key += "bedrock"
	if key in difficulty_sav:
		difficulty_label.show()
		difficulty_label.text = "已完成 - "
		match difficulty_sav[key]:
			0: difficulty_label.text += "简单"
			1: difficulty_label.text += "普通"
			2: difficulty_label.text += "困难"
	else:
		difficulty_label.hide()
	pass
