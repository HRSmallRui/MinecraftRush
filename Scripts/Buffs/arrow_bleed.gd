extends DotBuff

@onready var blood_frame: AnimatedSprite2D = $BloodFrame

var enemy: Enemy


func buff_start():
	enemy = unit
	if enemy.enemy_buff_tags.has("ArrowBleed"):
		enemy.enemy_buff_tags["ArrowBleed"] += 1
	else:
		enemy.enemy_buff_tags["ArrowBleed"] = 1
	pass


func _ready() -> void:
	if unit is Enemy:
		if unit.enemy_buff_tags.has("ArrowBleed"):
			if unit.enemy_buff_tags["ArrowBleed"] >= 5:
				queue_free()
				return
		blood_frame.global_position = unit.hurt_box.global_position
	super()
	pass


func remove_buff():
	super()
	var enemy: Enemy = unit
	enemy.enemy_buff_tags["ArrowBleed"] -= 1
	pass


func _process(delta: float) -> void:
	super(delta)
	blood_frame.global_position = enemy.hurt_box.global_position
	pass
