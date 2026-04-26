extends Stage

@export var steve_sp_scene: PackedScene
@export var steve_skill_button_scene: PackedScene
@export var steve_sp_intro_scene: PackedScene
@export_group("Region Expanding")
@export var on_region_expand_tower_list: Array[DefenceTower]
@export var region_expand_fire_region_list: Array[NavigationRegion2D]
@export var on_region_expand_path_list: Array[EnemyPath]
@export_group("Path Opening")
@export var start_lightning_markers: Array[Marker2D]
@export var left_marker_list: Array[Marker2D]
@export var right_marker_list: Array[Marker2D]
@export var on_path_open_tower_list: Array[DefenceTower]
@export var path_opening_mask: Node2D
@export var path_opening_area_shape: CollisionPolygon2D
@export var path_opening_fire_region: NavigationRegion2D
@export var lightning_scene: PackedScene
@export var explosion_scene: PackedScene
@export var smoke_scene: PackedScene
@export var path_opening_path_list: Array[EnemyPath]

@onready var region_marker: Marker2D = $RegionMarker
@onready var later_camera_shape: CollisionShape2D = $StageCamera/CollisionShape2D2
@onready var lightning_markers: Node2D = $LightningMarkers
@onready var tower_destroy_area: Area2D = $TowerDestroyArea
@onready var camera_up_down_component: Control = $StageUI/CameraUpDownComponent


func _ready() -> void:
	super()
	camera_up_down_component.hide()
	var time:Dictionary = Time.get_datetime_dict_from_system()
	print(time)
	if time.hour == 16 and time.minute == 4:
		Achievement.achieve_complete("DNA_time")
	if stage_sav.select_hero_id == 0 and stage_sav.level_sav[20][1] == 0:
		var unlock_layer: CanvasLayer = steve_sp_intro_scene.instantiate()
		add_child(unlock_layer)
	pass


func summon_hero(summon_pos:Vector2 = hero_summon_marker.position):
	if stage_sav.select_hero_id == 0 and stage_sav.level_sav[20][1] == 0:
		var hero: Hero = steve_sp_scene.instantiate()
		hero.position = summon_pos
		hero.station_position = hero.position
		allys.add_child(hero)
		hero.skill_levels = [3,3,3,3,3]
		hero_list.append(hero)
		return
	super(summon_pos)
	pass


func add_hero_skill_button():
	if stage_sav.select_hero_id == 0 and stage_sav.level_sav[20][1] == 0:
		var skill_button: SkillButton = steve_skill_button_scene.instantiate()
		skill_button_container.add_child(skill_button)
		skill_button.skill_level = 3
		return
	super()
	pass


func expand_regopn():
	await get_tree().create_timer(20,false).timeout
	stage_camera.move_limit_shape = later_camera_shape
	stage_camera.update_move_limit()
	stage_camera.position = region_marker.global_position
	for tower in on_region_expand_tower_list:
		tower.show()
	for region in region_expand_fire_region_list:
		region.enabled = true
	for path in on_region_expand_path_list:
		path.enabled = true
	camera_up_down_component.show()
	pass


func open_path():
	await get_tree().create_timer(10,false).timeout
	var tween_time: float = 2
	create_tween().tween_property(path_opening_mask,"modulate:a",0,tween_time)
	for tower in on_path_open_tower_list:
		tower.show()
	for path in path_opening_path_list:
		path.enabled = true
	for i in start_lightning_markers.size():
		var marker: Marker2D = start_lightning_markers[i]
		summon_lightning(marker.global_position)
		AudioManager.instance.play_explosion_audio()
		if i == 0:
			for area in tower_destroy_area.get_overlapping_areas():
				var tower: DefenceTower = area.owner
				tower.destroy_tower()
				await get_tree().process_frame
				var new_tower: DefenceTower = towers.get_child(-1)
				new_tower.queue_free()
		await get_tree().create_timer(0.3,false).timeout
	
	for i in left_marker_list.size():
		var left_marker: Marker2D = left_marker_list[i]
		var right_marker: Marker2D = right_marker_list[i]
		summon_lightning(left_marker.global_position)
		summon_lightning(right_marker.global_position)
		AudioManager.instance.play_explosion_audio()
		await get_tree().create_timer(0.3,false).timeout
	
	path_opening_area_shape.disabled = false
	path_opening_fire_region.enabled = true
	pass


func wave_tip(wave_count: int):
	match wave_count:
		7:
			expand_regopn()
		10:
			open_path()
	pass


func summon_lightning(summon_pos: Vector2):
	var lightning: Line2D = lightning_scene.instantiate()
	lightning.position = summon_pos
	var explosion_effect: AnimatedSprite2D = explosion_scene.instantiate()
	explosion_effect.position = summon_pos
	var smoke_effect: AnimatedSprite2D = smoke_scene.instantiate()
	smoke_effect.position = summon_pos
	
	bullets.add_child(lightning)
	bullets.add_child(explosion_effect)
	bullets.add_child(smoke_effect)
	pass


func win(wait_time: float = 3):
	if is_win: return
	is_win = true
	on_wining.emit()
	pass
