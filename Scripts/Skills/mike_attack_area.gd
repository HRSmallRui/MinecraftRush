extends SkillConditionArea2D

@export var mike_block: HeroPropertyBlock


@onready var sting_shooter_1: Node2D = $StingShooter1
@onready var sting_shooter_2: Node2D = $StingShooter2
@onready var sting_shooter_3: Node2D = $StingShooter3
@onready var sting_shooter_4: Node2D = $StingShooter4
@onready var sting_shooter_5: Node2D = $StingShooter5
@onready var attack_audio: AudioStreamPlayer = $AttackAudio

var damage_low: int
var damage_high: int


func _ready() -> void:
	sting_animation(sting_shooter_1)
	await get_tree().create_timer(0.1,false).timeout
	sting_animation(sting_shooter_2)
	await get_tree().create_timer(0.1,false).timeout
	sting_animation(sting_shooter_3)
	await get_tree().create_timer(0.1,false).timeout
	sting_animation(sting_shooter_4)
	await get_tree().create_timer(0.1,false).timeout
	sting_animation(sting_shooter_5)
	await get_tree().create_timer(0.5,false).timeout
	var disappear_tween: Tween = create_tween()
	disappear_tween.tween_property(self,"modulate:a",0,0.4)
	await disappear_tween.finished
	queue_free()
	pass


func sting_animation(sting_shooter: Node2D):
	sting_shooter.position += Vector2(randf_range(-25,25),randf_range(-18,18))
	var appear_tween: Tween = create_tween().set_ease(Tween.EASE_OUT)
	create_tween().tween_property(sting_shooter,"modulate:a",1,0.3)
	if sting_shooter.position.x < 0:
		sting_shooter.rotation_degrees = randf_range(60,90)
	else:
		sting_shooter.rotation_degrees = randf_range(90,120)
	var sting: Sprite2D = sting_shooter.get_child(0)
	appear_tween.tween_property(sting,"position:x",randf_range(-300,-200),0.4)
	await appear_tween.finished
	var shoot_tween: Tween = create_tween().set_ease(Tween.EASE_IN)
	shoot_tween.tween_property(sting,"position:x",randf_range(-5,5),0.05)
	$CollisionShape2D.position = sting_shooter.position
	attack_audio.play()
	await shoot_tween.finished
	var damage: int = float(randi_range(damage_low,damage_high)) / 5
	#print("attack")
	for body in get_overlapping_bodies():
		var enemy: Enemy = body.owner
		enemy.take_damage(damage,DataProcess.DamageType.SuperDamage,0,true,null,false,true,)
		enemy.start_data.armor -= 0.04
		enemy.start_data.magic_defence -= 0.04
		enemy.current_data.update_armor()
		enemy.current_data.update_magic_defence()
	pass
