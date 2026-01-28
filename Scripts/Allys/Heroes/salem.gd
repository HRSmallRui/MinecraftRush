extends Hero

@onready var magic_ball: Sprite2D = $UnitBody/MagicBall
@onready var magic_ball_animation_player: AnimationPlayer = $UnitBody/MagicBallAnimationPlayer
@onready var normal_attack_audio: AudioStreamPlayer = $NormalAttackAudio
@onready var skill_2_timer: Timer = $Skill2Timer
@onready var skill_2_area: Area2D = $UnitBody/Skill2Area
@onready var skill_2_hit_area: Area2D = $UnitBody/Skill2HitArea
@onready var skill_4_marker: Marker2D = $UnitBody/Skill4Marker
@onready var skill_4_marker_flip: Marker2D = $UnitBody/Skill4MarkerFlip
@onready var salem_big_ball: Sprite2D = $UnitBody/SalemBigBall
@onready var skill_4_timer: Timer = $Skill4Timer
@onready var skill_4_area: Area2D = $UnitBody/Skill4Area

var skill2_locked_enemy: Enemy
var skill4_locked_enemy: Enemy


func _ready() -> void:
	super()
	skill_2_timer.wait_time = HeroSkillLibrary.hero_skill_data_library[ally_id][2].CD
	skill_4_timer.wait_time = HeroSkillLibrary.hero_skill_data_library[ally_id][4].CD
	salem_big_ball.hide()
	salem_big_ball.scale = Vector2.ZERO
	salem_big_ball.modulate.a = 0
	pass


func start_data_process():
	super()
	match hero_level:
		1,2,3,4,5,6,7,8:
			skill_levels[0] = 1
		9,10:
			skill_levels[0] = 2
	pass


func anim_offset():
	match ally_sprite.animation:
		"idle","attack":
			ally_sprite.position = Vector2(0,-115)
		"die":
			ally_sprite.position = Vector2(-75,-100) if ally_sprite.flip_h else Vector2(70,-100)
		"far_attack":
			ally_sprite.position = Vector2(0,-115)
		"move":
			ally_sprite.position = Vector2(5,-115) if ally_sprite.flip_h else Vector2(-5,-115)
		"rebirth":
			ally_sprite.position = Vector2(10,-115) if ally_sprite.flip_h else Vector2(-10,-115)
		"skill2":
			ally_sprite.position = Vector2(-25,-115) if ally_sprite.flip_h else Vector2(20,-115)
		"skill4":
			ally_sprite.position = Vector2(-15,-115) if ally_sprite.flip_h else Vector2(15,-115)
	
	magic_ball.position = far_attack_marker_flip.position if ally_sprite.flip_h else far_attack_marker.position
	pass


func frame_changed():
	if ally_sprite.animation == "attack" and ally_sprite.frame == 7:
		var damage: int = randi_range(current_data.near_damage_low,current_data.near_damage_high)
		normal_attack_audio.play()
		if current_intercepting_enemy != null:
			if current_intercepting_enemy.take_damage(damage,DataProcess.DamageType.MagicDamage,0,false,self,false,false,):
				@warning_ignore("narrowing_conversion")
				get_exp(float(damage) * hero_property_block.xp_speed_rate)
	
	if ally_sprite.animation == "far_attack":
		if ally_sprite.frame == 4:
			magic_ball_animation_player.play("shoot")
		if ally_sprite.frame == 12:
			far_attack_frame(DataProcess.DamageType.MagicDamage)
			AudioManager.instance.witch_shot_audio.play()
	
	if ally_sprite.animation == "skill2" and ally_sprite.frame == 10:
		if skill2_locked_enemy == null: return
		skill2_locked_enemy.disappear_kill()
		skill_2_hit_area.global_position = skill2_locked_enemy.global_position
		var dust: Node2D = preload("res://Scenes/Effects/dust_effect.tscn").instantiate()
		dust.position = skill2_locked_enemy.global_position
		Stage.instance.bullets.add_child(dust)
		var explosion_effect: AnimatedSprite2D = preload("res://Scenes/Effects/bullet_explosion_effect.tscn").instantiate()
		explosion_effect.position = dust.position
		explosion_effect.modulate = Color.DARK_GREEN
		Stage.instance.bullets.add_child(explosion_effect)
		AudioManager.instance.play_explosion_audio()
		get_exp(skill2_exp_get[skill_levels[2]-1])
		await get_tree().physics_frame
		await get_tree().physics_frame
		for body in skill_2_hit_area.get_overlapping_bodies():
			var enemy: Enemy = body.owner
			var damage: int = HeroSkillLibrary.hero_skill_data_library[ally_id][2].damage[skill_levels[2]-1]
			enemy.take_damage(damage,DataProcess.DamageType.TrueDamage,0,false,null,true,true,)
	
	if ally_sprite.animation == "skill4" and ally_sprite.frame == 20:
		salem_big_ball.hide()
		salem_big_ball.modulate.a = 0
		if skill4_locked_enemy == null: return
		AudioManager.instance.magic_shoot_heavy_audio.play()
		var salem_big_bullet: Bullet = summon_bullet(preload("res://Scenes/Bullets/salem_big_ball.tscn"),salem_big_ball.global_position,skill4_locked_enemy.hurt_box.global_position,0,DataProcess.DamageType.MagicDamage)
		salem_big_bullet.special_skill_level = skill_levels[4]
		salem_big_bullet.bullet_special_tag_levels["passive"] = skill_levels[0]
		salem_big_bullet.bullet_special_tag_levels["explosion"] = skill_levels[1]
		Stage.instance.bullets.add_child(salem_big_bullet)
	pass


