extends ShooterBullet


func _ready() -> void:
	free_timer.wait_time = (target_position - self.global_position).length() / bullet_speed
	super()
	pass


func enemy_take_damage(enemy: Enemy):
	if enemy.enemy_type < Enemy.EnemyType.Super:
		enemy.sec_kill(false)
		var kill_effect: Node2D = preload("res://Scenes/Effects/red_sec_kill_effect.tscn").instantiate()
		kill_effect.position = enemy.hurt_box.global_position
		kill_effect.scale *= 2
		Stage.instance.bullets.add_child(kill_effect)
	pass


func after_attack_process(unit: Node2D):
	if unit == null: return
	if unit is Enemy:
		var show_text: String = "秒杀！"
		if unit.enemy_state == Enemy.EnemyState.DIE:
			TextEffect.text_effect_show(show_text,TextEffect.TextEffectType.SecKill,position + Vector2(0,-10))
	pass
