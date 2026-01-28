extends Bullet
class_name MagicBall

@export var magic_ball_tail_scene: PackedScene
@export var hit_effect_scene: PackedScene

var has_summon_hit_effect: bool = false


func _ready() -> void:
	free_timer.wait_time = (target_position - self.global_position).length() / bullet_speed
	super()
	while true:
		await get_tree().create_timer(0.015,false).timeout
		var tail: Node2D = magic_ball_tail_scene.instantiate()
		tail.global_position = global_position
		if move_type > MoveType.Trace: 
			tail.global_position = bullet_sprite.global_position
		add_child(tail)
	pass


func after_attack_process(unit: Node2D):
	hit_effect()
	super(unit)
	if unit == null: return
	if unit is Enemy:
		var show_text: String
		match randi_range(0,1):
			0: show_text = "呜！"
			1: show_text = "咻！"
		if unit.enemy_state == Enemy.EnemyState.DIE:
			TextEffect.text_effect_show(show_text,TextEffect.TextEffectType.Magic,position + Vector2(0,-10))
		elif randf_range(0,1) < 0.1:
			TextEffect.text_effect_show(show_text,TextEffect.TextEffectType.Magic,position + Vector2(0,-10))
	pass


func _on_free_timer_timeout():
	hit_effect()
	super()
	pass


func hit_effect():
	if has_summon_hit_effect: return
	has_summon_hit_effect = true
	if hit_effect_scene == null: return
	var hit_effect = hit_effect_scene.instantiate() as AnimatedSprite2D
	hit_effect.position = self.global_position + (target_position - global_position).normalized() * 15
	if move_type > MoveType.Trace:
		hit_effect.position = bullet_sprite.global_position + (target_position - global_position).normalized() * 15
	get_parent().add_child(hit_effect)
	pass


func enemy_take_damage(enemy: Enemy):
	super(enemy)
	if damage_type != DataProcess.DamageType.MagicDamage: return
	var level: int = clampi(Stage.instance.stage_sav.upgrade_sav[2],0,Stage.instance.limit_tech_level)
	if level >= 4:
		var speed_low_buff: PropertyBuff = preload("res://Scenes/Buffs/TowerBuffs/magic_speed_low_buff.tscn").instantiate()
		enemy.buffs.add_child(speed_low_buff)
	if level >= 3 and enemy.current_data.armor > 0.1:
		var armor_broken_buff: PropertyBuff = preload("res://Scenes/Buffs/TowerBuffs/magic_armor_broken_buff.tscn").instantiate()
		enemy.buffs.add_child(armor_broken_buff)
	pass
