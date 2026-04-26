extends Area2D


func _ready() -> void:
	body_entered.connect(on_enemy_body_enter)
	pass


func on_enemy_body_enter(body: UnitBody):
	var enemy: Enemy = body.owner
	if enemy.enemy_id < 10:
		enemy.start_data.unit_move_speed *= 1.5
		enemy.current_data.health *= randf_range(0.2,0.6)
		enemy.current_data.update_move_speed()
	pass
