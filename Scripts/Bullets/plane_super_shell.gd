extends Bullet


func enemy_take_damage(enemy: Enemy):
	var plane_kill_debuff: BuffClass = preload("res://Scenes/Buffs/TowerBuffs/plane_kill_debuff.tscn").instantiate()
	plane_kill_debuff.buff_level = special_skill_level
	enemy.buffs.add_child(plane_kill_debuff)
	pass
