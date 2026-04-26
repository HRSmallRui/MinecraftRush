extends Node2D
class_name DesertWolfSkill

@onready var wolf_anim: AnimatedSprite2D = $WolfAnim
@onready var wolf_audio: AudioStreamPlayer = $WolfAudio
@onready var duration_timer: Timer = $DurationTimer
@onready var hit_area: Area2D = $HitArea

var sample_enemy: Enemy
var damage: int
var dizness_time: float
var sample_curve: Curve2D
var progress: float:
	set(v):
		if sample_curve == null: return
		progress = clampf(v,0,sample_curve.get_baked_length())
		on_set_progress(progress)
var move_speed: float = 2


func _ready() -> void:
	set_process(false)
	modulate.a = 0
	var enemy_path: EnemyPath = sample_enemy.get_parent()
	sample_curve = enemy_path.curve
	progress = clampf(sample_enemy.progress + 80, 0, sample_curve.get_baked_length())
	var appear_tween: Tween = create_tween()
	appear_tween.tween_property(self,"modulate:a",1,0.3)
	await appear_tween.finished
	set_process(true)
	wolf_audio.play()
	duration_timer.start()
	hit_area.monitoring = true
	pass


func on_set_progress(new_progress: float):
	position = sample_curve.sample_baked(new_progress)
	var direction: Vector2 = sample_curve.sample_baked(progress - 0.1) - global_position
	wolf_anim.flip_h = direction.x < 0
	if direction.y < -7:
		wolf_anim.play("move_back")
	elif direction.y > 7:
		wolf_anim.play("move_front")
	else:
		wolf_anim.play("move_normal")
	pass


func _process(delta: float) -> void:
	progress -= move_speed * delta * 60
	if progress <= 1 and !duration_timer.is_stopped():
		queue_free()
	pass


func _on_duration_timer_timeout() -> void:
	var disappear_tween: Tween = create_tween()
	disappear_tween.tween_property(self,"modulate:a",0,0.3)
	hit_area.monitoring = false
	await disappear_tween.finished
	queue_free()
	pass # Replace with function body.


func _on_hit_area_body_entered(body: Node2D) -> void:
	var unit = body.owner
	if unit is Enemy:
		unit.take_damage(damage,DataProcess.DamageType.PhysicsDamage,0,true,)
		var dizness_buff: PropertyBuff = preload("res://Scenes/Buffs/dizness_buff.tscn").instantiate()
		dizness_buff.duration = dizness_time
		dizness_buff.buff_tag = "wolf_dizness"
		dizness_buff.unit = unit
		unit.buffs.add_child(dizness_buff)
	pass # Replace with function body.
