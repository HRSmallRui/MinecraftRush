extends SkillConditionArea2D

@export var skill_duration_list: Array[float]
@export var protection_buff_scene: PackedScene
@export var heal_rate_list: Array[float]
@export var steve_armor_up_buff_scene: PackedScene
@export var steve_heal_rate: float
@export var heal_buff_scene: PackedScene
@export var heal_buff_effect_scene: PackedScene

@onready var buff_sprite: Sprite2D = $BuffSprite
@onready var shot_timer: Timer = $ShotTimer
@onready var duration_timer: Timer = $DurationTimer


func _ready() -> void:
	buff_sprite.modulate.a = 0
	create_tween().tween_property(buff_sprite,"modulate:a",1,0.4)
	duration_timer.wait_time = skill_duration_list[skill_level]
	duration_timer.start()
	var steve: Hero = Stage.instance.hero_list[0]
	var heal_data: int = steve.start_data.health * steve_heal_rate
	steve.current_data.heal(heal_data)
	var heal_effect: BuffClass = heal_buff_effect_scene.instantiate()
	steve.buffs.add_child(heal_effect)
	var steve_armor_buff: PropertyBuff = steve_armor_up_buff_scene.instantiate()
	steve_armor_buff.duration = skill_duration_list[skill_level]
	steve.buffs.add_child(steve_armor_buff)
	
	await get_tree().physics_frame
	await get_tree().physics_frame
	var heal_rate: float = heal_rate_list[skill_level]
	for body in get_overlapping_bodies():
		var ally: Ally = body.owner
		if ally.ally_type == Ally.AllyType.Heroes: continue
		ally.current_data.heal(heal_rate * ally.start_data.health)
		var soldier_heal_effect: BuffClass = heal_buff_effect_scene.instantiate()
		ally.buffs.add_child(soldier_heal_effect)
	pass


func _on_shot_timer_timeout() -> void:
	for body in get_overlapping_bodies():
		var ally: Ally = body.owner
		var heal_buff: HealBuff = heal_buff_scene.instantiate()
		ally.buffs.add_child(heal_buff)
		var protection_buff: PropertyBuff = protection_buff_scene.instantiate()
		ally.buffs.add_child(protection_buff)
	pass # Replace with function body.


func _on_duration_timer_timeout() -> void:
	shot_timer.stop()
	var disappear_tween: Tween = create_tween()
	disappear_tween.tween_property(buff_sprite,"modulate:a",0,0.4)
	await disappear_tween.finished
	queue_free()
	pass # Replace with function body.
