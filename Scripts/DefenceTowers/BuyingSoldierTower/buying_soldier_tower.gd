extends DefenceTower
class_name BuyingSoldierTower

@export_multiline var tower_intro: String
@export var soldier_count_limit: int
@export var buying_soldier_list: Array[BuyingSoldier]

@onready var first_move_rays: Node2D = $FirstMoveRays
@onready var flag_button: TextureButton = $TowerUI/Circle/FlagButton

var move_center_position: Vector2


func _on_tower_area_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event.is_action_released("click") and Stage.instance.mouse_in_path:
		tower_area.hide()
		Stage.instance.ui_process(null)
		move(Stage.instance.get_local_mouse_position())
		Stage.instance.move_point_effect(Stage.instance.get_local_mouse_position())
		var flag_effect: AnimatedSprite2D = preload("res://Scenes/Effects/flag_effect.tscn").instantiate()
		flag_effect.position = Stage.instance.get_local_mouse_position()
		Stage.instance.allys.add_child(flag_effect)
	pass # Replace with function body.


func _ready() -> void:
	tower_area.hide()
	super()
	await get_tree().physics_frame
	first_move()
	pass


func first_move():
	await get_tree().physics_frame
	await get_tree().physics_frame
	for ray: RayCast2D in first_move_rays.get_children():
		if ray.is_colliding():
			var target_pos = ray.get_collision_point() + ray.target_position * 0.5
			move_center_position = target_pos
			#print(move_center_position)
			first_move_rays.queue_free()
			return
	pass


func _on_flag_button_pressed() -> void:
	Stage.instance.ui_process(self,Stage.StageUI.Move)
	ui_animation_player.play("hide_ui")
	tower_area.show()
	pass # Replace with function body.


func ui_process(member: Node):
	super(member)
	if member != self: tower_area.hide()
	pass


func move(target_pos: Vector2):
	move_center_position = target_pos
	allocate_position(target_pos)
	
	if buying_soldier_list.size() == 1:
		buying_soldier_list[0].move(target_pos)
	elif buying_soldier_list.size() == 2:
		buying_soldier_list[0].move( target_pos - Vector2(30,0))
		buying_soldier_list[1].move( target_pos + Vector2(30,0))
	else:
		for i in buying_soldier_list.size():
			var current_pos = target_pos
			current_pos.x += cos((2 * PI / buying_soldier_list.size() * i)- PI/2) * 24
			current_pos.y -= sin((2 * PI / buying_soldier_list.size() * i)- PI/2) * 24
			buying_soldier_list[i].move(current_pos)
	pass


func allocate_position(target_pos: Vector2):
	if buying_soldier_list.size() == 1:
		buying_soldier_list[0].station_position = target_pos
	elif buying_soldier_list.size() == 2:
		buying_soldier_list[0].station_position = target_pos - Vector2(30,0)
		buying_soldier_list[1].station_position = target_pos + Vector2(30,0)
	else:
		for i in buying_soldier_list.size():
			var current_pos = target_pos
			current_pos.x += cos((2 * PI / buying_soldier_list.size() * i)- PI/2) * 24
			current_pos.y -= sin((2 * PI / buying_soldier_list.size() * i)- PI/2) * 24
			buying_soldier_list[i].station_position = current_pos
	pass


func update_soldiers_position():
	allocate_position(move_center_position)
	for soldier in buying_soldier_list:
		if soldier.ally_state == Ally.AllyState.IDLE or soldier.ally_state == Ally.AllyState.MOVE:
			soldier.move_back()
	pass


func update_buying_soldier_brothers():
	for buying_soldier in buying_soldier_list:
		var now_brother_list: Array[BuyingSoldier] = buying_soldier_list.duplicate()
		now_brother_list.erase(buying_soldier)
		buying_soldier.buying_soldier_brothers = now_brother_list
	pass
