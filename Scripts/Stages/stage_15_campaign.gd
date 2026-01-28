extends Stage

@export var path_left_list: Array[EnemyPath]
@export var path_left_collision: CollisionPolygon2D
@export var left_hidden_tower: DefenceTower
@export var left_path_mask: Sprite2D
@export var left_explosion_markers: Array[Marker2D]
@export var left_hideen_tower2: DefenceTower

@export var path_right_list: Array[EnemyPath]
@export var path_right_collision: CollisionPolygon2D
@export var right_hidden_tower: DefenceTower
@export var right_path_mask: Sprite2D
@export var right_explosion_markers: Array[Marker2D]

@onready var boss_path: EnemyPath = $Enemies/BossPath

var stage_step: int = 0


func _ready() -> void:
	super()
	#await get_tree().create_timer(0.1,false).timeout
	#stage_step = 1
	#win()
	pass


func win(wait_time: float = 3):
	if is_win:
		return
	match stage_step:
		0:
			stage_step = 1
			summon_boss()
			is_win = true
		1:
			stage_step = 2
			after_boss_defeat()
			is_win = true
	
	await get_tree().create_timer(1,false).timeout
	is_win = false
	pass


func after_boss_defeat():
	var stage_story_layer: StoryLayer = preload("res://Scenes/Stages/Stage15/stage_15_story_layer.tscn").instantiate()
	add_child(stage_story_layer)
	create_tween().tween_property(boss_music,"volume_db",-80,1)
	
	await get_tree().create_timer(14,false).timeout
	var rain_layer: Node2D = preload("res://Scenes/Stages/Stage15/stage_15_layer.tscn").instantiate()
	background.add_child(rain_layer)
	await get_tree().create_timer(3,false).timeout
	var final_boss: Enemy = preload("res://Scenes/Enemies/hating_emperor_story.tscn").instantiate()
	enemies.get_child(-1).add_child(final_boss)
	var pos: Vector2 = enemies.get_child(-1).get_child(0).position
	final_boss.position = pos
	pass


func summon_boss():
	await get_tree().create_timer(5,false).timeout
	var boss: Enemy = preload("res://Scenes/Enemies/enemy_57.tscn").instantiate()
	boss_path.add_child(boss)
	for enemy_path: EnemyPath in enemies.get_children():
		enemy_path.wave_summon(current_wave+1)
	pass


func delay_win():
	await get_tree().create_timer(1,false).timeout
	is_win = false
	pass


func wave_tip(wave_count: int):
	match wave_count:
		6:
			open_path_left()
		8:
			open_path_right()
	pass


func open_path_left():
	explosion(left_explosion_markers)
	for path in path_left_list:
		path.enabled = true
	path_left_collision.disabled = false
	left_hidden_tower.show()
	left_hideen_tower2.show()
	create_tween().tween_property(left_path_mask,"modulate:a",0,1.2)
	pass


func open_path_right():
	explosion(right_explosion_markers)
	for path in path_right_list:
		path.enabled = true
	path_right_collision.disabled = false
	right_hidden_tower.show()
	create_tween().tween_property(right_path_mask,"modulate:a",0,1.2)
	pass


func explosion(marker_list: Array[Marker2D]):
	for marker in marker_list:
		var explosion_effect: AnimatedSprite2D = preload("res://Scenes/Effects/bullet_explosion_effect.tscn").instantiate()
		explosion_effect.position = marker.global_position
		Stage.instance.bullets.add_child(explosion_effect)
		var smoke_effect: AnimatedSprite2D = preload("res://Scenes/Effects/smoke_effect.tscn").instantiate()
		smoke_effect.position = marker.global_position
		Stage.instance.bullets.add_child(smoke_effect)
		AudioManager.instance.play_explosion_audio()
		await get_tree().create_timer(0.2,false).timeout
	pass
