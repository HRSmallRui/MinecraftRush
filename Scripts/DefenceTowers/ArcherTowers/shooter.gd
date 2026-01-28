extends AnimatedSprite2D
class_name Shooter

@export var tower: ArcherTower
@export var summon_frame: int
@export var arrow_scene: PackedScene = preload("res://Scenes/Bullets/physics_arrow.tscn")

@onready var front_no_flip: Marker2D = $FrontNoFlip
@onready var front_flip: Marker2D = $FrontFlip
@onready var back_flip: Marker2D = $BackFlip
@onready var back_no_flip: Marker2D = $BackNoFlip


func _ready() -> void:
	frame_changed.connect(frame_condition)
	pass


func anim_offset():
	
	pass


func _process(delta: float) -> void:
	anim_offset()
	pass


func shoot():
	var pos: Vector2
	if tower.target_list.size() > 0:
		var target_enemy: Enemy = get_lateset_enemy(tower.target_list)
		pos = target_enemy.position
	elif tower.last_target != null:
		pos = tower.last_target.position
	else: return
	flip_h = pos.x < global_position.x
	if pos.y < tower.position.y: play("shoot_back")
	else: play("shoot_front")
	pass


func shoot_audio_play():
	AudioManager.instance.shoot_audio_1.play()
	pass


func frame_condition():
	if frame == summon_frame and (animation == "shoot_back" or animation == "shoot_front"):
		shoot_audio_play()
		var enemy: Enemy
		if tower.target_list.size() > 0:
			enemy = get_lateset_enemy(tower.target_list)
		elif tower.last_target != null:
			enemy = tower.last_target
		else: return
		
		flip_h = enemy.position.x < global_position.x
		var before_frame = frame + 1
		if enemy.position.y < tower.position.y: play("shoot_back")
		else: play("shoot_front")
		frame = before_frame
		
		var summon_pos: Vector2
		if animation == "shoot_front":
			summon_pos = front_flip.global_position if flip_h else front_no_flip.global_position
		elif animation == "shoot_back":
			summon_pos = back_flip.global_position if flip_h else back_no_flip.global_position
		var target_pos: Vector2 = enemy.hurt_box.global_position + enemy.direction * enemy.current_data.unit_move_speed * 2
		
		summon_bullet(summon_pos,target_pos)
	pass


func summon_bullet(summon_pos: Vector2, target_pos: Vector2, bullet_scene: PackedScene = arrow_scene) -> Bullet:
	
	var arrow = bullet_scene.instantiate() as Bullet
	arrow.damage = randi_range(tower.current_data.damage_low,tower.current_data.damage_high)
	arrow.source = tower
	arrow.global_position = summon_pos
	arrow.target_position = target_pos
	arrow.z_index = z_index
	
	var level: int = clampi(Stage.instance.stage_sav.upgrade_sav[0],0,Stage.instance.limit_tech_level)
	if level >= 3 and randf_range(0,1) < 0.15:
		arrow.broken_rate = 1
	if level >= 4 and randf_range(0,1) < 0.18:
		arrow.damage *= 2
	
	Stage.instance.bullets.add_child(arrow)
	return arrow
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
