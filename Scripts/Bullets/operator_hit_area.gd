extends Area2D

@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D

var low_damage: int = 30
var damage: int = 60


func _ready() -> void:
	#var explosion_radius: float = collision_shape_2d.shape.radius
	if Stage.instance.get_current_techno_level(3) >= 4:
		low_damage = damage
	
	await get_tree().physics_frame
	await get_tree().physics_frame
	
	for hurt_box in get_overlapping_areas():
		var enemy: Enemy = hurt_box.owner
		var now_damage: int = randi_range(low_damage,damage)
		#print(now_damage)
		enemy.take_damage(now_damage,DataProcess.DamageType.ExplodeDamage,0,true,self,false,true)
		if Stage.instance.get_current_techno_level(3) >= 5 and randf_range(0,1) < 0.15:
			var dizness_buff: DiznessBuff = preload("res://Scenes/Buffs/dizness_buff.tscn").instantiate()
			enemy.buffs.add_child(dizness_buff)
	pass
