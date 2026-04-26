extends EnemyPath


func on_enemy_summoning(enemy: Enemy):
	var water_particle: AnimatedSprite2D = preload("res://Scenes/Effects/block_particle.tscn").instantiate()
	water_particle.position = enemy.position
	water_particle.modulate = Color(0,0.8,1,0.6)
	Stage.instance.bullets.add_child(water_particle)
	AudioManager.instance.play_water_audio()
	pass
