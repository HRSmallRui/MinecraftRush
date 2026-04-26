extends PercentageDamageBullet


func after_attack_process(unit: Node2D):
	super(unit)
	if unit == null: return
	if unit is Enemy:
		TextEffect.text_effect_show("重创！",TextEffect.TextEffectType.SecKill,position + Vector2(0,-10))
	
	pass
