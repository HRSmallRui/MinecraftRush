extends MagicTower
class_name ProtectorChurch

@export var level_damage_list: Array[DamageBlock]
@export var dust_kill_waiting_time_list: Array[float]

@onready var unit_move_area: Area2D = $UnitMoveArea
@onready var first_move_rays: Node2D = $FirstMoveRays
@onready var ready_attack_timer: Timer = $ReadyAttackTimer
@onready var magic_heart: Sprite2D = $Wizard/MagicHeart
@onready var shot_timer: Timer = $ShotTimer
@onready var security_timer: Timer = $SecurityTimer
@onready var ray_audio: AudioStreamPlayer = $RayAudio
@onready var ray_audio_2: AudioStreamPlayer = $RayAudio2
@onready var dust_kill_timer: Timer = $DustKillTimer
@onready var dust_kill_audio: AudioStreamPlayer = $DustKillAudio
@onready var rotate_animation_player: AnimationPlayer = $Wizard/MagicAnimationPlayer
@onready var loopmove_animation_player: AnimationPlayer = $Wizard/MagicHeart/AnimationPlayer

var golem_position: Vector2
var is_attacking: bool = false
var attack_count: int
var damage_level: int = 0
var current_ray: ProtectorChurchRay
var linked_enemy: Enemy
var iron_golem: SummonAlly


func _ready() -> void:
	super()
	unit_move_area.hide()
	first_move()
	ready_attack_timer.timeout.connect(normal_attack)
	var magic_tech_level: int = clampi(Stage.instance.stage_sav.upgrade_sav[2],0,Stage.instance.limit_tech_level)
	if magic_tech_level >= 5:
		for damage_block in level_damage_list:
			damage_block.damage_low = DataProcess.upgrade_damage(damage_block.damage_low,0.15)
			damage_block.damage_high = DataProcess.upgrade_damage(damage_block.damage_high,0.15)
	pass


func first_move():
	await get_tree().physics_frame
	await get_tree().physics_frame
	for ray: RayCast2D in first_move_rays.get_children():
		if ray.is_colliding():
			var target_pos = ray.get_collision_point() + ray.target_position * 0.5
			golem_position = target_pos
			first_move_rays.queue_free()
			return
	print(golem_position)
	pass


func _on_flag_button_pressed() -> void:
	Stage.instance.ui_process(self,Stage.StageUI.Move)
	ui_animation_player.play("hide_ui")
	unit_move_area.show()
	pass # Replace with function body.


func ui_process(member: Node):
	super(member)
	if member != self:
		unit_move_area.hide()
	pass


func _on_unit_move_area_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event.is_action_released("click") and Stage.instance.mouse_in_path:
		unit_move_area.hide()
		move(Stage.instance.get_local_mouse_position())
		Stage.instance.ui_process(null)
		Stage.instance.move_point_effect(Stage.instance.get_local_mouse_position())
		var flag_effect: AnimatedSprite2D = preload("res://Scenes/Effects/flag_effect.tscn").instantiate()
		flag_effect.position = Stage.instance.get_local_mouse_position()
		Stage.instance.allys.add_child(flag_effect)
	pass # Replace with function body.


func move(target_position: Vector2):
	golem_position = target_position
	if iron_golem != null:
		iron_golem.station_position = target_position
		iron_golem.move(target_position)
	pass


func fighting_process():
	if !is_attacking and tower_skill_levels[1] > 0 and dust_kill_timer.is_stopped():
		is_attacking = true
		magician.play("shoot_front")
		dust_kill_timer.start()
		dust_kill()
	
	if !is_attacking and normal_attack_timer.is_stopped() and ready_attack_timer.is_stopped():
		ready_attack_timer.start()
		is_attacking = true
		var is_front: bool
		if tower_area.has_overlapping_bodies():
			var samples: Array[Enemy]
			for body in tower_area.get_overlapping_bodies():
				var enemy: Enemy = body.owner
				samples.append(enemy)
			linked_enemy = get_highest_health_enemy(samples)
			is_front = linked_enemy.global_position.y > global_position.y
		elif last_target != null:
			is_front = last_target.global_position.y > global_position.y
			linked_enemy = last_target
		magician.play("shoot_front") if is_front else magician.play("shoot_back")
	
	if is_attacking and linked_enemy != null and magician.frame >= 12:
		var current_frame: int = magician.frame
		var is_front: bool = linked_enemy.global_position.y > global_position.y
		magician.play("shoot_front") if is_front else magician.play("shoot_back")
		magician.frame = current_frame
	pass


func normal_attack():
	if linked_enemy == null: return
	loopmove_animation_player.speed_scale = 0.5
	rotate_animation_player.speed_scale = 2
	ray_audio.play()
	ray_audio_2.play()
	attack_count = 0
	damage_level = 0
	shot_timer.start()
	security_timer.start()
	var ray: ProtectorChurchRay = preload("res://Scenes/DefenceTowers/MagicTower/TowerComponents/protector_church_ray.tscn").instantiate()
	ray.start_point = magic_heart
	ray.end_point = linked_enemy.hurt_box
	ray.ray_level = 0
	current_ray = ray
	add_child(ray)
	pass


