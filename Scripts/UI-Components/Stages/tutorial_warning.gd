extends CanvasLayer


@onready var intro_label: Label = $IntroLabel


func _ready() -> void:
	intro_label.visible_ratio = 0
	create_tween().tween_property(intro_label,"visible_ratio",1,0.5)
	await get_tree().create_timer(2,false).timeout
	var disappear_tween: Tween = create_tween()
	disappear_tween.tween_property(intro_label,"modulate:a",0,1)
	await disappear_tween.finished
	queue_free()
	pass
