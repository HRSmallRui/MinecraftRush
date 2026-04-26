extends SkillConditionArea2D

@export var normal_damage: int
@export var super_damage: int

@onready var fog_audio: AudioStreamPlayer = $FogAudio
@onready var skill_particle_shooter: GPUParticles2D = $SkillParticleShooter
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D

var damage: int


func _ready() -> void:
	fog_audio.play(0.4)
	damage = normal_damage if skill_level == 1 else super_damage
	pass


func _on_shot_timer_timeout() -> void:
	for body in get_overlapping_bodies():
		var ally: Ally = body.owner
		ally.take_damage(damage,DataProcess.DamageType.TrueDamage,0,false,null)
	pass # Replace with function body.


func _on_timer_timeout() -> void:
	collision_shape_2d.disabled = true
	var disappear_tween: Tween = create_tween()
	disappear_tween.tween_property(self,"modulate:a",0,1)
	await disappear_tween.finished
	queue_free()
	pass # Replace with function body.
