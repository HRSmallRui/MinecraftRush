extends TipUI


func close_page():
	$AnimationPlayer2.play("close")
	await $AnimationPlayer2.animation_finished
	super()
	pass
