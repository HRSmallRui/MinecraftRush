extends PropertyBuff

@onready var effect: Sprite2D = $Effect


func buff_start():
	super()
	if unit is Ally:
		effect.hide()
		effect.global_position = unit.hurt_box.global_position
		effect.show()
	pass
