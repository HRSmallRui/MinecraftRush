extends Shooter


func anim_offset():
	match animation:
		"idle_front","shoot_front":
			offset = Vector2(-7,0) if flip_h else Vector2.ZERO
		"shoot_back":
			offset = Vector2(-9,-1) if flip_h else Vector2(5,-1)
	pass
