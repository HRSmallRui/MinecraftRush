extends BuffClass
class_name PropertyBuff

enum PropertyType{
	Health,
	NearDamage,
	FarDamage,
	NearDamageSpeed,
	FarDamageSpeed,
	Armor,
	MagicDefence,
	ExplosionDefence,
	TotalDefenceRate,
	MoveSpeed,
	HitRate,
	VulnerableRate,
	FarDamageRange
}

enum OperationType{
	Add, ##加法
	Multiply ##乘法
}

@export var buff_blocks: Array[PropertyBuffBlock]


func buff_start():
	var unit: UnitData = unit.current_data
	for buff_block in buff_blocks:
		if buff_block.property_type == PropertyType.NearDamage:
			unit.near_damage_buffs.append(buff_block)
			unit.update_near_damage()
		elif buff_block.property_type == PropertyType.FarDamage:
			unit.far_damage_buffs.append(buff_block)
			unit.update_far_damage()
		elif buff_block.property_type == PropertyType.NearDamageSpeed:
			unit.near_damage_speed_buffs.append(buff_block)
			unit.update_near_attack_speed()
		elif buff_block.property_type == PropertyType.FarDamageSpeed:
			unit.far_damage_speed_buffs.append(buff_block)
			unit.update_far_damage_speed()
		elif buff_block.property_type == PropertyType.Armor:
			unit.armor_buffs.append(buff_block)
			unit.update_armor()
		elif buff_block.property_type == PropertyType.MagicDefence:
			unit.magic_defence_buffs.append(buff_block)
			unit.update_magic_defence()
		elif buff_block.property_type == PropertyType.ExplosionDefence:
			unit.explode_defence_buffs.append(buff_block)
		elif buff_block.property_type == PropertyType.TotalDefenceRate:
			unit.total_defence_buffs.append(buff_block)
			unit.update_total_defence_rate()
		elif buff_block.property_type == PropertyType.MoveSpeed:
			unit.move_speed_buffs.append(buff_block)
			unit.update_move_speed()
		elif buff_block.property_type == PropertyType.HitRate:
			unit.hit_rate_buffs.append(buff_block)
			unit.update_hit_rate()
		elif buff_block.property_type == PropertyType.VulnerableRate:
			unit.vulnerable_rate_buffs.append(buff_block)
			unit.update_vulnerable_rate()
		elif buff_block.operation_type == PropertyType.FarDamageRange:
			unit.far_damage_range_buffs.append(buff_block)
			unit.update_far_attack_range()
	pass


func remove_buff():
	remove_buff_block()
	super()
	pass


func remove_buff_block():
	var unit: UnitData = unit.current_data
	for buff_block in buff_blocks:
		if buff_block.property_type == PropertyType.NearDamage:
			unit.near_damage_buffs.erase(buff_block)
			unit.update_near_damage()
		elif buff_block.property_type == PropertyType.FarDamage:
			unit.far_damage_buffs.erase(buff_block)
			unit.update_far_damage()
		elif buff_block.property_type == PropertyType.NearDamageSpeed:
			unit.near_damage_speed_buffs.erase(buff_block)
			unit.update_near_attack_speed()
		elif buff_block.property_type == PropertyType.FarDamageSpeed:
			unit.far_damage_speed_buffs.erase(buff_block)
			unit.update_far_damage_speed()
		elif buff_block.property_type == PropertyType.Armor:
			unit.armor_buffs.erase(buff_block)
			unit.update_armor()
		elif buff_block.property_type == PropertyType.MagicDefence:
			unit.magic_defence_buffs.erase(buff_block)
			unit.update_magic_defence()
		elif buff_block.property_type == PropertyType.ExplosionDefence:
			unit.explode_defence_buffs.erase(buff_block)
		elif buff_block.property_type == PropertyType.TotalDefenceRate:
			unit.total_defence_buffs.erase(buff_block)
			unit.update_total_defence_rate()
		elif buff_block.property_type == PropertyType.MoveSpeed:
			unit.move_speed_buffs.erase(buff_block)
			unit.update_move_speed()
		elif buff_block.operation_type == PropertyType.HitRate:
			unit.hit_rate_buffs.erase(buff_block)
			unit.update_hit_rate()
		elif buff_block.property_type == PropertyType.VulnerableRate:
			unit.vulnerable_rate_buffs.erase(buff_block)
			unit.update_vulnerable_rate()
		elif buff_block.operation_type == PropertyType.FarDamageRange:
			unit.far_damage_range_buffs.erase(buff_block)
			unit.update_far_attack_range()
	pass
