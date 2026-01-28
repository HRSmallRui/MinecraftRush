extends Node2D
class_name Ally

enum AllyState{
	IDLE,
	MOVE,
	BATTLE,
	SPECIAL,
	DIE
}

enum AllyGroup{
	Warrior,
	Shooters,
	Magicians
}

enum AllyType{
	Soldiers,
	SuperSoldiers,
	Heroes
}

@export var ally_id: int
@export var ally_name: String
@export var ally_level: int = 1
@export var ally_texture: Texture
@export var ally_type: AllyType
@export var ally_group: AllyGroup
@export var is_fly: bool = false
@export var start_data: UnitData
@export var far_attack_bullet_scene: PackedScene
@export var intercepting_range: int = 100
@export var heal_speed: int
@export var rebirth_time: int

@onready var select_sprite: Sprite2D = $UnitBody/SelectSprite
@onready var ally_button: Button = $UnitBody/AllyButton
@onready var heal_timer: Timer = $HealTimer
@onready var rebirth_timer: Timer = $RebirthTimer
@onready var ally_sprite: AnimatedSprite2D = $UnitBody/AllySprite
@onready var health_bar: TextureProgressBar = $UnitBody/HealthBar
@onready var normal_attack_timer: Timer = $NormalAttackTimer
@onready var intercepting_area: Area2D = $UnitBody/InterceptingArea
@onready var buffs: Node2D = $UnitBody/Buffs
@onready var hurt_box: HurtBox = $UnitBody/HurtBox
@onready var direction_change_timer: Timer = $DirectionChangeTimer
@onready var unit_body: UnitBody = $UnitBody
@onready var far_attack_area: Area2D = $UnitBody/FarAttackArea
@onready var far_attack_marker: Marker2D = $UnitBody/FarAttackMarker
@onready var far_attack_marker_flip: Marker2D = $UnitBody/FarAttackMarkerFlip
@onready var far_attack_timer: Timer = $FarAttackTimer

var ally_state:AllyState = AllyState.IDLE
var move_tween: Tween
var current_data: UnitData
var station_position: Vector2
var current_intercepting_enemy: Enemy
var enemy_list: Array[Enemy]
var waiting_to_move: bool = false
var next_move_position: Vector2
var far_attack_target_enemy: Enemy
var ally_buff_tags: Dictionary


func _enter_tree() -> void:
	if Stage.instance.ui_update.is_connected(Callable(self,"ui_process")): return
	Stage.instance.ui_update.connect(ui_process)
	current_data = start_data.duplicate(true)
	current_data.owner = self
	current_data.start_data = start_data
	pass


func _ready() -> void:
	ally_sprite.position = Vector2.ZERO
	select_sprite.hide()
	ally_button.modulate.a = 0
	update_health_bar()
	intercepting_area.position = position
	
	rebirth_timer.timeout.connect(rebirth)
	ally_sprite.frame_changed.connect(frame_changed)
	ally_sprite.animation_finished.connect(anim_finished)
	ally_sprite.animation_changed.connect(anim_changed)
	
	current_data.die.connect(die)
	direction_change_timer.timeout.connect(face_change_direction)
	
	intercepting_area.scale = Vector2.ONE * float(intercepting_range) / 100
	
	normal_attack_timer.wait_time = current_data.near_attack_speed
	if rebirth_time > 0:
		rebirth_timer.wait_time = rebirth_time
	if current_data.far_damage_range > 0:
		far_attack_area.scale = Vector2.ONE * float(current_data.far_damage_range)/100
	else:
		var shape:CollisionShape2D = far_attack_area.get_child(0)
		shape.disabled = true
		far_attack_area.scale = Vector2.ZERO
	if current_data.far_attack_speed > 0:
		far_attack_timer.wait_time = current_data.far_attack_speed
	pass


func ui_process(member: Node):
	select_sprite.visible = member == self
	if Stage.instance.stage_ui == Stage.StageUI.None or Stage.instance.stage_ui == Stage.StageUI.Check:
		ally_button.mouse_filter = Control.MOUSE_FILTER_STOP
	else:
		ally_button.mouse_filter = Control.MOUSE_FILTER_IGNORE
	pass


func _on_ally_button_pressed() -> void:
	Stage.instance.ui_process(self,Stage.StageUI.Check)
	MobileMiddleProcess.instance.current_touch_object = self
	pass # Replace with function body.


