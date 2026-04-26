extends Area2D

@export var damage_block: DamageBlock
@export var dizness_scene: PackedScene
@export var dizness_duration: float


func _ready() -> void:
	await get_tree().physics_frame
	await get_tree().physics_frame
	
	for body in get_overlapping_bodies():
		var ally: Ally = body.owner
		var damage: int = damage_block.get_damage()
		ally.take_damage(damage,DataProcess.DamageType.TrueDamage,0,false,null,false,true)
		var dizness_buff: DiznessBuff = dizness_scene.instantiate()
		dizness_buff.duration = dizness_duration
		dizness_buff.buff_tag = "hating_dizness"
		ally.buffs.add_child(dizness_buff)
	
	queue_free()
	pass
