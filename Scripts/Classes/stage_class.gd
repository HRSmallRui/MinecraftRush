extends Node2D
class_name Stage

signal ui_update(member: Node)
signal wave_appear(wave_count:int)
signal wave_summon(wave_count: int)
signal on_wining

enum StageMode{
	Campaign,
	Diamond,
	Bedrock
}

enum StageUI{
	None,
	Check,
	Move,
	SkillPreparation
}

static var instance: Stage

@export var stage_count: int = 1
@export var stage_mode: StageMode
@export var limit_tech_level: int = 5
@export var tower_scene_list: Array[PackedScene]
@export_group("初始配置")
@export var current_health: int = 20
@export var current_money: int = 0
@export var total_waves: int = 8
@export var current_wave: int = 0
@export var unlocked_tower_list = [true,true,true,true]
@export var stage_environment_tags: Array[String]
@export_group("怪物生成配置文件")
@export var stage_summon_config: StageSummonConfig


@onready var preparation_music: AudioStreamPlayer = $Musics/PreparationMusic
@onready var battle_music: AudioStreamPlayer = $Musics/BattleMusic
@onready var boss_music: AudioStreamPlayer = $Musics/BossMusic
@onready var allys: Node2D = $Allys
@onready var enemies: Node2D = $Enemies
@onready var towers: Node2D = $Towers
@onready var bullets: Node2D = $Bullets
@onready var stop: StopCursor = $Stop

@onready var health_label: Label = $StageUI/PlayerStatus/HBoxContainer/Health/HBoxContainer/MarginContainer/HealthLabel
@onready var money_label: Label = $StageUI/PlayerStatus/HBoxContainer/Money/HBoxContainer/MarginContainer/MoneyLabel
@onready var wave_label: Label = $StageUI/WaveLabel
@onready var stage_camera: StageCamera = $StageCamera
@onready var information_bar: InformationBar = $StageUI/InformationBar
@onready var tips_container: VBoxContainer = $StageUI/TipsContainer
@onready var wave_during_timer: Timer = $WaveDuringTimer
@onready var skill_button_container: HBoxContainer = $StageUI/SkillButtonContainer
@onready var hero_summon_marker: Marker2D = $HeroSummonMarker
@onready var wave_next_timer: Timer = $WaveNextTimer
@onready var stage_UI_layer: CanvasLayer = $StageUI
@onready var background: Node2D = $Background
@onready var player_status: VBoxContainer = $StageUI/PlayerStatus
@onready var lable_marker: Marker2D = $StageUI/PlayerStatus/LableMarker
@onready var pause_button: TextureButton = $StageUI/PauseButton
@onready var zoom_slider: HSlider = $StageUI/ZoomSlider
@onready var zoom_animation_player: AnimationPlayer = $StageUI/ZoomAnimationPlayer
@onready var zoom_button: Button = $StageUI/ZoomButton
@onready var click_area: Area2D = $ClickArea
@onready var wave_buttons: Control = $WaveButtons

@onready var save_button: Button = $StageUI/SaveButton
@onready var load_button: Button = $StageUI/LoadButton

var stage_ui: StageUI = StageUI.None
var can_control: bool = true
var stage_sav: GameSaver
var ready_for_new_wave: bool = false
var mouse_in_path: bool = false
var mouse_in_fire_stop_area: bool = false
var mouse_in_fire_extra_area: bool = false
var hero_list: Array[Hero]
var is_screen_draging: bool = false
var is_dark_time: bool = false
var is_win: bool = false
var is_special_wave: bool = false
var mouse_relative_velocity: Vector2
var can_pause: bool = true

var pause_ui: PackedScene = preload("res://Scenes/UI-Components/Stages/pause_ui.tscn")
#var enemy_count: int = 0


func _init() -> void:
	instance = self
	stage_sav = Global.get_game_sav().duplicate(true)
	pass


func start_load():
	
	pass


func _enter_tree() -> void:
	#for i in 6:
		#stage_sav.upgrade_sav[i] = clampi(stage_sav.upgrade_sav[i],0,limit_tech_level)
	pass


