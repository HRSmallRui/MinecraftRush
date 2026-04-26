extends DefenceTower
class_name BombardTower

@export var start_data: NormalTowerData
@export var bombard_tower_sprite: BombardTowerSprite

@onready var normal_attack_timer: Timer = $NormalAttackTimer

var current_data: NormalTowerData
var target_list: Array[Enemy]
var last_target: Enemy


func _enter_tree() -> void:
	if Stage.instance.ui_update.is_connected(Callable(self,"ui_process")): return
	start_data = start_data.duplicate()
	var tech_level:int = clampi(Stage.instance.stage_sav.upgrade_sav[3],0,Stage.instance.limit_tech_level)
	if tech_level >= 1: start_tower_range *= 1.1
	if tech_level >= 2:
		start_data.damage_low = DataProcess.upgrade_damage(start_data.damage_low,0.1)
		start_data.damage_high = DataProcess.upgrade_damage(start_data.damage_high,0.1)
	super()
	current_data = start_data.duplicate(true)
	
	pass


func _ready() -> void:
	super()
	tower_area.body_entered.connect(enemy_body_in)
	tower_area.body_exited.connect(enemy_body_out)
	pass


func _process(delta: float) -> void:
	super(delta)
	normal_attack_timer.wait_time = current_data.attack_speed
	if tower_area.get_overlapping_bodies().size() > 0: fighting_process()
	else: idle_process()
	pass


func idle_process():
	
	pass


func fighting_process():
	if normal_attack_timer.is_stopped():
		normal_attack_timer.start()
		bombard_tower_sprite.attack()
	pass


func enemy_body_in(body: UnitBody):
	target_list.append(body.unit as Enemy)
	if last_target == null:
		last_target = body.unit as Enemy
	elif !last_target in target_list:
		last_target = target_list[0]
	pass


func enemy_body_out(body: UnitBody):
	target_list.erase(body.unit as Enemy)
	if target_list.size() > 0:
		last_target = target_list[0]
	pass


func update_tower_data():
	super()
	update_tower_damage()
	update_tower_attack_speed()
	pass


func update_tower_damage():
	current_data.damage_low = start_data.damage_low
	current_data.damage_high = start_data.damage_high
	for property_block in tower_damage_buffs:
		if property_block.operation_type == TowerBuff.OperationType.Add:
			current_data.damage_low += property_block.operation_data
			current_data.damage_high += property_block.operation_data
		elif property_block.operation_type == TowerBuff.OperationType.Multiply:
			current_data.damage_low = float(current_data.damage_low) * property_block.operation_data
			current_data.damage_high = float(current_data.damage_high) * property_block.operation_data
	pass


func update_tower_attack_speed():
	current_data.attack_speed = current_data.attack_speed
	for property_block in tower_attack_speed_buffs:
		if property_block.operation_type == TowerBuff.OperationType.Add:
			current_data.attack_speed += property_block.operation_data
		elif property_block.operation_type == TowerBuff.OperationType.Multiply:
			current_data.attack_speed *= property_block.operation_data
	pass
