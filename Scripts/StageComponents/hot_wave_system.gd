extends Node2D
class_name HotWaveSystem

enum HotSunStep{
	None,
	Small,
	Super,
	Dark
}

@export var offset_2: float
@export var wave_hot_sun_steps: Array[HotSunStep]
@export var start_hot_sun_step:HotSunStep
@export var immune_groups: Array[String]

@onready var sun_light: PointLight2D = $CanvasLayer/SunLight
@onready var hot_wave_rect: ColorRect = $CanvasLayer/HotWaveRect
@onready var hit_area: Area2D = $HitArea

var gradient: Gradient
var current_hot_sun_step: HotSunStep
var shader_material: ShaderMaterial
var heat_stength: float:
	set(v):
		if shader_material == null: return
		shader_material.set_shader_parameter("heat_strength",v)


func _process(delta: float) -> void:
	if get_tree().paused:
		$AnimationPlayer.play("pause")
	else:
		$AnimationPlayer.play("no_pause")
	
	gradient.offsets[1] = offset_2
	pass


func _ready() -> void:
	var gradient_texture: GradientTexture2D = sun_light.texture
	var now_gradient = gradient_texture.gradient
	gradient = now_gradient
	translate_to_sun_step(start_hot_sun_step, true)
	Stage.instance.wave_summon.connect(stage_wave)
	Stage.instance.on_wining.connect(on_win)
	pass


func translate_to_sun_step(new_step: HotSunStep, hot_time: bool = false):
	var new_hot_strength: float
	var new_sun_energy: float
	shader_material = hot_wave_rect.material
	match new_step:
		HotSunStep.None:
			new_hot_strength = 0
			new_sun_energy = 0.2
		HotSunStep.Small:
			new_hot_strength = 0.6
			new_sun_energy = 0.5
		HotSunStep.Super:
			new_hot_strength = 1
			new_sun_energy = 1
		HotSunStep.Dark:
			new_hot_strength = 0
			new_sun_energy = 0
	if hot_time:
		shader_material.set_shader_parameter("heat_strength",new_hot_strength)
		sun_light.energy = new_sun_energy
	else:
		var process_tween: Tween = create_tween()
		process_tween.tween_property(sun_light,"energy",new_sun_energy,0.5)
		create_tween().tween_property(self,"heat_stength",new_hot_strength,0.5)
		await process_tween.finished
	current_hot_sun_step = new_step
	pass


func stage_wave(wave_count: int):
	await get_tree().create_timer(1,false).timeout
	translate_to_sun_step(wave_hot_sun_steps[wave_count-1])
	pass


func _on_heat_timer_timeout() -> void:
	if current_hot_sun_step == HotSunStep.None: return
	for hurt_box in hit_area.get_overlapping_areas():
		var ally: Ally = hurt_box.owner
		if !is_immune(ally.get_groups()):
			var damage_buff: PropertyBuff = preload("res://Scenes/Buffs/EnvironmentBuffs/heat_damage_low_buff.tscn").instantiate()
			if current_hot_sun_step == HotSunStep.Super: 
				damage_buff.buff_blocks[0] = damage_buff.buff_blocks[0].duplicate()
				damage_buff.buff_blocks[0].operation_data = 0.5
			var damage: int = 0 if current_hot_sun_step == HotSunStep.Small else 1
			ally.take_damage(damage,DataProcess.DamageType.TrueDamage,0,false)
			ally.buffs.add_child(damage_buff)
	pass # Replace with function body.


func is_immune(unit_groups: Array[StringName]) -> bool:
	for group in unit_groups:
		if group in immune_groups: return true
	return false
	pass


func on_win():
	await get_tree().create_timer(2,false).timeout
	translate_to_sun_step(HotSunStep.None)
	pass
