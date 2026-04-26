extends ShooterBullet

@export var hurt_buff_scene: PackedScene
@export var dizness_buff_scene: PackedScene


func enemy_take_damage(enemy: Enemy):
	super(enemy)
	var dizness_buff: DiznessBuff = dizness_buff_scene.instantiate()
	dizness_buff.duration = 1
	enemy.buffs.add_child(dizness_buff)
	var hurt_rate_buff: PropertyBuff = hurt_buff_scene.instantiate()
	enemy.buffs.add_child(hurt_rate_buff)
	pass
