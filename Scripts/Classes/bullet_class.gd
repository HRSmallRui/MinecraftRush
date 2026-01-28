extends Node2D
class_name Bullet

enum MoveType{
	Gravity,
	Straight,
	CurveMove,
	Trace,
	CurveLeft,
	CurveRight
}


@export var damage_type: DataProcess.DamageType
@export var damage: int
@export var move_type: MoveType
@export var broken_rate: float
@export var one_shot: bool = true
@export var bullet_speed: float
@export var explosion: bool = false
@export var source: Node2D
@export var damage_source: String = "Arrow"

@onready var hit_box: Area2D = $HitBox
@onready var free_timer: Timer = $FreeTimer
@onready var bullet_sprite: Sprite2D = $BulletSprite

var target_position: Vector2
var special_skill_level: int
var bullet_special_tag_levels: Dictionary
var bullet_special_tags_array: Array[String]
var erase_enemy_list: Array[Enemy]
var erase_ally_list: Array[Ally]


func _ready() -> void:
	free_timer.start()
	
	match move_type:
		MoveType.Gravity:
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
			
			await get_tree().create_timer(0.15 / bullet_speed,false).timeout
			hit_box.monitoring = true
			await get_tree().create_timer(0.35 / bullet_speed,false).timeout
			hit_box.monitoring = false
		
		MoveType.Straight:
			look_at(target_position)
			var time: float = (target_position - self.global_position).length() / bullet_speed
			create_tween().tween_property(self,"global_position",target_position,time)
			await get_tree().create_timer(time+0.1,false).timeout
			hit_box.monitoring = false
		
		MoveType.Trace:
			hit_box.monitoring = false
			var middle_position: Vector2 = (global_position + target_position) / 2
			var direction: Vector2 = (target_position - global_position).normalized()
			var move_time: float = (target_position - global_position).length() / bullet_speed
			free_timer.wait_time = move_time/4 + move_time * 1.25 + 0.1
			free_timer.start()
			var rotate_degree:float
			if direction.x > 0:
				rotate_degree = 180
			else:
				rotate_degree = -180
			
			var front_position: Vector2 = global_position
			global_position = middle_position
			bullet_sprite.global_position = front_position
			var rotate_front_tween: Tween = create_tween()
			rotate_front_tween.tween_property(self,"rotation_degrees",rotate_degree/4,move_time/4)
			await rotate_front_tween.finished
			var rotate_latter_tween: Tween = create_tween()
			rotate_latter_tween.tween_property(self,"rotation_degrees",rotate_degree,move_time * 1.25)
			await rotate_latter_tween.finished
			hit_box.monitoring = true
			
		MoveType.CurveLeft:
			hit_box.monitoring = false
			var middle_position: Vector2 = (global_position + target_position) / 2
			var direction: Vector2 = (target_position - global_position).normalized()
			var move_time: float = (target_position - global_position).length() / bullet_speed
			free_timer.wait_time = move_time/4 + move_time * 1.25 + 0.1
			free_timer.start()
			var rotate_degree:float = 180
			
			var front_position: Vector2 = global_position
			global_position = middle_position
			bullet_sprite.global_position = front_position
			var rotate_front_tween: Tween = create_tween()
			rotate_front_tween.tween_property(self,"rotation_degrees",rotate_degree/4,move_time/4)
			await rotate_front_tween.finished
			var rotate_latter_tween: Tween = create_tween()
			rotate_latter_tween.tween_property(self,"rotation_degrees",rotate_degree,move_time * 1.25)
			await get_tree().create_timer(move_time,false).timeout
			hit_box.monitoring = true
		
		MoveType.CurveRight:
			hit_box.monitoring = false
			var middle_position: Vector2 = (global_position + target_position) / 2
			var direction: Vector2 = (target_position - global_position).normalized()
			var move_time: float = (target_position - global_position).length() / bullet_speed
			free_timer.wait_time = move_time/4 + move_time * 1.25 + 0.1
			free_timer.start()
			var rotate_degree:float = -180
			
			var front_position: Vector2 = global_position
			global_position = middle_position
			bullet_sprite.global_position = front_position
			var rotate_front_tween: Tween = create_tween()
			rotate_front_tween.tween_property(self,"rotation_degrees",rotate_degree/4,move_time/4)
			await rotate_front_tween.finished
			var rotate_latter_tween: Tween = create_tween()
			rotate_latter_tween.tween_property(self,"rotation_degrees",rotate_degree,move_time * 1.25)
			await get_tree().create_timer(move_time,false).timeout
			hit_box.monitoring = true
	pass


