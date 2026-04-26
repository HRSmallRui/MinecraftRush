extends Sprite2D


@export var fuchen: Hero
@export var trace_area: Area2D

@onready var rotation_player: AnimationPlayer = $RotationPlayer
@onready var move_player: AnimationPlayer = $MovePlayer
@onready var path_navigation_agent: NavigationAgent2D = $PathNavigationAgent
@onready var skill_3_audio: AudioStreamPlayer = $Skill3Audio
@onready var ray_audio: AudioStreamPlayer = $RayAudio
@onready var elec_audio: AudioStreamPlayer = $ElecAudio

var ally_sprite: AnimatedSprite2D
var skill_4_linked_enemy: Enemy
var current_ray: ProtectorChurchRay
var move_point: FuchenRayMovePoint


func _ready() -> void:
	await get_tree().process_frame
	ally_sprite = fuchen.ally_sprite
	
	ally_sprite.frame_changed.connect(hero_frame_changed)
	ally_sprite.animation_changed.connect(on_sprite_update_animation)
	pass


func hero_frame_changed():
	if ally_sprite.animation == "far_attack" and ally_sprite.frame == 17:
		shoot()
	if ally_sprite.animation == "skill3" and ally_sprite.frame == 21:
		skill_3_release()
		skill_3_audio.play()
		AudioManager.instance.magic_shot_audio.play()
	pass


func on_sprite_update_animation():
	match ally_sprite.animation:
		"far_attack","skill3","skill4_start","skill4_loop":
			rotation_player.speed_scale = 2
			move_player.speed_scale = 0.5
		_:
			rotation_player.speed_scale = 1
			move_player.speed_scale = 1
	
	if ally_sprite.animation == "die":
		create_tween().tween_property(self,"modulate:a",0,0.4)
	if ally_sprite.animation == "rebirth":
		create_tween().tween_property(self,"modulate:a",1,0.4)
	if ally_sprite.animation == "skill4_loop":
		skill_4_release()
	pass


func shoot():
	if fuchen.far_attack_target_enemy == null: return
	var summon_pos:Vector2 = global_position
	var target_pos: Vector2 = fuchen.far_attack_target_enemy.hurt_box.global_position
	target_pos += fuchen.far_attack_target_enemy.direction * fuchen.far_attack_target_enemy.current_data.unit_move_speed * 2
	var damage: int = randi_range(fuchen.current_data.far_damage_low,fuchen.current_data.far_damage_high)
	var bullet: Bullet = fuchen.summon_bullet(fuchen.far_attack_bullet_scene,summon_pos,target_pos,damage,DataProcess.DamageType.MagicDamage)
	Stage.instance.bullets.add_child(bullet)
	AudioManager.instance.magic_shot_audio.play()
	pass


func skill_3_release():
	fuchen.get_exp(fuchen.skill3_exp_get[fuchen.skill_levels[3]-1])
	var loop_count: int = HeroSkillLibrary.hero_skill_data_library[1][3].magic_ball_count[fuchen.skill_levels[3]-1]
	var in_range_list: Array[Enemy]
	for body in trace_area.get_overlapping_bodies():
		var enemy:Enemy = body.owner
		in_range_list.append(enemy)
	for i in loop_count:
		var magic_ball: Bullet = preload("res://Scenes/Bullets/fuchen_skill_3_bullet.tscn").instantiate()
		magic_ball.position = global_position
		magic_ball.damage = HeroSkillLibrary.hero_skill_data_library[1][3].damage
		if in_range_list.size() > 0:
			var target_position: Vector2 = in_range_list[0].hurt_box.global_position
			magic_ball.target_position = target_position
			in_range_list = erase_enemy_list(in_range_list)
		else:
			var map = path_navigation_agent.get_navigation_map()
			var random_point: Vector2 = NavigationServer2D.map_get_random_point(map,path_navigation_agent.navigation_layers,true)
			magic_ball.target_position = random_point
		Stage.instance.bullets.add_child(magic_ball)
	pass


func erase_enemy_list(enemy_list: Array[Enemy]) -> Array[Enemy]:
	var new_list: Array[Enemy] = enemy_list.duplicate()
	var base_enemy: Enemy = enemy_list[0]
	for enemy in enemy_list:
		if (enemy.global_position - base_enemy.global_position).length() < 40:
			new_list.erase(enemy)
	
	return new_list
	pass


func skill_4_release():
	ray_audio.play()
	elec_audio.play()
	
	current_ray = preload("res://Scenes/DefenceTowers/MagicTower/TowerComponents/protector_church_ray.tscn").instantiate()
	move_point = preload("res://Scenes/Allys/Heroes/fuchen_ray_move_point.tscn").instantiate()
	var enemy_path: EnemyPath = skill_4_linked_enemy.get_parent()
	var new_progress: float = skill_4_linked_enemy.progress + 40
	new_progress = clampf(new_progress,0,enemy_path.curve.get_baked_length())
	move_point.damage = HeroSkillLibrary.hero_skill_data_library[1][4].damage_per_count[fuchen.skill_levels[4]-1]
	enemy_path.add_child(move_point)
	move_point.progress = new_progress
	move_point.linked_hero = fuchen
	current_ray.start_point = self
	current_ray.end_point = move_point
	
	current_ray.z_index += 1
	Stage.instance.bullets.add_child(current_ray)
	current_ray.end_point_particle.get_child(0).scale *= 3
	move_point.end.connect(skill_4_stop)
	pass


func _on_skill_4_duration_timer_timeout() -> void:
	skill_4_stop()
	pass # Replace with function body.


func _on_fuchen_get_skill_4_linked_enemy(enemy: Enemy) -> void:
	skill_4_linked_enemy = enemy
	pass # Replace with function body.


func skill_4_stop():
	ray_audio.stop()
	elec_audio.stop()
	if current_ray != null:
		current_ray.disappear()
	if ally_sprite.animation == "skill4_loop":
		ally_sprite.play("skill4_end")
	if move_point != null:
		move_point.queue_free()
	pass
