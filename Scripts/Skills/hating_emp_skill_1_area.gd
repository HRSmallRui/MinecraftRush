extends Area2D


func _ready() -> void:
	await get_tree().physics_frame
	await get_tree().physics_frame
	var lightning: Line2D = preload("res://Scenes/Effects/lightning.tscn").instantiate()
	lightning.position = position
	Stage.instance.bullets.add_child(lightning)
	AudioManager.instance.play_explosion_audio()
	var explosion_effect: AnimatedSprite2D = preload("res://Scenes/Effects/bullet_explosion_effect.tscn").instantiate()
	explosion_effect.position = position
	Stage.instance.bullets.add_child(explosion_effect)
	var smoke_effect: AnimatedSprite2D = preload("res://Scenes/Effects/smoke_effect.tscn").instantiate()
	smoke_effect.position = position
	Stage.instance.bullets.add_child(smoke_effect)
	
	for body in get_overlapping_bodies():
		var ally: Ally = body.owner
		ally.take_damage(400,DataProcess.DamageType.TrueDamage,0,true,null,false,true)
		var dizness_buff: DiznessBuff = preload("res://Scenes/Buffs/dizness_buff.tscn").instantiate()
		dizness_buff.duration = 2
	await get_tree().create_timer(1,false).timeout
	queue_free()
	pass
