extends Area2D

@export var dust_scene: PackedScene
@export var damage: int = 1000

@onready var line_node: Node2D = $LineNode
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var light: Sprite2D = $StartPointParticle/Light
@onready var timer: Timer = $Timer

var linked_path: EnemyPath
var enemy_list: Array[Enemy]
var progress: float


func _ready() -> void:
	collision_shape_2d.disabled = true
	set_process(false)
	line_node.scale.x = 0
	light.scale = Vector2.ZERO
	create_tween().tween_property(light,"scale",Vector2.ONE,0.8)
	create_tween().tween_property(line_node,"scale:x",1,0.8)
	linked_path = Stage.instance.get_closest_enemy_path(position)
	progress = linked_path.curve.get_closest_offset(position)
	position = linked_path.curve.sample_baked(progress)
	await get_tree().create_timer(0.8,false).timeout
	set_process(true)
	timer.start()
	collision_shape_2d.disabled = false
	pass


func _on_body_entered(body: Node2D) -> void:
	var enemy: Enemy = body.owner
	if enemy.enemy_type == Enemy.EnemyType.Boss:
		enemy.call_deferred("broken")
	else:
		enemy.take_damage(damage,DataProcess.DamageType.TrueDamage,0,true,null,false,true)
	pass # Replace with function body.


func _on_dust_timer_timeout() -> void:
	var dust: Sprite2D = dust_scene.instantiate()
	dust.position = position
	dust.rotation = rotation
	dust.scale *= 2
	Stage.instance.background.add_child(dust)
	pass # Replace with function body.


func _process(delta: float) -> void:
	position = linked_path.curve.sample_baked(progress)
	progress -= delta * 40
	if progress <= 20:
		set_process(false)
		ending_move()
	pass


func ending_move():
	collision_shape_2d.disabled = true
	var disappear_tween: Tween = create_tween()
	disappear_tween.tween_property(line_node,"scale:x",0,0.5)
	create_tween().tween_property(light,"scale",Vector2.ZERO,0.5)
	await disappear_tween.finished
	queue_free()
	pass


func _on_timer_timeout() -> void:
	ending_move()
	pass # Replace with function body.
