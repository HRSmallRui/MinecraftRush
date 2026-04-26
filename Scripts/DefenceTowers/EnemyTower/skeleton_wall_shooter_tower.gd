extends EnemyTower


func _ready() -> void:
	tower_data = tower_data.duplicate()
	tower_data.attack_speed += randf_range(-1,1)
	super()
	pass


func destroy():
	super()
	tower_shooter.play("die")
	pass
