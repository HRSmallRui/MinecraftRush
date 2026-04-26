extends TextureProgressBar

@export var enemy: Enemy


func _process(delta: float) -> void:
	value = float(enemy.current_data.health ) / float(enemy.start_data.health)
	visible = enemy.current_data.health < enemy.start_data.health and enemy.enemy_state != Enemy.EnemyState.DIE
	pass