func summon_bullet(bullet_scene: PackedScene,summon_pos: Vector2, target_pos: Vector2, damage: int, damage_type: DataProcess.DamageType) -> Bullet:
	var bullet: Bullet = super(bullet_scene,summon_pos,target_pos,damage,damage_type)
	
	if bullet_scene == far_attack_bullet_scene:
		bullet.special_skill_level = skill_levels[0]
		bullet.bullet_special_tag_levels["explosion"] = skill_levels[1]
		bullet.bullet_special_tag_levels["aoe"] = skill_levels[3]
	
	return bullet
	pass


func idle_process():
	if skill_2_timer.is_stopped() and skill_levels[2] > 0 and skill_2_area.get_overlapping_bodies().size() >= 4:
		var enemy: Enemy = get_skill2_enemy()
		if enemy != null:
			translate_to_new_state(AllyState.SPECIAL)
			ally_sprite.play("skill2")
			skill2_locked_enemy = enemy
			skill_2_timer.start()
			ally_sprite.flip_h = enemy.position.x < position.x
			return
	if skill_4_area.get_overlapping_bodies().size() >= 2 and skill_levels[4] > 0 and skill_4_timer.is_stopped():
		var enemy: Enemy = skill_4_area.get_overlapping_bodies()[0].owner
		skill4_locked_enemy = enemy
		translate_to_new_state(AllyState.SPECIAL)
		ally_sprite.play("skill4")
		skill_4_timer.start()
		ally_sprite.flip_h = enemy.position.x < position.x
		salem_big_ball.position = skill_4_marker_flip.position if ally_sprite.flip_h else skill_4_marker.position
		salem_big_ball.show()
		salem_big_ball.scale = Vector2.ZERO
		create_tween().tween_property(salem_big_ball,"scale",Vector2.ONE,0.4)
		create_tween().tween_property(salem_big_ball,"modulate:a",1,0.4)
		return
	super()
	pass


func get_skill2_enemy() -> Enemy:
	var skill2_enemy_list: Array[Enemy]
	for body in skill_2_area.get_overlapping_bodies():
		var enemy: Enemy = body.owner
		if enemy.enemy_type < Enemy.EnemyType.Super: skill2_enemy_list.append(enemy)
	if skill2_enemy_list.is_empty(): return null
	var back_enemy: Enemy = skill2_enemy_list[0]
	for enemy in skill2_enemy_list:
		if enemy.start_data.health > back_enemy.start_data.health: back_enemy = enemy
		elif enemy.start_data.health == back_enemy.start_data.health and enemy.current_data.health > back_enemy.current_data.health:
			back_enemy = enemy
	
	return back_enemy
	pass


func _process(delta: float) -> void:
	super(delta)
	salem_big_ball.rotation_degrees += 720 * delta
	pass