func _ready() -> void:
	zoom_slider.hide()
	zoom_button.hide()
	#save_button.visible = OS.is_debug_build()
	#load_button.visible = OS.is_debug_build()
	save_button.hide()
	load_button.hide()
	if OS.get_name() == "Android":
		mobile_ui_scale()
	#mobile_ui_scale()
	
	stage_UI_layer.show()
	add_hero_skill_button()
	_hero_summon_condition()
	update_player_status()
	Achievement.achieve_complete("MR1")
	if stage_mode != StageMode.Campaign and !stage_sav.challenge_mode_tip:
		challenge_mode_tip()
	await get_tree().create_timer(0.4,false).timeout
	wave_appear.emit(1)
	pass


func mobile_ui_scale():
	#zoom_slider.show()
	#zoom_button.show()
	var scale_rate: float = 1.2
	player_status.scale *= scale_rate
	wave_label.global_position = lable_marker.global_position
	wave_label.scale *= scale_rate
	pause_button.scale *= scale_rate
	skill_button_container.scale *= scale_rate
	skill_button_container.position.x += 40
	skill_button_container.position.y -= 20
	information_bar.scale *= scale_rate
	tips_container.scale *= 2
	pass


func _hero_summon_condition():
	summon_hero()
	pass


func add_hero_skill_button():
	var hero_skill_button: SkillButton
	match stage_sav.select_hero_id:
		0: hero_skill_button = load("res://Scenes/UI-Components/Stages/SkillButton/steve_skill.tscn").instantiate()
		1: hero_skill_button = load("res://Scenes/UI-Components/Stages/SkillButton/fuchen_skill.tscn").instantiate()
		2: hero_skill_button = load("res://Scenes/UI-Components/Stages/SkillButton/alex_skill_button.tscn").instantiate()
		3: hero_skill_button = load("res://Scenes/UI-Components/Stages/SkillButton/talzin_skill_button.tscn").instantiate()
		4: hero_skill_button = load("res://Scenes/UI-Components/Stages/SkillButton/robort_skill.tscn").instantiate()
		7: hero_skill_button = load("res://Scenes/UI-Components/Stages/SkillButton/salem_skill_button.tscn").instantiate()
		8: hero_skill_button = load("res://Scenes/UI-Components/Stages/SkillButton/johnny_skill_button.tscn").instantiate()
		9: hero_skill_button = load("res://Scenes/UI-Components/Stages/SkillButton/mike_skill_button.tscn").instantiate()
		
	skill_button_container.add_child(hero_skill_button)
	pass


func _process(delta: float) -> void:
	update_player_status()
	pass


func update_player_status():
	health_label.text = str(current_health)
	money_label.text = str(current_money)
	wave_label.text = "波次： " + str(current_wave) + " / " + str(total_waves)
	if is_special_wave: 
		wave_label.text = "波次： ?? / ??"
	wave_label.size.x = $StageUI/PlayerStatus/Wave.size.x - 60
	pass


func ui_process(member: Node, new_ui: StageUI = StageUI.None):
	stage_ui = new_ui
	
	if new_ui == StageUI.Move or new_ui == StageUI.SkillPreparation:
		Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	else:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	ui_update.emit(member)
	pass


func _input(event: InputEvent) -> void:
	if !can_control: return
	
	if event is InputEventScreenDrag:
		is_screen_draging = true
		mouse_relative_velocity = event.velocity * stage_camera.zoom
	elif event.is_action_released("click") and is_screen_draging:
		await get_tree().process_frame
		is_screen_draging = false
		mouse_relative_velocity = Vector2.ZERO
	
	if event.is_action_pressed("cancel"):
		ui_process(null)
	elif event.is_action_pressed("escape"):
		if information_bar.current_check_member == null: pause()
		else: ui_process(null)
	elif event.is_action_pressed("wave_call"):
		if ready_for_new_wave:
			wave_summon.emit(current_wave + 1)
			ready_for_new_wave = false
	elif event.is_action_pressed("hero_select"):
		var hero_live_list: Array[Hero]
		for hero in hero_list:
			if hero.ally_state != Ally.AllyState.DIE: hero_live_list.append(hero)
		if hero_live_list.size() > 0:
			if !information_bar.current_check_member is Hero:
				ui_process(hero_live_list[0],StageUI.Move)
			else:
				for i in hero_live_list.size():
					if hero_live_list[i] == information_bar.current_check_member:
						if i == hero_live_list.size()-1: ui_process(null)
						else: 
							ui_process(hero_live_list[i+1],StageUI.Move)
							break
	pass


