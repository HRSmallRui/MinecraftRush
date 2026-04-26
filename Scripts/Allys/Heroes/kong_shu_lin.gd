extends Hero

signal skill2_effect_release

@export_group("Skill1")
@export var skill1_damage_list: Array[int]
@export var skill1_bullet_scene: PackedScene
@export_group("Skill2")
@export var skill2_damage_list: Array[DamageBlock]
@export var debuff_duration_list: Array[float]
@export var skill2_buff_scene: PackedScene
@export_group("Skill3")
@export var skill3_bullet_count_list: Array[int]
@export var skill3_damage: DamageBlock
@export_group("Skill4")
@export var dodge_possible_list: Array[float]
@export var skill4_damage_rate_list: Array[float]
@export var skill4_based_kill_possible_list: Array[float]

@onready var passive_timer: Timer = $PassiveTimer
@onready var skill_1_timer: Timer = $Skill1Timer
@onready var skill_2_timer: Timer = $Skill2Timer
@onready var skill_3_timer: Timer = $Skill3Timer
@onready var skill_4_timer: Timer = $Skill4Timer
@onready var skill_2_attack_area: Area2D = $UnitBody/Skill2AttackArea
@onready var live_layer_label: Label = $HeroUI/HeroUnitButton/Panel/LiveLayerLabel
@onready var far_attack_audio: AudioStreamPlayer = $FarAttackAudio
@onready var skill_2_preparation_effect: Sprite2D = $Skill2PreparationEffect
@onready var skill_3_shot_timer: Timer = $Skill3ShotTimer
@onready var skill_2_finish_audio: AudioStreamPlayer = $Skill2FinishAudio
@onready var skill_4_slash_audio: AudioStreamPlayer = $Skill4SlashAudio

var lives_layer: int:
	set(v):
		lives_layer = clampi(v,0,10)
		live_layer_label.text = str(lives_layer)
var skill1_target_enemy: Enemy
var skill2_prepare_effect_pos: Vector2
var remain_skill3_count: int
var last_skill3_pos: Vector2


func _ready() -> void:
	super()
	lives_layer = 0
	skill_2_preparation_effect.hide()
	skill2_prepare_effect_pos = skill_2_preparation_effect.position
	pass


func anim_offset():
	match ally_sprite.animation:
		"attack","idle":
			ally_sprite.position = Vector2(5,-95) if ally_sprite.flip_h else Vector2(-5,-95)
		"die":
			ally_sprite.position = Vector2(60,-85) if ally_sprite.flip_h else Vector2(-60,-85)
		"far_attack":
			ally_sprite.position = Vector2(-25,-85) if ally_sprite.flip_h else Vector2(25,-85)
		"move":
			ally_sprite.position = Vector2(-10,-85) if ally_sprite.flip_h else Vector2(10,-85)
		"rebirth":
			ally_sprite.position = Vector2(-5,-85) if ally_sprite.flip_h else Vector2(5,-85)
		"skill1":
			ally_sprite.position = Vector2(-15,-85) if ally_sprite.flip_h else Vector2(15,-85)
		"skill2":
			ally_sprite.position = Vector2(15,-75) if ally_sprite.flip_h else Vector2(-15,-75)
		"skill3_loop":
			ally_sprite.position = Vector2(5,-115) if ally_sprite.flip_h else Vector2(-10,-115)
		"skill3_start":
			ally_sprite.position = Vector2(-5,-95) if ally_sprite.flip_h else Vector2(5,-95)
		"skill4":
			ally_sprite.position = Vector2(5,-120) if ally_sprite.flip_h else Vector2(-5,-120)
	pass


