extends AnimatedSprite2D
class_name Magician

@export var tower: MagicTower
@export var summon_frame: int

@onready var magic_animation_player: AnimationPlayer = $MagicAnimationPlayer
@onready var magic_heart: Sprite2D = $MagicHeart


func _ready() -> void:
	frame_changed.connect(frame_condition)
	pass


func _process(delta: float) -> void:
	anim_offset()
	magic_animation_player.speed_scale = 3 if is_playing() else 1
	pass


func anim_offset():
	match animation:
		"idle_front","shoot_front":
			offset = Vector2.ZERO
		"shoot_back":
			offset = Vector2(9,0)
	pass


func shoot():
	var pos: Vector2
	if tower.target_list.size() > 0:
		pos = get_lateset_enemy(tower.target_list).position
	elif tower.last_target != null:
		pos = tower.last_target.position
	else: return
	if pos.y < tower.position.y: play("shoot_back")
	else: play("shoot_front")
	pass


func summon_bullet(summon_pos: Vector2, target_pos: Vector2):
	var magic_ball = load("res://Scenes/Bullets/magic_ball.tscn").instantiate() as Bullet
	magic_ball.position = summon_pos
	magic_ball.target_position = target_pos
	magic_ball.damage = randi_range(tower.current_data.damage_low,tower.current_data.damage_high)
	magic_ball.source = tower
	if Stage.instance.stage_sav.upgrade_sav[2] >= 2 and randf_range(0,1) <= 0.12:
		magic_ball.damage_type = DataProcess.DamageType.TrueDamage
	
	Stage.instance.bullets.add_child(magic_ball)
	pass


func frame_condition():
	if frame == summon_frame:
		
		var enemy: Enemy
		if tower.target_list.size() > 0:
			enemy = get_lateset_enemy(tower.target_list)
		elif tower.last_target != null:
			enemy = tower.last_target
		else: return
		AudioManager.instance.magic_shot_audio.play()
		var before_frame = frame+1
		if enemy.position.y < tower.position.y: play("shoot_back")
		else: play("shoot_front")
		frame = before_frame
		
		var summon_pos: Vector2 = magic_heart.global_position
		var target_pos: Vector2 = enemy.hurt_box.global_position + enemy.direction * enemy.current_data.unit_move_speed * 1.3
		
		summon_bullet(summon_pos,target_pos)
	pass


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
	pass
