extends MagicBall


func ally_take_damage(ally: Ally):
	if ally.ally_type == Ally.AllyType.Soldiers:
		if randf_range(0,1) < 0.3:
			ally.disappear_kill()
			var dust: Node2D = preload("res://Scenes/Effects/dust_effect.tscn").instantiate()
			dust.position = ally.position
			Stage.instance.bullets.add_child(dust)
			return
	super(ally)
	pass
