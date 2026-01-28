extends Node2D

@export var mike: Hero
@export var far_attack_area: Area2D
@export var magic_ball_scene: PackedScene

@onready var book_sprite: AnimatedSprite2D = $BookSprite
@onready var attack_timer: Timer = $AttackTimer

var is_attacking: bool


func _process(delta: float) -> void:
	attack_process()
	if !is_attacking: book_sprite.flip_h = !mike.ally_sprite.flip_h
	book_sprite.speed_scale = 2 if is_attacking else 1
	var target_pos_x: float = -95 if mike.ally_sprite.flip_h else 95
	position.x = lerpf(position.x,target_pos_x,delta * 10)
	visible = !mike.ally_state == Ally.AllyState.DIE
	pass


func attack_process():
	if mike.ally_state == Ally.AllyState.DIE: return
	if attack_timer.is_stopped() and far_attack_area.has_overlapping_bodies():
		var body = far_attack_area.get_overlapping_bodies()[-1]
		var enemy: Enemy = body.owner
		var target_pos: Vector2 = enemy.hurt_box.global_position
		target_pos += enemy.direction * enemy.current_data.unit_move_speed * 1.5
		var damage: int = randi_range(mike.current_data.far_damage_low,mike.current_data.far_damage_high)
		var bullet: Bullet = mike.summon_bullet(magic_ball_scene,book_sprite.global_position,target_pos,damage,DataProcess.DamageType.SuperDamage)
		Stage.instance.bullets.add_child(bullet)
		AudioManager.instance.magic_shot_audio.play()
		attack_timer.start()
		is_attacking = true
		book_sprite.flip_h = enemy.position.x < global_position.x
		await get_tree().create_timer(0.4,false).timeout
		is_attacking = false
	pass
