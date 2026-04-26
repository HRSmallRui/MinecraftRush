extends Magician

@export var witch_tower: WitchTower


func anim_offset():
	
	pass


func frame_condition():
	if "shoot" in animation and frame == summon_frame:
		var enemy: Enemy
		if tower.target_list.size() > 0:
			enemy = get_lateset_enemy(tower.target_list)
		elif tower.last_target != null:
			enemy = tower.last_target
		else: return
		AudioManager.instance.witch_shot_audio.play()
		var before_frame = frame+1
		if enemy.position.y < tower.position.y: play("shoot_back")
		else: play("shoot_front")
		frame = before_frame
		shoot_process()
		
	if "fog" in animation and frame == summon_frame:
		var enemy: Enemy
		if tower.target_list.size() > 0:
			enemy = get_lateset_enemy(tower.target_list)
		elif tower.last_target != null:
			enemy = tower.last_target
		else: return
		AudioManager.instance.magic_shoot_heavy_audio.play()
		var before_frame = frame+1
		if enemy.position.y < tower.position.y: play("fog_back")
		else: play("fog_front")
		frame = before_frame
		release_fog(enemy)
	
	if "curse" in animation and frame == 12:
		var enemy: Enemy = witch_tower.skill_2_locked_enemy
		if enemy == null: return
		AudioManager.instance.magic_shoot_heavy_audio.play()
		var before_frame = frame-1
		if enemy.position.y < tower.position.y: play("curse_back")
		else: play("curse_front")
		frame = before_frame
		play_backwards()
		release_curse(enemy)
	pass


func witch_summon_bullet(summon_pos: Vector2, target_pos: Vector2, move_type: Bullet.MoveType):
	var magic_ball = load("res://Scenes/Bullets/green_magic_ball.tscn").instantiate() as Bullet
	magic_ball.position = summon_pos
	magic_ball.target_position = target_pos
	magic_ball.source = tower
	magic_ball.move_type = move_type
	magic_ball.damage = randi_range(tower.current_data.damage_low,tower.current_data.damage_high)
	if Stage.instance.stage_sav.upgrade_sav[2] >= 2 and randf_range(0,1) <= 0.12:
		magic_ball.damage_type = DataProcess.DamageType.TrueDamage
	
	Stage.instance.bullets.add_child(magic_ball)
	pass


func shoot_process():
	var normal_enemy_list: Array[Enemy] = tower.target_list.duplicate()
	var hited_enemy_list: Array[Enemy]
	if normal_enemy_list.is_empty():
		lock_enemy(tower.last_target,1)
		lock_enemy(tower.last_target,2)
		return
	var enemy_list: Array[Enemy] = normal_enemy_list.duplicate()
	for enemy in enemy_list:
		if enemy.enemy_buff_tags.has("witch_hurt"):
			normal_enemy_list.erase(enemy)
			hited_enemy_list.append(enemy)
	
	var enemy_1: Enemy
	var enemy_2: Enemy
	
	if normal_enemy_list.is_empty():
		enemy_1 = get_lateset_enemy(hited_enemy_list)
		hited_enemy_list.erase(enemy_1)
		if hited_enemy_list.is_empty(): enemy_2 = enemy_1
		else: enemy_2 = get_lateset_enemy(hited_enemy_list)
	else:
		enemy_1 = get_lateset_enemy(normal_enemy_list)
		normal_enemy_list.erase(enemy_1)
		if normal_enemy_list.is_empty():
			if hited_enemy_list.is_empty(): enemy_2 = enemy_1
			else: enemy_2 = get_lateset_enemy(hited_enemy_list)
		else:
			enemy_2 = get_lateset_enemy(normal_enemy_list)
	
	lock_enemy(enemy_1,1)
	lock_enemy(enemy_2,2)
	pass


func lock_enemy(enemy: Enemy, id: int):
	if enemy == null: return
	var summon_pos: Vector2 = magic_heart.global_position
	summon_pos.x += -10 if id == 1 else 10
	var target_pos: Vector2 = enemy.hurt_box.global_position + enemy.direction * enemy.current_data.unit_move_speed * 2
	witch_summon_bullet(summon_pos,target_pos,Bullet.MoveType.CurveLeft if id == 1 else Bullet.MoveType.CurveRight)
	pass


func release_fog(locked_enemy: Enemy):
	var magic_ball:Bullet = preload("res://Scenes/Bullets/witch_fog_ball.tscn").instantiate()
	magic_ball.position = magic_heart.global_position
	magic_ball.target_position = locked_enemy.hurt_box.global_position + locked_enemy.direction * locked_enemy.current_data.unit_move_speed * 2
	magic_ball.bullet_special_tag_levels["witch_fog"] = tower.tower_skill_levels[0]
	Stage.instance.bullets.add_child(magic_ball)
	pass


func release_curse(locked_enemy: Enemy):
	var curse_dot: DotBuff = preload("res://Scenes/Buffs/TowerBuffs/WitchTower/witch_dead_c_urse_dot.tscn").instantiate()
	curse_dot.buff_level = tower.tower_skill_levels[1]
	var property_buff: PropertyBuff
	match tower.tower_skill_levels[1]:
		1: 
			curse_dot.duration = 5
			property_buff = preload("res://Scenes/Buffs/TowerBuffs/WitchTower/witch_dead_curse_property.tscn").instantiate()
		2: 
			curse_dot.duration = 7
			property_buff = preload("res://Scenes/Buffs/TowerBuffs/WitchTower/witch_dead_curse_property_lv2.tscn").instantiate()
		3: 
			curse_dot.duration = 10
			property_buff = preload("res://Scenes/Buffs/TowerBuffs/WitchTower/witch_dead_curse_property_lv3.tscn").instantiate()
	locked_enemy.buffs.add_child(curse_dot)
	locked_enemy.buffs.add_child(property_buff)
	pass
