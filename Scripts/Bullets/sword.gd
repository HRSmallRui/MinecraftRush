extends ShooterBullet


func after_attack_process(unit: Node2D):
	if unit == null: return
	if unit is Enemy and bullet_special_tags_array.has("CriticalHit"):
		var show_text: String = "暴击！"
		TextEffect.text_effect_show(show_text,TextEffect.TextEffectType.SecKill,position + Vector2(0,-10))
		unit.hurt_audio_play(damage_source)
	else:
		super(unit)
	pass
