extends Area2D

@export var damage_block: DamageBlock
@export var explosion_effect_scene: PackedScene
@export var smoke_effect_scene: PackedScene

@onready var shell_sprite: Sprite2D = $ShellSprite


func _ready() -> void:
	var direction: HatingReinforceSystem.Direction = HatingReinforceSystem.instance.current_shooting_from
	shell_sprite.position.y = randf_range(-1200,-1080)
	shell_sprite.position.x = randf_range(-2000,-1920)
	if (direction == HatingReinforceSystem.Direction.FROM_RIGHT or
	(direction == HatingReinforceSystem.Direction.RANDOM and randf() < 0.5)):
		shell_sprite.position.x *= -1
	shell_sprite.look_at(position)
	var move_tween: Tween = create_tween()
	move_tween.tween_property(shell_sprite,"position",Vector2.ZERO,0.4)
	await move_tween.finished
	for body in get_overlapping_bodies():
		var unit = body.owner
		var damage: int = randi_range(damage_block.damage_low,damage_block.damage_high)
		if unit is Ally:
			unit.take_damage(damage,DataProcess.DamageType.ExplodeDamage,0,false,null,false,true)
		elif unit is Enemy:
			unit.take_damage(damage,DataProcess.DamageType.ExplodeDamage,0,false,null,true,true)
	
	AudioManager.instance.play_explosion_audio()
	var explosion_effect: AnimatedSprite2D = explosion_effect_scene.instantiate()
	explosion_effect.position = position
	explosion_effect.scale *= 2
	Stage.instance.bullets.add_child(explosion_effect)
	var smoke_effect: AnimatedSprite2D = smoke_effect_scene.instantiate()
	smoke_effect.position = position
	smoke_effect.scale *= 2
	Stage.instance.bullets.add_child(smoke_effect)
	queue_free()
	pass
