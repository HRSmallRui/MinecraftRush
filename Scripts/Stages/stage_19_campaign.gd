extends Stage

@export_group("StoryLayers")
@export_subgroup("StepStory")
@export var begin_story_layer_scene: PackedScene
@export var cooperation_story_layer_scene: PackedScene
@export var end_story_layer_scene: PackedScene
@export var loop_music_player_scene: PackedScene
@export_subgroup("InnerStory")
@export var region_expanding_story_layer_scene: PackedScene
@export var hating_explosion_story_layer_scene: PackedScene
@export_group("")
@export var later_camera_collision: CollisionShape2D
@export var tower_summon_list: Array[DefenceTower]
@export var tower_new_summon_scene_list: Array[PackedScene]
@export_group("Cooperator")
@export var zombie_gene_scene: PackedScene
@export var skeleton_gene_scene: PackedScene
@export var zombie_gene_summon_marker: Marker2D
@export var skeleton_gene_summon_marker: Marker2D

@onready var battle_music_player: LoopMusicPlayer = $Musics/BattleMusicPlayer
@onready var tower_condition_area: Area2D = $TowerConditionArea
@onready var story_move_marker: Marker2D = $StoryMoveMarker
@onready var hating_reinforce_system: HatingReinforceSystem = $HatingReinforceSystem
@onready var hide_tower_based: DefenceTower = $Towers/DefenceTowerBased15
@onready var firerain_random_region_2: NavigationRegion2D = $FirerainRandomRegions/FirerainRandomRegion2

var tower_summon_pos_list: Array[Vector2]
var next_tower_replace_list: Array[DefenceTower]
var cooperator_music_player: LoopMusicPlayer


func _ready() -> void:
	for tower in tower_summon_list:
		tower_summon_pos_list.append(tower.global_position)
	super()
	add_child(begin_story_layer_scene.instantiate())
	await get_tree().create_timer(0.01,false).timeout
	preparation_music.play()
	pass


func into_story():
	var tower_list: Array[DefenceTower]
	for area in tower_condition_area.get_overlapping_areas():
		var tower: DefenceTower = area.owner
		tower_list.append(tower)
	tower_list = get_new_tower_list(tower_list)
	if information_bar.current_check_member in tower_list:
		ui_process(null)
	for tower in tower_list:
		tower.process_mode = Node.PROCESS_MODE_DISABLED
		tower.tower_ui.hide()
	explode_all_towers(tower_list)
	await get_tree().create_timer(0.3 * tower_list.size(),false).timeout
	var explosion_story_layer: StoryLayer = hating_explosion_story_layer_scene.instantiate()
	add_child(explosion_story_layer)
	await get_tree().create_timer(explosion_story_layer.ending_time + 1,false).timeout
	
	var story_layer: StoryLayer = cooperation_story_layer_scene.instantiate()
	add_child(story_layer)
	ui_process(null)
	first_music_player_process()
	#await get_tree().create_timer(12).timeout
	await get_tree().create_timer(2.5).timeout
	add_cooperators()
	#battle_music_player.stop_music()
	#battle_music_player.queue_free()
	await get_tree().create_timer(0.2,false).timeout
	cooperator_music_player = loop_music_player_scene.instantiate()
	preparation_music.get_parent().add_child(cooperator_music_player)
	on_battle_music_playing.emit()
	pass


func wave_tip(wave_count: int):
	if wave_count == 7:
		await get_tree().create_timer(50,false).timeout
		expend_region()
	elif wave_count == 8:
		await get_tree().create_timer(30,false).timeout
		into_story()
	pass


func expend_region():
	stage_camera.move_limit_shape = later_camera_collision
	stage_camera.update_move_limit()
	stage_camera.position = story_move_marker.global_position
	add_child(region_expanding_story_layer_scene.instantiate())
	hide_tower_based.show()
	firerain_random_region_2.enabled = true
	pass


func add_cooperators():
	summon_cooperation_hero(zombie_gene_scene,zombie_gene_summon_marker)
	summon_cooperation_hero(skeleton_gene_scene,skeleton_gene_summon_marker)
	for i in next_tower_replace_list.size():
		var tower: DefenceTower = next_tower_replace_list[i]
		if tower == null: continue
		var replace_tower: DefenceTower = tower_new_summon_scene_list[i].instantiate()
		replace_tower.position = tower.position
		towers.add_child(replace_tower)
		tower.queue_free()
	pass


func explode_all_towers(tower_list: Array[DefenceTower]):
	for tower in tower_list:
		var explosion_area: Area2D = hating_reinforce_system.hating_shell_scene.instantiate()
		explosion_area.position = tower.position
		Stage.instance.bullets.add_child(explosion_area)
		delay_explode_tower(tower)
		await get_tree().create_timer(0.3,false).timeout
	pass


func delay_explode_tower(tower: DefenceTower):
	await get_tree().create_timer(0.4,false).timeout
	tower.destroy_tower()
	var new_tower: DefenceTower = towers.get_child(-1)
	new_tower.process_mode = Node.PROCESS_MODE_DISABLED
	next_tower_replace_list.append(new_tower)
	pass


func summon_cooperation_hero(hero_scene: PackedScene, summon_marker: Marker2D):
	var hero: Hero = hero_scene.instantiate()
	hero.position = summon_marker.global_position
	hero.station_position = hero.position
	allys.add_child(hero)
	AudioManager.instance.level_up_audio.stop()
	hero_list.append(hero)
	summon_marker.queue_free()
	pass


func win(wait_time: float = 3):
	if is_win: return
	is_win = true
	on_wining.emit()
	print("win")
	#return
	
	await get_tree().create_timer(2,false).timeout
	if cooperator_music_player != null:
		cooperator_music_player.set_volume(-100,2)
	await get_tree().create_timer(wait_time,false).timeout
	battle_music.stop()
	boss_music.stop()
	var story_layer: StoryLayer = end_story_layer_scene.instantiate()
	add_child(story_layer)
	pass


func get_new_tower_list(tower_list: Array[DefenceTower]) -> Array[DefenceTower]:
	var back_list: Array[DefenceTower]
	
	var d_tower_list: Array[DefenceTower] = tower_list.duplicate()
	while !d_tower_list.is_empty():
		var tower: DefenceTower = get_most_left_tower(d_tower_list)
		d_tower_list.erase(tower)
		back_list.append(tower)
	
	return back_list


func get_most_left_tower(tower_list: Array[DefenceTower]) -> DefenceTower:
	if tower_list.is_empty(): return null
	var back_tower: DefenceTower = tower_list[0]
	for tower in tower_list:
		if tower.position.x < back_tower.position.x:
			back_tower = tower
	
	return back_tower


func first_music_player_process():
	battle_music_player.set_volume(-100,2)
	await get_tree().create_timer(2).timeout
	battle_music_player.queue_free()
	pass
