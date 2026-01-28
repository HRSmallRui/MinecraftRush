extends TipUI

@export var show_texture: Texture
@export var show_name: String
@export var tower_group: DefenceTower.TowerType
@export_range(3,5) var tower_id: int
@export_multiline var archer_intro_list: PackedStringArray
@export_multiline var barrack_intro_list: PackedStringArray
@export_multiline var magic_intro_list: PackedStringArray
@export_multiline var bombard_intro_list: PackedStringArray

@onready var name_label: Label = $Paper/NameLabel
@onready var group_label: Label = $Paper/GroupLabel
@onready var intro_label: Label = $Paper/IntroLabel
@onready var tower_texture: TextureRect = $Paper/Icon/TowerTexture


func _ready() -> void:
	tower_texture.texture = show_texture
	name_label.text = show_name
	group_label.text = "等级4 "
	match tower_group:
		DefenceTower.TowerType.Archer:
			group_label.text += "箭塔"
			intro_label.text = archer_intro_list[tower_id-3]
		DefenceTower.TowerType.Barrack:
			group_label.text += "兵营"
			intro_label.text = barrack_intro_list[tower_id-3]
		DefenceTower.TowerType.Magic:
			group_label.text += "法师塔"
			intro_label.text = magic_intro_list[tower_id-3]
		DefenceTower.TowerType.Bombard:
			group_label.text += "炮塔"
			intro_label.text = bombard_intro_list[tower_id-3]
	
	Stage.instance.stage_sav.tower_unlock_sav[tower_group][tower_id] = true
	Global.sav_game_sav(Stage.instance.stage_sav)
	super()
	pass
