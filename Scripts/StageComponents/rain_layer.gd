extends CanvasLayer
class_name RainSystem

enum RainStep{
	None,
	Small,
	Medium,
	Big,
	Super
}

@export var start_rain_step: RainStep
@export var step_color_list: Array[Color]
@export var wave_step_list: Array[RainStep]
@export var stop_rain: bool

@onready var rain_small: Sprite2D = $RainSmall
@onready var rain_medium: Sprite2D = $RainMedium
@onready var rain_big: Sprite2D = $RainBig
@onready var rain_animation_player: AnimationPlayer = $RainAnimationPlayer
@onready var rain_super: Sprite2D = $RainSuper
@onready var black_mask: ColorRect = $BlackMask
@onready var lightning_timer: Timer = $LightningTimer
@onready var lightning_animation_player: AnimationPlayer = $LightningAnimationPlayer
@onready var rain_audio_small: AudioStreamPlayer = $RainAudioSmall
@onready var rain_audio_medium: AudioStreamPlayer = $RainAudioMedium
@onready var rain_audio_big: AudioStreamPlayer = $RainAudioBig
@onready var rain_audio_super: AudioStreamPlayer = $RainAudioSuper
@onready var lightning_audio_1: AudioStreamPlayer = $LightningAudio1
@onready var lightning_audio_2: AudioStreamPlayer = $LightningAudio2
@onready var lightning_audio_3: AudioStreamPlayer = $LightningAudio3
@onready var hit_area: Area2D = $"../HitArea"
@onready var rain_step_label: Label = $RainStepLabel

var current_rain_step: RainStep
var rain_damage: int


func _ready() -> void:
	translate_to_rain_step(start_rain_step)
	Stage.instance.wave_summon.connect(wave_step)
	lightning_timer.start()
	rain_step_label.modulate.a = 0
	if stop_rain:
		Stage.instance.on_wining.connect(on_win)
	pass


func _process(delta: float) -> void:
	if get_tree().paused:
		if rain_animation_player.current_animation != "pause":
			rain_animation_player.play("pause")
	else:
		if rain_animation_player.current_animation != "no_pause":
			rain_animation_player.play("no_pause")
	pass


func translate_to_rain_step(rain_step: RainStep):
	rain_small.visible = rain_step >= 1
	rain_medium.visible = rain_step >= 2
	rain_big.visible = rain_step >= 3
	rain_super.visible = rain_step >= 4
	Stage.instance.is_dark_time = rain_step > 0
	
	match rain_step:
		RainStep.Small:
			rain_damage = 1
			rain_step_label.text = "小雨"
		RainStep.Medium:
			rain_damage = 2
			rain_step_label.text = "中雨"
		RainStep.Big:
			rain_damage = 3
			rain_step_label.text = "大雨"
		RainStep.Super:
			rain_damage = 5
			rain_step_label.text = "雷暴雨"
		RainStep.None:
			rain_damage = 0
			rain_step_label.text = "晴天"
	
	rain_audio_small.play() if rain_step == RainStep.Small else rain_audio_small.stop()
	rain_audio_medium.play() if rain_step == RainStep.Medium else rain_audio_medium.stop()
	rain_audio_big.play() if rain_step == RainStep.Big else rain_audio_big.stop()
	rain_audio_super.play() if rain_step == RainStep.Super else rain_audio_super.stop()
	create_tween().tween_property(black_mask,"color",step_color_list[rain_step],0.5)
	
	if current_rain_step != rain_step:
		rain_label_animation()
	
	current_rain_step = rain_step
	pass


func rain_label_animation():
	var appear_tween: Tween = create_tween()
	appear_tween.set_pause_mode(Tween.TWEEN_PAUSE_STOP)
	appear_tween.tween_property(rain_step_label,"modulate:a",1,0.5)
	await get_tree().create_timer(2.5,false).timeout
	var disappear_tween: Tween = create_tween()
	disappear_tween.set_pause_mode(Tween.TWEEN_PAUSE_STOP)
	disappear_tween.tween_property(rain_step_label,"modulate:a",0,0.5)
	pass


func wave_step(wave_count: int):
	await get_tree().create_timer(2,false).timeout
	var new_step: RainStep = wave_step_list[wave_count-1]
	if new_step != current_rain_step:
		translate_to_rain_step(new_step)
	pass


func _on_lightning_timer_timeout() -> void:
	if current_rain_step == RainStep.Super:
		lightning_play()
		await lightning_animation_player.animation_finished
	lightning_timer.wait_time = randf_range(6,12)
	lightning_timer.start()
	pass # Replace with function body.


func lightning_play():
	var type: int = randi_range(1,3)
	lightning_animation_player.play("lightning" + str(type))
	pass


func add_lightning_buff():
	for box in hit_area.get_overlapping_areas():
		var enemy: Enemy = box.owner
		if "creeper" in enemy.get_groups() and randf_range(0,1) < 0.3:
			enemy.enemy_buff_tags["lightning"] = 1
			enemy.remove_from_group("creeper")
			enemy.add_new_buff_tag("lightning")
			var lightning_buff: PropertyBuff = preload("res://Scenes/Buffs/lightning_sheild.tscn").instantiate()
			lightning_buff.unit = enemy
			enemy.buffs.add_child(lightning_buff)
	pass


func _on_timer_timeout() -> void:
	if current_rain_step == RainStep.None: return
	for box in hit_area.get_overlapping_areas():
		var enemy: Enemy = box.owner
		if "enderman" in enemy.get_groups() and enemy.enemy_state != Enemy.EnemyState.DIE:
			enemy.take_damage(rain_damage,DataProcess.DamageType.TrueDamage,0,true)
	pass # Replace with function body.


func on_win():
	translate_to_rain_step(RainStep.None)
	pass
