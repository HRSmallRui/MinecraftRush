extends BombardTowerSprite

@export var shining_animation_player: AnimationPlayer
@export var watcher: AnimatedSprite2D
@export var watcher_audio: AudioStreamPlayer

@onready var front_no_flip: Marker2D = $FrontNoFlip
@onready var front_flip: Marker2D = $FrontFlip
@onready var back_flip: Marker2D = $BackFlip
@onready var back_no_flip: Marker2D = $BackNoFlip
@onready var shoot_audio: AudioStreamPlayer = $ShootAudio


func attack():
	var pos: Vector2
	if tower.target_list.size() > 0:
		pos = get_lateset_enemy(tower.target_list).position
	elif tower.last_target != null:
		pos = tower.last_target.position
	else: return
	flip_h = pos.x < global_position.x
	if pos.y < tower.position.y: play("shoot_back")
	else: play("shoot_front")
	shining_animation_player.play("shine")
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
		var before_frame = frame
		if enemy.position.y < tower.position.y: play("shoot_back")
		else: play("shoot_front")
		frame = before_frame + 1
		
		var summon_pos: Vector2
		if animation == "shoot_front":
			summon_pos = front_flip.global_position if flip_h else front_no_flip.global_position
		elif animation == "shoot_back":
			summon_pos = back_flip.global_position if flip_h else back_no_flip.global_position
		var target_pos: Vector2 = enemy.hurt_box.global_position + enemy.direction * enemy.current_data.unit_move_speed * 2
		
		attacker_summon_bullet(summon_pos,target_pos)
	pass


func shoot_audio_play():
	shoot_audio.play()
	pass


func attacker_summon_bullet(summon_pos: Vector2, target_pos: Vector2):
	var arrow = shell_scene.instantiate() as Bullet
	arrow.damage = randi_range(tower.current_data.damage_low,tower.current_data.damage_high)
	arrow.source = tower
	arrow.global_position = summon_pos
	arrow.target_position = target_pos
	
	Stage.instance.bullets.add_child(arrow)
	pass


func _on_animation_finished() -> void:
	watcher.play()
	watcher_audio.play()
	pass # Replace with function body.
