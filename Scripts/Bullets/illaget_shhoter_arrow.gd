extends ShooterBullet


func enemy_take_damage(enemy: Enemy):
	if "ilagger" in enemy.get_groups():
		damage *= 2
		damage_type = DataProcess.DamageType.TrueDamage
	super(enemy)
	pass
