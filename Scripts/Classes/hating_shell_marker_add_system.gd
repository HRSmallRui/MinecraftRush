extends Node
class_name HatingShellMarkerAddSystem

@export var adding_wave: int
@export var hating_system: HatingReinforceSystem

var marker_list: Array[Marker2D]

func _ready() -> void:
	for child: Marker2D in get_children():
		marker_list.append(child)
	Stage.instance.wave_summon.connect(on_wave_summon)
	pass


func on_wave_summon(wave_count: int):
	if wave_count == adding_wave:
		hating_system.summon_marker_list += marker_list
	pass
