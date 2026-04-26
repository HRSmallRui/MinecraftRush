extends Hero

@export_group("Skill1")
@export var skill1_damage_block: DamageBlock
@export var freeze_buff_scene: PackedScene
@export var delay_slash_effect_scene: PackedScene
@export var slash_effect_scene: PackedScene
@export_group("Skill2")
@export_range(0,1,0.01) var defence_possible: float
@export_range(0,1,0.01) var defence_immune_rate: float
@export_range(0,1,0.01) var defence_damage_rate: float
@export_group("Skill3")
@export var skill3_damage: int
@export var sword_effect_scene: PackedScene
#@export var super_attack_marker_list: Array[Marker2D]

@onready var skill_1_timer: Timer = $Skill1Timer
@onready var skill_3_timer: Timer = $Skill3Timer
@onready var skill_3_attack_area: Area2D = $UnitBody/Skill3AttackArea
@onready var defence_audio: AudioStreamPlayer = $DefenceAudio
@onready var defence_timer: Timer = $DefenceTimer
@onready var skill_1_condition_area: Area2D = $UnitBody/Skill1ConditionArea
@onready var skill_1_area: Area2D = $Skill1Area
@onready var slash_audio: AudioStreamPlayer = $SlashAudio
@onready var skill_3_release_audio: AudioStreamPlayer = $Skill3ReleaseAudio

var target_enemy_path: EnemyPath
var move_to_start_point: bool
var freeze_enemy_list: Array[Enemy]
var freeze_buff_list: Array[BuffClass]
var delay_slash_effect_list: Array[Node2D]


func anim_offset():
	match ally_sprite.animation:
		"attack","idle":
			ally_sprite.position = Vector2(0,-110) if ally_sprite.flip_h else Vector2(5,-110)
		"defence":
			ally_sprite.position = Vector2(-10,-80) if ally_sprite.flip_h else Vector2(10,-80)
		"die":
			ally_sprite.position = Vector2(35,-115) if ally_sprite.flip_h else Vector2(-35,-115)
		"move":
			ally_sprite.position = Vector2(-30,-95) if ally_sprite.flip_h else Vector2(30,-95)
		"rebirth":
			ally_sprite.position = Vector2(-50,-165) if ally_sprite.flip_h else Vector2(50,-165)
		"skill1_end":
			ally_sprite.position = Vector2(25,-50) if ally_sprite.flip_h else Vector2(-25,-50)
		"skill1_start":
			ally_sprite.position = Vector2(-70,-60) if ally_sprite.flip_h else Vector2(70,60)
		"skill3_end","skill3_start":
			ally_sprite.position = Vector2(-30,-155) if ally_sprite.flip_h else Vector2(30,-155)
	pass


func frame_changed():
	if ally_sprite.animation == "attack" and ally_sprite.frame == 14:
		cause_damage()
	
	if ally_sprite.animation == "skill1_start" :
		if ally_sprite.frame == 14:
			create_tween().tween_property(self,"modulate:a",0,0.2)
		if ally_sprite.frame == 22:
			ally_sprite.pause()
			delay_slash()
			skill_3_release_audio.play()
	if ally_sprite.animation == "skill1_end" and ally_sprite.frame == 33:
		body_collision.disabled = false
		hurt_box.set_collision_layer_value(4,true)
		for buff in  freeze_buff_list:
			if buff != null: buff.remove_buff()
		freeze_buff_list.clear()
		
		for enemy in freeze_enemy_list:
			if enemy == null: continue
			var damage: int = randi_range(skill1_damage_block.damage_low,skill1_damage_block.damage_high)
			enemy.take_damage(damage,DataProcess.DamageType.TrueDamage,0,false,null,true,true)
			var red_slash_effect: Node2D = slash_effect_scene.instantiate()
			red_slash_effect.position = enemy.hurt_box.global_position
			red_slash_effect.scale *= 0.5
			Stage.instance.bullets.add_child(red_slash_effect)
		freeze_enemy_list.clear()
		slash_audio.play()
		
		for shape in skill_1_area.get_children():
			shape.queue_free()
		for slash_effect in delay_slash_effect_list:
			slash_effect.queue_free()
		delay_slash_effect_list.clear()
	
	if ally_sprite.animation == "skill3_start" and ally_sprite.frame == 29:
		ally_sprite.pause()
		skill3_release()
		await get_tree().create_timer(0.5,false).timeout
		if ally_state != AllyState.DIE: ally_sprite.play("skill3_end")
	pass


func take_damage(damage: int, damage_type: DataProcess.DamageType, broken_rate: float, far_attack: bool = false, source: Node2D = null,explosion: bool = false,aoe_attack: bool = false, deadly: bool = true) -> bool:
	var current_damage: int = damage
	var is_defence: bool
	if source != null and randf() < defence_possible and (ally_state != AllyState.SPECIAL and ally_state != AllyState.DIE):
		if source is Enemy:
			current_damage = float(damage) * defence_immune_rate
			is_defence = true
			defence_timer.start()
			#print(current_damage)
	var result: bool = super(current_damage,damage_type,broken_rate,far_attack,source,explosion,aoe_attack,deadly)
	if is_defence and ally_state != AllyState.DIE and current_intercepting_enemy != null:
		var enemy: Enemy = current_intercepting_enemy
		var return_damage: int = float(damage) * defence_damage_rate
		enemy.take_damage(return_damage,DataProcess.DamageType.TrueDamage,0,false)
		translate_to_new_state(AllyState.SPECIAL)
		ally_sprite.play("defence")
		defence_audio.play()
	return result


