extends Node2D
class_name LingeringPotionShooter

@export var potion_color: Color = Color.WHITE
@export var potion_texture: Texture
@export var texture_modulate: Color = Color.WHITE
@export var exist_time: float = 10
@export var showing_length: float = 10
@export var move_length: float = 80
@export var interval_time: float = 0.1

@onready var during_timer: Timer = $DuringTimer
@onready var shooting_timer: Timer = $ShootingTimer


func _ready() -> void:
	during_timer.wait_time = exist_time
	during_timer.start()
	shooting_timer.wait_time = interval_time
	pass


func _on_during_timer_timeout() -> void:
	queue_free()
	pass # Replace with function body.


func _on_shooting_timer_timeout() -> void:
	var potion_particle: PotionParticleEffect = preload("res://Scenes/Effects/potion_particle_component.tscn").instantiate()
	potion_particle.particle_color = potion_color
	potion_particle.particle_texture = potion_texture
	potion_particle.position = global_position
	potion_particle.texture_modulate = texture_modulate
	var offset_position: Vector2 = Vector2(randf_range(-1,1),randf_range(-1,1))
	offset_position = offset_position.normalized()
	offset_position *= randf_range(0,showing_length)
	potion_particle.position += offset_position
	potion_particle.move_length = move_length
	Stage.instance.bullets.add_child(potion_particle)
	pass # Replace with function body.
