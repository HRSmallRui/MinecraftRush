extends Area2D
class_name FireHurtArea

@export var smoke_particle_shooters: Array[LingeringPotionShooter]

@onready var exist_timer: Timer = $ExistTimer
@onready var damage_timer: Timer = $DamageTimer
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var texture: Sprite2D = $Texture
@onready var shadow: Sprite2D = $Shadow


var skill_level: int = 1
var in_water: bool = false


func _ready() -> void:
	if in_water:
		texture.hide()
		shadow.show()
	else:
		for shooter in smoke_particle_shooters:
			shooter.queue_free()
	
	match skill_level:
		1: exist_timer.wait_time = 6
		2: exist_timer.wait_time = 12
	exist_timer.start()
	await exist_timer.timeout
	collision_shape.disabled = true
	damage_timer.stop()
	var disappear_tween: Tween = create_tween()
	disappear_tween.tween_property(self,"modulate:a",0,0.2)
	await disappear_tween.finished
	queue_free()
	pass


func _on_damage_timer_timeout() -> void:
	var damage: int
	var broken_rate: float
	match skill_level:
		1: 
			damage = 3
			broken_rate = 0
		2: 
			damage = 5
			broken_rate = 0.5
	for enemy_hurt_box: UnitBody in get_overlapping_bodies():
		var enemy: Enemy = enemy_hurt_box.owner
		enemy.take_damage(damage,DataProcess.DamageType.PhysicsDamage,broken_rate,false,null,false,true)
	pass # Replace with function body.
