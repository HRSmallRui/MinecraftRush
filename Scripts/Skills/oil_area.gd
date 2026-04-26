extends SkillConditionArea2D

@onready var oil_sprite: Sprite2D = $OilSprite
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var during_timer: Timer = $DuringTimer
@onready var shot_timer: Timer = $ShotTimer


func _ready() -> void:
	oil_sprite.scale = Vector2.ZERO
	create_tween().tween_property(oil_sprite,"scale",Vector2.ONE,0.4)
	
	match skill_level:
		1: during_timer.wait_time = 6
		2: during_timer.wait_time = 8
	during_timer.start()
	pass


func _on_during_timer_timeout() -> void:
	collision_shape_2d.disabled = true
	shot_timer.stop()
	var disappear_tween: Tween = create_tween()
	disappear_tween.tween_property(self,"modulate:a",0,0.5)
	await disappear_tween.finished
	queue_free()
	pass # Replace with function body.


func _on_shot_timer_timeout() -> void:
	for body in get_overlapping_bodies():
		var enemy: Enemy = body.owner
		var slow_buff: PropertyBuff = preload("res://Scenes/Buffs/TowerBuffs/oil_slow_buff.tscn").instantiate()
		enemy.buffs.add_child(slow_buff)
	pass # Replace with function body.
