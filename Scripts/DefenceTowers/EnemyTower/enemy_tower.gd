extends Node2D
class_name EnemyTower

enum TargetMode{
	CLOSEST,
	RANDOM
}

@export var tower_data: NormalTowerData
@export var target_mode: TargetMode
@export var tower_range: int
@export var tower_shooter: EnemyTowerShooter

@onready var tower_area: Area2D = $TowerArea
@onready var normal_attack_timer: Timer = $NormalAttackTimer
@onready var area_collision: CollisionShape2D = $TowerArea/AreaCollision

var target_position: Vector2


func _ready() -> void:
	area_collision.disabled = true
	tower_area.scale = Vector2.ONE * float(tower_range) / 100
	normal_attack_timer.wait_time = tower_data.attack_speed
	
	await Stage.instance.wave_summon
	area_collision.disabled = false
	pass


func destroy():
	tower_shooter.play("idle")
	area_collision.disabled = true
	pass


func _process(delta: float) -> void:
	if tower_area.has_overlapping_bodies():
		fighting_process()
	else:
		idle_process()
	pass


func idle_process():
	
	pass


func fighting_process():
	if normal_attack_timer.is_stopped():
		if tower_area.get_overlapping_bodies().is_empty(): return
		normal_attack_timer.start()
		
		var target_ally: Ally = tower_area.get_overlapping_bodies()[0].owner
		var ally_list: Array[Ally]
		for body in tower_area.get_overlapping_bodies():
			var ally: Ally = body.owner
			ally_list.append(ally)
		match target_mode:
			TargetMode.CLOSEST:
				for ally in ally_list:
					if ally.global_position.distance_to(position) > target_ally.global_position.distance_to(position):
						target_ally = ally
			TargetMode.RANDOM:
				target_ally = ally_list.pick_random() as Ally
		
		target_position = target_ally.hurt_box.global_position
		tower_shooter.shoot()
	pass
