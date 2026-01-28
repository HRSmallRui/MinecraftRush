extends Enemy

signal false_die_frame

@onready var attack_area: Area2D = $UnitBody/AttackArea
@onready var appear_audio: AudioStreamPlayer = $AppearAudio
@onready var boss_ui: BossUI = $BossUI
@onready var skill_1_timer: Timer = $Skill1Timer
@onready var skill_2_timer: Timer = $Skill2Timer
@onready var large_attack_area: Area2D = $UnitBody/LargeAttackArea
@onready var appear_audio_2: AudioStreamPlayer = $AppearAudio2
@onready var aoe_hit: AudioStreamPlayer = $AoeHit
@onready var heal_area: Area2D = $UnitBody/HealArea
@onready var skill_2_hurt_area: Area2D = $UnitBody/Skill2HurtArea

var is_dying: bool


func anim_offset():
	match enemy_sprite.animation:
		"appear":
			enemy_sprite.position = Vector2(30,-3410) if enemy_sprite.flip_h else Vector2(-30,-3410)
		"attack","idle":
			enemy_sprite.position = Vector2(360,-855) if enemy_sprite.flip_h else Vector2(-345,-855)
		"die":
			enemy_sprite.position = Vector2(-330,-385) if enemy_sprite.flip_h else Vector2(345,-385)
		"move_back":
			enemy_sprite.position = Vector2(-35,-425) if enemy_sprite.flip_h else Vector2(25,-425)
		"move_front":
			enemy_sprite.position = Vector2(-20,-425) if enemy_sprite.flip_h else Vector2(15,-425)
		"move_normal":
			enemy_sprite.position = Vector2(20,-455) if enemy_sprite.flip_h else Vector2(-25,-455)
		"rebirth":
			enemy_sprite.position = Vector2(-440,-420) if enemy_sprite.flip_h else Vector2(440,-420)
		"skill1":
			enemy_sprite.position = Vector2(-105,-2355) if enemy_sprite.flip_h else Vector2(100,-2355)
		"skill2":
			enemy_sprite.position = Vector2(-135,-540) if enemy_sprite.flip_h else Vector2(130,-540)
	pass


func invincible_set(is_invincible: bool):
	interceptable = !is_invincible
	hurt_box.set_collision_layer_value(6,!is_invincible)
	unit_body.set_collision_layer_value(6,!is_invincible)
	enemy_button.visible = !is_invincible
	health_bar.modulate.a = 0 if is_invincible else 1
	if is_invincible and Stage.instance.information_bar.current_check_member == self:
		Stage.instance.ui_process(null)
	pass


func frame_changed():
	if enemy_sprite.animation == "attack" and enemy_sprite.frame == 23:
		aoe_hit.play()
		for body in attack_area.get_overlapping_bodies():
			var ally: Ally = body.owner
			var damage: int = randi_range(current_data.near_damage_low,current_data.near_damage_high)
			ally.take_damage(damage,DataProcess.DamageType.PhysicsDamage,0,false,self,false)
	if enemy_sprite.animation == "appear" and enemy_sprite.frame == 7:
		appear_audio_2.play()
		for body in large_attack_area.get_overlapping_bodies():
			var ally: Ally = body.owner
			ally.take_damage(500,DataProcess.DamageType.PhysicsDamage,0,false,self)
		Stage.instance.stage_camera.shake(20)
	if enemy_sprite.animation == "appear":
		if enemy_sprite.frame > 40 and enemy_sprite.frame < 67:
			Stage.instance.stage_camera.shake(20)
		if enemy_sprite.frame == 34:
			appear_audio.play()
	if enemy_sprite.animation == "skill1":
		if enemy_sprite.frame == 24:
			Stage.instance.stage_camera.shake(20)
		if enemy_sprite.frame == 28:
			Stage.instance.stage_camera.shake(40)
			for body in large_attack_area.get_overlapping_bodies():
				var ally: Ally = body.owner
				ally.take_damage(400,DataProcess.DamageType.ExplodeDamage,0,false,self)
			aoe_hit.play()
			AudioManager.instance.play_explosion_audio()
	if enemy_sprite.animation == "skill2":
		if enemy_sprite.frame == 9:
			appear_audio.play()
		if enemy_sprite.frame > 16 and enemy_sprite.frame < 36:
			Stage.instance.stage_camera.shake(30)
		if enemy_sprite.frame == 20:
			current_data.heal(start_data.health * 0.05)
			for body in heal_area.get_overlapping_bodies():
				var enemy: Enemy = body.owner
				if enemy == self: continue
				enemy.current_data.heal(enemy.start_data.health * 0.2)
			for body in skill_2_hurt_area.get_overlapping_bodies():
				var ally: Ally = body.owner
				ally.take_damage(100,DataProcess.DamageType.TrueDamage,0,false,self)
	
	if enemy_sprite.animation == "die" and enemy_sprite.frame == 24:
		enemy_sprite.pause()
		false_die_frame.emit()
	pass


