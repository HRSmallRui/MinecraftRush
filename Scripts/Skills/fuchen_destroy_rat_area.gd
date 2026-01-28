extends Area2D


@onready var ray: Line2D = $Ray
@onready var end_point_particle: GPUParticles2D = $Ray/EndPointParticle
@onready var damage_timer: Timer = $DamageTimer


func _ready() -> void:
	modulate.a = 0
	ray.width = 0
	create_tween().tween_property(self,"modulate:a",1,damage_timer.wait_time)
	create_tween().tween_property(ray,"width",40,damage_timer.wait_time)
	await damage_timer.timeout
	for hurt_box in get_overlapping_areas():
		var enemy:Enemy = hurt_box.owner
		enemy.take_damage(120,DataProcess.DamageType.MagicDamage,0,)
	
	await get_tree().create_timer(0.5,false).timeout
	damage_timer.start()
	create_tween().tween_property(self,"modulate:a",0,damage_timer.wait_time)
	create_tween().tween_property(ray,"width",0,damage_timer.wait_time)
	await damage_timer.timeout
	queue_free()
	pass
