extends AnimatedSprite2D

@export var linked_tower: DefenceTower
@export var bullet_damage_list: Array[DamageBlock]
@export var spit_scene: PackedScene

@onready var shoot_marker: Marker2D = $ShootMarker
@onready var shoot_marker_flip: Marker2D = $ShootMarkerFlip
@onready var normal_attack_timer: Timer = $NormalAttackTimer
@onready var shoot_audio: AudioStreamPlayer = $ShootAudio

var locked_enemy: Enemy


func _ready() -> void:
	frame_changed.connect(on_frame_changed)
	pass


func _physics_process(delta: float) -> void:
	if linked_tower.tower_skill_levels[1] > 0 and normal_attack_timer.is_stopped():
		if linked_tower.tower_area.has_overlapping_bodies():
			var enemy: Enemy = linked_tower.tower_area.get_overlapping_bodies().pick_random().owner as Enemy
			flip_h = enemy.position.x < global_position.x
			locked_enemy = enemy
			play("shoot")
			normal_attack_timer.start()
	pass


func on_frame_changed():
	if frame == 13 and locked_enemy != null:
		shoot_audio.play()
		flip_h = locked_enemy.global_position.x < global_position.x
		var summon_pos: Vector2 = shoot_marker_flip.global_position if flip_h else shoot_marker.global_position
		var damage_block: DamageBlock = bullet_damage_list[linked_tower.tower_skill_levels[2]-1]
		var damage: int = randi_range(damage_block.damage_low,damage_block.damage_high)
		var target_pos: Vector2 = locked_enemy.hurt_box.global_position
		target_pos += locked_enemy.direction * locked_enemy.current_data.unit_move_speed * 2
		summon_bullet(damage,summon_pos,target_pos)
	pass


func summon_bullet(damage: int, summon_pos: Vector2, target_pos: Vector2):
	var spit: Bullet = spit_scene.instantiate()
	spit.damage = damage
	spit.position = summon_pos
	spit.target_position = target_pos
	spit.special_skill_level = linked_tower.tower_skill_levels[1]
	Stage.instance.bullets.add_child(spit)
	pass
