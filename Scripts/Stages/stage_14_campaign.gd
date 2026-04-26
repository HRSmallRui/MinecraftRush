extends Stage

@export_group("PathOpen1")
@export var path_mask1: Sprite2D
@export var tree_mask: Sprite2D
@export var hidden_enemy_path_list_1: Array[EnemyPath]
@export var enemy_path_shape_1: CollisionPolygon2D
@export var explosion_list_1: Array[Marker2D]
@export var hidden_tower_list_1: Array[DefenceTower]

@export_group("PathOpen2")
@export var path_mask2: Sprite2D
@export var hidden_enemy_path_list_2: Array[EnemyPath]
@export var enemy_path_shape_2: CollisionPolygon2D
@export var explosion_list_2: Array[Marker2D]
@export var hidden_tower_list_2: Array[DefenceTower]


func wave_tip(wave_count: int):
	match wave_count:
		4:
			open_path_1()
		8:
			open_path_2()
	pass


func play_explosion(markers: Array[Marker2D]):
	for marker in markers:
		var explosion_effect: AnimatedSprite2D = preload("res://Scenes/Effects/bullet_explosion_effect.tscn").instantiate()
		explosion_effect.position = marker.global_position
		explosion_effect.scale *= 2
		Stage.instance.bullets.add_child(explosion_effect)
		AudioManager.instance.play_explosion_audio()
		Stage.instance.stage_camera.shake(10)
		await get_tree().create_timer(0.2,false).timeout
	pass


func open_path_1():
	play_explosion(explosion_list_1)
	for enemy_path in hidden_enemy_path_list_1:
		enemy_path.enabled = true
	enemy_path_shape_1.disabled = false
	create_tween().tween_property(tree_mask,"modulate:a",0,0.8)
	create_tween().tween_property(path_mask1,"modulate:a",0,0.8)
	for tower in hidden_tower_list_1:
		tower.show()
	pass


func open_path_2():
	play_explosion(explosion_list_2)
	for enemy_path in hidden_enemy_path_list_2:
		enemy_path.enabled = true
	enemy_path_shape_2.disabled = false
	create_tween().tween_property(path_mask2,"modulate:a",0,0.8)
	for tower in hidden_tower_list_2:
		tower.show()
	pass
