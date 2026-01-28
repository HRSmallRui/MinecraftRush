extends MagicBall


func enemy_take_damage(enemy: Enemy):
	var hurt_effect: PropertyBuff = preload("res://Scenes/Buffs/TowerBuffs/witch_hurt_debuff.tscn").instantiate()
	enemy.buffs.add_child(hurt_effect)
	super(enemy)
	pass
