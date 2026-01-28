extends TextureRect

var normal_texture: Texture
var locked_texture: Texture
@export var sav_keyword: String

const CARD_LOCKED = preload("res://Assets/Images/UI/Achievements/card_locked.tres")
const CARD_NORMAL = preload("res://Assets/Images/UI/Achievements/card_normal.tres")

@onready var texture_rect: TextureRect = $TextureRect
@onready var name_label: Label = $NameLabel
@onready var intro_label: Label = $IntroLabel


func _ready() -> void:
	var achieve_struct: AchievementStruct = AchievementLibrary.achievement_library[sav_keyword]
	name_label.text = achieve_struct.achievement_name
	intro_label.text = achieve_struct.achievement_intro
	normal_texture = load("res://Assets/Images/UI/Achievements/" + sav_keyword + ".png")
	locked_texture = load("res://Assets/Images/UI/Achievements/" + sav_keyword + "-locked.png")
	if sav_keyword in Map.instance.current_sav.compeleted_keywords:
		compelete_state()
	else:
		locked_state()
	pass


func compelete_state():
	texture_rect.texture = normal_texture
	pass


func locked_state():
	texture = CARD_LOCKED
	intro_label.modulate = Color.WHITE
	name_label.modulate = Color.ORANGE * 0.6
	texture_rect.texture = locked_texture
	pass
