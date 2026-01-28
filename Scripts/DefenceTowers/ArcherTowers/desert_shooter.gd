extends Shooter

var critical_possible: float = 0.2


func anim_offset():
	match animation:
		"idle_front","shoot_front":
			offset = Vector2(-10,0) if flip_h else Vector2.ZERO
		"shoot_back":
			offset = Vector2(-6,0) if flip_h else Vector2(-5,0)
	pass

func summon_bullet(summon_pos: Vector2, target_pos: Vector2, bullet_scene: PackedScene = arrow_scene) -> Bullet:
	var bullet: Bullet = super(summon_pos,target_pos,bullet_scene)
	if randf_range(0,1) < critical_possible:
		bullet.damage *= 2
		bullet.broken_rate = 0.8
		bullet.bullet_special_tags_array.append("CriticalHit")
	return bullet
	pass
