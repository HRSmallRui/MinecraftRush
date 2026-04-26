extends Node2D

@export var boss_scene: PackedScene
@export var lightning_scene: PackedScene
@export var explosion_scene: PackedScene
@export var smoke_scene: PackedScene
@export var lock_tower_buff_scene: PackedScene
@export var hit_lightning_area_scene: PackedScene
@export var lightning_cd_min: float
@export var lightning_cd_max: float
@export_group("台词文本")
@export_multiline var start_text: String
@export_multiline var on_fighting_text: String
@export_multiline var preparing_text_list: Array[String]
@export_multiline var fighting_text_list: Array[String]
@export_multiline var boss_coming_text: String
@export_group("Areas")
@export var tower_condition_area: Area2D
@export var ally_condition_area: Area2D
@export var enemy_condition_area: Area2D
@export_group("OtherNodes")
@export var boss_summon_marker: Marker2D
@export var boss_summon_path: EnemyPath

@onready var dialog_panel: DialogPanel = $DialogPanel
@onready var skill_1_timer: Timer = $Skill1Timer
@onready var skill_2_timer: Timer = $Skill2Timer
@onready var skill_3_timer: Timer = $Skill3Timer
@onready var skill_4_timer: Timer = $Skill4Timer
@onready var enemy_sprite: AnimatedSprite2D = $EnemySprite
@onready var skill_shot_timer: Timer = $SkillShotTimer
@onready var preparation_text_timer: Timer = $PreparationTextTimer
#@onready var battle_text_timer: Timer = $BattleTextTimer
@onready var teleport_audio: AudioStreamPlayer = $TeleportAudio

var skill_can_release_list: Array[bool] = [false,false,false,false]
var remaining_preparation_text_list: Array[String]
var remaining_battle_text_list: Array[String]


func _ready() -> void:
	Stage.instance.wave_summon.connect(on_wave_summon)
	Stage.instance.on_wining.connect(on_win)
	enemy_sprite.animation_changed.connect(on_anim_changed)
	enemy_sprite.animation_finished.connect(func(): enemy_sprite.play("idle"))
	enemy_sprite.frame_changed.connect(on_frame_changed)
	on_anim_changed()
	start_dialog_process()
	remaining_preparation_text_list = preparing_text_list.duplicate()
	remaining_battle_text_list = fighting_text_list.duplicate()
	
	#await get_tree().create_timer(5,false).timeout
	#on_win()
	pass


func on_wave_summon(wave_count: int):
	if wave_count != 1:
		_on_battle_text_timer_timeout()
	
	match wave_count:
		9:
			skill_can_release_list[0] = true
		10:
			skill_can_release_list[0] = false
		11:
			skill_can_release_list[0] = true
		17:
			skill_can_release_list[0] = false
		12:
			skill_can_release_list[1] = true
		4:
			skill_can_release_list[2] = true
		3:
			skill_can_release_list[3] = true
		1:
			wave1_dialog_process()
			skill_shot_timer.start()
			preparation_text_timer.stop()
			#battle_text_timer.start()
	pass





func on_win():
	Stage.instance.on_wining.disconnect(on_win)
	skill_shot_timer.stop()
	await get_tree().create_timer(2,false).timeout
	skill_can_release_list = [false,false,false,false]
	summon_boss()
	pass


func start_dialog_process():
	await get_tree().create_timer(0.2,false).timeout
	Stage.instance.stage_camera.zoom = Vector2.ONE * 1.5
	Stage.instance.stage_camera.position = global_position
	dialog_panel.dialog(start_text,3)
	pass


func wave1_dialog_process():
	await get_tree().create_timer(0.5,false).timeout
	dialog_panel.dialog(on_fighting_text,3)
	pass


func on_anim_changed():
	match enemy_sprite.animation:
		"idle":
			enemy_sprite.position = Vector2(1,-23)
		"skill1":
			enemy_sprite.position = Vector2(0,-22)
		"skill2","skill3":
			enemy_sprite.position = Vector2(0,-22)
		"skill4":
			enemy_sprite.position = Vector2(0,-27)
	pass


