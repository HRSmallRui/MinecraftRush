extends ShooterBullet

@onready var explosion_area: Area2D = $ExplosionArea

var has_exploded: bool


func _ready() -> void:
	free_timer.wait_time = (target_position - self.global_position).length() / bullet_speed + 0.1
	super()
	pass


func enemy_take_damage(enemy: Enemy):
	super(enemy)
	explode()
	pass


func _on_free_timer_timeout():
	super()
	explode()
	pass


func explode():
	if has_exploded: return
	has_exploded = true
	AudioManager.instance.play_explosion_audio()
	var explosion_effect: AnimatedSprite2D = preload("res://Scenes/Effects/bullet_explosion_effect.tscn").instantiate()
	explosion_effect.position = position
	Stage.instance.bullets.add_child(explosion_effect)
	
	var damage: int = HeroSkillLibrary.hero_skill_data_library[10][3].damage[special_skill_level-1]
	for hurt_box in explosion_area.get_overlapping_areas():
		var enemy: Enemy = hurt_box.owner
		enemy.take_damage(damage,DataProcess.DamageType.ExplodeDamage,0,true,null,true,true,)
	pass
