extends Node2D
class_name PotionParticleLeader

@export var potion_color: Color = Color.WHITE
@export var potion_texture: Texture
@export var buff_vehicle: BuffClass
@export var particle_size_rate: float = 1
@export var particle_z_index: int = 0
@export var min_interval_time: float = 0.1
@export var max_interval_time: float = 0.2


func _ready() -> void:
	await get_tree().process_frame
	while true:
		summon_potion_particle()
		await get_tree().create_timer(randf_range(min_interval_time,max_interval_time),false).timeout
	pass


func summon_potion_particle():
	var base_pos: Vector2
	var unit = buff_vehicle.data_owner.owner
	var sprite_pos: Vector2
	if unit is Ally: 
		base_pos = unit.position
		sprite_pos = unit.hurt_box.global_position
	elif unit is Enemy: 
		base_pos = unit.position
		sprite_pos = unit.hurt_box.global_position
	var potion_particle: PotionParticleEffect = preload("res://Scenes/Effects/potion_particle_component.tscn").instantiate()
	potion_particle.position = base_pos
	potion_particle.particle_texture = potion_texture
	potion_particle.particle_color = potion_color
	potion_particle.particle_size_rate = particle_size_rate
	potion_particle.particle_z_index = particle_z_index
	potion_particle.texture_modulate = potion_color
	
	if unit is Ally: Stage.instance.bullets.add_child(potion_particle)
	elif unit is Enemy: Stage.instance.bullets.add_child(potion_particle)
	potion_particle.particle_sprite.global_position = sprite_pos + Vector2(randf_range(-20,20),0)
	pass
