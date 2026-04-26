extends ShooterBullet


func _ready() -> void:
	free_timer.wait_time = (target_position - self.global_position).length() / bullet_speed
	super()
	pass


func _process(delta: float) -> void:
	bullet_sprite.rotation_degrees += delta * 720
	pass


func _on_free_timer_timeout():
	var salem_explosion_area: SkillConditionArea2D = preload("res://Scenes/Skills/salem_explosion_area.tscn").instantiate()
	salem_explosion_area.position = position
	salem_explosion_area.skill_level = special_skill_level
	salem_explosion_area.passive_level = bullet_special_tag_levels["passive"]
	salem_explosion_area.dead_explosion_level = bullet_special_tag_levels["explosion"]
	Stage.instance.bullets.add_child(salem_explosion_area)
	super()
	pass
