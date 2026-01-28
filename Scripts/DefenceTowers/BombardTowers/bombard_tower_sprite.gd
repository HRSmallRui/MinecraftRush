extends AnimatedSprite2D
class_name BombardTowerSprite

@export var summon_frame: int
@export var tower: BombardTower
@onready var summon_marker: Marker2D = $SummonMarker
@export var shell_scene: PackedScene


func _ready() -> void:
	frame_changed.connect(frame_condition)
	pass


func attack():
	play("attack")
	pass


func frame_condition():
	if animation == "attack" and frame == summon_frame:
		var enemy: Enemy
		if tower.target_list.size() > 0:
			enemy = get_lateset_enemy(tower.target_list)
		elif tower.last_target != null:
			enemy = tower.last_target
		else: return
		
		var target_pos: Vector2 = enemy.hurt_box.global_position + enemy.direction * enemy.current_data.unit_move_speed * 2
		var summon_pos: Vector2 = summon_marker.global_position
		summon_bullet(summon_pos,target_pos)
	pass


func summon_bullet(summon_pos: Vector2, target_pos: Vector2) -> Shell:
	var shell = shell_scene.instantiate() as Shell
	shell.damage = tower.current_data.damage_high
	var level: int = clampi(Stage.instance.stage_sav.upgrade_sav[3],0,Stage.instance.limit_tech_level)
	if level >= 4:
		shell.low_damage = tower.current_data.damage_high
	else: shell.low_damage = tower.current_data.damage_low
	shell.target_position = target_pos
	shell.position = summon_pos
	Stage.instance.bullets.add_child(shell)
	return shell
	pass


func get_lateset_enemy(enemy_list: Array[Enemy]) -> Enemy:
	var back_enemy:Enemy = enemy_list[0]
	var new_remaining_length: float
	var curve: Curve2D = back_enemy.get_parent().curve
	new_remaining_length = curve.get_baked_length() - back_enemy.progress
	for enemy in enemy_list:
		var remaining_length: float
		var current_curve: Curve2D = enemy.get_parent().curve
		remaining_length = current_curve.get_baked_length() - enemy.progress
		if remaining_length < new_remaining_length:
			new_remaining_length = remaining_length
			back_enemy = enemy
	return back_enemy
	pass
