extends TowerBuff
class_name TowerLockBuff


func buff_start():
	super()
	tower.is_locked = true
	tower.tower_self_area.monitoring = false
	for area in tower.linked_areas:
		var shape: CollisionShape2D = area.get_child(0)
		shape.disabled = true
	tower.tower_button.disabled = true
	if Stage.instance.information_bar.current_check_member == tower:
		Stage.instance.ui_process(null)
	pass


func remove_buff():
	super()
	tower.is_locked = false
	tower.tower_self_area.monitorable = true
	for area in tower.linked_areas:
		var shape: CollisionShape2D = area.get_child(0)
		shape.disabled = false
	tower.tower_button.disabled = false
	pass
