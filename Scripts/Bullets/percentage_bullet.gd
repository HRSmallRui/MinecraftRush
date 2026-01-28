extends ShooterBullet
class_name PercentageDamageBullet

@export var normal_damaged: bool = true
@export var percentage_damage_type: DataProcess.DamageType
@export var percentage_damage_broken_rate: float
@export_range(0,1,0.01) var percentage_rate: float
@export var can_hurt_enemy_level: Enemy.EnemyType = Enemy.EnemyType.Big
@export var can_hurt_ally_level: Ally.AllyType = Ally.AllyType.SuperSoldiers


func enemy_take_damage(enemy: Enemy):
	if normal_damaged:
		super(enemy)
	if enemy.enemy_type > can_hurt_enemy_level:
		return
	if enemy.enemy_state != Enemy.EnemyState.DIE:
		var damage: int = float(enemy.start_data.health) * percentage_rate
		enemy.take_damage(damage,percentage_damage_type,percentage_damage_broken_rate,true,null,false,!one_shot,)
	pass


func ally_take_damage(ally: Ally):
	if normal_damaged:
		super(ally)
	if ally.ally_type > can_hurt_ally_level:
		return
	if ally.ally_state != Ally.AllyState.DIE:
		var damage: int = float(ally.start_data.health) * percentage_rate
		ally.take_damage(damage,percentage_damage_type,percentage_damage_broken_rate,true,null,false,!one_shot,)
	pass
