extends Resource
class_name UnitData

signal hurt(damage:int)
signal die(explosion: bool)

@export var health: int ##生命值，初始数据为最大生命值，当前数据为当前生命值
@export var dodge_rate: float = 0 ##闪避率

@export_group("攻击相关")
@export_subgroup("近战")
@export var near_damage_low: int ##近战攻击力下限
@export var near_damage_high: int ##近战攻击力上限
@export var near_attack_speed: float = 1 ##近战攻击速度
@export var near_hit_rate: float = 1 ##命中率
@export_subgroup("远程")
@export var far_damage_low: int ##远程攻击力下限
@export var far_damage_high: int ##远程攻击力上限
@export var far_attack_speed: float ##远程攻击速度
@export var far_damage_range: int ##远程攻击距离
@export_group("防御相关")
@export_range(0,1,0.05) var armor: float ##护甲
@export var physic_immune: bool ##是否物免
@export_range(0,1,0.05) var magic_defence: float ##魔法抗性
@export var magic_immune: bool ##魔法免疫
@export_range(0,1,0.05) var explode_defence: float ##炮伤抗性
@export var explode_immune: bool ##炮伤免疫
@export_range(0,1,0.05) var total_defence_rate: float ##总减伤率
var vulnerable_rate: float = 0 ##易伤
@export_group("其他")
@export var unit_move_speed: float ##移动速度

static var speed_unit: float = 50
var owner: Node2D
var start_data: UnitData

#[type,data] type:1 加法, 2 乘法
var near_damage_buffs: Array[PropertyBuffBlock]
var far_damage_buffs: Array[PropertyBuffBlock]
var near_damage_speed_buffs: Array[PropertyBuffBlock]
var far_damage_speed_buffs: Array[PropertyBuffBlock]
var far_damage_range_buffs: Array[PropertyBuffBlock]
var armor_buffs: Array[PropertyBuffBlock]
var magic_defence_buffs: Array[PropertyBuffBlock]
var explode_defence_buffs: Array[PropertyBuffBlock]
var total_defence_buffs: Array[PropertyBuffBlock]
var move_speed_buffs: Array[PropertyBuffBlock]
var hit_rate_buffs: Array[PropertyBuffBlock]
var vulnerable_rate_buffs: Array[PropertyBuffBlock]


func ready_data(data: UnitData):
	health = data.health
	near_damage_low = data.near_damage_low
	near_damage_high = data.near_damage_high
	near_attack_speed = data.near_attack_speed
	far_damage_low = data.far_damage_low
	far_damage_high = data.far_damage_high
	far_attack_speed = data.far_attack_speed
	far_damage_range = data.far_damage_range
	armor = data.armor
	physic_immune = data.physic_immune
	magic_defence = data.magic_defence
	magic_immune = data.magic_immune
	explode_defence = data.explode_defence
	explode_immune = data.explode_immune
	total_defence_rate = data.total_defence_rate
	unit_move_speed = data.unit_move_speed
	pass


##受伤方法
func take_damage(damage: int, damage_type: DataProcess.DamageType, broken_rate: float, far_attack: bool = false, source: Node2D = null,explosion: bool = false, deadly: bool = true):
	if health <= 0: return
	var total_damage: float = damage
	match damage_type:
		DataProcess.DamageType.PhysicsDamage:
			if physic_immune: return
			total_damage = damage * (1-armor * (1-broken_rate))
		DataProcess.DamageType.MagicDamage:
			if magic_immune: return
			total_damage = damage * (1-magic_defence * (1-broken_rate))
		DataProcess.DamageType.ExplodeDamage:
			if physic_immune or explode_immune: return
			total_damage = damage * (1-armor/2 * (1-broken_rate)) * (1-explode_defence * (1-broken_rate))
	if damage_type != DataProcess.DamageType.SuperDamage:
		total_damage = total_damage * (1+vulnerable_rate)
		total_damage = total_damage * (1-total_defence_rate)
	total_damage = snappedf(total_damage,0.1)
	if total_damage < 0: total_damage = 0
	health -= snappedi(total_damage,1)
	
	if !deadly and health <= 0:
		health = 1
	
	if health <= 0: 
		if owner is Ally:
			if owner.ally_type == Ally.AllyType.Soldiers: die.emit(explosion)
			else: die.emit(false)
		if owner is Enemy:
			if owner.enemy_type == Enemy.EnemyType.Small: die.emit(explosion)
			else: die.emit(false)
	else: hurt.emit(total_damage)
	pass


func heal(heal_data: int):
	var start_data: UnitData
	if owner is Ally: start_data = owner.start_data
	elif owner is Enemy: start_data = owner.start_data
	if health + heal_data > start_data.health:
		health = start_data.health
	else:
		health += heal_data
	pass


func update_data():
	update_move_speed()
	pass


func update_move_speed():
	unit_move_speed = start_data.unit_move_speed
	for move_buff_block in move_speed_buffs:
		if move_buff_block.operation_type == PropertyBuff.OperationType.Add:
			unit_move_speed += move_buff_block.operation_data
		elif move_buff_block.operation_type == PropertyBuff.OperationType.Multiply:
			unit_move_speed *= move_buff_block.operation_data
	pass


func update_armor():
	armor = start_data.armor
	for armor_buff_block in armor_buffs:
		if armor_buff_block.operation_type == PropertyBuff.OperationType.Add:
			armor += armor_buff_block.operation_data
		elif armor_buff_block.operation_type == PropertyBuff.OperationType.Multiply:
			armor *= armor_buff_block.operation_data
	if armor < 0: armor = 0
	pass


