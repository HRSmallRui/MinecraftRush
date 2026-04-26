extends Stage


@export var explosion_markers: Array[Marker2D]
@onready var path_mask_1: Sprite2D = $Background/BasedSprite/PathMask1
@onready var path_mask_2: Sprite2D = $Background/BasedSprite/PathMask2
@onready var path_mask_3: Sprite2D = $Background/BasedSprite/PathMask3
@onready var path_mask_4: Sprite2D = $Background/BasedSprite/PathMask4
@onready var polygon_hide: CollisionPolygon2D = $PathArea/PolygonHide
@onready var firerain_random_region_2: NavigationRegion2D = $FirerainRandomRegions/FirerainRandomRegion2
@onready var dirt_audio: AudioStreamPlayer = $AudioManager/DirtAudio
@onready var enemy_path_7: EnemyPath = $Enemies/EnemyPath7
@onready var enemy_path_8: EnemyPath = $Enemies/EnemyPath8
@onready var enemy_path_9: EnemyPath = $Enemies/EnemyPath9


func path_show():
	loop_explosion()
	path_disappear_animation()
	await get_tree().create_timer(0.8,false).timeout
	polygon_hide.disabled = false
	firerain_random_region_2.enabled = true
	
	enemy_path_7.enabled = true
	enemy_path_8.enabled = true
	enemy_path_9.enabled = true
	pass


func _ready() -> void:
	super()
	pass


func loop_explosion():
	for marker: Marker2D in explosion_markers:
		var particle: AnimatedSprite2D = preload("res://Scenes/Effects/block_particle.tscn").instantiate()
		particle.position = marker.position
		particle.modulate = Color(1,1,0.7,1)
		particle.scale *= 2
		Stage.instance.background.add_child(particle)
		dirt_audio.play()
		await get_tree().create_timer(0.1,false).timeout
	pass


func path_disappear_animation():
	create_tween().tween_property(path_mask_1,"modulate:a",0,0.4)
	await get_tree().create_timer(0.3,false).timeout
	create_tween().tween_property(path_mask_2,"modulate:a",0,0.4)
	await get_tree().create_timer(0.3,false).timeout
	create_tween().tween_property(path_mask_3,"modulate:a",0,0.4)
	await get_tree().create_timer(0.3,false).timeout
	create_tween().tween_property(path_mask_4,"modulate:a",0,0.4)
	pass


func wave_tip(wave_count: int):
	if wave_count == 8:
		await get_tree().create_timer(2,false).timeout
		path_show()
	elif wave_count == 5:
		await get_tree().create_timer(5,false).timeout
		stage_camera.position = Vector2(2337,948)
		stage_camera.zoom = Vector2.ONE * 2
	pass


func win(wait_time: float = 6):
	super(wait_time)
	pass
