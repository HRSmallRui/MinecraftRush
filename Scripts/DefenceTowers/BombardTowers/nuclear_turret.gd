extends BombardTower
class_name NuclearTurret

@onready var skill_2_condition_area: Area2D = $Skill2ConditionArea
@onready var skill_2_timer: Timer = $Skill2Timer


func fighting_process():
	if tower_skill_levels[1] > 0 and skill_2_timer.is_stopped():
		if skill_2_condition_area.get_overlapping_bodies().size() >= 2 and !bombard_tower_sprite.is_playing():
			bombard_tower_sprite.play("skill2")
			skill_2_timer.start()
			normal_attack_timer.start()
	if !bombard_tower_sprite.is_playing():
		super()
	pass
