extends ShooterBullet


func after_attack_process(unit: Node2D):
	if unit == null: return
	if unit is Enemy:
		unit.hurt_audio_play(damage_source)
		var show_text: String
		match randi_range(0,1):
			0: show_text = "嗖！"
			1: show_text = "啪！"
		if unit.enemy_state == Enemy.EnemyState.DIE:
			TextEffect.text_effect_show(show_text,TextEffect.TextEffectType.Magic,position + Vector2(0,-10))
		elif randf_range(0,1) < 0.1:
			TextEffect.text_effect_show(show_text,TextEffect.TextEffectType.Magic,position + Vector2(0,-10))
	pass