func _process(delta: float) -> void:
	#current_data.update_data()
	anim_offset()
	update_health_bar()
	match ally_state:
		AllyState.IDLE:
			idle_process()
		AllyState.MOVE:
			move_process()
		AllyState.BATTLE:
			battle_process()
		AllyState.SPECIAL:
			special_process()
	
	anim_offset()
	pass


func update_health_bar():
	health_bar.value = float(current_data.health) / float(start_data.health)
	health_bar.visible = current_data.health < start_data.health and ally_state != AllyState.DIE
	pass


func anim_offset():
	
	pass


func idle_process():
	if waiting_to_move:
		waiting_to_move = false
		move(next_move_position)
		#print("move")
		return
	
	if current_intercepting_enemy == null and intercepting_area.monitoring:
		if intercepting_area.has_overlapping_bodies():
			var enemy_list: Array[Enemy]
			for body in intercepting_area.get_overlapping_bodies():
				var enemy = body.owner as Enemy
				if !enemy.interceptable: continue
				enemy_list.append(enemy)
			if enemy_list.size() > 0:
				var enemy: Enemy = get_closest_enemy(enemy_list)
				if enemy != null:
					current_intercepting_enemy = enemy
					enemy.current_intercepting_units.append(self)
					move_to_intercept(enemy.intercepting_marker.global_position)
					enemy.update_state()
	
	if ally_state == AllyState.IDLE and far_attack_timer.is_stopped() and far_attack_area.has_overlapping_bodies() and far_attack_area.monitoring:
		var enemy: Enemy = far_attack_area.get_overlapping_bodies()[0].owner
		far_attack_target_enemy = enemy
		translate_to_new_state(AllyState.SPECIAL)
		ally_sprite.flip_h = enemy.position.x < position.x
		ally_sprite.play("far_attack")
		far_attack_timer.start()
	pass


func move_process():
	ally_sprite.play("move")
	pass


func battle_process():
	if waiting_to_move:
		waiting_to_move = false
		move(next_move_position)
	
	if ally_sprite.animation == "idle":
		if current_intercepting_enemy != null:
			if current_intercepting_enemy.enemy_state == Enemy.EnemyState.DIE:
				current_intercepting_enemy.current_intercepting_units.erase(self)
				current_intercepting_enemy = null
				return
			if current_intercepting_enemy.current_intercepting_units.size() > 0:
				if current_intercepting_enemy.current_intercepting_units[0] == self and (global_position - current_intercepting_enemy.intercepting_marker.global_position).length() > 1:
					move_to_intercept(current_intercepting_enemy.intercepting_marker.global_position)
					return
	
	if ally_sprite.animation == "idle" and current_intercepting_enemy == null:
		move_back()
		return
	
	if current_intercepting_enemy != null:
		if current_intercepting_enemy.current_intercepting_units.size() > 0 and current_intercepting_enemy.current_intercepting_units[0] != self:
			if intercepting_area.get_overlapping_bodies().size() > 0:
				for body: UnitBody in intercepting_area.get_overlapping_bodies():
					if body.owner == current_intercepting_enemy: continue
					
					#if self is Soldier:
						#var soldier_self = self as Soldier
						#if !body in soldier_self.tower.tower_area.get_overlapping_bodies():
							#continue
					var enemy = body.owner as Enemy
					if enemy.interceptable and enemy.enemy_state == Enemy.EnemyState.MOVE:
						current_intercepting_enemy.current_intercepting_units.erase(self)
						current_intercepting_enemy = enemy
						enemy.current_intercepting_units.append(self)
						move_to_intercept(enemy.intercepting_marker.global_position)
						enemy.update_state()
						return
	battle()
	pass


func battle():
	if ally_sprite.animation == "idle":
		if normal_attack_timer.is_stopped():
			ally_sprite.play("attack")
			normal_attack_timer.start()
			return
	pass


func special_process():
	
	pass


func translate_to_new_state(new_state: AllyState):
	match new_state:
		AllyState.IDLE:
			ally_sprite.play("idle")
			intercepting_area.monitoring = true
			change_collision_layer(false)
		AllyState.MOVE:
			intercepting_area.monitoring = false
			change_collision_layer(true)
			intercepting_area.position = station_position
		AllyState.BATTLE:
			ally_sprite.play("idle")
			intercepting_area.monitoring = true
			change_collision_layer(false)
		AllyState.SPECIAL:
			intercepting_area.monitoring = false
			change_collision_layer(false)
		AllyState.DIE:
			waiting_to_move = false
			intercepting_area.monitoring = false
			change_collision_layer(true)
			unit_body.set_collision_layer_value(8,true)
			hurt_box.set_collision_layer_value(8,true)
			enemy_list.clear()
			
			if Stage.instance.information_bar.current_check_member == self: Stage.instance.ui_process(null)
			if current_intercepting_enemy != null:
				current_intercepting_enemy.current_intercepting_units.erase(self)
			current_intercepting_enemy = null
	
	ally_state = new_state
	pass