func _on_pause_button_pressed() -> void:
	pause()
	pass # Replace with function body.


func pause():
	if !can_pause: return
	add_child(pause_ui.instantiate())
	get_tree().paused = true
	pass


func _on_click_area_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if !event.is_action_released("click"): return
	if is_screen_draging and mouse_relative_velocity.length() > 50:
		return
	if stage_ui == StageUI.None or stage_ui == StageUI.Check:
		ui_process(null)
		MobileMiddleProcess.instance.current_touch_object = null
	elif stage_ui == StageUI.SkillPreparation and information_bar.current_check_member is SkillButton:
		information_bar.current_check_member.skill_unlease_condition()
		await get_tree().process_frame
		if stage_ui == StageUI.SkillPreparation: stop_effect()
	elif stage_ui == StageUI.Move:
		if information_bar.current_check_member is Hero:
			var hero = information_bar.current_check_member as Hero
			hero.when_moving_mouse_in_path = Stage.instance.mouse_in_path
			hero.move(get_local_mouse_position())
		await get_tree().process_frame
		if stage_ui == StageUI.Move: stop_effect()
	pass # Replace with function body.


func lives_taken(damage: int):
	if damage > 0:
		current_health -= damage
		AudioManager.instance.lose_heart_audio.play()
		#Input.vibrate_handheld()
	if current_health <= 0:
		lose()
	pass


func _on_wave_appear(wave_count: int) -> void:
	AudioManager.instance.wave_coming_audio.play()
	ready_for_new_wave = true
	if wave_count > 1:
		wave_during_timer.wait_time = stage_summon_config.wave_exist_timers[wave_count-2]
		wave_during_timer.start()
	pass # Replace with function body.


func _on_wave_summon(wave_count: int) -> void:
	if wave_count == 1:
		unlock_skill()
	
	if wave_count > 1:
		wave_money_get(wave_count)
	
	#if stage_ui != StageUI.None: ui_process(null)
	wave_during_timer.stop()
	current_wave += 1
	wave_tip(wave_count)
	ready_for_new_wave = false
	AudioManager.instance.wave_summon_audio.play()
	
	if wave_count == 1:
		preparation_music.stop()
		await get_tree().create_timer(0.5).timeout
		switch_music_play_mode(1)
	
	if current_wave < total_waves:
		var next_wait_time: float = stage_summon_config.next_wave_timers[current_wave-1]
		wave_next_timer.wait_time = next_wait_time
		wave_next_timer.start()
		await wave_next_timer.timeout
		wave_appear.emit(wave_count + 1)
	
	
	pass # Replace with function body.


func switch_music_play_mode(music_id: int):
	#0:prepare, 1:battle, 2:boss
	if music_id == 0: preparation_music.play()
	else: preparation_music.stop()
	
	if music_id == 1: battle_music.play()
	else: battle_music.stop()
	
	if music_id == 2: boss_music.play()
	else: boss_music.stop()
	pass


func wave_tip(wave_count: int):
	
	pass


func _on_wave_during_timer_timeout() -> void:
	wave_summon.emit(current_wave + 1)
	pass # Replace with function body.


func enemy_die():
	if is_win: return
	achievement_enemy_die()
	await get_tree().process_frame
	for enemy_path: EnemyPath in enemies.get_children():
		if !enemy_path.summoning_finished: return
		for enemy in enemy_path.get_children():
			if enemy is Enemy:
				if enemy.enemy_state != Enemy.EnemyState.DIE: return
	#if enemy_count > 0: return
	win()
	pass


func achievement_enemy_die():
	
	pass


