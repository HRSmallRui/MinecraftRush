extends Stage

@export var enemy_path_list: Array[EnemyPath]

@onready var stage_10_mask: Sprite2D = $"Background/BasedSprite/Stage10-mask"
@onready var collision_polygon_2d_3: CollisionPolygon2D = $PathArea/CollisionPolygon2D3
@onready var firerain_random_region_3: NavigationRegion2D = $FirerainRandomRegions/FirerainRandomRegion3


func wave_tip(wave_count: int):
	if wave_count == 8:
		await get_tree().create_timer(6,false).timeout
		stage_10_mask.hide()
		for enemy_path in enemy_path_list:
			enemy_path.enabled = true
		collision_polygon_2d_3.disabled = false
		firerain_random_region_3.enabled = true
	pass
