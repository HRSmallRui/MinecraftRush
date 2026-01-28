extends TipButton


func _ready() -> void:
	texture_button.pressed.connect(show_tip)
	await $AnimationPlayer.animation_finished
	$AnimationPlayer.play("loop")
	pass


func show_tip():
	Stage.instance.add_child(open_tip_scene.instantiate())
	queue_free()
	pass
