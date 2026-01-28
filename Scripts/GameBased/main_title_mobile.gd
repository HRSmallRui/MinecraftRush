extends Node2D


@onready var start_button: TextureButton = $Index/StartButton
@onready var option_button: TextureButton = $Index/OptionButton
@onready var extra_button: TextureButton = $Index/ExtraButton
@onready var change_page_animation_player: AnimationPlayer = $ChangePageAnimationPlayer
@onready var index_animation_player: AnimationPlayer = $Index/IndexAnimationPlayer
@onready var version_label: Label = $Index/VersionLabel
@onready var music_slider: HSlider = $Options/MusicSlider
@onready var sound_slider: HSlider = $Options/SoundSlider


func _ready() -> void:
	start_button.position.x = 617
	option_button.position.x = 617
	extra_button.position.x = 617
	version_label.text = "V" + Global.version_text + ".MOBILE"
	version_label.text += Global.get_version_back_words()
	
	var user_sav: UserSaver = Global.get_user_sav()
	AudioServer.set_bus_volume_db(1,user_sav.user_music_volume)
	AudioServer.set_bus_volume_db(2,user_sav.user_sound_volume)
	music_slider.value = AudioServer.get_bus_volume_db(1)
	sound_slider.value = AudioServer.get_bus_volume_db(2)
	pass


func _on_start_button_pressed() -> void:
	index_animation_player.play_backwards("appear")
	await index_animation_player.animation_finished
	change_page_animation_player.play("sav_slot")
	pass # Replace with function body.


func _on_close_button_pressed() -> void:
	change_page_animation_player.play_backwards("sav_slot")
	await change_page_animation_player.animation_finished
	index_animation_player.play("appear")
	pass # Replace with function body.


func _on_option_button_pressed() -> void:
	index_animation_player.play_backwards("appear")
	await index_animation_player.animation_finished
	change_page_animation_player.play("option")
	pass # Replace with function body.


func _on_option_close_button_pressed() -> void:
	change_page_animation_player.play_backwards("option")
	await change_page_animation_player.animation_finished
	index_animation_player.play("appear")
	pass # Replace with function body.


func _on_music_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(1,value)
	var user_sav = Global.get_user_sav() as UserSaver
	user_sav.user_music_volume = value
	Global.sav_user_sav(user_sav)
	pass # Replace with function body.


func _on_sound_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(2,value)
	var user_sav = Global.get_user_sav() as UserSaver
	user_sav.user_sound_volume = value
	Global.sav_user_sav(user_sav)
	pass # Replace with function body.
