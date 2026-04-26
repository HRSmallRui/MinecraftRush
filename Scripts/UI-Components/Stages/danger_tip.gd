extends Control
class_name DangerTip

@onready var texture: TextureRect = $Texture

var linked_enemy: Enemy


func _ready() -> void:
	Stage.instance.ui_update.connect(ui_process)
	ui_process(Stage.instance.information_bar.current_check_member)
	if OS.get_name() == "Android":
		scale = Vector2.ONE
	pass


func _on_texture_rect_gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("click"):
		Stage.instance.stage_camera.position = linked_enemy.global_position
	pass # Replace with function body.


func _process(delta: float) -> void:
	if linked_enemy == null:
		queue_free()
		return
	if linked_enemy.enemy_state == Enemy.EnemyState.DIE:
		queue_free()
		return
	var pos: Vector2 = Vector2(960,540)
	var direction: Vector2 = (linked_enemy.global_position - Stage.instance.stage_camera.global_position).normalized()
	#print(direction)
	var x_rate: float = abs(960 / direction.x)
	var y_rate: float = abs(540 / direction.y)
	pos += direction * minf(x_rate,y_rate)
	position = pos
	position.x = clampf(position.x,0 + texture.size.x / 2 * scale.x, 1920 - texture.size.x / 2 * scale.x)
	position.y = clampf(position.y, 0 + texture.size.y / 2 * scale.y, 1080 - texture.size.y / 2 * scale.y)
	pass


func ui_process(member: Node):
	texture.mouse_filter = Control.MOUSE_FILTER_IGNORE if (Stage.instance.stage_ui == Stage.StageUI.Move or 
	Stage.instance.stage_ui == Stage.StageUI.SkillPreparation) else Control.MOUSE_FILTER_STOP
	pass
