extends DotBuff


@onready var blood_buff_anim: AnimatedSprite2D = $BloodBuffAnim

var locked_enemy: Enemy


func buff_start():
	super()
	if unit is Enemy:
		locked_enemy = unit
	pass


func _buff_process(delta: float):
	blood_buff_anim.global_position = locked_enemy.hurt_box.global_position
	pass
