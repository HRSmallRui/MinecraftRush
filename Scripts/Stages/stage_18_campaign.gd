extends Stage

@export var enemy_tower_list: Array[EnemyTower]
@export var explosion_marker_list: Array[Marker2D]
@export var later_disable_path_list: Array[EnemyPath]
@export var later_enable_path_list: Array[EnemyPath]

@onready var camera_collision_shape: CollisionShape2D = $StageCamera/CollisionShape2D
@onready var firerain_random_region_2: NavigationRegion2D = $FirerainRandomRegions/FirerainRandomRegion2
@onready var camera_marker: Marker2D = $CameraMarker
@onready var explosion_wating_timer: Timer = $Background/ExplosionWatingTimer


func wave_tip(wave_count: int):
	if wave_count == 8:
		explosion_wating_timer.start()
		await explosion_wating_timer.timeout
		open_path()
	pass


func open_path():
	for i in 4:
		var enemy_tower: EnemyTower = enemy_tower_list[i]
		var explosion_marker: Marker2D = explosion_marker_list[i]
		var destroy_effect:Node2D = preload("res://Scenes/Effects/destroy_wall_effect.tscn").instantiate()
		destroy_effect.position = explosion_marker.global_position
		Stage.instance.bullets.add_child(destroy_effect)
		Stage.instance.stage_camera.position = explosion_marker.global_position
		await get_tree().create_timer(0.4,false).timeout
		enemy_tower.destroy()
		await get_tree().create_timer(0.1,false).timeout
	
	for path in later_disable_path_list:
		path.enabled = false
	for path in later_enable_path_list:
		path.enabled = true
	
	await get_tree().create_timer(1,false).timeout
	stage_camera.move_limit_shape = camera_collision_shape
	stage_camera.update_move_limit()
	firerain_random_region_2.enabled = true
	stage_camera.min_zoom_length_desktop = 0.9
	stage_camera.position = camera_marker.global_position
	pass
