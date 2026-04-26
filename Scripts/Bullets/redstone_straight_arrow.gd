extends ShooterBullet


func enemy_take_damage(enemy: Enemy):
	super(enemy)
	if randf() < 0.1 and enemy.start_data.armor > 0:
		var broken_armor: float
		match special_skill_level:
			1: broken_armor = 0.04
			2: broken_armor = 0.08
		enemy.start_data.armor = maxf(enemy.start_data.armor - broken_armor, 0)
		enemy.current_data.update_armor()
	pass
