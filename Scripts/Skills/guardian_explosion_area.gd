extends Area2D


func _ready() -> void:
	AudioManager.instance.play_explosion_audio()
	Stage.instance.stage_camera.shake(20)
	var explosion_effect: AnimatedSprite2D = preload("res://Scenes/Effects/bullet_explosion_effect.tscn").instantiate()
	explosion_effect.scale *= 2
	explosion_effect.position = position
	Stage.instance.bullets.add_child(explosion_effect)
	
	await get_tree().physics_frame
	await get_tree().physics_frame
	
	var damage: int = randi_range(200,340)
	for body in get_overlapping_bodies():
		var ally: Ally = body.owner
		ally.take_damage(damage,DataProcess.DamageType.MagicDamage,0,false,null,false,true)
	
	queue_free()
	pass
