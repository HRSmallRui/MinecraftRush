extends Area2D

@export var appear_audio_list: Array[AudioStream]

@onready var alchemist_liquid: Sprite2D = $AlchemistLiquid
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var shot_timer: Timer = $ShotTimer
@onready var free_timer: Timer = $FreeTimer
@onready var appear_audio: AudioStreamPlayer = $AppearAudio


func _ready() -> void:
	
	appear_audio.stream = appear_audio_list.pick_random()
	appear_audio.play()
	var target_scale: Vector2 = alchemist_liquid.scale
	alchemist_liquid.scale = Vector2.ZERO
	alchemist_liquid.modulate.a = 0
	const appear_time: float = 0.2
	create_tween().tween_property(alchemist_liquid,"scale",target_scale,appear_time)
	create_tween().tween_property(alchemist_liquid,"modulate:a",1,appear_time)
	await get_tree().create_timer(0.2,false).timeout
	free_timer.start()
	shot_timer.start()
	pass


func _on_free_timer_timeout() -> void:
	shot_timer.stop()
	var disappear_tween: Tween = create_tween()
	disappear_tween.tween_property(alchemist_liquid,"modulate:a",0,0.3)
	await disappear_tween.finished
	queue_free()
	pass # Replace with function body.


func _on_shot_timer_timeout() -> void:
	for body in get_overlapping_bodies():
		var enemy: Enemy = body.owner
		var speed_debuff: PropertyBuff = preload("res://Scenes/Buffs/TowerBuffs/alchemist_speed_debuff.tscn").instantiate()
		enemy.buffs.add_child(speed_debuff)
		enemy.take_damage(4,DataProcess.DamageType.MagicDamage,0,false,null,false,false,)
	pass # Replace with function body.
