extends SkillConditionArea2D

@export var freeze_buff_scene: PackedScene
@export var skill_damage: int
@export var bullet_damage_list: Array[int]
@export var bullet_scene: PackedScene

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var shot_timer: Timer = $ShotTimer
@onready var knife_audio: AudioStreamPlayer = $KnifeAudio
@onready var duration_timer: Timer = $DurationTimer


func _ready() -> void:
	await get_tree().physics_frame
	await get_tree().physics_frame
	_on_shot_timer_timeout()
	summon_bullet()
	pass


func _on_shot_timer_timeout() -> void:
	for body in get_overlapping_areas():
		var enemy: Enemy = body.owner
		var freeze_buff: PropertyBuff = freeze_buff_scene.instantiate()
		freeze_buff.duration = 0.2
		freeze_buff.buff_tag = "kongshulin_freeze"
		enemy.buffs.add_child(freeze_buff)
		enemy.take_damage(skill_damage,DataProcess.DamageType.TrueDamage,0,false,)
	pass # Replace with function body.


func _on_duration_timer_timeout() -> void:
	animation_player.play_backwards("stop_time")
	collision_shape_2d.disabled = true
	shot_timer.stop()
	pass # Replace with function body.


func summon_bullet():
	var bullet_list: Array[Bullet]
	for i in 40:
		var bullet: Bullet = bullet_scene.instantiate()
		bullet.target_position = position + Vector2(randf_range(-1,1),randf_range(-1,1)) * 40
		bullet.position = bullet.target_position + Vector2(randf_range(-1,1),randf_range(-1,1)) * 100
		bullet.damage = bullet_damage_list[skill_level]
		Stage.instance.bullets.add_child(bullet)
		knife_audio.play()
		bullet.process_mode = Node.PROCESS_MODE_DISABLED
		bullet_list.append(bullet)
		await get_tree().create_timer(0.1,false).timeout
	await duration_timer.timeout
	for bullet in bullet_list:
		bullet.process_mode = Node.PROCESS_MODE_INHERIT
		bullet.hit_box.monitoring = true
		await get_tree().create_timer(0.02,false).timeout
		AudioManager.instance.shoot_audio_1.play()
	pass
