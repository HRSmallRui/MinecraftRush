extends Area2D

@export var dizness_scene: PackedScene
@export var dizness_duration: float

@onready var ray: Line2D = $Ray


func _ready() -> void:
	ray.scale.x = 0
	create_tween().tween_property(ray,"scale:x",1,0.4)
	await get_tree().physics_frame
	await get_tree().physics_frame
	for body in get_overlapping_bodies():
		var ally: Ally = body.owner
		var damage: int
		if ally.ally_type == Ally.AllyType.Heroes:
			damage = ally.start_data.health * 0.1
		else:
			damage = ally.start_data.health * 0.4
		ally.take_damage(damage,DataProcess.DamageType.TrueDamage,0,)
		var dizness_buff: DiznessBuff = dizness_scene.instantiate()
		dizness_buff.duration = dizness_duration
		ally.buffs.add_child(dizness_buff)
	
	await get_tree().create_timer(1,false).timeout
	var disappear_tween: Tween = create_tween()
	disappear_tween.tween_property(ray,"scale:x",0,0.6)
	await disappear_tween.finished
	queue_free()
	pass