func _ready() -> void:
	boss_ui.process_mode = Node.PROCESS_MODE_DISABLED
	skill_2_timer.start()
	super()
	progress_ratio = 0.4
	invincible_set(true)
	translate_to_new_state(EnemyState.SPECIAL)
	enemy_sprite.play("appear")
	await enemy_sprite.animation_finished
	invincible_set(false)
	translate_to_new_state(EnemyState.MOVE)
	pass


func boss_music_play():
	await get_tree().create_timer(2,false).timeout
	super()
	Stage.instance.is_special_wave = true
	boss_ui.health_bar.value = 0
	boss_ui.process_mode = Node.PROCESS_MODE_INHERIT
	pass


func battle():
	super()
	if enemy_sprite.animation == "idle":
		if skill_1_timer.is_stopped():
			skill_1_timer.start()
			enemy_sprite.play("skill1")
			invincible_set(true)
			await enemy_sprite.animation_finished
			invincible_set(false)
			return
		if skill_2_timer.is_stopped():
			skill_2_timer.start()
			enemy_sprite.play("skill2")
			return
		
	pass


func move_process(delta: float):
	super(delta)
	if skill_2_timer.is_stopped() and enemy_state == EnemyState.MOVE:
		skill_2_timer.start()
		translate_to_new_state(EnemyState.SPECIAL)
		enemy_sprite.play("skill2")
		await enemy_sprite.animation_finished
		if enemy_state == EnemyState.DIE: return
		if current_intercepting_units.size() > 0:
			translate_to_new_state(EnemyState.BATTLE)
		else:
			translate_to_new_state(EnemyState.MOVE)
	pass


func die(explosion: bool = false):
	if is_dying: return
	if !is_final_boss:
		false_die()
		return
	super(explosion)
	Achievement.achieve_complete("Boss2Dead")
	pass


func false_die():
	is_dying = true
	if Stage.instance.information_bar.current_check_member == self: Stage.instance.ui_process(null)
	for ally in current_intercepting_units:
		ally.current_intercepting_enemy = null
	die_audio_play()
	translate_to_new_state(EnemyState.SPECIAL)
	invincible_set(true)
	enemy_sprite.play("die")
	await false_die_frame
	is_dying = false
	
	await get_tree().create_timer(2,false).timeout
	is_final_boss = true
	var heal_tween: Tween = create_tween()
	heal_tween.tween_property(current_data,"health",2800,1)
	await heal_tween.finished
	enemy_sprite.play("rebirth")
	await enemy_sprite.animation_finished
	translate_to_new_state(EnemyState.MOVE)
	invincible_set(false)
	skill_2_timer.stop()
	pass


func die_blood(blood_packed_scene: PackedScene = preload("res://Scenes/Effects/blood.tscn")):
	var blood = blood_packed_scene.instantiate() as Sprite2D
	blood.position = position
	blood.scale *= 3
	Stage.instance.bullets.add_child(blood)
	pass
