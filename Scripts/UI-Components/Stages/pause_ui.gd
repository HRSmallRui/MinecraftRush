extends CanvasLayer
class_name PauseUI

@onready var vague: ColorRect = $Vague
@onready var click_audio: AudioStreamPlayer = $ClickAudio
@onready var music_slider: HSlider = $VBoxContainer/MusicSlider
@onready var sound_slider: HSlider = $VBoxContainer/SoundSlider

func _ready() -> void:
	music_slider.value = Global.get_user_sav().user_music_volume
	sound_slider.value = Global.get_user_sav().user_sound_volume
	pass


func _input(event: InputEvent) -> void:
	if $AnimationPlayer.is_playing(): return
	if event.is_action_pressed("escape"):
		back()
	pass


func back():
	click_audio.play()
	$AnimationPlayer.play("Exit")
	await $AnimationPlayer.animation_finished
	get_tree().paused = false
	queue_free()
	pass


func _on_continue_button_pressed() -> void:
	
	back()
	pass # Replace with function body.


func _on_quit_button_pressed() -> void:
	click_audio.play()
	Global.change_scene("res://Scenes/GameBased/main_map.tscn")
	Global.time_scale = 1
	self.process_mode = Node.PROCESS_MODE_DISABLED
	pass # Replace with function body.


func _on_restart_button_pressed() -> void:
	click_audio.play()
	$AnimationPlayer.play("Exit")
	await $AnimationPlayer.animation_finished
	get_tree().paused = false
	get_tree().reload_current_scene()
	pass # Replace with function body.


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


func _process(delta: float) -> void:
	$AnimationPlayer.speed_scale = 1 / Engine.time_scale
	pass
