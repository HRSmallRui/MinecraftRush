extends Enemy

@export var later_data: UnitData
@export var skill4_scene: PackedScene
@export var skill4_unlocked_story_scene: PackedScene
@export var skill4_teach_scene: PackedScene
@export var step_2_enemy_scene: PackedScene
@export var lightning_scene: PackedScene
@export var explosion_scene: PackedScene
@export var smoke_scene: PackedScene
@export var broken_damage: int = 200
@export_multiline var fighting_text_list: Array[String]
@export_group("Step2")
@export_multiline var step2_text_list: Array[String]
@export var step2_story_scene: PackedScene
@export var step2_boss_music_scene: PackedScene
@export_group("NormalAttack")
@export var normal_attack_damage: DamageBlock
@export var normal_attack_area: Area2D
@export_group("SkillConfig")
@export var skill2_summon_count: int
@export var skill2_hit_area_scene: PackedScene
@export var skill3_lightning_area_scene: PackedScene
@export var tower_lock_buff_scene: PackedScene

@onready var boss_ui: BossUI = $BossUI
@onready var dialog_panel: DialogPanel = $UnitBody/DialogPanel
@onready var skill_2_timer: Timer = $Skill2Timer
@onready var skill_3_timer: Timer = $Skill3Timer
@onready var skill_4_timer: Timer = $Skill4Timer
@onready var power_light: Sprite2D = $UnitBody/PowerLight
@onready var ally_condition_area: Area2D = $UnitBody/AllyConditionArea
@onready var tower_condition_area: Area2D = $UnitBody/TowerConditionArea
@onready var invincible_timer: Timer = $InvincibleTimer
@onready var recover_timer: Timer = $RecoverTimer
@onready var protection_timer: Timer = $ProtectionTimer
@onready var broken_audio: AudioStreamPlayer = $BrokenAudio
@onready var dialog_timer: Timer = $DialogTimer
@onready var skill_1_audio: AudioStreamPlayer = $Skill1Audio

var skill_2_finished: bool = true
var skill_3_finished: bool = true
var skill_4_finished: bool = true
var story_summoned: bool
var remain_text_list: Array[String]


func _ready() -> void:
	super()
	invincible_timer.start()
	start_data.health = -1
	current_data.health = -1
	delay_show_health_bar()
	translate_to_new_state(EnemyState.SPECIAL)
	enemy_sprite.play("idle")
	init_animation()
	power_light.modulate.a = 0
	recover_timer.timeout.connect(recover)
	pass


func init_animation():
	await get_tree().create_timer(1,false).timeout
	enemy_sprite.play("skill1_start")
	pass


func anim_offset():
	match enemy_sprite.animation:
		"attack","idle":
			enemy_sprite.position = Vector2(5,-115) if enemy_sprite.flip_h else Vector2(-10,-115)
		"break","die":
			enemy_sprite.position = Vector2(10,-105) if enemy_sprite.flip_h else Vector2(-15,-105)
		"move_front":
			enemy_sprite.position = Vector2(-5,-100) if enemy_sprite.flip_h else Vector2(5,-100)
		"move_normal":
			enemy_sprite.position = Vector2(5,-110) if enemy_sprite.flip_h else Vector2(-10,-110)
		"recover":
			enemy_sprite.position = Vector2(-10,-100) if enemy_sprite.flip_h else Vector2(15,-100)
		"skill1_end":
			enemy_sprite.position = Vector2(10,-105) if enemy_sprite.flip_h else Vector2(-5,-105)
		"skill1_start":
			enemy_sprite.position = Vector2(-15,-165) if enemy_sprite.flip_h else Vector2(15,-165)
		"skill2":
			enemy_sprite.position = Vector2(5,-110) if enemy_sprite.flip_h else Vector2(-10,-110)
		"skill3","skill4":
			enemy_sprite.position = Vector2(10,-110) if enemy_sprite.flip_h else Vector2(-15,-110)
	pass


