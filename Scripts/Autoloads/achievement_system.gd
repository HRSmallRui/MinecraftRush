extends Node

signal is_avalable

@export var test: bool:
	set(v):
		test = v
		show_achieve_bar("MR1")

@onready var show_layer: CanvasLayer = $ShowLayer


var is_achievement_playing: bool:
	set(v):
		is_achievement_playing = v
		if !is_achievement_playing: is_avalable.emit()

var achievement_waiting_list: Array[String]


func show_achieve_bar(achieve_keywords: String):
	achievement_waiting_list.append(achieve_keywords)
	while true:
		if achievement_waiting_list[0] == achieve_keywords and !is_achievement_playing:
			var achievement_panel: AchievementPanel = preload("res://Scenes/UI-Components/achievement_panel.tscn").instantiate()
			achievement_panel.achievement_keywords = achieve_keywords
			show_layer.add_child(achievement_panel)
			achievement_waiting_list.erase(achieve_keywords)
			break
		else:
			await is_avalable
	pass


func achieve_complete(keywords: String):
	var sav: GameSaver = Stage.instance.stage_sav
	if !keywords in sav.compeleted_keywords:
		sav.compeleted_keywords.append(keywords)
		show_achieve_bar(keywords)
		Global.sav_game_sav(sav)
	pass


func achieve_int_add(keywords: String, add_value: int ,complete_count: int):
	var sav: GameSaver = Stage.instance.stage_sav
	if keywords in sav.compeleted_keywords: return
	if keywords in sav.number_count_achievements:
		sav.number_count_achievements[keywords] += add_value
	else:
		sav.number_count_achievements[keywords] = add_value
	if sav.number_count_achievements[keywords] >= complete_count:
		sav.compeleted_keywords.append(keywords)
		show_achieve_bar(keywords)
	Global.sav_game_sav(sav)
	pass


func add_achieve_temp_value(value_keywords: String):
	var sav: GameSaver = Stage.instance.stage_sav
	if !sav.property_bus.has("achievement_temp"):
		sav.property_bus["achievement_temp"] = Array()
	var temp_array: Array = sav.property_bus["achievement_temp"]
	if temp_array.has(value_keywords): return
	sav.property_bus["achievement_temp"].append(value_keywords)
	pass


func get_achieve_temp() -> Array:
	var sav: GameSaver = Stage.instance.stage_sav
	return sav.property_bus["achievement_temp"]
	pass