func frame_changed():
	if ally_sprite.animation == "attack":
		if ally_sprite.frame == 8 or ally_sprite.frame == 18:
			current_data.near_damage_low *= 0.5
			current_data.near_damage_high *= 0.5
			cause_damage()
			current_data.update_near_damage()
	if ally_sprite.animation == "far_attack" and ally_sprite.frame == 14:
		far_attack_frame()
		far_attack_audio.play()
	
	if ally_sprite.animation == "skill1" and ally_sprite.frame == 26:
		var enemy: Enemy = get_skill1_enemy()
		if enemy != null: skill1_target_enemy = enemy
		if skill1_target_enemy == null: return
		ally_sprite.flip_h = skill1_target_enemy.position.x < position.x
		var damage: int = skill1_damage_list[skill_levels[1]-1]
		var summon_pos: Vector2 = far_attack_marker_flip.global_position if ally_sprite.flip_h else far_attack_marker.global_position
		var target_pos: Vector2 = skill1_target_enemy.hurt_box.global_position
		var bullet: Bullet = summon_bullet(skill1_bullet_scene,summon_pos,target_pos,damage,DataProcess.DamageType.TrueDamage)
		Stage.instance.bullets.add_child(bullet)
		AudioManager.instance.shoot_audio_2.play()
		get_exp(skill1_exp_get[skill_levels[1]-1])
	
	if ally_sprite.animation == "skill2" and ally_sprite.frame == 21:
		skill2_effect_release.emit()
		skill_2_preparation_effect.hide()
		get_exp(skill2_exp_get[skill_levels[2]-1])
		var damage_block: DamageBlock = skill2_damage_list[skill_levels[2]-1]
		for body in skill_2_attack_area.get_overlapping_bodies():
			var enemy: Enemy = body.owner
			var damage: int = randi_range(damage_block.damage_low,damage_block.damage_high)
			enemy.take_damage(damage,DataProcess.DamageType.TrueDamage,0,false,null,true,true,)
	if ally_sprite.animation == "skill2" and ally_sprite.frame == 42:
		skill_2_finish_audio.play()
	
	if ally_sprite.animation == "skill3_start" and ally_sprite.frame == 9:
		remain_skill3_count = skill3_bullet_count_list[skill_levels[3]-1]
		ally_sprite.play("skill3_loop")
		skill_3_shot_timer.start()
	
	if ally_sprite.animation == "skill4" and ally_sprite.frame == 10:
		var enemy: Enemy = current_intercepting_enemy
		if enemy == null: return
		var kill_possible: float = skill4_based_kill_possible_list[skill_levels[4]-1]
		kill_possible += 0.05 * (lives_layer - 1)
		#prints("kill_possible:",kill_possible)
		var show_text: String
		if randf() < kill_possible and enemy.enemy_type < Enemy.EnemyType.Super and lives_layer >= 1:
			enemy.sec_kill(true)
			show_text = "秒杀！"
			lives_layer -= 2
		else:
			var damage: int = randi_range(current_data.near_damage_low,current_data.near_damage_high)
			damage *= skill4_damage_rate_list[skill_levels[4]-1]
			enemy.take_damage(damage,DataProcess.DamageType.PhysicsDamage,0.5,false,self,false,false)
			show_text = "重击！"
		skill_4_slash_audio.play()
		TextEffect.text_effect_show(show_text,TextEffect.TextEffectType.SecKill,enemy.hurt_box.global_position + Vector2(0,-30))
		get_exp(skill4_exp_get[skill_levels[4]-1])
	if ally_sprite.animation == "skill4" and ally_sprite.frame == 28:
		skill_2_finish_audio.play()
	pass


func get_live_layer():
	if lives_layer >= 10 or ally_state == AllyState.DIE: return
	lives_layer += 1
	current_data.heal(start_data.health * 0.1)
	#print(start_data.health * 0.05)
	passive_timer.start()
	pass


func _on_passive_area_body_exited(body: Node2D) -> void:
	if !passive_timer.is_stopped(): return
	var enemy: Enemy = body.owner
	if enemy.enemy_state == Enemy.EnemyState.DIE:
		get_live_layer()
	pass # Replace with function body.


func die(explosion: bool):
	if lives_layer >= 8:
		lives_layer -= 8
		AudioManager.instance.level_up_audio.play()
		current_data.health = 0.5 * start_data.health
		return
	super(explosion)
	lives_layer = 0
	pass


