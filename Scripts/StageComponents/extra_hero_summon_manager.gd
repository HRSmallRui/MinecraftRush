extends Node2D
class_name ExtraHeroSummonManager

@export var hero_scene_list: Array[PackedScene]
@export var hero_marker_list: Array[Marker2D]


func _ready() -> void:
	await get_tree().create_timer(0.2,false).timeout
	for i in hero_scene_list.size():
		var hero: Hero = hero_scene_list[i].instantiate()
		hero.position = hero_marker_list[i].global_position
		hero.station_position = hero.position
		Stage.instance.allys.add_child(hero)
		Stage.instance.hero_list.append(hero)
	queue_free()
	pass
