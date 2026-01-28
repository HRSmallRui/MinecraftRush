extends BombardTowerSprite

@export var explosion_effect_marker_group: Array[Marker2D]
@export var nuclear_effect_color: Color

@onready var nuclear_relase: AudioStreamPlayer = $NuclearRelase
@onready var plane_timer: Timer = $PlaneTimer
@onready var plane_sprite: Sprite2D = $Skill1Mask/PlaneSprite
@onready var skill_1_animation_player: AnimationPlayer = $Skill1AnimationPlayer
@onready var push_audio: AudioStreamPlayer = $PushAudio
@onready var pull_audio: AudioStreamPlayer = $PullAudio
@onready var glass_audio: AudioStreamPlayer = $GlassAudio
@onready var air_audio: AudioStreamPlayer = $AirAudio
@onready var skill_2_condition_area: Area2D = $"../Skill2ConditionArea"
@onready var skill_2_hit_area: Area2D = $"../Skill2HitArea"
@onready var dot_timer: Timer = $DotTimer
@onready var dot_during_timer: Timer = $DotDuringTimer


func summon_bullet(summon_pos: Vector2, target_pos: Vector2) -> Shell:
	var shell: Shell = super(summon_pos,target_pos)
	nuclear_relase.play(0.4)
	glass_audio.play()
	var smoke: AnimatedSprite2D = preload("res://Scenes/Effects/bullet_explosion_effect.tscn").instantiate()
	smoke.position = summon_marker.global_position
	Stage.instance.bullets.add_child(smoke)
	return shell
	pass


func _process(delta: float) -> void:
	var plane_condition_area: Area2D = tower.linked_areas[1]
	if plane_condition_area.has_overlapping_bodies() and tower.tower_skill_levels[0] > 0 and plane_timer.is_stopped():
		var linked_enemy: Enemy = get_latest_enemy()
		if linked_enemy != null:
			plane_timer.start()
			release_TNT_plane(linked_enemy)
	pass


func release_TNT_plane(target_enemy: Enemy):
	skill_1_animation_player.play("open")
	push_audio.play()
	plane_sprite.show()
	
	var tnt_plane: NuclearTNTPlane = preload("res://Scenes/DefenceTowers/BombardTowers/TowerComponents/tnt_plane.tscn").instantiate()
	var enemy_path: EnemyPath = target_enemy.get_parent()
	tnt_plane.move_path = enemy_path.curve
	tnt_plane.progress = clampf(target_enemy.progress + 160, 0, enemy_path.curve.get_baked_length())
	tnt_plane.position = plane_sprite.global_position
	tnt_plane.level = tower.tower_skill_levels[0]
	
	await skill_1_animation_player.animation_finished
	plane_sprite.hide()
	
	Stage.instance.allys.add_child(tnt_plane)
	skill_1_animation_player.play_backwards("open")
	pull_audio.play()
	pass


func get_latest_enemy() -> Enemy:
	var enemy_list: Array[Enemy]
	for body in tower.linked_areas[1].get_overlapping_bodies():
		var enemy: Enemy = body.owner
		if !"special" in enemy.get_groups():
			enemy_list.append(enemy)
	if enemy_list.is_empty(): return null
	var back_enemy: Enemy = enemy_list[0]
	for enemy in enemy_list:
		if enemy.progress_ratio > back_enemy.progress_ratio:
			back_enemy = enemy
	return back_enemy
	pass


func frame_condition():
	super()
	if animation == "skill2" and frame == 17:
		skill2_release()
	pass


func skill2_release():
	air_audio.play()
	glass_audio.play()
	for marker:Marker2D in explosion_effect_marker_group:
		var explosion_effect: AnimatedSprite2D = preload("res://Scenes/Effects/bullet_explosion_effect.tscn").instantiate()
		explosion_effect.position = marker.global_position
		Stage.instance.bullets.add_child(explosion_effect)
		var nuclear_potion_effect: LingeringPotionShooter = preload("res://Scenes/Effects/lingering_potion_shooter.tscn").instantiate()
		nuclear_potion_effect.position = marker.global_position
		nuclear_potion_effect.potion_color = nuclear_effect_color
		nuclear_potion_effect.exist_time = dot_during_timer.wait_time
		nuclear_potion_effect.showing_length = 50
		Stage.instance.bullets.add_child(nuclear_potion_effect)
	AudioManager.instance.play_explosion_audio()
	
	var explosion_damage: int
	match tower.tower_skill_levels[1]:
		1: explosion_damage = randi_range(120,140)
		2: explosion_damage = randi_range(160,180)
		3: explosion_damage = randi_range(200,240)
	for body in skill_2_hit_area.get_overlapping_bodies():
		var enemy: Enemy = body.owner
		enemy.take_damage(explosion_damage,DataProcess.DamageType.TrueDamage,0,false,null,true,true)
	
	dot_timer.start()
	dot_during_timer.start()
	pass


func _on_dot_during_timer_timeout() -> void:
	dot_timer.stop()
	pass # Replace with function body.


func _on_dot_timer_timeout() -> void:
	var damage: int
	match tower.tower_skill_levels[1]:
		1: damage = 6
		2: damage = 8
		3: damage = 10
	
	for body in skill_2_hit_area.get_overlapping_bodies():
		var enemy: Enemy = body.owner
		enemy.take_damage(damage,DataProcess.DamageType.TrueDamage,0,false,null,false,true)
	pass # Replace with function body.
