extends Area2D

@export var camera: Camera2D
@export var min_position: Vector2
@export var max_position: Vector2

var mouse_in: bool


func _input(event: InputEvent) -> void:
	if !mouse_in: return
	if event is InputEventScreenDrag and Map.instance.can_control:
		camera.position -= event.relative * 2
		camera.position.x = clampf(camera.position.x,min_position.x,max_position.x)
		camera.position.y = clampf(camera.position.y,min_position.y,max_position.y)
	pass


func _on_mouse_entered() -> void:
	mouse_in = true
	pass # Replace with function body.


func _on_mouse_exited() -> void:
	mouse_in = false
	pass # Replace with function body.
