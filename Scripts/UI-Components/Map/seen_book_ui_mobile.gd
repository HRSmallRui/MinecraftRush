extends Control


func _ready() -> void:
	modulate.a = 0
	create_tween().tween_property(self,"modulate:a",1,0.4)
	pass
