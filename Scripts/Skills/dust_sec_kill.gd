extends Area2D
class_name DustSecKillArea2D

var level: int = 1


func _ready() -> void:
	modulate.a = 0
	create_tween().tween_property(self,"modulate:a",1,0.4)
	await get_tree().create_timer(0.3,false).timeout
	var damage: int
	match level:
		1: damage = 400
		2: damage = 600
		3: damage = 800
	
	for unit_body: UnitBody in get_overlapping_bodies():
		var enemy: Enemy = unit_body.owner
		if enemy.enemy_type >= Enemy.EnemyType.Super:
			enemy.take_damage(damage,DataProcess.DamageType.MagicDamage,0,true,null,false,false)
		else:
			Achievement.achieve_int_add("ChurchDust",1,3333)
			enemy.disappear_kill()
			var dust_effect: Sprite2D = preload("res://Scenes/Effects/dust_effect.tscn").instantiate()
			dust_effect.position = enemy.position
			Stage.instance.allys.add_child(dust_effect)
	
	await get_tree().create_timer(0.5,false).timeout
	create_tween().tween_property(self,"modulate:a",0,0.4)
	await get_tree().create_timer(0.6,false).timeout
	queue_free()
	pass