func frame_changed():
	if enemy_sprite.animation == "skill1_start" and enemy_sprite.frame == 55:
		enemy_sprite.pause()
	if enemy_sprite.animation == "skill1_end" and enemy_sprite.frame == 36:
		special_end_update()
	if enemy_sprite.animation == "skill1_end" and enemy_sprite.frame == 13:
		lock_all_towers()
	if enemy_sprite.animation == "attack":
		if enemy_sprite.frame == 1:
			normal_attack_area.global_position = intercepting_marker.global_position
		if enemy_sprite.frame == 13:
			summon_lightning(normal_attack_area.global_position)
			AudioManager.instance.play_explosion_audio()
			for body in normal_attack_area.get_overlapping_bodies():
				var ally: Ally = body.owner
				var damage: int = normal_attack_damage.get_damage()
				ally.take_damage(damage,DataProcess.DamageType.TrueDamage,0.2,true,null,false,true,)
	
	if enemy_sprite.animation == "skill2" and enemy_sprite.frame == 26:
		skill2_release()
	if enemy_sprite.animation == "skill2" and enemy_sprite.frame == 55:
		special_end_update()
	
	if enemy_sprite.animation == "skill3":
		if enemy_sprite.frame == 20:
			skill3_release()
		if enemy_sprite.frame == 35:
			special_end_update()
	
	if enemy_sprite.animation == "skill4":
		if enemy_sprite.frame == 20:
			skill4_release()
		if enemy_sprite.frame == 35:
			special_end_update()
	
	if !story_summoned:
		story_condition_process()
	
	
	if enemy_sprite.animation == "break" and enemy_sprite.frame == 20:
		enemy_sprite.pause()
	if enemy_sprite.animation == "recover" and enemy_sprite.frame == 15:
		special_end_update()
	pass


func boss_music_play():
	
	pass


func take_damage(damage: int, damage_type: DataProcess.DamageType, broken_rate: float, far_attack: bool = false, source: Node2D = null,explosion: bool = false,aoe_attack: bool = false, deadly: bool = true) -> bool:
	if start_data.health < 0: return false
	var result: bool = super(damage,damage_type,broken_rate,far_attack,source,explosion,aoe_attack,deadly)
	return result


func delay_show_health_bar():
	boss_ui.process_mode = Node.PROCESS_MODE_DISABLED
	body_collision.disabled = true
	hurt_box.monitorable = false
	await get_tree().create_timer(5.5,false).timeout
	Stage.instance.can_control = true
	Stage.instance.can_pause = true
	boss_ui.process_mode = Node.PROCESS_MODE_INHERIT
	
	var target_zoom: Vector2 = Stage.instance.stage_camera.min_zoom * Vector2.ONE
	create_tween().tween_property(Stage.instance.stage_camera,"zoom",target_zoom,0.2)
	enemy_sprite.play("skill1_end")
	pass


func lock_all_towers():
	skill_1_audio.play()
	dialog_timer.start()
	create_tween().tween_property(power_light,"modulate:a",1,0.3)
	invincible_timer.start()
	body_collision.disabled = false
	hurt_box.monitorable = true
	Stage.instance.is_special_wave = true
	for tower: DefenceTower in Stage.instance.towers.get_children():
		if tower.tower_level == 0: continue
		var lock_buff: TowerLockBuff = tower_lock_buff_scene.instantiate()
		tower.tower_buffs.add_child(lock_buff)
	pass


func summon_lightning(summon_pos: Vector2):
	var lightning: Line2D = lightning_scene.instantiate()
	lightning.position = summon_pos
	var explosion_effect: AnimatedSprite2D = explosion_scene.instantiate()
	explosion_effect.position = summon_pos
	var smoke_effect: AnimatedSprite2D = smoke_scene.instantiate()
	smoke_effect.position = summon_pos
	Stage.instance.bullets.add_child(lightning)
	Stage.instance.bullets.add_child(explosion_effect)
	Stage.instance.bullets.add_child(smoke_effect)
	pass


