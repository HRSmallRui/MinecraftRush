extends SkillConditionArea2D

@export var level_time: Array[float]

@onready var timer: Timer = $Timer
@onready var smoke_audio: AudioStreamPlayer = $SmokeAudio
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var shot_timer: Timer = $ShotTimer
@onready var skill_particle_shooter: GPUParticles2D = $SkillParticleShooter


func _ready() -> void:
	timer.wait_time = level_time[skill_level-1]
	timer.start()
	smoke_audio.play(0.45)
	pass


func _on_timer_timeout() -> void:
	collision_shape_2d.disabled = true
	shot_timer.stop()
	var disappear_tween: Tween = create_tween()
	disappear_tween.tween_property(skill_particle_shooter,"modulate:a",0,0.5)
	await disappear_tween.finished
	queue_free()
	pass # Replace with function body.


func _on_shot_timer_timeout() -> void:
	for body in get_overlapping_bodies():
		var enemy: Enemy = body.owner
		var smoke_debuff: PropertyBuff = preload("res://Scenes/Buffs/TowerBuffs/smoke_buff.tscn").instantiate()
		enemy.buffs.add_child(smoke_debuff)
	pass # Replace with function body.