func win(wait_time: float = 3):
	print("win")
	on_wining.emit()
	is_win = true
	await get_tree().create_timer(wait_time,false).timeout
	battle_music.stop()
	boss_music.stop()
	match stage_mode:
		StageMode.Campaign:
			add_child(preload("res://Scenes/UI-Components/Stages/campaign_win_ui.tscn").instantiate())
		StageMode.Diamond:
			add_child(preload("res://Scenes/UI-Components/Stages/diamond_win_ui.tscn").instantiate())
		StageMode.Bedrock:
			add_child(preload("res://Scenes/UI-Components/Stages/bedrock_win_ui.tscn").instantiate())
		
	ui_process(null)
	pass


func lose():
	current_health = 0
	update_player_status()
	ui_process(null)
	preparation_music.stop()
	battle_music.stop()
	boss_music.stop()
	add_child(preload("res://Scenes/UI-Components/Stages/lose_ui.tscn").instantiate())
	pass


func unlock_skill():
	if $TeachSystem != null: return
	
	for skill_button: SkillButton in skill_button_container.get_children():
		skill_button.unlock()
		await get_tree().create_timer(0.2,false).timeout
	pass


func _on_path_area_mouse_entered() -> void:
	mouse_in_path = true
	pass # Replace with function body.


func _on_path_area_mouse_exited() -> void:
	mouse_in_path = false
	pass # Replace with function body.


func summon_hero(summon_pos:Vector2 = hero_summon_marker.position):
	await get_tree().create_timer(0.1,false).timeout
	var hero: Hero
	match stage_sav.select_hero_id:
		0:
			hero = load("res://Scenes/Allys/Heroes/steve.tscn").instantiate()
		1:
			hero = load("res://Scenes/Allys/Heroes/fuchen.tscn").instantiate()
		2:
			hero = load("res://Scenes/Allys/Heroes/alex.tscn").instantiate()
		3:
			hero = load("res://Scenes/Allys/Heroes/talzin.tscn").instantiate()
		4:
			hero = load("res://Scenes/Allys/Heroes/robort.tscn").instantiate()
		7:
			hero = load("res://Scenes/Allys/Heroes/salem.tscn").instantiate()
		8:
			hero = load("res://Scenes/Allys/Heroes/johnny.tscn").instantiate()
		9:
			hero = load("res://Scenes/Allys/Heroes/mike_smith.tscn").instantiate()
	
	hero.position = summon_pos
	hero.station_position = hero.position
	allys.add_child(hero)
	hero_list.append(hero)
	pass


func stop_effect():
	stop.hide()
	stop.position = get_local_mouse_position()
	stop.stop()
	pass


func move_point_effect(target_pos: Vector2):
	var move_point = preload("res://Scenes/Effects/move_point.tscn").instantiate() as AnimatedSprite2D
	move_point.position = target_pos
	$Background.add_child(move_point)
	pass


func wave_money_get(wave_count: int):
	var rate: float = wave_during_timer.time_left / wave_during_timer.wait_time
	if rate > 0.9: rate = 1.0
	elif rate < 0.05: return
	var money = int(float(stage_summon_config.wave_money_get[wave_count-2]) * rate)
	if money == 0: return
	current_money += money
	var money_effect = preload("res://Scenes/Effects/money_get_effect.tscn").instantiate() as MoneyGetEffect
	if OS.get_name() == "Android":
		money_effect.position = Vector2(291,50)
	elif OS.get_name() == "Windows":
		var camera_origin: Vector2 = -Vector2(960,540)
		#print(camera_origin)
		money_effect.position = stage_camera.get_local_mouse_position() - camera_origin
		#print(stage_camera.get_local_mouse_position())
		#print(money_effect.position)
		money_effect.position.x += 10
		money_effect.position = Vector2(clampf(money_effect.position.x,10,1920-50),clampf(money_effect.position.y,20,1080-20))
	money_effect.money_count = money
	stage_UI_layer.add_child(money_effect)
	wave_cooling_fast(wave_count,rate)
	pass


func wave_cooling_fast(wave_count: int, rate: float):
	var firerain_button: SkillButton = skill_button_container.get_child(0)
	var reinforce_button: SkillButton = skill_button_container.get_child(1)
	var heroskill_button: SkillButton = skill_button_container.get_child(2)
	var fast_firerain: float = snappedf(stage_summon_config.firerain_cooling_fast[wave_count-2] * rate,0.1)
	var fast_reinforce: float = snappedf(stage_summon_config.reinforce_cooling_fast[wave_count-2] * rate, 0.1)
	var fast_heroskill: float = snappedf(stage_summon_config.hero_skill_cooling_fast[wave_count-2] * rate,0.1)
	firerain_button.cooling_fast(fast_firerain)
	reinforce_button.cooling_fast(fast_reinforce)
	heroskill_button.cooling_fast(fast_heroskill)
	pass


