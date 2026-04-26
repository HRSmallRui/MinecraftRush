extends CanvasLayer

@export var hit_area_scene: PackedScene

var boss: Enemy

@onready var directional_light_2d: DirectionalLight2D = $DirectionalLight2D
@onready var point_light_2d: PointLight2D = $PointLight2D


func _ready() -> void:
	directional_light_2d.modulate.a = 0
	point_light_2d.modulate.a = 0
	create_tween().tween_property(directional_light_2d,"modulate:a",1,0.5)
	create_tween().tween_property(point_light_2d,"modulate:a",1,0.5)
	
	Stage.instance.can_control = false
	Stage.instance.can_pause = false
	
	var skill_button: SkillButton = Stage.instance.skill_button_container.get_child(-1)
	skill_button.process_mode = Node.PROCESS_MODE_ALWAYS
	skill_button.unlock()
	Stage.instance.information_bar.process_mode = Node.PROCESS_MODE_ALWAYS
	Stage.instance.stage_camera.process_mode = Node.PROCESS_MODE_ALWAYS
	Stage.instance.stage_camera.position = boss.global_position
	
	await get_tree().create_timer(2).timeout
	Stage.instance.ui_process(skill_button,Stage.StageUI.Check)
	
	await get_tree().create_timer(2).timeout
	var hit_area: Area2D = hit_area_scene.instantiate()
	hit_area.position = boss.global_position
	Stage.instance.bullets.add_child(hit_area)
	Stage.instance.ui_process(null)
	skill_button.translate_to_state(SkillButton.ButtonState.Cooling)
	Stage.instance.information_bar.process_mode = Node.PROCESS_MODE_INHERIT
	Stage.instance.stage_camera.process_mode = Node.PROCESS_MODE_INHERIT
	skill_button.process_mode = Node.PROCESS_MODE_INHERIT
	
	get_tree().paused = false
	Stage.instance.can_control = true
	Stage.instance.can_pause = true
	queue_free()
	pass
