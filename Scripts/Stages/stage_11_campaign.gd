extends Stage

@onready var mask: Sprite2D = $Background/BasedSprite/Mask
@onready var defence_tower_based_hide: DefenceTower = $Towers/DefenceTowerBasedHide
@onready var defence_tower_based_hide_2: DefenceTower = $Towers/DefenceTowerBasedHide2
@onready var collision_polygon_2d_3: CollisionPolygon2D = $PathArea/CollisionPolygon2D3
@onready var firerain_random_region_3: NavigationRegion2D = $FirerainRandomRegions/FirerainRandomRegion3


func wave_tip(wave_count: int):
	if wave_count != 8: return
	await get_tree().create_timer(4,false).timeout
	mask.hide()
	defence_tower_based_hide.show()
	defence_tower_based_hide_2.show()
	collision_polygon_2d_3.disabled = false
	firerain_random_region_3.enabled = true
	pass


func win(wait_time: float = 6):
	super(wait_time)
	pass
