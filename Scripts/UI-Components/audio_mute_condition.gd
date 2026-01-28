extends Node


func _process(delta: float) -> void:
	AudioServer.set_bus_mute(1,AudioServer.get_bus_volume_db(1) < -29.9)
	AudioServer.set_bus_mute(2,AudioServer.get_bus_volume_db(2) < -9.9)
	pass
