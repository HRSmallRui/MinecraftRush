extends Control


@onready var reset_button: TextureButton = $Control/ResetButton
@onready var music_slider: HSlider = $Control/MusicSlider
@onready var sound_slider: HSlider = $Control/SoundSlider
@onready var difficulty_button: Button = $Control/DifficultyButton

@export var can_control: bool


func _ready() -> void:
	music_slider.value = Global.get_user_sav().user_music_volume
	sound_slider.value = Global.get_user_sav().user_sound_volume
	pass


func _on_music_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(1,value)
	var user_Sav = Global.get_user_sav() as UserSaver
	user_Sav.user_music_volume = value
	Global.sav_user_sav(user_Sav)
	pass # Replace with function body.


func _on_sound_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(2,value)
	var user_sav = Global.get_user_sav() as UserSaver
	user_sav.user_sound_volume = value
	Global.sav_user_sav(user_sav)
	pass # Replace with function body.


func _on_reset_button_pressed() -> void:
	music_slider.value = 0
	sound_slider.value = 0
	pass # Replace with function body.


func update_difficulty():
	match Map.instance.current_sav.difficulty:
		0:
			difficulty_button.text = "简单"
		1:
			difficulty_button.text = "普通"
		2:
			difficulty_button.text = "困难"
	pass


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("escape") and can_control:
		$"../..".option_quit()
	pass


func _on_cheat_enter_button_pressed() -> void:
	can_control = false
	var cheatword_ui: Control = preload("res://Scenes/UI-Components/Map/cheatword_ui.tscn").instantiate()
	get_parent().add_child(cheatword_ui)
	await cheatword_ui.tree_exited
	can_control = true
	pass # Replace with function body.
