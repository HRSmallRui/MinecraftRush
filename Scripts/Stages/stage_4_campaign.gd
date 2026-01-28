extends Stage

@export_group("防御塔")
@export var hide_left_based: DefenceTower
@export var hide_left_based_2: DefenceTower
@export var hide_right_based_1: DefenceTower
@export var hide_right_based_2: DefenceTower
@export var hide_right_based_3: DefenceTower
@export_group("路径碰撞体")
@export var left_path_polygon: CollisionPolygon2D
@export var right_path_polygon: CollisionPolygon2D
@export_group("爆炸标记点")
@export var left_explosion_markers: Array[Marker2D]
@export var right_explosion_markers: Array[Marker2D]

@onready var hide_path_left: Sprite2D = $Background/BasedSprite/HidePathLeft
@onready var hide_path_right: Sprite2D = $Background/BasedSprite/HidePathRight
@onready var hide_tree_left: Sprite2D = $Background/BasedSprite/HideTreeLeft
@onready var hide_tree_right: Sprite2D = $Background/BasedSprite/HideTreeRight
@onready var firerain_random_region_left: NavigationRegion2D = $FirerainRandomRegions/FirerainRandomRegionLeft
@onready var firerain_random_region_right: NavigationRegion2D = $FirerainRandomRegions/FirerainRandomRegionRight
@onready var enemy_path_10: EnemyPath = $Enemies/EnemyPath10
@onready var enemy_path_11: EnemyPath = $Enemies/EnemyPath11
@onready var enemy_path_12: EnemyPath = $Enemies/EnemyPath12
@onready var enemy_path_13: EnemyPath = $Enemies/EnemyPath13
@onready var enemy_path_14: EnemyPath = $Enemies/EnemyPath14
@onready var enemy_path_15: EnemyPath = $Enemies/EnemyPath15


func _ready() -> void:
	super()
	pass


func wave_tip(wave_count: int):
	match wave_count:
		6:
			left_road_appear()
		10:
			right_road_appear()
	pass


func left_road_appear():
	explosion_animation(left_explosion_markers)
	create_tween().tween_property(hide_tree_left,"modulate:a",0,0.8)
	create_tween().tween_property(hide_path_left,"modulate:a",0,0.8)
	await get_tree().create_timer(0.2,false).timeout
	hide_left_based.show()
	hide_left_based_2.show()
	await get_tree().create_timer(0.6,false).timeout
	left_path_polygon.disabled = false
	firerain_random_region_left.enabled = true
	enemy_path_10.enabled = true
	enemy_path_11.enabled = true
	enemy_path_12.enabled = true
	pass


func explosion_animation(explosion_marker_list: Array[Marker2D]):
	for explosion_marker in explosion_marker_list:
		var effect: AnimatedSprite2D = preload("res://Scenes/Effects/bullet_explosion_effect.tscn").instantiate()
		effect.position = explosion_marker.global_position
		effect.scale *= 3
		stage_camera.shake(10)
		allys.add_child(effect)
		AudioManager.instance.play_explosion_audio()
		await get_tree().create_timer(0.25,false).timeout
		firerain_random_region_right.enabled = true
	pass


func right_road_appear():
	explosion_animation(right_explosion_markers)
	create_tween().tween_property(hide_tree_right,"modulate:a",0,1.4)
	create_tween().tween_property(hide_path_right,"modulate:a",0,1.4)
	await get_tree().create_timer(0.4,false).timeout
	hide_right_based_1.show()
	hide_right_based_2.show()
	hide_right_based_3.show()
	await get_tree().create_timer(1,false).timeout
	right_path_polygon.disabled = false
	enemy_path_13.enabled = true
	enemy_path_14.enabled = true
	enemy_path_15.enabled = true
	pass


func win(wait_time: float = 6):
	super(wait_time)
	if current_health >= 20:
		Achievement.achieve_complete("Stage4")
	pass
