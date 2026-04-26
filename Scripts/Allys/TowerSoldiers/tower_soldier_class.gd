extends SummonAlly
class_name TowerSoldier


@export var linked_tower: DefenceTower


func rebirth():
	if linked_tower.is_locked:
		await linked_tower.tower_unlock
	super()
	position = linked_tower.position
	move_back()
	pass