func update_near_damage():
	near_damage_low = start_data.near_damage_low
	near_damage_high = start_data.near_damage_high
	for damage_buff_block in near_damage_buffs:
		if damage_buff_block.operation_type == PropertyBuff.OperationType.Add:
			near_damage_low += damage_buff_block.operation_data
			near_damage_high += damage_buff_block.operation_data
		elif damage_buff_block.operation_type == PropertyBuff.OperationType.Multiply:
			near_damage_low = float(near_damage_low) * damage_buff_block.operation_data
			near_damage_high = float(near_damage_high) * damage_buff_block.operation_data
	pass


func update_far_damage():
	far_damage_low = start_data.far_damage_low
	far_damage_high = start_data.far_damage_high
	for far_damage_buff_block in far_damage_buffs:
		if far_damage_buff_block.operation_type == PropertyBuff.OperationType.Add:
			far_damage_low += far_damage_buff_block.operation_data
			far_damage_high += far_damage_buff_block.operation_data
		elif far_damage_buff_block.operation_type == PropertyBuff.OperationType.Multiply:
			far_damage_low = float(far_damage_low) * far_damage_buff_block.operation_data
			far_damage_high = float(far_damage_high) * far_damage_buff_block.operation_data
	pass


func update_magic_defence():
	magic_defence = start_data.magic_defence
	for magic_buff_block in magic_defence_buffs:
		if magic_buff_block.operation_type == PropertyBuff.OperationType.Add:
			magic_defence += magic_buff_block.operation_data
		elif magic_buff_block.operation_type == PropertyBuff.OperationType.Multiply:
			magic_defence *= magic_buff_block.operation_data
	
	if magic_defence < 0: magic_defence = 0
	pass


func update_total_defence_rate():
	total_defence_rate = start_data.total_defence_rate
	for magic_buff_block in total_defence_buffs:
		if magic_buff_block.operation_type == PropertyBuff.OperationType.Add:
			total_defence_rate += magic_buff_block.operation_data
		elif magic_buff_block.operation_type == PropertyBuff.OperationType.Multiply:
			total_defence_rate *= magic_buff_block.operation_data
	if total_defence_rate < 0: total_defence_rate = 0
	pass


func update_vulnerable_rate():
	vulnerable_rate = start_data.vulnerable_rate
	for vulnerable_block in vulnerable_rate_buffs:
		if vulnerable_block.operation_type == PropertyBuff.OperationType.Add:
			vulnerable_rate += vulnerable_block.operation_data
		elif vulnerable_block.operation_type == PropertyBuff.OperationType.Multiply:
			vulnerable_rate *= vulnerable_block.operation_data
	
	if vulnerable_rate < 0: vulnerable_rate = 0
	pass


func update_hit_rate():
	near_hit_rate = start_data.near_hit_rate
	for hit_block in hit_rate_buffs:
		if hit_block.operation_type == PropertyBuff.OperationType.Add:
			near_hit_rate += hit_block.operation_data
		elif hit_block.operation_type == PropertyBuff.OperationType.Multiply:
			near_hit_rate *= hit_block.operation_data
	pass


func update_far_attack_range():
	far_damage_range = start_data.far_damage_range
	for range_block in far_damage_range_buffs:
		if range_block.operation_type == PropertyBuff.OperationType.Add:
			far_damage_range += range_block.operation_data
		elif range_block.operation_type == PropertyBuff.OperationType.Multiply:
			far_damage_range = float(far_damage_range) * range_block.operation_data
	
	var far_attack_area: Area2D
	if owner is Ally:
		far_attack_area = owner.far_attack_area
		var shape: CollisionShape2D = far_attack_area.get_child(0)
		shape.disabled = far_damage_range == 0
	elif owner is Enemy:
		far_attack_area = owner.far_attack_area
		var shape: CollisionShape2D = far_attack_area.get_child(0)
		shape.disabled = far_damage_range == 0
	
	if far_attack_area == null: return
	far_attack_area.scale = Vector2.ONE * float(far_damage_range) / 100
	pass


func update_far_damage_speed():
	far_attack_speed = start_data.far_attack_speed
	for speed_block in far_damage_speed_buffs:
		if speed_block.operation_type == PropertyBuff.OperationType.Add:
			far_attack_speed += speed_block.operation_data
		elif speed_block.operation_type == PropertyBuff.OperationType.Multiply:
			far_attack_speed *= speed_block.operation_data
	
	if far_attack_speed == 0: return
	var damage_timer: Timer
	if owner is Ally:
		damage_timer = owner.far_attack_timer
	elif owner is Enemy:
		damage_timer = owner.far_attack_timer
	
	if damage_timer == null: return
	damage_timer.wait_time = far_attack_speed
	pass


func update_near_attack_speed():
	near_attack_speed = start_data.near_attack_speed
	for speed_block in  near_damage_speed_buffs:
		if speed_block.operation_type == PropertyBuff.OperationType.Add:
			near_attack_speed += speed_block.operation_data
		elif speed_block.operation_type == PropertyBuff.OperationType.Multiply:
			near_attack_speed *= speed_block.operation_data
	
	var damage_timer: Timer
	if owner is Ally:
		damage_timer = owner.normal_attack_timer
	elif owner is Enemy:
		damage_timer = owner.normal_attack_timer
	
	if damage_timer == null: return
	
	damage_timer.wait_time = near_attack_speed
	pass
