extends SkillConditionArea2D

@export var max_point_limit: int = 20

@onready var fire_sprite: AnimatedSprite2D = $FireSprite
@onready var tail_line: Line2D = $TailLine
@onready var shadow: Sprite2D = $Shadow
@onready var bomb: Sprite2D = $Bomb


func _ready() -> void:
	bomb.scale = Vector2.ZERO
	tail_line.clear_points()
	fire_sprite.position.y = -1200
	if randf_range(0,1) < 0.5:
		shadow.position.x = -1000
		fire_sprite.position.x = -1000
	else:
		fire_sprite.position.x = 1000
		shadow.position.x = 1000
	fire_sprite.look_at(self.global_position)
	fire_sprite.rotation_degrees += 180
	shadow.modulate.a = 0
	var fire_tween: Tween = create_tween()
	var fly_time: float = 0.5
	fire_tween.tween_property(fire_sprite,"position",Vector2.ZERO,fly_time)
	create_tween().tween_property(shadow,"position",Vector2.ZERO,fly_time)
	create_tween().tween_property(shadow,"modulate:a",1,fly_time)
	await fire_tween.finished
	create_tween().tween_property(bomb,"scale",Vector2.ONE * 0.6,0.6)
	create_tween().tween_property(bomb,"modulate:a",0,0.5)
	fire_sprite.hide()
	shadow.hide()
	AudioManager.instance.play_explosion_audio()
	var damage_low: int = HeroSkillLibrary.hero_skill_data_library[9][1].damage_low
	var damage_high: int = HeroSkillLibrary.hero_skill_data_library[9][1].damage_high
	var explosion_effect: AnimatedSprite2D = preload("res://Scenes/Effects/bullet_explosion_effect.tscn").instantiate()
	explosion_effect.position = position
	Stage.instance.bullets.add_child(explosion_effect)
	var fire_particle: AnimatedSprite2D = preload("res://Scenes/Effects/fire_particle.tscn").instantiate()
	fire_particle.position = position
	Stage.instance.bullets.add_child(fire_particle)
	var smoke: AnimatedSprite2D = preload("res://Scenes/Effects/smoke_effect.tscn").instantiate()
	smoke.position = position
	Stage.instance.bullets.add_child(smoke)
	Stage.instance.stage_camera.shake(10)
	for body in get_overlapping_bodies():
		var enemy: Enemy = body.owner
		enemy.take_damage(randi_range(damage_low,damage_high),DataProcess.DamageType.SuperDamage,0,false,null,false,true)
	
	await get_tree().create_timer(2,false).timeout
	queue_free()
	pass


func _on_tail_timer_timeout() -> void:
	tail_line.add_point(fire_sprite.global_position)
	if tail_line.get_point_count() >= max_point_limit:
		tail_line.remove_point(0)
	pass # Replace with function body.
