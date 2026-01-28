extends RefCounted
class_name AchievementStruct

var achievement_name: String
var achievement_intro: String

func _init(a_name: String, a_intro: String) -> void:
	achievement_name = a_name
	achievement_intro = a_intro
	pass
