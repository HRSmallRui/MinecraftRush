extends ShooterBullet


func _on_free_timer_timeout() -> void:
	super()
	summon_potion_effect()
	pass


func ally_take_damage(ally: Ally):
	#super(ally)
	summon_potion_effect()
	var heal_buff: HealBuff = preload("res://Scenes/Buffs/TowerBuffs/Alchemist/alchemist_heal_buff.tscn").instantiate()
	heal_buff.buff_level = special_skill_level
	ally.buffs.add_child(heal_buff)
	var support_buff: PropertyBuff
	match special_skill_level:
		1: support_buff = load("res://Scenes/Buffs/TowerBuffs/Alchemist/alchemist_support_buff_lv1.tscn").instantiate()
		2: support_buff = load("res://Scenes/Buffs/TowerBuffs/Alchemist/alchemist_support_buff_lv2.tscn").instantiate()
		3: support_buff = load("res://Scenes/Buffs/TowerBuffs/Alchemist/alchemist_support_buff_lv3.tscn").instantiate()
	ally.buffs.add_child(support_buff)
	pass


func summon_potion_effect():
	var potion_effect: AnimatedSprite2D = preload("res://Scenes/Effects/potion_slash_effect_with_audio.tscn").instantiate()
	potion_effect.position = position
	potion_effect.modulate = Color.RED
	potion_effect.scale *= 0.6
	Stage.instance.bullets.add_child(potion_effect)
	pass