func broken():
	if start_data.health < 0:
		start_data = later_data.duplicate()
		current_data = start_data.duplicate()
		if Stage.instance.stage_sav.difficulty == GameSaver.Difficulty.EASY:
			start_data.health *= 0.8
		elif Stage.instance.stage_sav.difficulty == GameSaver.Difficulty.HARD:
			start_data.health *= 1.2
		current_data.start_data = start_data
		current_data.health = start_data.health
		current_data.owner = self
		current_data.die.connect(die)
	dialog_panel.hide()
	translate_to_new_state(EnemyState.SPECIAL)
	start_data.total_defence_rate = 0
	enemy_sprite.play("break")
	take_damage(broken_damage,DataProcess.DamageType.TrueDamage,0,)
	current_data.update_total_defence_rate()
	create_tween().tween_property(power_light,"modulate:a",0,0.4)
	recover_timer.start()
	var explosion_effect: AnimatedSprite2D = explosion_scene.instantiate()
	explosion_effect.position = hurt_box.global_position
	Stage.instance.bullets.add_child(explosion_effect)
	AudioManager.instance.play_explosion_audio()
	broken_audio.play()
	pass


func recover():
	enemy_sprite.play("recover")
	protection_timer.start()
	pass


func move_process(delta: float):
	if ally_condition_area.has_overlapping_bodies() and skill_3_timer.is_stopped():
		skill_3_timer.start()
		translate_to_new_state(EnemyState.SPECIAL)
		enemy_sprite.play("skill3")
		skill_3_finished = false
		return
	if tower_condition_area.get_overlapping_areas().size() > 5 and skill_4_timer.is_stopped():
		skill_4_timer.start()
		translate_to_new_state(EnemyState.SPECIAL)
		enemy_sprite.play("skill4")
		skill_4_finished = false
		return
	if ally_condition_area.has_overlapping_bodies() and skill_2_timer.is_stopped():
		skill_2_timer.start()
		translate_to_new_state(EnemyState.SPECIAL)
		enemy_sprite.play("skill2")
		skill_2_finished = false
		return
	super(delta)
	pass


func skill2_release():
	var rect: Rect2 = Stage.instance.stage_camera.move_limit_shape.shape.get_rect()
	var shape: CollisionShape2D = Stage.instance.stage_camera.move_limit_shape
	for i in 66:
		var summon_pos: Vector2 = Vector2(randf_range(rect.position.x,rect.end.x),randf_range(rect.position.y,rect.end.y))
		summon_pos += shape.global_position
		summon_pos.y = maxf(summon_pos.y,530)
		#print(summon_pos)
		summon_pos = Stage.instance.get_closest_enemy_path(summon_pos).curve.get_closest_point(summon_pos)
		var hit_area: Area2D = skill2_hit_area_scene.instantiate()
		hit_area.position = summon_pos
		Stage.instance.bullets.add_child(hit_area)
		Stage.instance.stage_camera.shake(2)
		await get_tree().create_timer(0.1,false).timeout
	skill_2_finished = true
	pass


func special_end_update():
	if enemy_state == EnemyState.DIE:
		return
	
	if current_intercepting_units.is_empty():
		translate_to_new_state(EnemyState.MOVE)
	else:
		translate_to_new_state(EnemyState.BATTLE)
	pass


func battle():
	if enemy_sprite.animation == "idle":
		if skill_3_timer.is_stopped():
			skill_3_timer.start()
			enemy_sprite.play("skill3")
			skill_3_finished = false
			return
		if skill_4_timer.is_stopped() and tower_condition_area.get_overlapping_areas().size() > 5:
			skill_4_timer.start()
			enemy_sprite.play("skill4")
			skill_4_finished = false
			return
		if skill_2_timer.is_stopped():
			skill_2_timer.start()
			enemy_sprite.play("skill2")
			skill_2_finished = false
			return
	super()
	pass


func skill3_release():
	skill_3_finished = true
	var summon_pos: Vector2
	if ally_condition_area.has_overlapping_bodies():
		var body = ally_condition_area.get_overlapping_bodies().pick_random() as Node2D
		var ally: Ally = body.owner
		summon_pos = ally.global_position
	elif enemy_state == EnemyState.BATTLE:
		summon_pos = intercepting_marker.global_position
	else:
		var rect: Rect2 = Stage.instance.stage_camera.move_limit_shape.shape.get_rect()
		var shape: CollisionShape2D = Stage.instance.stage_camera.move_limit_shape
		summon_pos = Vector2(randf_range(rect.position.x,rect.end.x),randf_range(rect.position.y,rect.end.y))
		summon_pos += shape.global_position
		summon_pos.y = maxf(summon_pos.y,530)
		summon_pos = Stage.instance.get_closest_enemy_path(summon_pos).curve.get_closest_point(summon_pos)
	
	var hit_area: Area2D = skill3_lightning_area_scene.instantiate()
	hit_area.position = summon_pos
	Stage.instance.bullets.add_child(hit_area)
	pass