#region SkillConditionProcess
func _on_skill_shot_timer_timeout() -> void:
	if enemy_sprite.animation != "idle": return
	
	if skill_1_timer.is_stopped() and tower_condition_area.has_overlapping_areas() and skill_can_release_list[0]:
		enemy_sprite.play("skill1")
		skill_1_timer.start()
		return
	if skill_2_timer.is_stopped() and skill2_can_release() and skill_can_release_list[1]:
		enemy_sprite.play("skill2")
		skill_2_timer.start()
		return
	if skill_3_timer.is_stopped() and ally_condition_area.has_overlapping_bodies() and skill_can_release_list[2]:
		enemy_sprite.play("skill3")
		skill_3_timer.wait_time = randf_range(lightning_cd_min,lightning_cd_max)
		skill_3_timer.start()
		return
	#if skill_4_timer.is_stopped() and enemy_condition_area.has_overlapping_bodies() and skill_can_release_list[3]:
		#enemy_sprite.play("skill4")
		#skill_4_timer.start()
		#return
	
	pass # Replace with function body.
#endregion


func _on_preparation_text_timer_timeout() -> void:
	if remaining_preparation_text_list.is_empty(): remaining_preparation_text_list = preparing_text_list.duplicate()
	var text: String = remaining_preparation_text_list.pick_random() as String
	dialog_panel.dialog(text,8)
	remaining_preparation_text_list.erase(text)
	pass # Replace with function body.


func _on_battle_text_timer_timeout() -> void:
	await get_tree().create_timer(2,false).timeout
	if remaining_battle_text_list.is_empty(): remaining_battle_text_list = fighting_text_list.duplicate()
	var text: String = remaining_battle_text_list.pick_random() as String
	dialog_panel.dialog(text,8)
	remaining_battle_text_list.erase(text)
	pass # Replace with function body.


#NOTE frame

func on_frame_changed():
	if enemy_sprite.animation == "skill1" and enemy_sprite.frame == 26:
		lock_towers()
	if enemy_sprite.animation == "skill2" and enemy_sprite.frame == 20:
		destroy_towers()
	if enemy_sprite.animation == "skill3" and enemy_sprite.frame == 20:
		hit_lightning_release()
	if enemy_sprite.animation == "skill4" and enemy_sprite.frame == 23:
		teleport_enemies()
	pass


func skill2_can_release() -> bool:
	for area in tower_condition_area.get_overlapping_areas():
		var tower: DefenceTower = area.owner
		if tower.tower_id <= 5: return true
	return false


func skill4_can_release() -> bool:
	for body in enemy_condition_area.get_overlapping_bodies():
		var enemy: Enemy = body.owner
		var enemy_path: EnemyPath = enemy.get_parent() as EnemyPath
		if enemy_path.curve.get_baked_length() - enemy.progress > 400: return true
	return false


#region SkillReleaseProcess

func lock_towers():
	var tower_list: Array[DefenceTower]
	for area in tower_condition_area.get_overlapping_areas():
		var tower: DefenceTower = area.owner
		tower_list.append(tower)
	var loop_count: int = randi_range(1,10)
	loop_count = min(loop_count,tower_list.size())
	tower_list.shuffle()
	tower_list.resize(loop_count)
	for tower in tower_list:
		var lock_buff: TowerLockBuff = lock_tower_buff_scene.instantiate()
		tower.tower_buffs.add_child(lock_buff)
		summon_lightning(tower.global_position)
	if loop_count > 0:
		AudioManager.instance.play_explosion_audio()
	pass


func destroy_towers():
	if tower_condition_area.has_overlapping_areas():
		var tower_list: Array[DefenceTower]
		for area in tower_condition_area.get_overlapping_areas():
			var tower: DefenceTower = area.owner
			if tower.tower_id < 5: tower_list.append(tower)
		if tower_list.is_empty(): return
		var tower: DefenceTower = tower_list.pick_random() as DefenceTower
		tower.destroy_tower()
		summon_lightning(tower.global_position)
		AudioManager.instance.play_explosion_audio()
	pass


