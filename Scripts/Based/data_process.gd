extends Resource
class_name DataProcess

enum DamageType{
	PhysicsDamage, ##物理伤害
	MagicDamage, ##魔法伤害
	ExplodeDamage, ##火炮伤害
	TrueDamage, ##真实伤害
	SuperDamage ##超级伤害（不吃伤害减免）
}

static func range_to_string(range_data: int) -> String:
	if range_data < 320: return "近"
	elif range_data < 360: return "中"
	elif range_data < 400: return "远"
	elif range_data < 460: return "超远"
	else: return "极远"
	pass


static func attack_speed_to_string(attack_speed: float) -> String:
	if attack_speed > 2: return "非常慢"
	elif attack_speed >= 1.5: return "慢"
	elif attack_speed >= 0.8: return "中"
	elif attack_speed >= 0.5: return "快"
	else: return "非常快"
	pass


static func defence_to_string(defence: float) -> String:
	defence = snappedf(defence,0.01)
	if defence >= 1: return "免疫"
	elif defence > 0.9: return "极高"
	elif defence > 0.6: return "高"
	elif defence > 0.3: return "中"
	elif defence > 0 : return "低"
	else: return "无"
	pass


static func move_speed_to_string(move_speed: float) -> String:
	move_speed = snappedf(move_speed,0.01)
	if move_speed > 1.2: return "快"
	elif move_speed > 0.71: return "中"
	else: return "慢"
	pass


static func upgrade_damage(damage: int, rate: float) -> int:
	var medium_damage: float = float(damage)
	medium_damage *= 1+rate
	if medium_damage - int(medium_damage) > 0.001:
		return int(medium_damage) + 1
	else: return int(medium_damage)
	pass
