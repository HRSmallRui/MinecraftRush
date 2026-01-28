extends PropertyBuff

@onready var sheild: AnimatedSprite2D = $Sheild


func _ready() -> void:
	super()
	sheild.modulate.a = 0
	create_tween().tween_property(sheild,"modulate:a",1,0.5)
	pass


func remove_buff():
	remove_buff_block()
	var disappear_tween: Tween = create_tween()
	disappear_tween.tween_property(sheild,"modulate:a",0,0.5)
	await disappear_tween.finished
	queue_free()
	pass
