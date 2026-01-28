extends Node2D
class_name PotionParticleEffect

@export var particle_texture: Texture
@export var particle_color: Color = Color.WHITE
@export var texture_modulate: Color
@export var particle_size_rate: float = 1
@export var particle_z_index: int = 0
@export var move_length: float = 80

@onready var particle_sprite: Sprite2D = $ParticleSprite


func _ready() -> void:
	if particle_texture == null:
		particle_sprite.modulate = particle_color
	else:
		particle_sprite.texture = particle_texture
		particle_sprite.modulate = texture_modulate
	
	particle_sprite.scale *= particle_size_rate
	particle_sprite.z_index = particle_z_index
	create_tween().tween_property(particle_sprite,"position:y",particle_sprite.position.y - move_length,0.5 * (move_length / 80))
	create_tween().tween_property(self,"modulate:a",0,0.5)
	await get_tree().create_timer(1,false).timeout
	queue_free()
	pass
