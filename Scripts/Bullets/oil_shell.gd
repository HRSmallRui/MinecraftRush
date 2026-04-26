extends Shell


func after_attack_process(unit: Node2D):
	super(unit)
	var oil: SkillConditionArea2D = preload("res://Scenes/Skills/oil_area.tscn").instantiate()
	oil.position = global_position
	oil.skill_level = special_skill_level
	Stage.instance.bullets.add_child(oil)
	pass


func shell_enemy_take_damage(enemy: Enemy, shell_damage: int):
	super(enemy,shell_damage)
	var dizness_buff: DiznessBuff = preload("res://Scenes/Buffs/dizness_buff.tscn").instantiate()
	dizness_buff.buff_tag = "oil_dizness"
	dizness_buff.duration = 2
	enemy.buffs.add_child(dizness_buff)
	pass
