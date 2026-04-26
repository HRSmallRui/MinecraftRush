extends Node2D

@onready var slash_sprite: Sprite2D = $SlashSprite


func _ready() -> void:
	slash_sprite.rotation_degrees = randf_range(-360,360)
	slash_sprite.scale = Vector2.ZERO
	var appear_tween: Tween = create_tween()
	appear_tween.tween_property(slash_sprite,"scale",Vector2.ONE,0.2)
	await appear_tween.finished
	await get_tree().create_timer(0.2,false).timeout
	var disappear_tween: Tween = create_tween()
	disappear_tween.tween_property(slash_sprite,"scale:y",0,0.4)
	await disappear_tween.finished
	queue_free()
	pass
