extends Area2D
class_name HideArea


func _ready() -> void:
	body_entered.connect(enemy_body_in)
	body_exited.connect(enemy_body_out)
	pass


func enemy_body_in(body: UnitBody):
	var enemy: Enemy = body.owner
	enemy.enemy_hide()
	pass


func enemy_body_out(body: UnitBody):
	var enemy: Enemy = body.owner
	if enemy != null:
		enemy.enemy_show()
	pass
