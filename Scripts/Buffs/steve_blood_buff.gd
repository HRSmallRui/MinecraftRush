extends BuffClass


@onready var blood_buff_anim: AnimatedSprite2D = $BloodBuffAnim


func _ready() -> void:
	super()
	await get_tree().process_frame
	var unit = data_owner.owner as Node2D
	if unit is Ally:
		
		blood_buff_anim.global_position = unit.hurt_box.global_position
	elif unit is Enemy:
		blood_buff_anim.global_position = unit.hurt_box.global_position
	pass


func _on_blood_timer_timeout() -> void:
	if unit is Ally:
		unit.take_damage(2,DataProcess.DamageType.TrueDamage,0,false)
	elif unit is Enemy:
		unit.take_damage(2,DataProcess.DamageType.TrueDamage,0,false)
	pass # Replace with function body.


func _buff_process(delta: float):
	
	pass


func remove_buff():
	
	super()
	pass
