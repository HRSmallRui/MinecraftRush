extends Bullet
class_name Shell

@onready var tail: Line2D = $Tail
@onready var tail_timer: Timer = $Tail/TailTimer

@export var low_damage: int

var explosion_radius: float


func _ready() -> void:
	tail_timer.timeout.connect(on_tail_timer_timeout)
	
	free_timer.wait_time = 0.45 / bullet_speed
	free_timer.start()
	explosion_radius = $HitBox/CollisionShape2D.shape.radius
	hit_box.monitoring = false
	var tweenx = create_tween()
	var tweeny = create_tween()
	var tween_rot = create_tween()
	
	var highest_y = self.global_position.y - 50 if self.global_position.y < target_position.y else target_position.y - 50
	var watch_pos = Vector2.ZERO
	watch_pos.y = highest_y
	watch_pos.x = (global_position.x + target_position.x) / 2
	look_at(watch_pos)
	
	tweenx.set_trans(Tween.TRANS_LINEAR)
	tweenx.set_ease(Tween.EASE_IN_OUT)
	
	tweeny.set_trans(Tween.TRANS_QUAD)
	tweeny.set_ease(Tween.EASE_OUT)
	
	tweenx.tween_property(self,"position:x",target_position.x,0.4 / bullet_speed)
	
	tweeny.tween_property(self,"position:y",highest_y,0.15 / bullet_speed)
	tweeny.set_ease(Tween.EASE_IN)
	tweeny.tween_property(self,"position:y",target_position.y,0.25 / bullet_speed)
	
	
	tween_rot.set_ease(Tween.EASE_OUT_IN)
	if target_position.x < self.global_position.x:
		tween_rot.tween_property(self,"rotation_degrees",-270,0.35 / bullet_speed)
		
	else:
		tween_rot.tween_property(self,"rotation_degrees",80,0.35 / bullet_speed)
	
	await get_tree().create_timer(0.4 / bullet_speed,false).timeout
	hit_box.monitoring = true
	pass


func after_attack_process(unit: Node2D):
	AudioManager.instance.play_explosion_audio()
	var explosion_effect = preload("res://Scenes/Effects/bullet_explosion_effect.tscn").instantiate() as AnimatedSprite2D
	explosion_effect.position = position
	get_parent().add_child(explosion_effect)
	var smoke_effect = preload("res://Scenes/Effects/smoke_effect.tscn").instantiate() as AnimatedSprite2D
	smoke_effect.position = position
	get_parent().add_child(smoke_effect)
	
	var show_text: String
	match randi_range(0,1):
		0: show_text = "轰！"
		1: show_text = "砰！"
	TextEffect.text_effect_show(show_text,TextEffect.TextEffectType.Bombard,position + Vector2(0,-40))
	pass


func _physics_process(delta: float) -> void:
	hit_box.global_rotation = 0
	if hit_box.monitoring:
		if hit_box.get_overlapping_areas().size() == 0: return
		else:
			for hurt_box: HurtBox in hit_box.get_overlapping_areas():
				var length: float = (hurt_box.global_position - global_position).length()
				if length > explosion_radius: continue
				
				var level: int = clampi(Stage.instance.stage_sav.upgrade_sav[3],0,Stage.instance.limit_tech_level)
				var new_damage = low_damage + int((damage - low_damage) * (0.1 + (explosion_radius - length)/ explosion_radius))
				new_damage = clampi(new_damage,0,damage)
				var unit = hurt_box.owner as Node2D
				if unit is Ally: 
					if unit.ally_state == Ally.AllyState.DIE: continue
					shell_ally_take_damage(unit,new_damage)
				elif unit is Enemy: 
					if unit.enemy_state == Enemy.EnemyState.DIE: continue
					shell_enemy_take_damage(unit,new_damage)
					if level >= 5 and randf_range(0,1) < 0.15:
						var dizness_buff: PropertyBuff = preload("res://Scenes/Buffs/TowerBuffs/bombard_dizness_buff.tscn").instantiate()
						unit.buffs.add_child(dizness_buff)
				if one_shot: break
			after_attack_process(null)
			queue_free()
	pass


func _on_free_timer_timeout() -> void:
	queue_free()
	after_attack_process(null)
	pass


func on_tail_timer_timeout():
	tail.add_point(global_position)
	if tail.points.size() > 20: tail.remove_point(0)
	pass


func shell_ally_take_damage(ally: Ally, shell_damage: int):
	ally.take_damage(shell_damage,damage_type,broken_rate,true,source,explosion)
	pass


func shell_enemy_take_damage(enemy: Enemy, shell_damage: int):
	enemy.take_damage(shell_damage,damage_type,broken_rate,true,source,explosion)
	pass
