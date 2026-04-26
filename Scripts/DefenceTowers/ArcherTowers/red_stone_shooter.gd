extends Shooter


func summon_bullet(summon_pos: Vector2, target_pos: Vector2, bullet_scene: PackedScene = arrow_scene) -> Bullet:
	var bullet: Bullet = super(summon_pos,target_pos,bullet_scene)
	
	bullet.special_skill_level = tower.tower_skill_levels[0]
	return bullet