func hit_lightning_release():
	if ally_condition_area.has_overlapping_bodies():
		var body: CharacterBody2D = ally_condition_area.get_overlapping_bodies().pick_random() as CharacterBody2D
		var ally: Ally = body.owner
		var hit_lightning_area: Area2D = hit_lightning_area_scene.instantiate()
		hit_lightning_area.position = ally.global_position
		Stage.instance.bullets.add_child(hit_lightning_area)
		AudioManager.instance.play_explosion_audio()
		summon_lightning(hit_lightning_area.global_position)
	pass


func teleport_enemies():
	if enemy_condition_area.has_overlapping_bodies():
		var teleported_count: int = 0
		teleport_audio.play()
		for body in enemy_condition_area.get_overlapping_bodies():
			if teleported_count >= 12: return
			var enemy: Enemy = body.owner
			var enemy_path: EnemyPath = enemy.get_parent()
			var remain_path_length: float = enemy_path.curve.get_baked_length() - enemy.progress
			if remain_path_length > 400 and enemy.enemy_state == Enemy.EnemyState.MOVE:
				teleport_one_enemy(enemy)
				teleported_count += 1
	pass

#endregion


func summon_lightning(summon_pos: Vector2):
	var lightning: Line2D = lightning_scene.instantiate()
	lightning.position = summon_pos
	Stage.instance.bullets.add_child(lightning)
	
	var explosion_effect: AnimatedSprite2D = explosion_scene.instantiate()
	explosion_effect.position = summon_pos
	Stage.instance.bullets.add_child(explosion_effect)
	
	var smoke_effect: AnimatedSprite2D = smoke_scene.instantiate()
	smoke_effect.position = summon_pos
	Stage.instance.bullets.add_child(smoke_effect)
	pass


func summon_teleport_effect(summon_pos: Vector2):
	var teleport_effect: AnimatedSprite2D = explosion_scene.instantiate()
	teleport_effect.modulate = Color.PURPLE
	teleport_effect.position = summon_pos
	Stage.instance.bullets.add_child(teleport_effect)
	pass


func teleport_one_enemy(enemy: Enemy):
	for ally: Ally in enemy.current_intercepting_units:
		if ally != null:
			ally.current_intercepting_enemy = null
	
	enemy.current_intercepting_units.clear()
	if enemy.enemy_state != Enemy.EnemyState.DIE: enemy.translate_to_new_state(Enemy.EnemyState.MOVE)
	enemy.progress += 200
	summon_teleport_effect(enemy.hurt_box.global_position)
	pass


func summon_boss():
	Stage.instance.stage_camera.zoom = Stage.instance.stage_camera.max_zoom * Vector2.ONE
	Stage.instance.stage_camera.position = global_position
	Stage.instance.can_pause = false
	Stage.instance.can_control = false
	Stage.instance.preparation_music.stop()
	Stage.instance.battle_music.stop()
	Stage.instance.on_battle_music_stop.emit()
	Stage.instance.on_prepare_music_stop.emit()
	Stage.instance.on_boss_music_playing.emit()
	
	Stage.instance.ui_process(null)
	dialog_panel.dialog(boss_coming_text,4)
	await get_tree().create_timer(6,false).timeout
	hide()
	summon_teleport_effect(global_position)
	teleport_audio.play()
	
	await get_tree().create_timer(4,false).timeout
	var boss: Enemy = boss_scene.instantiate()
	boss.progress = boss_summon_path.curve.get_closest_offset(boss_summon_marker.global_position)
	boss_summon_path.add_child(boss)
	summon_teleport_effect(boss.hurt_box.global_position)
	teleport_audio.play()
	Stage.instance.stage_camera.position = boss.position
	await teleport_audio.finished
	queue_free()
	pass