func idle_process():
	super()
	if ally_state == AllyState.IDLE:
		#if skill_1_timer.is_stopped() and skill_1_condition_area.get_overlapping_bodies().size() >= 4:
			#var target_enemy: Enemy = get_skill1_enemy()
			#if target_enemy != null:
				#target_enemy_path = target_enemy.get_parent()
				#body_collision.disabled = true
				#hurt_box.set_collision_layer_value(4,false)
				#translate_to_new_state(AllyState.SPECIAL)
				#ally_sprite.play("skill1_start")
				#skill_1_timer.start()
				#ally_sprite.flip_h = target_enemy.global_position.x < global_position.x
				#var self_progress: float = target_enemy_path.curve.get_closest_offset(position)
				#move_to_start_point = self_progress > target_enemy.progress
				#return
		
		if skill_3_timer.is_stopped() and skill_3_attack_area.get_overlapping_bodies().size() >= 3:
			translate_to_new_state(AllyState.SPECIAL)
			ally_sprite.play("skill3_start")
			skill_3_timer.start()
			return
	pass


func get_skill1_enemy() -> Enemy:
	for body in skill_1_condition_area.get_overlapping_bodies():
		var enemy: Enemy = body.owner
		if enemy.get_groups().has("special"): continue
		var enemy_path: EnemyPath = enemy.get_parent()
		var curve: Curve2D = enemy_path.curve
		if position.distance_to(curve.get_closest_point(global_position)) > 40: continue
		return enemy
	return null


func delay_slash():
	await get_tree().create_timer(0.2,false).timeout
	var self_progress: float = target_enemy_path.curve.get_closest_offset(position)
	var delta_progress: float = 600
	delta_progress *= -1 if move_to_start_point else 1
	freeze_and_slash(self_progress,delta_progress)
	position = target_enemy_path.curve.sample_baked(self_progress + delta_progress)
	create_tween().tween_property(self,"modulate:a",1,0.2)
	ally_sprite.play("skill1_end")
	intercepting_area.position = position
	station_position = position
	pass


func freeze_and_slash(start_progress: float, delta_progress: float):
	var count: int = 20
	var circle_shape: CircleShape2D = CircleShape2D.new()
	circle_shape.radius = 40
	delta_progress /= count
	for i in count:
		var collision: CollisionShape2D = CollisionShape2D.new()
		collision.shape = circle_shape
		collision.position = target_enemy_path.curve.sample_baked(start_progress + delta_progress * i)
		collision.position = Stage.instance.get_closest_main_enemy_path(collision.global_position).curve.get_closest_point(collision.global_position)
		skill_1_area.add_child(collision)
	
	await get_tree().physics_frame
	await get_tree().physics_frame
	for body in skill_1_area.get_overlapping_bodies():
		var enemy: Enemy = body.owner
		freeze_enemy_list.append(enemy)
	for enemy in freeze_enemy_list:
		if enemy.enemy_type >= Enemy.EnemyType.MiniBoss: continue
		var freeze_buff: PropertyBuff = freeze_buff_scene.instantiate()
		freeze_buff_list.append(freeze_buff)
		enemy.buffs.add_child(freeze_buff)
		var delay_slash_effect: Node2D = delay_slash_effect_scene.instantiate()
		delay_slash_effect.position = enemy.hurt_box.global_position
		delay_slash_effect.scale *= 0.6
		Stage.instance.bullets.add_child(delay_slash_effect)
		delay_slash_effect_list.append(delay_slash_effect)
	pass


func skill3_release():
	for i in 40:
		var pos: Vector2= position + Vector2(randf_range(-208,0),randf_range(-145,145))
		var sword_effect: Node2D = sword_effect_scene.instantiate()
		sword_effect.position = pos
		sword_effect.scale *= 0.3
		var sword_effect2: Node2D = sword_effect_scene.instantiate()
		sword_effect2.position = pos
		sword_effect2.scale = sword_effect.scale
		sword_effect2.position.x +=  2 * (position.x - pos.x)
		Stage.instance.bullets.add_child(sword_effect)
		Stage.instance.bullets.add_child(sword_effect2)
		sword_effect.get_node("Cut/SwordSprite").rotation_degrees += randf_range(-15,0)
		sword_effect2.get_node("Cut/SwordSprite").rotation_degrees += randf_range(0,15)
		delay_free_sword_effect(sword_effect)
		delay_free_sword_effect(sword_effect2)
	for body in skill_3_attack_area.get_overlapping_bodies():
		var enemy: Enemy = body.owner
		enemy.take_damage(skill3_damage,DataProcess.DamageType.PhysicsDamage,0,false,null,true,true)
	pass


func battle():
	if ally_sprite.animation == "idle":
		if skill_3_timer.is_stopped() and skill_3_attack_area.get_overlapping_bodies().size() >= 3:
			translate_to_new_state(AllyState.SPECIAL)
			ally_sprite.play("skill3_start")
			skill_3_timer.start()
			return
	super()
	pass


func delay_free_sword_effect(sword_effect: Node2D):
	await get_tree().create_timer(1.5,false).timeout
	var disappear_tween: Tween = create_tween()
	disappear_tween.tween_property(sword_effect,"modulate:a",0,0.6)
	await disappear_tween.finished
	sword_effect.queue_free()
	pass
