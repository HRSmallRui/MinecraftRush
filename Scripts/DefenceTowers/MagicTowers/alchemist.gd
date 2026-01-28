extends Magician

@export var alchemist_tower: AlchemistTower

@onready var summon_marker: Marker2D = $SummonMarker

var locked_enemy: Enemy


func anim_offset():
	magic_heart.position = summon_marker.position
	match animation:
		"idle_front","shoot_front":
			offset = Vector2.ZERO
		"shoot_back":
			offset = Vector2(-2,-1)
	pass


func summon_bullet(summon_pos: Vector2, target_pos: Vector2):
	var magic_ball = load("res://Scenes/Bullets/orange_magic_ball.tscn").instantiate() as Bullet
	magic_ball.position = summon_pos
	magic_ball.target_position = target_pos
	magic_ball.damage = randi_range(tower.current_data.damage_low,tower.current_data.damage_high)
	magic_ball.source = tower
	if Stage.instance.stage_sav.upgrade_sav[2] >= 2 and randf_range(0,1) <= 0.12:
		magic_ball.damage_type = DataProcess.DamageType.TrueDamage
	magic_ball.bullet_special_tag_levels["fly"] = true
	if locked_enemy != null:
		if locked_enemy.unit_body.get_collision_layer_value(6):
			magic_ball.bullet_special_tag_levels["fly"] = false
	
	Stage.instance.bullets.add_child(magic_ball)
	pass


func frame_condition():
	if frame == summon_frame and "shoot" in animation:
		
		var enemy: Enemy
		if tower.target_list.size() > 0:
			enemy = get_lateset_enemy(tower.target_list)
		elif tower.last_target != null:
			enemy = tower.last_target
		else: return
		locked_enemy = enemy
		AudioManager.instance.witch_shot_audio.play()
		var before_frame = frame+1
		if enemy.position.y < tower.position.y: play("shoot_back")
		else: play("shoot_front")
		frame = before_frame
		
		var summon_pos: Vector2 = magic_heart.global_position
		var target_pos: Vector2 = enemy.hurt_box.global_position + enemy.direction * enemy.current_data.unit_move_speed * 1.5
		
		summon_bullet(summon_pos,target_pos)
	
	if frame == summon_frame and "skill1" in animation:
		
		var enemy: Enemy = alchemist_tower.get_valid_skill1_enemy()
		if enemy == null: return
		
		AudioManager.instance.magic_shoot_heavy_audio.play()
		var before_frame = frame+1
		if enemy.position.y < tower.position.y: play("skill1_back")
		else: play("skill1_front")
		frame = before_frame
		
		var summon_pos: Vector2 = global_position + Vector2(0,-10)
		var target_pos: Vector2 = enemy.hurt_box.global_position + enemy.direction * enemy.current_data.unit_move_speed * 1.3
		
		summon_golen_bullet(summon_pos,target_pos)
	
	if frame == summon_frame and "skill2" in animation:
		
		var ally_list: Array[Ally] = alchemist_tower.get_valid_skill2_allys()
		if ally_list.is_empty(): return
		
		AudioManager.instance.shoot_audio_1.play()
		for ally in ally_list:
			if ally == null: continue
			summon_support_potion(magic_heart.global_position,ally.hurt_box.global_position)
	pass


func summon_golen_bullet(summon_pos: Vector2, target_pos: Vector2):
	var magic_ball = load("res://Scenes/Bullets/orange_magic_ball_gold.tscn").instantiate() as Bullet
	magic_ball.position = summon_pos
	magic_ball.target_position = target_pos
	#magic_ball.damage = randi_range(tower.current_data.damage_low,tower.current_data.damage_high)
	magic_ball.source = tower
	if Stage.instance.stage_sav.upgrade_sav[2] >= 2 and randf_range(0,1) <= 0.12:
		magic_ball.damage_type = DataProcess.DamageType.TrueDamage
	magic_ball.special_skill_level = tower.tower_skill_levels[0]
	
	Stage.instance.bullets.add_child(magic_ball)
	pass


func summon_support_potion(summon_pos: Vector2, target_pos: Vector2):
	var support_potion: Bullet = load("res://Scenes/Bullets/alchemist_support_bullet.tscn").instantiate() as Bullet
	support_potion.position = summon_pos
	support_potion.target_position = target_pos
	support_potion.special_skill_level = tower.tower_skill_levels[1]
	Stage.instance.bullets.add_child(support_potion)
	pass
