extends ShooterBullet

@export var dizness_buff_scene: PackedScene
@export var dizness_duration: float


func enemy_take_damage(enemy: Enemy):
	super(enemy)
	var dizness_buff: DiznessBuff = dizness_buff_scene.instantiate()
	dizness_buff.duration = dizness_duration
	dizness_buff.buff_tag = "steve_passive_dizness"
	enemy.buffs.add_child(dizness_buff)
	pass


func after_attack_process(unit: Node2D):
	if unit is Enemy:
		var show_text: String
		match randi_range(0,1):
			0: show_text = "嗖！"
			1: show_text = "啪！"
		if unit.enemy_state == Enemy.EnemyState.DIE:
			TextEffect.text_effect_show(show_text,TextEffect.TextEffectType.SecKill,position + Vector2(0,-10))
		elif randf_range(0,1) < 0.1:
			TextEffect.text_effect_show(show_text,TextEffect.TextEffectType.SecKill,position + Vector2(0,-10))
	pass
