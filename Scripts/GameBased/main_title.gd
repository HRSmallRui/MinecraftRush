extends Node2D
class_name MainTitle

enum CurrentUI{
	Main,
	SavSlot,
	SavDelete,
	Option,
	ReadyToQuit
}

@export var can_control: bool

@onready var main_title_music: AudioStreamPlayer = $MainTitleMusic
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var sav_slot_panel: SavSlotPanel = $SavSlotPanel
@onready var version_label: Label = $VersionLabel

@onready var sav_slot_button: SavButton = $SavSlotButtons/SavSlotButton
@onready var sav_slot_button_2: SavButton = $SavSlotButtons/SavSlotButton2
@onready var sav_slot_button_3: SavButton = $SavSlotButtons/SavSlotButton3
@onready var stop_panel: Panel = $StopPanel

var current_ui: CurrentUI = CurrentUI.Main
var ready_to_delete_slot: int


func _ready() -> void:
	
	version_label.text = "V" + Global.version_text
	version_label.text += Global.get_version_back_words()
	
	$Logo.position = Vector2(324,-165)
	var user_sav = Global.get_user_sav() as UserSaver
	if user_sav == null: Global.sav_user_sav(UserSaver.new())
	user_sav = Global.get_user_sav() as UserSaver
	AudioServer.set_bus_volume_db(1,user_sav.user_music_volume)
	AudioServer.set_bus_volume_db(2,user_sav.user_sound_volume)
	$Option/MusicSlider.value = AudioServer.get_bus_volume_db(1)
	$Option/SoundSlider.value = AudioServer.get_bus_volume_db(2)
	
	await get_tree().create_timer(0.4).timeout
	main_title_music.play()
	await animation_player.animation_finished
	animation_player.play("Main")
	pass


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("escape") and can_control:
		match current_ui:
			CurrentUI.Main:
				quit_answer_animation()
			CurrentUI.SavSlot:
				exit_savs()
			CurrentUI.Option:
				finishi_option_animation()
			CurrentUI.ReadyToQuit:
				quit_exit_animation()
			CurrentUI.SavDelete:
				delete_quit_animation()
	pass


func _on_start_button_pressed() -> void:
	prepare_to_start()
	background_animation(0)
	pass # Replace with function body.


func prepare_to_start():
	animation_player.play("StartExit")
	await animation_player.animation_finished
	animation_player.play("SavsEnter")
	current_ui = CurrentUI.SavSlot
	pass


func show_slot_panel(is_new: bool,slot_number: int = 0,difficulty: String = "",total_stars: int = 0,
total_diamonds: int = 0, total_bedrocks: int = 0, last_sav_time: String = ""):
	sav_slot_panel.show()
	if is_new:
		sav_slot_panel.new_slot.show()
		sav_slot_panel.old_slot.hide()
		sav_slot_panel.slot_number_label.text = "空档位"
		return
	sav_slot_panel.new_slot.hide()
	sav_slot_panel.old_slot.show()
	sav_slot_panel.slot_number_label.text = "档位 " + str(slot_number)
	sav_slot_panel.star_label.text = str(total_stars) + "/ " + str(Global.total_stars)
	sav_slot_panel.diamond_label.text = str(total_diamonds) + "/ " + str(Global.total_level_count - ReadyToFightUI.no_challenge_levels.size())
	sav_slot_panel.bedrock_label.text = str(total_bedrocks) + "/ " + str(Global.total_level_count - ReadyToFightUI.no_challenge_levels.size())
	sav_slot_panel.time_label.text = last_sav_time
	sav_slot_panel.difficulty_label.text = "难度： " + difficulty
	match difficulty:
		"简单":
			sav_slot_panel.difficulty_label.modulate = Color.GREEN
		"普通":
			sav_slot_panel.difficulty_label.modulate = Color.ORANGE
		"困难":
			sav_slot_panel.difficulty_label.modulate = Color.RED
	pass


func hide_slot_panel():
	sav_slot_panel.hide()
	pass


func _on_sav_back_button_pressed() -> void:
	exit_savs()
	pass # Replace with function body.


func exit_savs():
	background_animation(1)
	animation_player.play("SavsExit")
	await animation_player.animation_finished
	animation_player.play("Main")
	current_ui = CurrentUI.Main
	pass


func _on_sound_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(2,value)
	var user_sav = Global.get_user_sav() as UserSaver
	user_sav.user_sound_volume = value
	Global.sav_user_sav(user_sav)
	pass # Replace with function body.


func _on_music_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(1,value)
	var user_Sav = Global.get_user_sav() as UserSaver
	user_Sav.user_music_volume = value
	Global.sav_user_sav(user_Sav)
	pass # Replace with function body.


func _on_option_button_pressed() -> void:
	option_animation()
	background_animation(2)
	pass # Replace with function body.


func option_animation():
	animation_player.play("OptionExit")
	await animation_player.animation_finished
	animation_player.play("SoundsEnter")
	current_ui = CurrentUI.Option
	pass


func _on_finish_button_pressed() -> void:
	finishi_option_animation()
	pass # Replace with function body.


func finishi_option_animation():
	background_animation(1)
	animation_player.play("SoundsExit")
	await animation_player.animation_finished
	animation_player.play("Main")
	current_ui = CurrentUI.Main
	pass


func _on_reset_button_pressed() -> void:
	$Option/MusicSlider.value = 0
	$Option/SoundSlider.value = 0
	pass # Replace with function body.


func _on_exit_button_pressed() -> void:
	quit_answer_animation()
	pass # Replace with function body.


func quit_answer_animation():
	animation_player.play("QuitEnter")
	current_ui = CurrentUI.ReadyToQuit
	pass


func _on_quit_button_pressed() -> void:
	get_tree().quit()
	pass # Replace with function body.


func _on_cancel_button_pressed() -> void:
	quit_exit_animation()
	pass # Replace with function body.


func quit_exit_animation():
	animation_player.play("QuitExit")
	current_ui = CurrentUI.Main
	pass


func delete_answer_animation():
	animation_player.play("DeleteSavEnter")
	current_ui = CurrentUI.SavDelete
	pass


func delete_quit_animation():
	animation_player.play("DeleteSavExit")
	current_ui = CurrentUI.SavSlot
	pass


func _on_ok_delete_button_pressed() -> void:
	match ready_to_delete_slot:
		1:
			sav_slot_button.reset_slot()
		2:
			sav_slot_button_2.reset_slot()
		3:
			sav_slot_button_3.reset_slot()
	delete_quit_animation()
	DirAccess.remove_absolute(Global.get_game_sav_path(ready_to_delete_slot))
	pass # Replace with function body.


func _on_cancel_delete_button_pressed() -> void:
	delete_quit_animation()
	pass # Replace with function body.


func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Classes/stage_class.tscn")
	pass # Replace with function body.


func background_animation(anim_type: int = 0):
	var target_pos_y: float
	match anim_type:
		0: target_pos_y = 0
		1: target_pos_y = -130
		2: target_pos_y = -260
	
	create_tween().tween_property($Background,"position:y",target_pos_y,0.3)
	pass
