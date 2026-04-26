extends Node2D

@export var show_wave_count: int = -1

@onready var lily_button: Button = $LilyButton
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var light_audio: AudioStreamPlayer = $LightAudio
@onready var click_audio: AudioStreamPlayer = $ClickAudio


func _ready() -> void:
	lily_button.disabled = true
	Stage.instance.wave_summon.connect(on_wave_summon)
	pass


func _on_lily_button_pressed() -> void:
	lily_button.disabled = true
	click_audio.play()
	hide()
	light_audio.play()
	heal()
	pass # Replace with function body.


func on_wave_summon(wave_count: int):
	if wave_count == show_wave_count:
		lily_button.disabled = false
		animation_player.play("appear")
		light_audio.play()
	if wave_count == show_wave_count+1 and visible:
		lily_button.disabled = true
		animation_player.play_backwards("appear")
		light_audio.play()
	pass


func heal():
	for ally in Stage.instance.allys.get_children():
		if ally is Ally:
			if ally.ally_state != Ally.AllyState.DIE:
				var heal_health: float = ally.start_data.health
				heal_health *= 0.5
				ally.current_data.heal(heal_health)
				var lily_buff: BuffClass = preload("res://Scenes/Buffs/EnvironmentBuffs/lily_heal_buff.tscn").instantiate()
				ally.buffs.add_child(lily_buff)
	pass
