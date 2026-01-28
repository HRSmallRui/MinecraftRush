extends PathFollow2D
class_name FuchenRayMovePoint

signal end

var damage: int
var move_speed: float = 100
var linked_hero: Hero

@onready var hit_box: Area2D = $HitBox


func _on_timer_timeout() -> void:
	var dust: Sprite2D = preload("res://Scenes/Effects/fuchen_land_dust.tscn").instantiate()
	dust.position = position
	dust.rotation = rotation
	Stage.instance.background.add_child(dust)
	
	for body in hit_box.get_overlapping_bodies():
		var enemy: Enemy = body.owner
		enemy.take_damage(damage,DataProcess.DamageType.MagicDamage,0,true,null)
	if hit_box.has_overlapping_bodies():
		linked_hero.get_exp(linked_hero.skill4_exp_get[linked_hero.skill_levels[4]-1])
	pass # Replace with function body.


func _process(delta: float) -> void:
	progress -= delta * move_speed
	if progress < 10:
		end.emit()
		queue_free()
	pass
