extends SkillButton

@onready var rain_timer: Timer = $RainTimer
@onready var robort_rain_layer: CanvasLayer = $RobortRainLayer
@onready var rain_audio_super: AudioStreamPlayer = $RainAudioSuper
@onready var rain_shot_timer: Timer = $RainShotTimer
@onready var enemy_condition_area: Area2D = $EnemyConditionArea
@onready var collision_shape_2d: CollisionShape2D = $EnemyConditionArea/CollisionShape2D

var level: int


func _ready() -> void:
	super()
	remove_child(enemy_condition_area)
	Stage.instance.bullets.add_child(enemy_condition_area)
	var target_collision: CollisionShape2D = Stage.instance.click_area.get_child(0)
	collision_shape_2d.position = target_collision.position
	collision_shape_2d.shape = target_collision.shape
	
	level = Stage.instance.stage_sav.hero_sav[4].skill_levels[4]
	robort_rain_layer.hide()
	rain_timer.wait_time = HeroSkillLibrary.hero_skill_data_library[4][5].storm_during_time[level]
	pass


func skill_unlease_condition():
	if Stage.instance.mouse_in_path and !Stage.instance.mouse_in_fire_stop_area:
		skill_unlease()
	pass


func skill_unlease():
	super()
	release_lightning(Stage.instance.get_local_mouse_position())
	release_raining()
	pass


func release_lightning(release_position: Vector2):
	var loop_count: int = HeroSkillLibrary.hero_skill_data_library[4][5].lightning_count[level]
	for i in loop_count:
		var lightning_area: SkillConditionArea2D = preload("res://Scenes/Skills/robort_lighting_area.tscn").instantiate()
		lightning_area.position = release_position + Vector2(randf_range(-60,60),randf_range(-45,45))
		Stage.instance.bullets.add_child(lightning_area)
		await get_tree().create_timer(0.4,false).timeout
	pass


func release_raining():
	if "desert" in Stage.instance.stage_environment_tags: return
	
	rain_audio_super.play()
	robort_rain_layer.show()
	rain_timer.start()
	rain_shot_timer.start()
	
	await rain_timer.timeout
	rain_audio_super.stop()
	robort_rain_layer.hide()
	rain_shot_timer.stop()
	pass


func _on_rain_shot_timer_timeout() -> void:
	for body in enemy_condition_area.get_overlapping_bodies():
		var enemy: Enemy = body.owner
		var slow_buff: PropertyBuff = preload("res://Scenes/Buffs/Robort/robort_slowly_buff.tscn").instantiate()
		enemy.buffs.add_child(slow_buff)
	pass # Replace with function body.
