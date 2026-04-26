extends Soldier


func anim_offset():
	match ally_sprite.animation:
		"idle","attack":
			ally_sprite.position = Vector2(-5,-120) if ally_sprite.flip_h else Vector2(5,-120)
		"die":
			ally_sprite.position = Vector2(85,-105) if ally_sprite.flip_h else Vector2(-85,-105)
		"move":
			ally_sprite.position = Vector2(-15,-100) if ally_sprite.flip_h else Vector2(10,-100)
	pass


func frame_changed():
	if ally_sprite.animation == "attack" and ally_sprite.frame == 14:
		cause_damage()
	pass


func soldier_skill_level_up(skill_id: int, skill_level: int):
	super(skill_id,skill_level)
	
	pass


func on_normal_attack_hit(target_enemy: Enemy):
	if soldier_skill_levels[2] > 0 and randf() < 0.4:
		var bleed_buff: DotBuff = preload("res://Scenes/Buffs/Allys/villager_knight_bleed.tscn").instantiate()
		bleed_buff.buff_level = soldier_skill_levels[2]
		target_enemy.buffs.add_child(bleed_buff)
	pass