func skill4_release():
	skill_4_finished = true
	var tower_list: Array[DefenceTower]
	for area in tower_condition_area.get_overlapping_areas():
		var tower: DefenceTower = area.owner
		if tower.tower_id > 5: continue
		tower_list.append(tower)
	if tower_list.is_empty(): 
		skill3_release()
		return
	var tower = tower_list.pick_random() as DefenceTower
	tower.destroy_tower()
	summon_lightning(tower.global_position)
	pass


func summon_story_layer() -> void:
	await get_tree().create_timer(2,false).timeout
	var boss_music_player: LoopMusicPlayer = Stage.instance.music_node.get_child(-1)
	boss_music_player.set_volume(-100,0.5)
	await get_tree().create_timer(0.8,false).timeout
	var story_layer: StoryLayer = skill4_unlocked_story_scene.instantiate()
	Stage.instance.add_child(story_layer)
	await get_tree().create_timer(0.01,false).timeout
	boss_music_player.set_volume(-5,1)
	get_tree().paused = true
	var new_skill_button: SkillButton = skill4_scene.instantiate()
	Stage.instance.skill_button_container.add_child(new_skill_button)
	var teach_system: CanvasLayer = skill4_teach_scene.instantiate()
	teach_system.boss = self
	Stage.instance.add_child(teach_system)
	pass # Replace with function body.


func story_condition_process():
	if skill_2_finished and skill_3_finished and skill_4_finished and (
		enemy_sprite.animation == "idle" or "move" in enemy_sprite.animation
	) and invincible_timer.is_stopped():
		summon_story_layer()
		story_summoned = true
	pass


func _on_protection_timer_timeout() -> void:
	start_data.total_defence_rate = 0.99
	current_data.update_total_defence_rate()
	create_tween().tween_property(power_light,"modulate:a",1,0.4)
	pass # Replace with function body.


func _on_dialog_timer_timeout() -> void:
	if remain_text_list.is_empty(): remain_text_list = fighting_text_list.duplicate()
	if enemy_sprite.animation == "break" or enemy_state == EnemyState.DIE: return
	var text: String = remain_text_list.pick_random() as String
	remain_text_list.erase(text)
	dialog_panel.dialog(text,5)
	pass # Replace with function body.


func die(explosion: bool = false):
	super(explosion)
	
	recover_timer.stop()
	var panel: Panel = boss_ui.panel
	create_tween().tween_property(panel,"modulate:a",0,1)
	dialog_timer.stop()
	broken_audio.play()
	var boss_music_player: LoopMusicPlayer = Stage.instance.music_node.get_child(-1)
	boss_music_player.set_volume(-150,3)
	await get_tree().create_timer(3,false).timeout
	Stage.instance.can_control = false
	Stage.instance.can_pause = false
	Stage.instance.stage_camera.position = position
	Stage.instance.stage_camera.zoom = Stage.instance.stage_camera.max_zoom * Vector2.ONE
	boss_music_player.queue_free()
	
	Stage.instance.add_child(step2_story_scene.instantiate())
	await get_tree().create_timer(3,false).timeout
	var music_player: LoopMusicPlayer = step2_boss_music_scene.instantiate()
	Stage.instance.music_node.add_child(music_player)
	music_player.set_volume(-100,0.01)
	music_player.set_volume(-4,1)
	Stage.instance.on_boss_music_playing.emit()
	for text in step2_text_list:
		dialog_panel.dialog(text,5)
		await get_tree().create_timer(5.75,false).timeout
	
	var next_boss: Enemy = step_2_enemy_scene.instantiate()
	next_boss.progress = progress
	get_parent().add_child(next_boss)
	create_tween().tween_property(Stage.instance.stage_camera,"zoom",Stage.instance.stage_camera.min_zoom * Vector2.ONE,0.3)
	Stage.instance.can_control = true
	Stage.instance.can_pause = true
	queue_free()
	pass
