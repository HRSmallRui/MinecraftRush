extends Shooter

@export var skeleton_archer_tower: SkeletonArcherTower

var sec_kill_arrow_scene: PackedScene = preload("res://Scenes/Bullets/skeleton_seckill_arrow.tscn")


func anim_offset():
	offset = Vector2(-2,0) if flip_h else Vector2(2,0)
	pass


func summon_bullet(summon_pos: Vector2, target_pos: Vector2, bullet_scene: PackedScene = arrow_scene) -> Bullet:
	if skeleton_archer_tower.tower_skill_levels[0] > 0:
		var enemy: Enemy
		if tower.target_list.size() > 0:
			enemy = tower.target_list[0]
		elif tower.last_target != null:
			enemy = tower.last_target
		if randf_range(0,1) < skeleton_archer_tower.current_sec_kill_possible and enemy.enemy_type < Enemy.EnemyType.Super:
			bullet_scene = sec_kill_arrow_scene
			skeleton_archer_tower.current_sec_kill_possible = 0
			AudioManager.instance.shoot_audio_2.play()
			var kill_effect: Node2D = preload("res://Scenes/Effects/red_sec_kill_effect.tscn").instantiate()
			kill_effect.position = summon_pos
			kill_effect.get_node("AnimationPlayer").speed_scale = 2
			Stage.instance.bullets.add_child(kill_effect)
			Achievement.achieve_int_add("SuperSkeleton",1,10)
	
	var arrow = super(summon_pos,target_pos,bullet_scene)
	arrow.broken_rate = 0.5
	
	if skeleton_archer_tower.tower_skill_levels[1] > 0:
		arrow.bullet_special_tag_levels["continue"] = [0.2,1,0.5,bullet_scene] ##穿梭时间，继续穿梭人数，伤害倍率,场景
	
	if skeleton_archer_tower.tower_skill_levels[0] > 0:
		var add_sec_kill_possible: float
		match skeleton_archer_tower.tower_skill_levels[0]:
			1: add_sec_kill_possible = 0.05
			2: add_sec_kill_possible = 0.1
			3: add_sec_kill_possible = 0.15
		skeleton_archer_tower.current_sec_kill_possible += add_sec_kill_possible
		
			
		
	return arrow
	pass
