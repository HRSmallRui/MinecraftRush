extends ShooterBullet



func enemy_take_damage(enemy: Enemy):
	AudioManager.instance.black_stone_hit_audio.play()
	if enemy != null:
		var dizness_buff: PropertyBuff = preload("res://Scenes/Buffs/TowerBuffs/bombard_dizness_buff.tscn").instantiate()
		dizness_buff.duration = 1
		dizness_buff.unit = enemy
		enemy.buffs.add_child(dizness_buff)
	super(enemy)
	pass


func after_attack_process(unit: Node2D):
	super(unit)
	if unit == null: return
	if unit is Enemy:
		var show_text: String
		match randi_range(0,1):
			0: show_text = "𪠽！"
			1: show_text = "砰！"
		TextEffect.text_effect_show(show_text,TextEffect.TextEffectType.Arrow,position + Vector2(0,-10))
	pass
