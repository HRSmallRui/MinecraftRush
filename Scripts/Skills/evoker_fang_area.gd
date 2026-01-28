extends SkillConditionArea2D


func _ready() -> void:
	await get_tree().create_timer(0.2,false).timeout
	for body in get_overlapping_bodies():
		var ally: Ally = body.owner
		ally.take_damage(randi_range(50,60),DataProcess.DamageType.PhysicsDamage,0,false,null,false,true,)
	await get_tree().create_timer(0.5,false).timeout
	queue_free()
	pass
