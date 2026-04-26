extends AnimatedSprite2D

@onready var sheep_1: AudioStreamPlayer = $Sheep1
@onready var sheep_2: AudioStreamPlayer = $Sheep2
@onready var sheep_3: AudioStreamPlayer = $Sheep3

var click_count: int = 0


func _ready() -> void:
	while true:
		await get_tree().create_timer(randf_range(4,8),false).timeout
		play("eating")
	pass


func _on_explode_button_pressed() -> void:
	if click_count == 10:
		explode()
		return
	click_count += 1
	play("idle")
	match randi_range(1,3):
		1: sheep_1.play()
		2: sheep_2.play()
		3: sheep_3.play()
	pass # Replace with function body.


func explode():
	hide()
	Achievement.achieve_int_add("SheepDead",1,10)
	var explode_effect: AnimatedSprite2D = preload("res://Scenes/Effects/dead_body_explosion.tscn").instantiate()
	explode_effect.position = position + Vector2(0,10)
	explode_effect.scale *= 1.5
	get_parent().add_child(explode_effect)
	AudioManager.instance.dead_body_explosion_audio.play()
	var blood_effect: Sprite2D = preload("res://Scenes/Effects/blood.tscn").instantiate()
	blood_effect.position = position + Vector2(0,20)
	blood_effect.scale *= 1.5
	get_parent().add_child(blood_effect)
	await get_tree().create_timer(3,false).timeout
	queue_free()
	pass
