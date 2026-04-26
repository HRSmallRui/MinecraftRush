extends Area2D

@onready var bomb: Sprite2D = $Bomb
@onready var prepare_effect: Sprite2D = $PrepareEffect


func _ready() -> void:
	bomb.scale = Vector2.ZERO
	var damage: int = HeroSkillLibrary.hero_skill_data_library[9][1].second_damage
	prepare_effect.rotation_degrees = randf_range(-50,-40)
	prepare_effect.scale = Vector2.ZERO
	var prepare_tween: Tween = create_tween()
	prepare_tween.tween_property(prepare_effect,"scale",Vector2.ONE * 2,0.5)
	create_tween().tween_property(prepare_effect,"rotation_degrees",270+randf_range(10,30),0.5)
	await prepare_tween.finished
	
	create_tween().tween_property(prepare_effect,"modulate:a",0,0.3)
	await get_tree().create_timer(0.3,false).timeout
	create_tween().tween_property(bomb,"scale",Vector2.ONE * 0.8,0.6)
	create_tween().tween_property(bomb,"modulate:a",0,0.6)
	for body in get_overlapping_bodies():
		var enemy: Enemy = body.owner
		enemy.take_damage(damage,DataProcess.DamageType.SuperDamage,0,false,null,false,true)
	AudioManager.instance.play_explosion_audio()
	Stage.instance.stage_camera.shake(20)
	var explosion_effect: AnimatedSprite2D = preload("res://Scenes/Effects/bullet_explosion_effect.tscn").instantiate()
	explosion_effect.position = position
	Stage.instance.bullets.add_child(explosion_effect)
	var fire_particle: AnimatedSprite2D = preload("res://Scenes/Effects/fire_particle.tscn").instantiate()
	fire_particle.position = position
	Stage.instance.bullets.add_child(fire_particle)
	var smoke: AnimatedSprite2D = preload("res://Scenes/Effects/smoke_effect.tscn").instantiate()
	smoke.position = position
	Stage.instance.bullets.add_child(smoke)
	
	await get_tree().create_timer(2,false).timeout
	queue_free()
	pass
