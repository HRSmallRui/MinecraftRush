extends DotBuff

@onready var explosion_area: Area2D = $ExplosionArea
@onready var skeleton: Sprite2D = $Skeleton


func buff_start():
	var enemy: Enemy = unit
	skeleton.global_position = enemy.hurt_box.global_position
	pass


func remove_buff():
	var enemy: Enemy = unit
	var explosion_damage: int
	var rate: float
	var min_damage: int
	match buff_level:
		1: 
			rate = 0.5
			min_damage = 50
		2: 
			rate = 0.75
			min_damage = 100
		3: 
			rate = 1.0
			min_damage = 150
	explosion_damage = float(enemy.start_data.health) * rate
	if explosion_damage < min_damage: explosion_damage = min_damage
	if enemy.enemy_state == Enemy.EnemyState.DIE and !enemy.is_disappear_killing:
		Achievement.achieve_int_add("CurseDead",1,200)
		for body in explosion_area.get_overlapping_bodies():
			var hurt_enemy: Enemy = body.owner
			if hurt_enemy == unit: continue
			hurt_enemy.take_damage(explosion_damage,DataProcess.DamageType.MagicDamage,0)
		var explosion_effect: AnimatedSprite2D = preload("res://Scenes/Effects/bullet_explosion_effect.tscn").instantiate()
		explosion_effect.position = enemy.hurt_box.global_position
		explosion_effect.modulate = Color.WEB_PURPLE
		explosion_effect.scale *= 0.5
		Stage.instance.bullets.add_child(explosion_effect)
		AudioManager.instance.play_explosion_audio()
	super()
	pass
