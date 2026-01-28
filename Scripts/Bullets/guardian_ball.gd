extends ShooterBullet


func _ready() -> void:
	free_timer.wait_time = (target_position - self.global_position).length() / bullet_speed
	super()
	pass


func _on_free_timer_timeout():
	hit_effect()
	super()
	pass


func hit_effect():
	var guardian_area: Area2D = preload("res://Scenes/Skills/guardian_explosion_area.tscn").instantiate()
	guardian_area.position = position
	Stage.instance.bullets.add_child(guardian_area)
	var explosion_effect: Node2D = preload("res://Scenes/Effects/energy_explosion_effect.tscn").instantiate()
	explosion_effect.position = position
	Stage.instance.bullets.add_child(explosion_effect)
	var smoke_effct: AnimatedSprite2D = preload("res://Scenes/Effects/smoke_effect.tscn").instantiate()
	smoke_effct.position = position
	Stage.instance.bullets.add_child(smoke_effct)
	pass
