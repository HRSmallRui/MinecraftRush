extends MagicTower
class_name WitchTower

@onready var skill_1_timer: Timer = $Skill1Timer
@onready var skill_2_timer: Timer = $Skill2Timer

var skill_2_locked_enemy: Enemy


func fighting_process():
	if normal_attack_timer.is_stopped():
		if tower_skill_levels[0] > 0 and skill_1_timer.is_stopped():
			skill_1_timer.start()
			var locked_enemy: Enemy
			if target_list.is_empty():
				locked_enemy = last_target
			else:
				locked_enemy = magician.get_lateset_enemy(target_list)
			magician.play("fog_front") if locked_enemy.position.y > position.y else magician.play("fog_back")
			normal_attack_timer.start()
			return
		if tower_skill_levels[1] > 0 and skill_2_timer.is_stopped():
			var enemy: Enemy = get_skill2_enemy(target_list)
			if enemy != null:
				normal_attack_timer.start()
				skill_2_timer.start()
				skill_2_locked_enemy = enemy
				magician.play("curse_front") if skill_2_locked_enemy.position.y > position.y else magician.play("curse_back")
	super()
	pass


func get_skill2_enemy(enemy_list: Array[Enemy]) -> Enemy:
	var array: Array[Enemy] = enemy_list.duplicate()
	for enemy in array:
		if enemy.enemy_type >= Enemy.EnemyType.Super: enemy_list.erase(enemy)
	
	if enemy_list.is_empty(): return null
	else:
		var back_enemy: Enemy = enemy_list[0]
		for enemy: Enemy in enemy_list:
			if enemy.start_data.health > back_enemy.start_data.health: back_enemy = enemy
			elif enemy.start_data.health == back_enemy.start_data.health:
				if enemy.current_data.health < back_enemy.current_data.health: back_enemy = enemy
		return back_enemy
	pass
