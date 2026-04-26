extends EnemyTowerShooter


func summon_bullet(summon_pos: Vector2, target_pos: Vector2):
	super(summon_pos,target_pos)
	AudioManager.instance.shoot_audio_1.play()
	pass


func anim_offset():
	match animation:
		"idle","shoot_back","shoot_front":
			offset = Vector2.ZERO
		"die":
			offset = Vector2(18,0) if flip_h else Vector2(-18,0)
	pass
