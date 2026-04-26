extends DefenceTower
class_name BarrackTower

@export var barrack_data: BarrackData
@export var unit_count: int = 3
@export var soldier_scene: PackedScene

@onready var flag_button: TextureButton = $TowerUI/Circle/FlagButton
@onready var first_move_rays: Node2D = $FirstMoveRays

@export var is_new_tower: bool = true
var soldier_list: Array[Soldier]


func _enter_tree() -> void:
	if Stage.instance.ui_update.is_connected(Callable(self,"ui_process")): return
	barrack_data = barrack_data.duplicate()
	var barrack_level: int = clampi(Stage.instance.stage_sav.upgrade_sav[1],0,Stage.instance.limit_tech_level)
	if barrack_level >= 1: start_tower_range *= 1.2
	if barrack_level >= 2: barrack_data.soldier_health *= 1.2
	if barrack_level >= 3: barrack_data.armor += 0.1
	if barrack_level >= 4: barrack_data.rebirth_time = int(barrack_data.rebirth_time * 0.8)
	super()
	
	pass


func _ready() -> void:
	tower_area.hide()
	super()
	flag_button.pressed.connect(ready_to_move)
	if is_new_tower:
		await get_tree().create_timer(0.1,false).timeout
		summon_soldiers()
		await get_tree().physics_frame
		first_move()
	pass


func ready_to_move():
	Stage.instance.ui_process(self,Stage.StageUI.Move)
	ui_animation_player.play("hide_ui")
	tower_area.show()
	pass


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


func first_move():
	await get_tree().physics_frame
	for ray: RayCast2D in first_move_rays.get_children():
		if ray.is_colliding():
			var target_pos = ray.get_collision_point() + ray.target_position * 0.5
			move(target_pos)
			first_move_rays.queue_free()
			return
	pass


func summon_soldiers():
	for i in unit_count:
		var soldier: Soldier = soldier_scene.instantiate() as Soldier
		soldier.position = self.position
		soldier.tower = self
		Stage.instance.allys.add_child(soldier)
		soldier_list.append(soldier)
	pass


func move(target_pos: Vector2):
	if unit_count == 1:
		soldier_list[0].move(target_pos)
	elif unit_count == 2:
		soldier_list[0].move(target_pos - Vector2(30,0))
		soldier_list[1].move(target_pos + Vector2(30,0))
	else:
		for i in soldier_list.size():
			var current_pos = target_pos
			current_pos.x += cos((2 * PI / unit_count * i)- PI/2) * 24
			current_pos.y -= sin((2 * PI / unit_count * i)- PI/2) * 24
			soldier_list[i].move(current_pos)
	pass


func ui_process(member: Node):
	super(member)
	if member != self: tower_area.hide()
	pass


func destroy_tower():
	super()
	for soldier in soldier_list:
		soldier.soldier_sell()
	pass


func tower_level_up(type: TowerType, id: int):
	super(type,id)
	var new_tower: BarrackTower = Stage.instance.towers.get_child(-1)
	for soldier in soldier_list:
		if soldier.current_intercepting_enemy != null:
			soldier.current_intercepting_enemy.current_intercepting_units.erase(soldier)
	if new_tower.unit_count <= unit_count:
		for i in new_tower.unit_count:
			level_up_summon_soldier(new_tower,i)
	pass


func level_up_summon_soldier(new_tower:BarrackTower,i: int):
	var soldier: Soldier = new_tower.soldier_scene.instantiate()
	soldier.tower = new_tower
	Stage.instance.allys.add_child(soldier)
	soldier_list[i].soldier_level_up(soldier)
	new_tower.soldier_list.append(soldier)
	pass


func tower_skill_level_up(skill_id: int, skill_level: int):
	super(skill_id,skill_level)
	for soldier in soldier_list:
		soldier.soldier_skill_level_up(skill_id,skill_level)
	pass
