extends Node2D
class_name DustStorm

@export var wave_dust_show_time: Array[float]

@onready var sand_group: Node2D = $CanvasLayer/SandGroup
@onready var during_timer: Timer = $DuringTimer


func _ready() -> void:
	Stage.instance.wave_summon.connect(wave_change)
	for sprite: Sprite2D in sand_group.get_children():
		sprite.modulate.a = 0
	pass


func wave_change(wave_count: int):
	if wave_dust_show_time[wave_count-1] > 0:
		show_sand_storm()
		during_timer.wait_time = wave_dust_show_time[wave_count-1]
		during_timer.start()
	pass


func show_sand_storm():
	await get_tree().create_timer(2,false).timeout
	for sprite: Sprite2D in sand_group.get_children():
		var appear_tween: Tween = create_tween()
		appear_tween.tween_property(sprite,"modulate:a",1,0.3)
		await appear_tween.finished
	pass


func hide_sand_storm():
	for sprite: Sprite2D in sand_group.get_children():
		var disappear_tween: Tween = create_tween()
		disappear_tween.tween_property(sprite,"modulate:a",0,0.4)
		await disappear_tween.finished
	pass


func _on_during_timer_timeout() -> void:
	hide_sand_storm()
	pass # Replace with function body.
