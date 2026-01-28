extends Bullet

@onready var tail: Line2D = $Tail
@onready var tail_timer: Timer = $TailTimer


func after_attack_process(unit: Node2D):
	AudioManager.instance.play_explosion_audio()
	var explosion_effect = preload("res://Scenes/Effects/bullet_explosion_effect.tscn").instantiate() as AnimatedSprite2D
	explosion_effect.position = bullet_sprite.global_position
	get_parent().add_child(explosion_effect)
	var smoke_effect = preload("res://Scenes/Effects/smoke_effect.tscn").instantiate() as AnimatedSprite2D
	smoke_effect.position = bullet_sprite.global_position
	get_parent().add_child(smoke_effect)
	
	var show_text: String
	match randi_range(0,1):
		0: show_text = "轰！"
		1: show_text = "砰！"
	TextEffect.text_effect_show(show_text,TextEffect.TextEffectType.Magic, Vector2(0,-40) + bullet_sprite.global_position)
	pass


func _on_free_timer_timeout() -> void:
	queue_free()
	after_attack_process(null)
	pass


func _on_tail_timer_timeout() -> void:
	tail.add_point(bullet_sprite.global_position)
	if tail.points.size() > 60: tail.remove_point(0)
	pass # Replace with function body.
