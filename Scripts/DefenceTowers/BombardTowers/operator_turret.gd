extends BombardTower


@onready var unit_move_area: Area2D = $UnitMoveArea
@onready var flag_button: TextureButton = $TowerUI/Circle/FlagButton
@onready var first_move_rays: Node2D = $FirstMoveRays
@onready var lightning_sprite: Sprite2D = $TowerSprite/LightningSprite
@onready var skill_1_timer: Timer = $Skill1Timer
@onready var watcher: AnimatedSprite2D = $TowerSprite/Watcher


var robot_position: Vector2
var linked_robot: SummonAlly


func _ready() -> void:
	super()
	unit_move_area.hide()
	flag_button.pressed.connect(ready_to_move)
	first_move()
	pass


func ready_to_move():
	Stage.instance.ui_process(self,Stage.StageUI.Move)
	ui_animation_player.play("hide_ui")
	unit_move_area.show()
	pass


func ui_process(member: Node):
	super(member)
	if member != self: unit_move_area.hide()
	pass


func _on_unit_move_area_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event.is_action_released("click") and Stage.instance.mouse_in_path:
		unit_move_area.hide()
		Stage.instance.ui_process(null)
		move(Stage.instance.get_local_mouse_position())
		Stage.instance.move_point_effect(Stage.instance.get_local_mouse_position())
		var flag_effect: AnimatedSprite2D = preload("res://Scenes/Effects/flag_effect.tscn").instantiate()
		flag_effect.position = Stage.instance.get_local_mouse_position()
		Stage.instance.allys.add_child(flag_effect)
	pass # Replace with function body.


func move(target_pos: Vector2):
	robot_position = target_pos
	if linked_robot != null:
		linked_robot.station_position = target_pos
		linked_robot.move(target_pos)
	pass


func first_move():
	await get_tree().physics_frame
	await get_tree().physics_frame
	for ray: RayCast2D in first_move_rays.get_children():
		if ray.is_colliding():
			var target_pos = ray.get_collision_point() + ray.target_position * 0.5
			robot_position = target_pos
			first_move_rays.queue_free()
			return
	pass


func tower_skill_level_up(skill_id: int, skill_level: int):
	super(skill_id,skill_level)
	if skill_id == 0 and skill_level == 1:
		lightning_sprite.show()
	
	if skill_id == 1 and skill_level == 1:
		var robot: SummonAlly = preload("res://Scenes/Allys/SummonAllys/operator_robot.tscn").instantiate()
		robot.position = robot_position
		linked_robot = robot
		linked_robot.station_position = robot_position
		Stage.instance.allys.add_child(robot)
	elif skill_id == 1 and linked_robot != null:
		linked_robot.level_up()
	pass


func fighting_process():
	super()
	if tower_skill_levels[0] > 0 and skill_1_timer.is_stopped() and tower_area.has_overlapping_bodies():
		skill_1_timer.start()
		lighting_release()
	pass


func lighting_release():
	watcher.play()
	await get_tree().create_timer(0.1,false).timeout
	if tower_area.has_overlapping_bodies():
		var body = tower_area.get_overlapping_bodies()[randi_range(0,tower_area.get_overlapping_bodies().size()-1)]
		var enemy: Enemy = body.owner
		var pos: Vector2 = enemy.position
		var lightning_area: SkillConditionArea2D = preload("res://Scenes/Skills/operator_lightning_area.tscn").instantiate()
		lightning_area.position = pos
		lightning_area.skill_level = tower_skill_levels[0]
		Stage.instance.bullets.add_child(lightning_area)
		Achievement.achieve_int_add("OperatorLightning",1,666)
	pass


func destroy_tower():
	super()
	if linked_robot != null:
		linked_robot.sell_ally()
	pass
