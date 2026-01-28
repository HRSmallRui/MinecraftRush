extends Line2D

@export var point_array: PackedVector2Array

@onready var delay_timer: Timer = $DelayTimer


func _ready() -> void:
	
	pass


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	queue_free()
	pass # Replace with function body.