func idle_process():
	super()
	if ally_state == AllyState.IDLE:
		if skill_2_timer.is_stopped() and skill_2_attack_area.get_overlapping_bodies().size() >= 5 and skill_levels[2] > 0:
			skill_2_timer.start()
			translate_to_new_state(AllyState.SPECIAL)
			ally_sprite.play("skill2")
			skill_2_preparation_effect.position = skill2_prepare_effect_pos
			if ally_sprite.flip_h: skill_2_preparation_effect.position.x *= -1
			skill_2_preparation_effect.show()
			return
		
		if skill_1_timer.is_stopped() and skill_levels[1] > 0 and far_attack_area.has_overlapping_bodies():
			var enemy: Enemy = get_skill1_enemy()
			if enemy != null:
				skill_1_timer.start()
				far_attack_timer.start()
				skill1_target_enemy = enemy
				translate_to_new_state(AllyState.SPECIAL)
				ally_sprite.flip_h = skill1_target_enemy.position.x < position.x
				ally_sprite.play("skill1")
				return
		
		if skill_3_timer.is_stopped() and skill_levels[3] > 0 and far_attack_area.has_overlapping_bodies():
			skill_3_timer.start()
			var enemy: Enemy = far_attack_area.get_overlapping_bodies()[0].owner
			ally_sprite.flip_h = enemy.position.x < position.x
			translate_to_new_state(AllyState.SPECIAL)
			ally_sprite.play("skill3_start")
			last_skill3_pos = enemy.hurt_box.global_position
			return
	pass


func get_skill1_enemy() -> Enemy:
	var back_enemy: Enemy
	var target_enemy_list: Array[Enemy]
	for body in far_attack_area.get_overlapping_bodies():
		var enemy: Enemy = body.owner
		target_enemy_list.append(enemy)
	if target_enemy_list.is_empty(): return null
	back_enemy = target_enemy_list[0]
	for enemy in target_enemy_list:
		if enemy.current_data.health > back_enemy.current_data.health: back_enemy = enemy
	return back_enemy


func translate_to_new_state(new_state: AllyState):
	super(new_state)
	skill_2_preparation_effect.hide()
	skill_3_shot_timer.stop()
	pass


func battle():
	if ally_sprite.animation == "idle":
		if skill_2_timer.is_stopped() and far_attack_area.get_overlapping_bodies().size() >= 5 and skill_levels[2] > 0:
			skill_2_timer.start()
			translate_to_new_state(AllyState.SPECIAL)
			ally_sprite.play("skill2")
			skill_2_preparation_effect.position = skill2_prepare_effect_pos
			if ally_sprite.flip_h: skill_2_preparation_effect.position.x *= -1
			skill_2_preparation_effect.show()
			return
	super()
	pass


func add_buff():
	for body in skill_2_attack_area.get_overlapping_bodies():
		var enemy: Enemy = body.owner
		var soul_debuff: PropertyBuff = skill2_buff_scene.instantiate()
		soul_debuff.duration = debuff_duration_list[skill_levels[2]-1]
		enemy.buffs.add_child(soul_debuff)
	pass


func _on_skill_3_shot_timer_timeout() -> void:
	if remain_skill3_count <= 0:
		skill_3_shot_timer.stop()
		translate_to_new_state(AllyState.IDLE)
		get_exp(skill3_exp_get[skill_levels[3]-1])
		return
	if far_attack_area.has_overlapping_bodies():
		var enemy: Enemy = far_attack_area.get_overlapping_bodies()[0].owner
		last_skill3_pos = enemy.hurt_box.global_position
	var target_pos: Vector2 = last_skill3_pos
	
	var damage: int = randi_range(skill3_damage.damage_low,skill3_damage.damage_high)
	var bullet: Bullet = summon_bullet(far_attack_bullet_scene,hurt_box.global_position,target_pos,damage,DataProcess.DamageType.PhysicsDamage)
	bullet.bullet_speed += 200
	Stage.instance.bullets.add_child(bullet)
	AudioManager.instance.shoot_audio_1.play()
	
	remain_skill3_count -= 1
	pass # Replace with function body.


func take_damage(damage: int, damage_type: DataProcess.DamageType, broken_rate: float, far_attack: bool = false, source: Node2D = null,explosion: bool = false,aoe_attack: bool = false, deadly: bool = true) -> bool:
	var dodge_possible: float = dodge_possible_list[skill_levels[4]-1]
	if source != null and !far_attack and skill_4_timer.is_stopped() and ally_state == AllyState.BATTLE:
		if source is Enemy and randf() < dodge_possible:
			dodge()
			skill_4_timer.start()
			ally_sprite.play("skill4")
			return false
	var result: bool = super(damage,damage_type,broken_rate,far_attack,source,explosion,aoe_attack,deadly)
	return result
