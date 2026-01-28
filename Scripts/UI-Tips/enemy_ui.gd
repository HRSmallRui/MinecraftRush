extends TipUI
class_name EnemyTip

@export var enemy_id: int = 0

@onready var name_label: Label = $Paper/NameLabel
@onready var intro_label: Label = $Paper/IntroLabel
@onready var tag_label: Label = $Paper/TagLabel
@onready var enemy_texture: TextureRect = $Paper/Icon/EnemyTexture


func _ready() -> void:
	super()
	Achievement.achieve_int_add("SearchInformation",1,6)
	enemy_texture.texture = load("res://Assets/Images/UI/SeenBook/Enemies/Textures/enemy" + str(enemy_id) + ".png")
	var block: EnemyData = EnemyLibrary.enemy_datas[enemy_id]
	name_label.text = block.enemy_name
	intro_label.text = block.enemy_intro
	tag_label.text = block.notifition_tags
	pass


func close_page():
	super()
	$EnemyTipAnimationPlayer.play("hide")
	pass
