extends SkillConditionArea2D


@onready var fork_sprite: AnimatedSprite2D = $ForkSprite
@onready var shot_timer: Timer = $ShotTimer
@onready var duration_timer: Timer = $DurationTimer
@onready var shadow: Sprite2D = $Shadow
@onready var in_path_area: Area2D = $InPathArea
@onready var skill_audio: AudioStreamPlayer = $SkillAudio

var damage_per_count: int


func _ready() -> void:
	await get_tree().physics_frame
	await get_tree().physics_frame
	if !in_path_area.has_overlapping_areas(): 
		queue_free()
		return
	skill_audio.play()
	
	shadow.scale = Vector2.ZERO
	create_tween().tween_property(shadow,"scale",Vector2.ONE * 3.6,0.12)
	await get_tree().create_timer(0.12,false).timeout
	var damage: int = HeroSkillLibrary.hero_skill_data_library[2][4].first_damage[skill_level-1]
	duration_timer.wait_time = HeroSkillLibrary.hero_skill_data_library[2][4].duration[skill_level-1]
	duration_timer.start()
	damage_per_count = HeroSkillLibrary.hero_skill_data_library[2][4].damage_per_count
	for body in get_overlapping_bodies():
		var enemy: Enemy = body.owner
		var dizness_buff: PropertyBuff = preload("res://Scenes/Buffs/Alex/alex_dizness_debuff.tscn").instantiate()
		dizness_buff.unit = enemy
		dizness_buff.buff_tag = "alex_dizness_4"
		dizness_buff.duration = 3
		enemy.buffs.add_child(dizness_buff)
		enemy.take_damage(damage,DataProcess.DamageType.ExplodeDamage,0,)
	shot_timer.start()
	pass


func _on_shot_timer_timeout() -> void:
	for body in get_overlapping_bodies():
		var enemy: Enemy = body.owner
		var speed_low_buff: PropertyBuff = preload("res://Scenes/Buffs/Alex/alex_skill_4_speed_low.tscn").instantiate()
		speed_low_buff.unit = enemy
		enemy.buffs.add_child(speed_low_buff)
		enemy.take_damage(damage_per_count,DataProcess.DamageType.PhysicsDamage,0)
	pass # Replace with function body.


func _on_duration_timer_timeout() -> void:
	shot_timer.stop()
	var disappear_tween: Tween = create_tween()
	disappear_tween.tween_property(self,"modulate:a",0,1)
	await disappear_tween.finished
	queue_free()
	pass # Replace with function body.
