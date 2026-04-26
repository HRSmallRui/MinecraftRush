extends BombardTower
class_name PlaneController

@export var plane_shell_scene: PackedScene
@export var plane_kill_shell_scene: PackedScene

@onready var flag_button: TextureButton = $TowerUI/Circle/FlagButton
@onready var first_move_rays: Node2D = $FirstMoveRays
@onready var plane_sprite: Sprite2D = $Plane/PlaneSprite
@onready var plane: Node2D = $Plane
@onready var plane_offset_animation_player: AnimationPlayer = $Plane/PlaneOffsetAnimationPlayer
@onready var plane_audio: AudioStreamPlayer = $Plane/PlaneAudio
@onready var plane_attack_area: Area2D = $PlaneAttackArea
@onready var smoke_condition_area: Area2D = $SmokeConditionArea
@onready var skill_1_timer: Timer = $Skill1Timer
@onready var plane_kill_area: Area2D = $PlaneKillArea
@onready var skill_2_timer: Timer = $Skill2Timer
@onready var select_sprite: Sprite2D = $Plane/SelectSprite

var plane_position: Vector2
var plane_move_tween: Tween
var plane_is_moving: bool = true


func _ready() -> void:
	super()
	update_tower_range()
	plane_sprite.position.y = -10
	tower_area.hide()
	flag_button.pressed.connect(ready_to_move)
	first_move()
	flag_button.disabled = true
	var fly_tween: Tween = create_tween()
	fly_tween.tween_property(plane_sprite,"position:y",-100,0.5)
	await fly_tween.finished
	move(plane_position)
	plane_audio.play()
	plane_offset_animation_player.play("loop")
	flag_button.disabled = false
	pass


func ready_to_move():
	Stage.instance.ui_process(self,Stage.StageUI.Move)
	ui_animation_player.play("hide_ui")
	tower_area.show()
	pass


func first_move():
	await get_tree().physics_frame
	await get_tree().physics_frame
	for ray: RayCast2D in first_move_rays.get_children():
		if ray.is_colliding():
			var target_pos = ray.get_collision_point() + ray.target_position * 0.5
			plane_position = target_pos
			first_move_rays.queue_free()
			return
	pass


func ui_process(member: Node):
	super(member)
	if member != self: tower_area.hide()
	select_sprite.visible = member == self
	pass


func move(target_pos: Vector2):
	plane_is_moving = true
	plane_attack_area.global_position = target_pos
	smoke_condition_area.global_position = target_pos
	plane_kill_area.global_position = target_pos
	if plane_move_tween != null:
		plane_move_tween.kill()
	plane_move_tween = create_tween()
	var move_time: float = (target_pos - plane.global_position).length() / 2.2 / 50
	plane_move_tween.tween_property(plane,"global_position",target_pos,move_time)
	plane_offset_animation_player.stop()
	plane_sprite.rotation_degrees = -15 if plane.global_position.x - target_pos.x > 50 else (15 if target_pos.x - plane.global_position.x > 50 else 0)
	plane_move_tween.finished.connect(
		func():
		plane_sprite.rotation = 0
		plane_offset_animation_player.play("loop")
		plane_is_moving = false
		)
	pass


func fighting_process():
	if !normal_attack_timer.is_stopped(): return
	
	if smoke_condition_area.has_overlapping_bodies() and skill_1_timer.is_stopped() and tower_skill_levels[0] > 0:
		release_smoke()
		skill_1_timer.start()
		normal_attack_timer.start()
		return
	
	var enemy_list: Array[Enemy]
	for body in plane_attack_area.get_overlapping_bodies():
		var enemy: Enemy = body.owner
		enemy_list.append(enemy)
	
	if plane_kill_area.has_overlapping_bodies() and skill_2_timer.is_stopped() and tower_skill_levels[1] > 0:
		var locked_enemy: Enemy = get_highest_health_enemy(enemy_list)
		if locked_enemy != null:
			var kill_bullet: Bullet = preload("res://Scenes/Bullets/plane_super_shell.tscn").instantiate()
			kill_bullet.position = plane_sprite.global_position
			kill_bullet.target_position = locked_enemy.hurt_box.global_position
			kill_bullet.special_skill_level = tower_skill_levels[1]
			Stage.instance.bullets.add_child(kill_bullet)
			normal_attack_timer.start()
			skill_2_timer.start()
			return
	
	var locked_enemy: Enemy = get_lateset_enemy(enemy_list)
	if locked_enemy != null:
		var shell: Shell = preload("res://Scenes/Bullets/shell_plane.tscn").instantiate()
		shell.damage = current_data.damage_high
		shell.low_damage = current_data.damage_low
		if Stage.instance.get_current_techno_level(3) >= 4:
			shell.low_damage = shell.damage
		shell.position = plane_sprite.global_position
		shell.target_position = locked_enemy.position
		Stage.instance.bullets.add_child(shell)
		normal_attack_timer.start()
	pass


func _process(delta: float) -> void:
	if plane_attack_area.has_overlapping_bodies() and !plane_is_moving:
		fighting_process()
	tower_range.scale = Vector2.ONE * float(current_tower_range)/100
	tower_area.scale = Vector2.ONE * float(current_tower_range)/100
	pass


func _on_tower_area_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event.is_action_released("click") and Stage.instance.mouse_in_path:
		tower_area.hide()
		Stage.instance.ui_process(null)
		move(Stage.instance.get_local_mouse_position())
		Stage.instance.move_point_effect(Stage.instance.get_local_mouse_position())
		var flag_effect: AnimatedSprite2D = preload("res://Scenes/Effects/flag_effect.tscn").instantiate()
		flag_effect.position = Stage.instance.get_local_mouse_position()
		Stage.instance.allys.add_child(flag_effect)
	pass # Replace with function body.


func get_lateset_enemy(enemy_list: Array[Enemy]) -> Enemy:
	var back_enemy:Enemy = enemy_list[0]
	var new_remaining_length: float
	var curve: Curve2D = back_enemy.get_parent().curve
	new_remaining_length = curve.get_baked_length() - back_enemy.progress
	for enemy in enemy_list:
		var remaining_length: float
		var current_curve: Curve2D = enemy.get_parent().curve
		remaining_length = current_curve.get_baked_length() - enemy.progress
		if remaining_length < new_remaining_length:
			new_remaining_length = remaining_length
			back_enemy = enemy
	return back_enemy


func release_smoke():
	AudioManager.instance.shoot_audio_1.play()
	await get_tree().create_timer(0.1,false).timeout
	
	var plane_smoke_area: SkillConditionArea2D = preload("res://Scenes/Skills/plane_smoke_area.tscn").instantiate()
	plane_smoke_area.position = plane.global_position
	Stage.instance.bullets.add_child(plane_smoke_area)
	pass


func tower_skill_level_up(skill_id: int, skill_level: int):
	super(skill_id,skill_level)
	if skill_id == 1:
		var cd_time: float
		match skill_level:
			1: cd_time = 25
			2: cd_time = 23
			3: cd_time = 21
		skill_2_timer.wait_time = cd_time
	pass


func get_highest_health_enemy(enemy_list: Array[Enemy]) -> Enemy:
	var back_enemy:Enemy = enemy_list[0]
	for enemy in enemy_list:
		if enemy.current_data.health > back_enemy.current_data.health:
			back_enemy = enemy
	return back_enemy
