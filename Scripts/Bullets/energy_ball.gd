extends MagicBall


func enemy_take_damage(enemy: Enemy):
	if Stage.instance.get_current_techno_level(3) >= 5:
		var dizness_buff: PropertyBuff = preload("res://Scenes/Buffs/TowerBuffs/bombard_dizness_buff.tscn").instantiate()
		enemy.buffs.add_child(dizness_buff)
		var tech_level: int = Stage.instance.get_current_techno_level(3)
	super(enemy)
	pass
