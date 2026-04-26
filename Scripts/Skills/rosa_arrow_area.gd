extends Area2D

@onready var arrow_node: Node2D = $ArrowNode
@onready var arrow_sprite: Sprite2D = $ArrowNode/ArrowMagic
@onready var tail: Line2D = $Tail

var arrow_height: float = 1200


func _ready() -> void:
	var damage: int = HeroSkillLibrary.hero_skill_data_library[10][5].damage
	arrow_node.rotation_degrees = randf_range(-30,30)
	arrow_sprite.position.y = -arrow_height + randf_range(-1,1) * 20
	var shoot_tween: Tween = create_tween()
	shoot_tween.tween_property(arrow_sprite,"position:y",0,0.15)
	tail.clear_points()
	shoot_tween.finished.connect(func():
		for body in get_overlapping_bodies():
			var enemy: Enemy = body.owner
			enemy.take_damage(damage,DataProcess.DamageType.TrueDamage,0,true,null,false,true,)
		await get_tree().create_timer(2,false).timeout
		var disappear_tween: Tween = create_tween()
		disappear_tween.tween_property(self,"modulate:a",0,0.6)
		await disappear_tween.finished
		queue_free()
		)
	pass


func _physics_process(delta: float) -> void:
	tail.add_point(arrow_sprite.global_position)
	if tail.points.size() >= 30:
		tail.remove_point(0)
	pass
