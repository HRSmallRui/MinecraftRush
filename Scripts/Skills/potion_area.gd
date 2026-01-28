extends SkillConditionArea2D


@onready var splash_1: AudioStreamPlayer = $Splash1
@onready var splash_2: AudioStreamPlayer = $Splash2
@onready var splash_3: AudioStreamPlayer = $Splash3


func _ready() -> void:
	var potion_slash_effect: AnimatedSprite2D = preload("res://Scenes/Effects/potion_slash_effect.tscn").instantiate()
	potion_slash_effect.modulate = Color.DARK_RED
	potion_slash_effect.position = position
	Stage.instance.bullets.add_child(potion_slash_effect)
	
	match randi_range(1,3):
		1: splash_1.play()
		2: splash_2.play()
		3: splash_3.play()
	
	plugin_condition()
	
	await get_tree().create_timer(2,false).timeout
	queue_free()
	pass


func plugin_condition():
	var plugin_duration: float
	match skill_level:
		1: plugin_duration = 4
		2: plugin_duration = 6
		3: plugin_duration = 8
	await get_tree().physics_frame
	await get_tree().physics_frame
	for hurt_box in get_overlapping_areas():
		var enemy: Enemy = hurt_box.owner
		var plugin_buff: DotBuff = preload("res://Scenes/Buffs/Allys/medical_plugin_dot_debuff.tscn").instantiate()
		plugin_buff.duration = plugin_duration
		plugin_buff.buff_level = skill_level
		enemy.buffs.add_child(plugin_buff)
	pass
