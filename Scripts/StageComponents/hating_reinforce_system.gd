extends Node2D
class_name HatingReinforceSystem

static var instance: HatingReinforceSystem

enum Direction{
	FROM_LEFT,
	FROM_RIGHT,
	RANDOM
}

@export var summon_count: Array[int]
@export var shooting_from_list: Array[Direction]
@export var hating_shell_scene: PackedScene
@export var linked_area: Area2D

#@onready var navigation_agent_2d: NavigationAgent2D = $NavigationAgent2D
@onready var shoot_audio: AudioStreamPlayer = $ShootAudio

var current_shooting_from: Direction
var summon_marker_list: Array[Marker2D]


func _init() -> void:
	instance = self
	pass


func _ready() -> void:
	Stage.instance.wave_summon.connect(on_wave_summon)
	for child in get_children():
		if child is Marker2D:
			summon_marker_list.append(child)
	pass


func summon_shell():
	var summon_pos: Vector2
	if randf() < 0.3 or !linked_area.has_overlapping_bodies():
		var marker: Marker2D = summon_marker_list.pick_random() as Marker2D
		summon_pos = marker.global_position
	else:
		var node2d: Node2D = linked_area.get_overlapping_bodies().pick_random().owner
		summon_pos = node2d.global_position
	summon_pos += Vector2(randf_range(-50,50),randf_range(-35,35))
	var shell: Area2D = hating_shell_scene.instantiate()
	shell.position = summon_pos
	Stage.instance.bullets.add_child(shell)
	pass


func on_wave_summon(wave_count: int):
	var wave_summon_count: int = summon_count[wave_count-1]
	current_shooting_from = shooting_from_list[wave_count-1]
	await get_tree().create_timer(10,false).timeout
	for i in wave_summon_count:
		summon_shell()
		await get_tree().create_timer(randf_range(0.3,0.5),false).timeout
	pass
