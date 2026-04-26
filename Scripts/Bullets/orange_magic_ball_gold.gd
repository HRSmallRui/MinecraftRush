extends MagicBall

var golden_during_time: float
var bounty_rate: float


func _ready() -> void:
	super()
	match special_skill_level:
		1: 
			golden_during_time = 4
			bounty_rate = 1.5
		2: 
			golden_during_time = 7
			bounty_rate = 1.75
		3: 
			golden_during_time = 10
			bounty_rate = 2
	pass


func enemy_take_damage(enemy: Enemy):
	#super(enemy)
	if "special" in enemy.get_groups(): return
	if enemy.enemy_type > Enemy.EnemyType.Super: return
	if enemy.enemy_type < Enemy.EnemyType.MiniBoss and !"special" in enemy.get_groups():
		var golden_golem: Enemy = preload("res://Scenes/DefenceTowers/MagicTower/TowerComponents/golden_golem.tscn").instantiate()
		golden_golem.origin_enemy = enemy
		golden_golem.position = enemy.position
		golden_golem.progress = enemy.progress
		golden_golem.bounty = float(enemy.bounty) * bounty_rate
		golden_golem.enemy_type = maxi(enemy.enemy_type,Enemy.EnemyType.Big)
		var enemy_path:Node = enemy.get_parent()
		enemy_path.add_child(golden_golem)
		enemy_path.remove_child(enemy)
		golden_golem.relay_timer.wait_time = golden_during_time
		golden_golem.relay_timer.start()
		if Stage.instance.information_bar.current_check_member == enemy:
			Stage.instance.ui_process(golden_golem)
		#golden_golem.start_data.health = float(enemy.start_data.health) * 0.5
		#golden_golem.current_data = golden_golem.start_data.duplicate(true)
		#golden_golem.current_data.owner = golden_golem
		#golden_golem.start_data.owner = golden_golem
		#golden_golem.current_data.start_data = golden_golem.start_data
		#golden_golem.current_data.die.connect(golden_golem.die)
		#golden_golem.current_data.health = float(enemy.current_data.health) * 0.5
		for ally in enemy.current_intercepting_units:
			ally.current_intercepting_enemy = null
		enemy.current_intercepting_units.clear()
		enemy.clear_buff()
		#golden_golem.current_intercepting_units = enemy.current_intercepting_units.duplicate()
	pass
