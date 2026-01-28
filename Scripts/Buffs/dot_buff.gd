extends BuffClass
class_name DotBuff

@export var dot_damage: Array[int]
@export var can_be_dead: bool = true ##可致死

@onready var dot_timer: Timer = $DotTimer


func _ready() -> void:
	super()
	dot_timer.start()
	pass


func _on_dot_timer_timeout() -> void:
	var damage: int = dot_damage[buff_level-1]
	if unit is Ally:
		unit.take_damage(damage,DataProcess.DamageType.TrueDamage,0,false,null,false,false,can_be_dead)
	elif unit is Enemy:
		unit.take_damage(damage,DataProcess.DamageType.TrueDamage,0,false,null,false,false,can_be_dead)
	pass # Replace with function body.