func frame_changed():
	
	pass


func anim_changed():
	anim_offset()
	pass


func cause_damage(damage_type: int = 0):
	if current_intercepting_enemy == null: return
	match damage_type:
		0:
			var target_enemy: Enemy = current_intercepting_enemy
			var damage: int = randi_range(current_data.near_damage_low,current_data.near_damage_high)
			if randf_range(0,1) < 0.1:
				attack_text_effect()
			AudioManager.instance.battle_audio_play()
			if target_enemy.take_damage(damage,DataProcess.DamageType.PhysicsDamage,0,false,self):
				if target_enemy.enemy_state != Enemy.EnemyState.DIE:
					on_normal_attack_hit(target_enemy)
	pass


func on_normal_attack_hit(target_enemy: Enemy):
	
	pass


func anim_finished():
	if ally_state == AllyState.BATTLE or ally_state == AllyState.SPECIAL or ally_state == AllyState.IDLE:
		await get_tree().process_frame
		ally_sprite.play("idle")
	if ally_state == AllyState.SPECIAL:
		if current_intercepting_enemy != null: 
			move_to_intercept(current_intercepting_enemy.intercepting_marker.global_position)
		elif (position - station_position).length() > 1:
			move_back()
		else:
			translate_to_new_state(AllyState.IDLE)
	
	anim_offset()
	pass


func _on_heal_timer_timeout() -> void:
	if ally_state != AllyState.IDLE: return
	current_data.heal(heal_speed)
	pass # Replace with function body.


func rebirth():
	show()
	waiting_to_move = false
	ally_button.show()
	unit_body.set_collision_layer_value(8,false)
	hurt_box.set_collision_layer_value(8,false)
	translate_to_new_state(AllyState.IDLE)
	current_data.health = start_data.health
	move_back()
	pass


func move(target_pos:Vector2):
	station_position = target_pos
	if ally_state == AllyState.DIE: return
	if ally_state == AllyState.SPECIAL:
		waiting_to_move = true
		next_move_position = target_pos
		return
	
	enemy_list.clear()
	if current_intercepting_enemy != null: current_intercepting_enemy.current_intercepting_units.erase(self)
	current_intercepting_enemy = null
	translate_to_new_state(AllyState.MOVE)
	move_animation(target_pos)
	await move_tween.finished
	translate_to_new_state(AllyState.IDLE)
	pass


func move_animation(target_pos: Vector2):
	ally_sprite.play("move")
	ally_sprite.flip_h = target_pos.x < global_position.x
	if move_tween != null: move_tween.kill()
	move_tween = create_tween()
	var time = (target_pos - global_position).length() / (current_data.unit_move_speed * UnitData.speed_unit)
	move_tween.tween_property(self,"global_position",target_pos,time)
	pass


func move_to_intercept(target_pos: Vector2):
	translate_to_new_state(AllyState.MOVE)
	if current_intercepting_enemy != null:
		var enemy: Enemy = current_intercepting_enemy
		if enemy.current_intercepting_units.size() > 0:
			if enemy.current_intercepting_units[0] != self:
				var array_size = enemy.current_intercepting_units.size()
				if array_size % 2 == 1: target_pos.y += 5
				else: target_pos.y -= 5
				target_pos.x += 6 if enemy.enemy_sprite.flip_h else -6
	move_animation(target_pos)
	await move_tween.finished
	if current_intercepting_enemy != null:
		ally_sprite.flip_h = current_intercepting_enemy.global_position.x < global_position.x
	translate_to_new_state(AllyState.BATTLE)
	pass


func move_back():
	translate_to_new_state(AllyState.MOVE)
	move_animation(station_position)
	await move_tween.finished
	translate_to_new_state(AllyState.IDLE)
	pass


func die(explosion: bool):
	ally_button.hide()
	clear_buff()
	translate_to_new_state(AllyState.DIE)
	if explosion:
		ally_sprite.pause()
		hide()
		die_explosion_process()
		rebirth_timer.start()
	else:
		ally_sprite.play("die")
		rebirth_timer.start()
	pass


