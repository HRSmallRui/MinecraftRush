extends ArcherTower

@export var shell_scene: PackedScene

@onready var skill_2_timer: Timer = $Skill2Timer
@onready var skill_2_area: Area2D = $Skill2Area
@onready var shell_marker: Marker2D = $TowerSprite/ShellMarker

var skill_2_damage_high_list: Array[int] = [200,300,400]
var skill_2_damage_low_list: Array[int] = [100,150,200]


func fighting_process():
	if skill_2_area.has_overlapping_bodies() and normal_attack_timer.is_stopped() and skill_2_timer.is_stopped() and tower_skill_levels[1] > 0:
		var enemy: Enemy = skill_2_area.get_overlapping_bodies()[0].owner
		var enemy_path: EnemyPath = enemy.get_parent()
		var target_curve: Curve2D = enemy_path.curve
		const delta_progress: float = 60
		var position_list: Array[Vector2]
		position_list.append(target_curve.sample_baked(enemy.progress))
		position_list.append(target_curve.sample_baked(enemy.progress + delta_progress))
		position_list.append(target_curve.sample_baked(enemy.progress + 2 * delta_progress))
		position_list.append(target_curve.sample_baked(enemy.progress - delta_progress))
		position_list.append(target_curve.sample_baked(enemy.progress - 2 * delta_progress))
		
		for pos in position_list:
			var shell: Shell = shell_scene.instantiate()
			shell.damage = skill_2_damage_high_list[tower_skill_levels[1]-1]
			shell.low_damage = skill_2_damage_low_list[tower_skill_levels[1]-1]
			shell.position = shell_marker.global_position
			shell.target_position = pos
			Stage.instance.bullets.add_child(shell)
		AudioManager.instance.shoot_audio_1.play()
		skill_2_timer.start()
		return
	super()
	pass
