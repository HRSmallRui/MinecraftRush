extends PropertyBuff

@onready var soul_effect: Sprite2D = $SoulEffect

var enemy: Enemy


func buff_start():
	super()
	enemy = unit
	pass


func _buff_process(delta: float):
	super(delta)
	soul_effect.global_position = enemy.hurt_box.global_position
	pass