func challenge_mode_tip():
	add_child(preload("res://Scenes/TipUI/challenge_mode_tip.tscn").instantiate())
	stage_sav.challenge_mode_tip = true
	Global.sav_game_sav(stage_sav)
	pass


func challenge_level_tip():
	
	pass


func final_boss_die():
	for enemy_path: EnemyPath in enemies.get_children():
		enemy_path.summoning_finished = true
		enemy_path.process_mode = Node.PROCESS_MODE_DISABLED
		for enemy in enemy_path.get_children():
			if enemy is Enemy:
				if enemy.enemy_state != Enemy.EnemyState.DIE:
					enemy.bounty = 0
					enemy.sec_kill(false)
	
	enemy_die()
	pass


func tower_check():
	
	pass


func _on_zoom_button_pressed() -> void:
	if snappedf(zoom_button.position.x,0.1) == 1685:
		zoom_animation_player.play("zoom_hide")
	if snappedf(zoom_button.position.x,0.1) == 1830:
		zoom_animation_player.play("zoom_show")
	pass # Replace with function body.


func get_closest_enemy_path(target_pos: Vector2) -> EnemyPath:
	var path_list: Array[EnemyPath]
	for enemy_path: EnemyPath in enemies.get_children():
		if enemy_path.enabled: path_list.append(enemy_path)
	
	if path_list.is_empty(): return null
	
	var back_path: EnemyPath = path_list[0]
	for enemy_path: EnemyPath in path_list:
		var old_length: float = (back_path.curve.get_closest_point(target_pos) - target_pos).length()
		var new_length: float = (enemy_path.curve.get_closest_point(target_pos) - target_pos).length()
		if new_length < old_length:
			back_path = enemy_path
	return back_path
	pass


func get_current_techno_level(slot_id: int) -> int:
	var tech_level: int = stage_sav.upgrade_sav[slot_id]
	return clampi(tech_level,0,limit_tech_level)
	pass


func _on_save_button_pressed() -> void:
	var battle_sav: BattleSaver = BattleSaver.new()
	battle_sav.stage_health = current_health
	battle_sav.stage_money = current_money
	battle_sav.stage_wave = current_wave
	battle_sav.next_wave_time = wave_next_timer.time_left
	battle_sav.next_wave_during_time = wave_during_timer.time_left
	for enemy_path: EnemyPath in enemies.get_children():
		print(enemy_path.name)
		var enemy_pack: PackedScene = PackedScene.new()
		enemy_pack.pack(enemy_path)
		battle_sav.enemy_path_groups.append(enemy_pack)
	for ally in allys.get_children():
		print(ally.name)
		var ally_pack: PackedScene = PackedScene.new()
		ally_pack.pack(ally)
		battle_sav.ally_group.append(ally_pack)
	for bullet in bullets.get_children():
		print(bullet.name)
		var bullet_pack: PackedScene = PackedScene.new()
		bullet_pack.pack(bullet)
		battle_sav.bullet_group.append(bullet_pack)
	for tower in towers.get_children():
		print(tower.name)
		var tower_pack: PackedScene = PackedScene.new()
		tower_pack.pack(tower)
		battle_sav.tower_group.append(tower_pack)
	ResourceSaver.save(battle_sav,"res://Savs/battle_sav.tres")
	pass # Replace with function body.


func _on_load_button_pressed() -> void:
	var battle_sav: BattleSaver = load("res://Savs/battle_sav.tres") as BattleSaver
	if battle_sav == null: return
	
	for enemy_path in enemies.get_children():
		enemy_path.queue_free()
	for enemy_path_pack in battle_sav.enemy_path_groups:
		var enemy_path: EnemyPath = enemy_path_pack.instantiate()
		enemies.add_child(enemy_path)
	pass # Replace with function body.
