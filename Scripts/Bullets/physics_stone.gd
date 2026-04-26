extends ShooterBullet

@onready var explosion_hit_area: Area2D = $ExplosionHitArea


func after_attack_process(unit: Node2D):
	super(unit)
	if bullet_special_tag_levels.has("stone_explosion"):
		var explosion_stone_effect: AnimatedSprite2D = preload("res://Scenes/Effects/explosion_stone_effect.tscn").instantiate()
		explosion_stone_effect.position = position
		Stage.instance.bullets.add_child(explosion_stone_effect)
		AudioManager.instance.stone_explosion_audio.play()
		var damage_low: int
		var damage_high: int
		match bullet_special_tag_levels["stone_explosion"]:
			1:
				damage_low = 10
				damage_high = 15
			2:
				damage_low = 15
				damage_high = 24
		for box in explosion_hit_area.get_overlapping_areas():
			var new_enemy: Enemy = box.owner
			new_enemy.take_damage(randi_range(damage_low,damage_high),DataProcess.DamageType.PhysicsDamage,0,false,source,explosion,true)
	pass
