extends Node2D

@onready var tnt_sprite: Sprite2D = $TNTSprite
@onready var tail: Line2D = $Tail


func _ready() -> void:
	tail.clear_points()
	tnt_sprite.position = Vector2(1920,-1080)
	tnt_sprite.look_at(position)
	var fly_tween: Tween = create_tween()
	fly_tween.tween_property(tnt_sprite,"position",Vector2.ZERO,0.4)
	fly_tween.finished.connect(func():
		var explosion_effect:AnimatedSprite2D = preload("res://Scenes/Effects/bullet_explosion_effect.tscn").instantiate()
		explosion_effect.position = position
		explosion_effect.scale *= 2
		explosion_effect.z_index += 1
		Stage.instance.bullets.add_child(explosion_effect)
		var smoke_effect: AnimatedSprite2D = preload("res://Scenes/Effects/smoke_effect.tscn").instantiate()
		smoke_effect.position = position
		smoke_effect.scale *= 2
		smoke_effect.z_index += 1
		Stage.instance.bullets.add_child(smoke_effect)
		
		AudioManager.instance.play_explosion_audio()
		Stage.instance.stage_camera.shake(5)
		
		queue_free()
		)
	pass


func _physics_process(delta: float) -> void:
	tail.add_point(tnt_sprite.global_position)
	if tail.points.size() > 30:
		tail.remove_point(0)
	pass