func die_explosion_process():
	var dead_explosion = preload("res://Scenes/Effects/dead_body_explosion.tscn").instantiate() as AnimatedSprite2D
	dead_explosion.position = position
	AudioManager.instance.explosion_dead_body_audio_play()
	get_parent().add_child(dead_explosion)
	pass


func sec_kill(explosion: bool):
	if ally_type > AllyType.SuperSoldiers:
		die(false)
	else:
		die(explosion)
	pass


func disappear_kill():
	translate_to_new_state(AllyState.DIE)
	hide()
	ally_sprite.pause()
	rebirth_timer.start()
	pass


func take_damage(damage: int, damage_type: DataProcess.DamageType, broken_rate: float, far_attack: bool = false, source: Node2D = null,explosion: bool = false,aoe_attack: bool = false, deadly: bool = true) -> bool:
	if source is Enemy and !far_attack and !aoe_attack:
		var data: UnitData = source.current_data
		var hit_possible: float = data.near_hit_rate - current_data.dodge_rate
		if randf_range(0,1) > hit_possible:
			dodge()
			return false
	current_data.take_damage(damage,damage_type,broken_rate,far_attack,source,explosion,deadly)
	heal_timer.stop()
	heal_timer.start()
	return true
	pass


func clear_buff():
	for buff: BuffClass in buffs.get_children():
		buff.remove_buff()
	pass


func face_change_direction(min_time: float = 6, max_time: float = 16):
	direction_change_timer.wait_time = randf_range(min_time,max_time)
	direction_change_timer.start()
	if ally_state == AllyState.IDLE:
		ally_sprite.flip_h = !ally_sprite.flip_h
		anim_offset()
	pass


func attack_text_effect(text_array: Array[String] = ["铮！","锵！","唰！","剁！","铛！","哐！"],effect_type: TextEffect.TextEffectType = TextEffect.TextEffectType.Barrack):
	var text:String = text_array[randi_range(0,text_array.size()-1)]
	var show_pos: Vector2 = hurt_box.global_position - Vector2(0,10)
	show_pos += Vector2(-20,0) if ally_sprite.flip_h else Vector2(20,0)
	TextEffect.text_effect_show(text,TextEffect.TextEffectType.Barrack,show_pos)
	pass


func change_collision_layer(invincible: bool):
	if is_fly:
		unit_body.set_collision_layer_value(5,!invincible)
		hurt_box.set_collision_layer_value(5,!invincible)
	else:
		unit_body.set_collision_layer_value(4,!invincible)
		hurt_box.set_collision_layer_value(4,!invincible)
	pass


func dodge():
	TextEffect.text_effect_show("闪避",TextEffect.TextEffectType.Magic,hurt_box.global_position)
	pass


func get_closest_enemy(enemy_list: Array[Enemy]) -> Enemy:
	if enemy_list.size() == 0: return null
	else:
		var back_enemy: Enemy = enemy_list[0] if enemy_list[0].enemy_state != Enemy.EnemyState.DIE else null
		for enemy in enemy_list:
			if enemy.enemy_state == Enemy.EnemyState.DIE: continue
			var new_length: float = (enemy.position - self.position).length()
			var back_length: float = (back_enemy.position - self.position).length()
			if new_length < back_length:
				back_enemy = enemy
		
		return back_enemy
	pass


func summon_bullet(bullet_scene: PackedScene,summon_pos: Vector2, target_pos: Vector2, damage: int, damage_type: DataProcess.DamageType) -> Bullet:
	var bullet: Bullet = bullet_scene.instantiate()
	bullet.position = summon_pos
	bullet.target_position = target_pos
	bullet.damage = damage
	bullet.damage_type = damage_type
	bullet.source = self
	return bullet
	pass


func far_attack_frame(damage_type: DataProcess.DamageType = DataProcess.DamageType.PhysicsDamage):
	if far_attack_area.has_overlapping_bodies():
		far_attack_target_enemy = far_attack_area.get_overlapping_bodies()[0].owner
	if far_attack_target_enemy == null: return
	var summon_pos:Vector2 = far_attack_marker_flip.global_position if ally_sprite.flip_h else far_attack_marker.global_position
	var target_pos: Vector2 = far_attack_target_enemy.hurt_box.global_position
	target_pos += far_attack_target_enemy.direction * far_attack_target_enemy.current_data.unit_move_speed * 2
	var damage: int = randi_range(current_data.far_damage_low,current_data.far_damage_high)
	var bullet: Bullet = summon_bullet(far_attack_bullet_scene,summon_pos,target_pos,damage,damage_type)
	Stage.instance.bullets.add_child(bullet)
	pass
