extends PropertyBuff


@onready var sheild_sprite: AnimatedSprite2D = $SheildSprite
@onready var point_light_2d: PointLight2D = $PointLight2D


func _process(delta: float) -> void:
	super(delta)
	if unit is Ally:
		sheild_sprite.global_position = unit.hurt_box.global_position
	elif unit is Enemy:
		sheild_sprite.global_position = unit.hurt_box.global_position
	point_light_2d.global_position = sheild_sprite.global_position
	pass
