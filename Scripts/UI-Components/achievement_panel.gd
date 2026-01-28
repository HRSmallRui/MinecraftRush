extends Panel
class_name AchievementPanel

@export var achievement_keywords: String

@onready var achievement_icon: TextureRect = $AchievementIcon
@onready var achievement_name_label: Label = $AchievementNameLabel
@onready var achievement_intro_label: Label = $AchievementIntroLabel


func _ready() -> void:
	var struct: AchievementStruct = AchievementLibrary.achievement_library[achievement_keywords]
	achievement_name_label.text = struct.achievement_name
	achievement_intro_label.text = struct.achievement_intro
	achievement_icon.texture = load("res://Assets/Images/UI/Achievements/" + achievement_keywords + ".png")
	
	Achievement.is_achievement_playing = true
	position.y = -180
	modulate.a = 0
	create_tween().tween_property(self,"position:y",0,0.3)
	create_tween().tween_property(self,"modulate:a",1,0.3)
	await get_tree().create_timer(2.4).timeout
	create_tween().tween_property(self,"position:y",-180,0.3)
	create_tween().tween_property(self,"modulate:a",0,0.4)
	await get_tree().create_timer(0.4).timeout
	Achievement.is_achievement_playing = false
	queue_free()
	pass
