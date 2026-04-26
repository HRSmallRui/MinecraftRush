extends VisibleOnScreenNotifier2D

@export var enemy: Enemy
@export var danger_tip_scene: PackedScene


func _ready() -> void:
	if enemy.enemy_type == Enemy.EnemyType.Boss:
		queue_free()
	pass


func _process(delta: float) -> void:
	if enemy.enemy_state != Enemy.EnemyState.DIE:
		if is_on_screen() and enemy.danger_tip != null:
			enemy.danger_tip.queue_free()
			enemy.danger_tip = null
		if !is_on_screen() and enemy.danger_tip == null and enemy.progress_ratio > 0.6:
			var new_danger_tip: DangerTip = danger_tip_scene.instantiate()
			enemy.danger_tip = new_danger_tip
			enemy.danger_tip.linked_enemy = enemy
			Stage.instance.danger_tip_layer.add_child(enemy.danger_tip)
	pass
