extends Node2D

@onready var idle: Sprite2D = $Idle
@onready var disappear: AnimatedSprite2D = $Disappear
@onready var click_area: Area2D = $ClickArea


func _on_click_area_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event.is_action_pressed("click"):
		click_area.monitoring = false
		click_area.monitorable = false
		click_area.hide()
		idle.hide()
		disappear.show()
		disappear.play()
		Achievement.achieve_complete("SandHuman")
	pass # Replace with function body.
