extends Bullet
class_name ShooterBullet

@export var tail_max_length: int = 20
@onready var tail: Line2D = $Tail

func after_attack_process(unit: Node2D):
	super(unit)
	if unit == null: return
	if unit is Enemy:
		var show_text: String
		match randi_range(0,1):
			0: show_text = "嗖！"
			1: show_text = "啪！"
		if unit.enemy_state == Enemy.EnemyState.DIE:
			TextEffect.text_effect_show(show_text,TextEffect.TextEffectType.Arrow,position + Vector2(0,-10))
		elif randf_range(0,1) < 0.1:
			TextEffect.text_effect_show(show_text,TextEffect.TextEffectType.Arrow,position + Vector2(0,-10))
	pass


func _physics_process(delta: float) -> void:
	tail.add_point(global_position)
	if tail.points.size() > tail_max_length: tail.remove_point(0)
	super(delta)
	pass


func enemy_take_damage(enemy: Enemy):
	super(enemy)
	pass
