extends Ally
class_name Soldier

@export var tower: BarrackTower
@export var soldier_name_list: Array[String]
@export var soldier_skill_levels: Array[int]

@onready var tech_heal_timer: Timer = $TechHealTimer

var soldier_brothers: Array[Soldier]


func _enter_tree() -> void:
	if Stage.instance.ui_update.is_connected(Callable(self,"ui_process")): return
	var upgrade_level: int = clampi(Stage.instance.stage_sav.upgrade_sav[1],0,Stage.instance.limit_tech_level)
	start_data = start_data.duplicate(true)
	if upgrade_level >= 2:
		start_data.health  = int(start_data.health * 1.2)
	if upgrade_level >= 3:
		start_data.armor += 0.1
	if upgrade_level >= 4:
		rebirth_time = int(rebirth_time * 0.8)
	super()
	allocate_name()
	pass


func allocate_name():
	ally_name = soldier_name_list[randi_range(0,soldier_name_list.size()-1)]
	pass


func _ready() -> void:
	super()
	await get_tree().process_frame
	soldier_brothers = tower.soldier_list.duplicate()
	soldier_brothers.erase(self)
	var level: int = clampi(Stage.instance.stage_sav.upgrade_sav[1],0,Stage.instance.limit_tech_level)
	if level >= 5:
		tech_heal_timer.start()
	pass


func ui_process(member: Node):
	select_sprite.visible = member == self or member == tower
	if Stage.instance.stage_ui == Stage.StageUI.None or Stage.instance.stage_ui == Stage.StageUI.Check:
		ally_button.mouse_filter = Control.MOUSE_FILTER_STOP
	else:
		ally_button.mouse_filter = Control.MOUSE_FILTER_IGNORE
	pass


func battle_process():
	if current_intercepting_enemy != null:
		if !self in current_intercepting_enemy.current_intercepting_units:
			current_intercepting_enemy = null
	super()
	pass


func idle_process():
	super()
	if current_intercepting_enemy == null and ally_state == AllyState.IDLE:
		for soldier in soldier_brothers:
			if soldier.current_intercepting_enemy != null:
				var enemy = soldier.current_intercepting_enemy as Enemy
				current_intercepting_enemy = enemy
				enemy.current_intercepting_units.append(self)
				move_to_intercept(enemy.intercepting_marker.global_position)
				return
	pass


func move_back():
	for soldier in soldier_brothers:
		if soldier.ally_state == AllyState.BATTLE and soldier.current_intercepting_enemy != null:
			var enemy = soldier.current_intercepting_enemy as Enemy
			current_intercepting_enemy = enemy
			enemy.current_intercepting_units.append(self)
			move_to_intercept(enemy.intercepting_marker.global_position)
			return
	super()
	pass


func rebirth():
	position = tower.position
	super()
	allocate_name()
	pass


func soldier_sell():
	if current_intercepting_enemy != null:
		current_intercepting_enemy.current_intercepting_units.erase(self)
	queue_free()
	pass


func soldier_level_up(new_soldier: Soldier):
	new_soldier.position = position
	new_soldier.station_position = station_position
	if current_intercepting_enemy == null:
		if ally_state == AllyState.DIE:
			new_soldier.rebirth()
		else:
			new_soldier.move_back()
	else:
		current_intercepting_enemy.current_intercepting_units.erase(self)
		current_intercepting_enemy.current_intercepting_units.append(new_soldier)
		new_soldier.current_intercepting_enemy = current_intercepting_enemy
		new_soldier.move_to_intercept(current_intercepting_enemy.intercepting_marker.global_position)
	
	queue_free()
	pass


func soldier_skill_level_up(skill_id: int, skill_level: int):
	soldier_skill_levels[skill_id] = skill_level
	pass


func _on_tech_heal_timer_timeout() -> void:
	var heal_data: int = int(float(start_data.health) * 0.02)
	if ally_state != AllyState.DIE:
		current_data.heal(heal_data)
	pass # Replace with function body.
