extends PropertyBuff

var current_animation: StringName
var current_frame: int
var freeze_sprite: AnimatedSprite2D


func buff_start():
	super()
	if unit is Ally:
		freeze_sprite = unit.ally_sprite
	elif unit is Enemy:
		freeze_sprite = unit.enemy_sprite
	current_animation = freeze_sprite.animation
	current_frame = freeze_sprite.frame
	pass


func _buff_process(delta: float):
	super(delta)
	freeze_sprite.animation = current_animation
	freeze_sprite.frame = current_frame
	pass
