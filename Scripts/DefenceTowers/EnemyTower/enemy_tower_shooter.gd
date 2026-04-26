extends AnimatedSprite2D
class_name EnemyTowerShooter

@export var linked_tower: EnemyTower
@export var bullet_scene: PackedScene
@export var summon_frame: int
@export_group("Markers")
@export var summon_marker_front: Marker2D
@export var summon_marker_front_flip: Marker2D
@export var summon_marker_back: Marker2D
@export var summon_marker_back_flip: Marker2D


func _ready() -> void:
	frame_changed.connect(on_frame_changed)
	pass


func anim_offset():
	
	pass


func _process(delta: float) -> void:
	anim_offset()
	pass


func shoot():
	flip_h = linked_tower.target_position.x < linked_tower.position.x
	var play_anim: String = "shoot_front" if linked_tower.target_position.y > linked_tower.global_position.y else "shoot_back"
	play(play_anim)
	pass


func on_frame_changed():
	if (animation == "shoot_front" or animation == "shoot_back") and frame == summon_frame:
		var summon_pos: Vector2
		summon_pos = (summon_marker_front_flip.global_position if flip_h else summon_marker_front.global_position)\
		if animation == "shoot_front" else\
		(summon_marker_back_flip.global_position if flip_h else summon_marker_back.global_position)
		
		summon_bullet(summon_pos,linked_tower.target_position)
	pass


func summon_bullet(summon_pos: Vector2, target_pos: Vector2):
	var bullet: Bullet = bullet_scene.instantiate()
	bullet.global_position = summon_pos
	bullet.target_position = target_pos
	bullet.damage = randi_range(linked_tower.tower_data.damage_low,linked_tower.tower_data.damage_high)
	Stage.instance.bullets.add_child(bullet)
	pass