func _physics_process(delta: float) -> void:
	if hit_box.monitoring:
		if hit_box.get_overlapping_areas().size() == 0: return
		else:
			var has_damaged: bool = false
			for hurt_box: HurtBox in hit_box.get_overlapping_areas():
				var unit = hurt_box.owner
				if unit is Ally: 
					if unit.ally_state == Ally.AllyState.DIE or unit in erase_ally_list: continue
					ally_take_damage(unit)
					has_damaged = true
				elif unit is Enemy: 
					if unit.enemy_state == Enemy.EnemyState.DIE or unit in erase_enemy_list: continue
					enemy_take_damage(unit)
					has_damaged = true
				after_attack_process(unit)
				if one_shot: break
			if has_damaged:	
				queue_free()
	
	if move_type == MoveType.Trace:
		hit_box.global_position = bullet_sprite.global_position
	if move_type == MoveType.CurveLeft or move_type == MoveType.CurveRight:
		hit_box.global_position = bullet_sprite.global_position
	pass


func after_attack_process(unit: Node2D):
	if unit == null: return
	if unit is Enemy:
		unit.hurt_audio_play(damage_source)
	pass


func _on_free_timer_timeout() -> void:
	queue_free()
	pass # Replace with function body.


func ally_take_damage(ally: Ally):
	ally.take_damage(damage,damage_type,broken_rate,true,source,explosion)
	pass


func enemy_take_damage(enemy: Enemy):
	#print(damage)
	
	if source != null:
		enemy.take_damage(damage,damage_type,broken_rate,true,source,explosion)
	else:
		enemy.take_damage(damage,damage_type,broken_rate,true,null,explosion)
	
	after_damage_special_tag_level_process()
	##箭塔流血科技
	if source == null: return
	var level: int = clampi(Stage.instance.stage_sav.upgrade_sav[0],0,Stage.instance.limit_tech_level)
	if source is ArcherTower and level >= 5:
		if randf_range(0,1) < 0.1:
			if enemy.enemy_state != Enemy.EnemyState.DIE:
				var blood_buff: DotBuff = preload("res://Scenes/Buffs/TowerBuffs/arrow_bleed.tscn").instantiate()
				blood_buff.dot_damage[0] = damage
				enemy.buffs.add_child(blood_buff)
				pass
	
	if source is Hero:
		source.get_exp(damage * source.exp_rate)
	
	pass


func after_damage_special_tag_level_process():
	if bullet_special_tag_levels.has("continue"):
		##穿梭时间，继续穿梭人数，伤害倍率,场景
		var bullet = bullet_special_tag_levels["continue"][3].instantiate() as Bullet
		bullet.position = position
		
		bullet.damage = damage * bullet_special_tag_levels["continue"][2]
		bullet.get_node("FreeTimer").wait_time = bullet_special_tag_levels["continue"][0]
		if bullet_special_tag_levels["continue"][1] > 1:
			bullet_special_tag_levels["continue"][1] -= 1
			bullet.bullet_special_tag_levels["continue"] = bullet_special_tag_levels["continue"]
		bullet.target_position = target_position
		var fly_length: float = bullet.bullet_speed * bullet_special_tag_levels["continue"][0]
		bullet.target_position += Vector2(cos(rotation),sin(rotation)) * fly_length
		for hurt_box in hit_box.get_overlapping_areas():
			var unit = hurt_box.owner
			if unit is Ally: bullet.erase_ally_list.append(unit)
			elif unit is Enemy: bullet.erase_enemy_list.append(unit)
		Stage.instance.bullets.add_child(bullet)
	pass
