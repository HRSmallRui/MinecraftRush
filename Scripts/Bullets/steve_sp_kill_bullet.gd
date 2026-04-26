extends ShooterBullet

@export var dizness_buff_scene: PackedScene
@export var dizness_duration: float

var is_killing: bool


func enemy_take_damage(enemy:Enemy):
	if enemy.enemy_type < Enemy.EnemyType.Super:
		enemy.sec_kill(true)
		is_killing = true
	super(enemy)
	var dizness_buff: DiznessBuff = dizness_buff_scene.instantiate()
	dizness_buff.duration = dizness_duration
	dizness_buff.buff_tag = "steve_sp_dizness"
	enemy.buffs.add_child(dizness_buff)
	pass


func after_attack_process(unit: Node2D):
	if unit is Enemy:
		var show_text: String
		show_text = "秒杀！" if is_killing else "重创！"
		TextEffect.text_effect_show(show_text,TextEffect.TextEffectType.SecKill,position + Vector2(0,-20))
	pass
