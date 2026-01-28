@tool
extends Node2D

@export var tower: DefenceTower

@onready var based_sprite: Sprite2D = $BasedSprite
@onready var based_sprite_select: Sprite2D = $BasedSpriteSelect


func _ready() -> void:
	var load_path: String = "res://Assets/Images/DefenceTowers/Based/"
	if tower.based_skin == DefenceTower.BasedSkin.Royal: load_path += "royal-"
	elif tower.based_skin == DefenceTower.BasedSkin.Jungle: load_path += "jungle-"
	elif tower.based_skin == DefenceTower.BasedSkin.Desert: load_path += "desert-"
	elif tower.based_skin == DefenceTower.BasedSkin.Rising: load_path += "rising-"
	elif tower.based_skin == DefenceTower.BasedSkin.Mountain: load_path += "mountain-"
	elif tower.based_skin == DefenceTower.BasedSkin.Swamp: load_path += "swamp-"
	
	if tower.tower_type == DefenceTower.TowerType.Based: load_path += "tower"
	else: load_path += "build"
	
	based_sprite.texture = load(load_path + ".png")
	based_sprite_select.texture = load(load_path + "-select.png")
	pass


func select():
	based_sprite.hide()
	based_sprite_select.show()
	pass


func select_cancel():
	based_sprite.show()
	based_sprite_select.hide()
	pass
