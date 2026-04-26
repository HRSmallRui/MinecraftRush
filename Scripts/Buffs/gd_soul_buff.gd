extends PropertyBuff

@onready var soul_effect: Sprite2D = $SoulEffect

var ally: Ally


func buff_start():
	super()
	ally = unit
	pass


func _buff_process(delta: float):
	super(delta)
	soul_effect.global_position = ally.hurt_box.global_position
	pass
