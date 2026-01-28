extends Button
class_name SavButton

@export var slot_number: int
@export var main_title: MainTitle

@onready var new_sav: Control = $NewSav
@onready var past_sav: Control = $PastSav

@onready var slot_number_label: Label = $PastSav/SlotNumberLabel

@onready var label_list: HBoxContainer = $PastSav/LabelList
@onready var star: TextureRect = $PastSav/Star
@onready var diamond: TextureRect = $PastSav/Diamond
@onready var bedrock: TextureRect = $PastSav/Bedrock


var is_new: bool
var difficulty: String
var total_stars: int
var total_diamonds: int
var total_bedrocks: int
var last_sav_time: String


func _ready() -> void:
	if OS.get_name() == "Windows":
		label_list.hide()
		star.hide()
		diamond.hide()
		bedrock.hide()
	var sav = Global.get_game_sav(slot_number) as GameSaver
	if sav == null: show_new()
	else: show_old(sav)
	pass


func _on_mouse_entered() -> void:
	main_title.show_slot_panel(is_new,slot_number,difficulty,total_stars,total_diamonds,total_bedrocks,
	last_sav_time)
	pass # Replace with function body.


func _on_mouse_exited() -> void:
	main_title.hide_slot_panel()
	pass # Replace with function body.


func reset_slot():
	is_new = true
	new_sav.show()
	past_sav.hide()
	pass


func show_new():
	new_sav.show()
	past_sav.hide()
	print("new")
	is_new = true
	pass


func show_old(sav: GameSaver):
	past_sav.show()
	new_sav.hide()
	print("old")
	slot_number_label.text = "档位 " + str(slot_number)
	is_new = false
	match sav.difficulty:
		0:
			difficulty = "简单"
		1:
			difficulty = "普通"
		2:
			difficulty = "困难"
	total_stars = sav.total_stars
	total_diamonds = sav.total_diamonds
	total_bedrocks = sav.total_bedrocks
	last_sav_time = sav.last_sav_time
	
	$PastSav/LabelList/StarLabel.text = str(total_stars) + " / " + str(Global.total_stars)
	$PastSav/LabelList/DiamondLabel.text = str(total_diamonds) + " / " + str(Global.total_level_count - ReadyToFightUI.no_challenge_levels.size())
	$PastSav/LabelList/BedrockLabel.text = str(total_bedrocks) + " / " + str(Global.total_level_count - ReadyToFightUI.no_challenge_levels.size())
	pass


func _on_delete_button_pressed() -> void:
	$PastSav/ClickAudio.play(0.2)
	main_title.ready_to_delete_slot = slot_number
	main_title.delete_answer_animation()
	pass # Replace with function body.


func _on_pressed() -> void:
	$PastSav/ClickAudio.play(0.2)
	main_title.stop_panel.show()
	main_title.can_control = false
	Global.current_sav_slot = slot_number
	Global.change_scene("res://Scenes/GameBased/main_map.tscn")
	pass # Replace with function body.