func _on_shot_timer_timeout() -> void:
	if linked_enemy != null:
		var damage: int = randi_range(current_data.damage_low,current_data.damage_high)
		var damage_type: DataProcess.DamageType = DataProcess.DamageType.MagicDamage
		var magic_tech_level: int = clampi(Stage.instance.stage_sav.upgrade_sav[2],0,Stage.instance.limit_tech_level)
		if magic_tech_level >= 2 and randf_range(0,1) < 0.12:
			damage_type = DataProcess.DamageType.TrueDamage
		linked_enemy.take_damage(damage,damage_type,0,true,self,false,false)
		var level: int = clampi(Stage.instance.stage_sav.upgrade_sav[2],0,Stage.instance.limit_tech_level)
		if level >= 3:
			var broken_buff: PropertyBuff = preload("res://Scenes/Buffs/TowerBuffs/magic_armor_broken_buff.tscn").instantiate()
			linked_enemy.buffs.add_child(broken_buff)
		if level >= 4:
			var speed_low_buff: PropertyBuff = preload("res://Scenes/Buffs/TowerBuffs/magic_speed_low_buff.tscn").instantiate()
			linked_enemy.buffs.add_child(speed_low_buff)
	attack_count += 1
	match attack_count:
		4,8,12,16,20:
			if current_ray != null: current_ray.ray_level += 1
			damage_level_up()
	pass # Replace with function body.


func enemy_body_out(body: UnitBody):
	if !is_inside_tree(): return
	await get_tree().physics_frame
	await get_tree().physics_frame
	super(body)
	var enemy: Enemy = body.owner
	if enemy == linked_enemy and !body in tower_area.get_overlapping_bodies():
		stop_attack()
		security_timer.stop()
	pass


func stop_attack():
	loopmove_animation_player.speed_scale = 1
	rotate_animation_player.speed_scale = 1
	ray_audio.stop()
	ray_audio_2.stop()
	if ready_attack_timer.is_stopped():
		normal_attack_timer.start()
	else:
		normal_attack_timer.stop()
	ready_attack_timer.stop()
	linked_enemy = null
	if current_ray != null:
		current_ray.disappear()
	magician.play_backwards()
	shot_timer.stop()
	start_data = start_data.duplicate()
	start_data.damage_low = level_damage_list[0].damage_low
	start_data.damage_high = level_damage_list[0].damage_high
	current_data.start_data = start_data
	current_data.update_damage()
	await magician.animation_finished
	is_attacking = false
	pass


func damage_level_up():
	damage_level += 1
	start_data = start_data.duplicate()
	start_data.damage_low = level_damage_list[damage_level].damage_low
	start_data.damage_high = level_damage_list[damage_level].damage_high
	current_data.start_data = start_data
	current_data.update_damage()
	pass


func _on_security_timer_timeout() -> void:
	stop_attack()
	pass # Replace with function body.


func tower_skill_level_up(skill_id: int, skill_level: int):
	super(skill_id,skill_level)
	if skill_id == 0 and skill_level == 1:
		var golem: SummonAlly = preload("res://Scenes/Allys/SummonAllys/iron_golem.tscn").instantiate()
		golem.position = golem_position
		iron_golem = golem
		iron_golem.station_position = golem_position
		Stage.instance.allys.add_child(iron_golem)
	elif skill_id == 0 and iron_golem != null:
		iron_golem.level_up()
	
	if skill_id == 1:
		dust_kill_timer.wait_time = dust_kill_waiting_time_list[skill_level-1]
	pass


func dust_kill():
	dust_kill_audio.play()
	var magic_kill_effect: DustSecKillArea2D = preload("res://Scenes/Skills/dust_sec_kill.tscn").instantiate()
	var target_enemy: Enemy
	if target_list.size() > 0:
		var select_target: Enemy = target_list[0]
		for enemy in target_list:
			if enemy.current_data.health > select_target.current_data.health:
				select_target = enemy
		target_enemy = select_target
	else: target_enemy = last_target
	magic_kill_effect.global_position = target_enemy.global_position
	magic_kill_effect.level = tower_skill_levels[1]
	Stage.instance.bullets.add_child(magic_kill_effect)
	await get_tree().create_timer(0.5,false).timeout
	magician.play_backwards()
	await get_tree().create_timer(0.5,false).timeout
	is_attacking = false
	pass


func get_highest_health_enemy(enemy_list: Array[Enemy]) -> Enemy:
	var back_enemy: Enemy = enemy_list[0]
	for enemy in enemy_list:
		if back_enemy.current_data.health < enemy.current_data.health:
			back_enemy = enemy
	
	return back_enemy
	pass


func destroy_tower():
	super()
	if iron_golem != null:
		iron_golem.sell_ally()
	pass
