extends Node2D

@export var show_wave_count: int = -1

@onready var button: Button = $Button
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var light_audio: AudioStreamPlayer = $LightAudio
@onready var click_audio: AudioStreamPlayer = $ClickAudio


func _ready() -> void:
	button.disabled = true
	Stage.instance.wave_summon.connect(on_wave_summon)
	pass


func _on_button_pressed() -> void:
	button.disabled = true
	click_audio.play()
	hide()
	skill_cooling()
	light_audio.play()
	pass # Replace with function body.


func on_wave_summon(wave_count: int):
	if wave_count == show_wave_count:
		button.disabled = false
		light_audio.play()
		animation_player.play("appear")
	if wave_count == show_wave_count+1 and visible:
		button.disabled = true
		animation_player.play_backwards("appear")
		light_audio.play()
	pass


func skill_cooling():
	for skill_button: SkillButton in Stage.instance.skill_button_container.get_children():
		if skill_button.button_state != SkillButton.ButtonState.Cooling: continue
		var cooling_time: float = skill_button.cooling_time
		cooling_time *= 0.2
		skill_button.cooling_fast(cooling_time)
	pass
