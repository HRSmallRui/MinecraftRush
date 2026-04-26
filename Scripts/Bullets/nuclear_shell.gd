extends Shell


func shell_enemy_take_damage(enemy: Enemy, shell_damage: int):
	super(enemy,shell_damage)
	if enemy.enemy_state != Enemy.EnemyState.DIE:
		var nuclear_dot_debuff: DotBuff = preload("res://Scenes/Buffs/TowerBuffs/nuclear_dot.tscn").instantiate()
		var nuclear_damage_debuff: PropertyBuff = preload("res://Scenes/Buffs/TowerBuffs/nuclear_damage_debuff.tscn").instantiate()
		enemy.buffs.add_child(nuclear_damage_debuff)
		enemy.buffs.add_child(nuclear_dot_debuff)
	pass
