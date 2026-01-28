extends ArcherTower

const changer_soldier_scene: PackedScene = preload("res://Scenes/Allys/SummonAllys/changer_soldier.tscn")

@onready var unit_move_area: Area2D = $UnitMoveArea
@onready var first_move_rays: Node2D = $FirstMoveRays
@onready var flag_button: TextureButton = $TowerUI/Circle/FlagButton
@onready var cage_condition_area: Area2D = $CageConditionArea
@onready var cage_timer: Timer = $CageTimer

var soldier_position: Vector2
var soldier_list: Array[SummonAlly]


func _ready() -> void:
	super()
	unit_move_area.hide()
	flag_button.pressed.connect(ready_to_move)
	first_move()
	pass


func _process(delta: float) -> void:
	super(delta)
	cage_condition_area.scale = tower_area.scale
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


func ready_to_move():
	Stage.instance.ui_process(self,Stage.StageUI.Move)
	ui_animation_player.play("hide_ui")
	unit_move_area.show()
	pass


func first_move():
	await get_tree().physics_frame
	await get_tree().physics_frame
	for ray: RayCast2D in first_move_rays.get_children():
		if ray.is_colliding():
			var target_pos = ray.get_collision_point() + ray.target_position * 0.5
			soldier_position = target_pos
			first_move_rays.queue_free()
			return
	pass


func move(target_pos: Vector2):
	soldier_position = target_pos
	if soldier_list.is_empty(): return
	var soldier_1: SummonAlly = soldier_list[0]
	var soldier_2: SummonAlly = soldier_list[1]
	var pos1: Vector2 = target_pos + Vector2(-20,0)
	var pos2: Vector2 = target_pos + Vector2(20,0)
	soldier_1.move(pos1)
	soldier_1.station_position = pos1
	soldier_2.move(pos2)
	soldier_2.station_position = pos2
	pass


func ui_process(member: Node):
	super(member)
	if member != self: unit_move_area.hide()
	pass


func tower_skill_level_up(skill_id: int, skill_level: int):
	super(skill_id,skill_level)
	if skill_id == 1 and skill_level == 1:
		summon_soldiers()
	if skill_id == 1 and skill_level > 1:
		for changer in soldier_list:
			changer.level_up()
	pass


func summon_soldiers():
	for i in 2:
		var changer: SummonAlly = changer_soldier_scene.instantiate()
		changer.position = position + Vector2(0,-2)
		soldier_list.append(changer)
		Stage.instance.allys.add_child(changer)
	move(soldier_position)
	pass


func destroy_tower():
	super()
	for changer in soldier_list:
		changer.sell_ally()
	pass


func get_valid_skill1_enemy() -> Enemy:
	var enemy_list: Array[Enemy]
	for body in cage_condition_area.get_overlapping_bodies():
		var enemy: Enemy = body.owner
		if enemy.enemy_type >= Enemy.EnemyType.Super: continue
		if enemy.enemy_buff_tags.has("is_caging"):
			if enemy.enemy_buff_tags["is_caging"]: continue
		if enemy.enemy_buff_tags.has("cage_count"):
			if enemy.enemy_buff_tags["cage_count"] >= 4: continue
		enemy_list.append(enemy)
	if enemy_list.is_empty(): return null
	return shooter_list[0].get_lateset_enemy(enemy_list)
	pass


func fighting_process():
	if tower_skill_levels[0] > 0 and cage_timer.is_stopped():
		var enemy: Enemy = get_valid_skill1_enemy()
		if enemy != null:
			cage_timer.start()
			var cage_dizness: DiznessBuff = preload("res://Scenes/Buffs/TowerBuffs/illager_cage.tscn").instantiate()
			var dizness_time: float
			match tower_skill_levels[0]:
				1: dizness_time = 2
				2: dizness_time = 3
				3: dizness_time = 4
			cage_dizness.duration = dizness_time
			enemy.buffs.add_child(cage_dizness)
			var cage_effect: Node2D = preload("res://Scenes/Effects/illager_cage.tscn").instantiate()
			cage_effect.position = enemy.position
			Stage.instance.bullets.add_child(cage_effect)
			var timer: Timer = cage_effect.get_node("Timer")
			timer.wait_time = dizness_time - 0.4
			timer.start()
			normal_attack_timer.start()
		var second_enemy: Enemy = get_valid_skill1_enemy()
		if second_enemy != null:
			var cage_dizness: DiznessBuff = preload("res://Scenes/Buffs/TowerBuffs/illager_cage.tscn").instantiate()
			var dizness_time: float
			match tower_skill_levels[0]:
				1: dizness_time = 2
				2: dizness_time = 3
				3: dizness_time = 4
			cage_dizness.duration = dizness_time
			second_enemy.buffs.add_child(cage_dizness)
			var cage_effect: Node2D = preload("res://Scenes/Effects/illager_cage.tscn").instantiate()
			cage_effect.position = second_enemy.position
			Stage.instance.bullets.add_child(cage_effect)
			var timer: Timer = cage_effect.get_node("Timer")
			timer.wait_time = dizness_time - 0.4
			timer.start()
	super()
	pass
