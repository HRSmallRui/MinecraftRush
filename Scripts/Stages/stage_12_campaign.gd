extends Stage

@export var witch_tower_texture: Texture
@export var witch_tower_name: String
@export var witch_tower_group: DefenceTower.TowerType
@export var witch_tower_id: int


func _ready() -> void:
	super()
	await get_tree().create_timer(0.01,false).timeout
	var witch_tower_ui: TipUI = preload("res://Scenes/TipUI/special_towers_unlock_ui.tscn").instantiate()
	witch_tower_ui.show_texture = witch_tower_texture
	witch_tower_ui.show_name = witch_tower_name
	witch_tower_ui.tower_group = witch_tower_group
	witch_tower_ui.tower_id = witch_tower_id
	add_child(witch_tower_ui)
	pass
