extends ShooterBullet


func enemy_take_damage(enemy: Enemy):
	super(enemy)
	var dizness_time: float
	match special_skill_level:
		1: dizness_time = 0.5
		2: dizness_time = 0.6
		3: dizness_time = 0.7
	if randf() < 0.4:
		var dizness_buff: DiznessBuff = preload("res://Scenes/Buffs/dizness_buff.tscn").instantiate()
		dizness_buff.buff_tag = "lama_spit_dizness"
		dizness_buff.duration = dizness_time
		enemy.buffs.add_child(dizness_buff)
	pass
