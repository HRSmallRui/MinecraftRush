extends Enemy

@onready var boss_music: AudioStreamPlayer = $BossMusic
@onready var boss_ui: BossUI = $BossUI
@onready var boss_music_2: AudioStreamPlayer = $BossMusic2
@onready var dialog_panel: DialogPanel = $UnitBody/DialogPanel
@onready var waiting_skill_timer: Timer = $WaitingSkillTimer
@onready var disappear_timer: Timer = $DisappearTimer
@onready var teleport_timer: Timer = $TeleportTimer
@onready var total_timer: Timer = $TotalTimer
@onready var teleport_audio: AudioStreamPlayer = $TeleportAudio
@onready var ally_area: Area2D = $UnitBody/AllyArea
@onready var tower_area: Area2D = $UnitBody/TowerArea
@onready var lightning_particle: GPUParticles2D = $UnitBody/LightningParticle
@onready var lightning_audio: AudioStreamPlayer = $LightningAudio

var last_skill_id: int = 0
var word_list: Array[String] = [
	"不过是些凡间俗物，尔等蝼蚁以为如此便可阻止吾之霸业吗？",
	"待解决了尔等蝼蚁，几日后便是人国之灭亡。",
	"厌鸣的无敌部队，将会踏破尔等小国的每一寸土地。九泉之下，尔等将会团聚的，这点大可放心。",
	"不过区区凡人，妄图阻挠吾？笑话！",
	"尔等大可睁大双眼，看着吾之神力如何击溃这溃烂不堪的防线。",
	"濒死的羔羊，妄图做最后无用的抵抗吗？",
	"有趣，有趣，在尔等灭亡前大可给吾增添些许乐趣。"
]


func _ready() -> void:
	super()
	dialog_panel.z_index += 1
	word_list = word_list.duplicate()
	Stage.instance.can_pause = false
	Stage.instance.can_control = false
	body_collision.disabled = true
	hurt_box.monitorable = false
	#position = Vector2(540,900)
	delay_boss_music_play()
	dialog_process()
	boss_ui.process_mode = Node.PROCESS_MODE_DISABLED
	await get_tree().process_frame
	Stage.instance.stage_camera.position = global_position
	Stage.instance.stage_camera.zoom = Vector2.ONE * 2
	await get_tree().create_timer(10.5,false).timeout
	boss_ui.process_mode = Node.PROCESS_MODE_INHERIT
	pass


func anim_offset():
	match enemy_sprite.animation:
		"idle":
			enemy_sprite.position = Vector2(0,-80)
		"skill1","skill2":
			enemy_sprite.position = Vector2(0,-100)
		"skill3":
			enemy_sprite.position = Vector2(0,-105)
		"super_skill":
			enemy_sprite.position = Vector2(0,-130)
		"teleport_finish":
			enemy_sprite.position = Vector2(0,-110)
	pass


func frame_changed():
	if enemy_sprite.animation == "skill1" and enemy_sprite.frame == 20:
		skill_1_release()
		disappear_timer.start()
	if enemy_sprite.animation == "skill2" and enemy_sprite.frame == 20:
		skill_2_release()
		disappear_timer.start()
	if enemy_sprite.animation == "skill3" and enemy_sprite.frame == 26:
		skill_3_release()
		disappear_timer.start()
	if enemy_sprite.animation == "super_skill" and enemy_sprite.frame == 25:
		super_release()
		enemy_sprite.pause()
	pass


func take_damage(damage: int, damage_type: DataProcess.DamageType, broken_rate: float, far_attack: bool = false, source: Node2D = null,explosion: bool = false,aoe_attack: bool = false, deadly: bool = true) -> bool:
	return false
	pass


func delay_boss_music_play():
	await get_tree().create_timer(0.5,false).timeout
	boss_music.play()
	await get_tree().create_timer(30.4).timeout
	boss_music_2.play()
	pass


func move_process(delta_time: float):
	
	pass


func dialog_process():
	await get_tree().create_timer(4.5,false).timeout
	dialog_panel.dialog("聒噪。",2)
	await get_tree().create_timer(2,false).timeout
	dialog_panel.dialog("吾之爱宠虽愚钝，此刻也轮不到尔等蝼蚁欢庆。",3)
	await get_tree().create_timer(4,false).timeout
	dialog_panel.dialog("杀吾兽，需用尔等性命来偿还。",3)
	Stage.instance.can_control = true
	body_collision.disabled = false
	hurt_box.monitorable = true
	waiting_skill_timer.start()
	#await waiting_skill_timer.timeout
	total_timer.start()
	pass


func _on_waiting_skill_timer_timeout() -> void:
	if total_timer.is_stopped():
		dialog_panel.dialog("该结束了。",3)
		await get_tree().create_timer(4,false).timeout
		enemy_sprite.play("super_skill")
		return
	var skill_list: Array[int] = [1,2,3]
	skill_list.erase(last_skill_id)
	var skill_id: int = skill_list.pick_random()
	last_skill_id = skill_id
	match skill_id:
		1:
			enemy_sprite.play("skill1")
		2:
			enemy_sprite.play("skill2")
		3:
			enemy_sprite.play("skill3")
	pass # Replace with function body.


func _on_disappear_timer_timeout() -> void:
	hide()
	if Stage.instance.information_bar.current_check_member == self:
		Stage.instance.ui_process(null)
	teleport_effect()
	body_collision.disabled = true
	hurt_box.monitorable = false
	teleport_timer.start()
	pass # Replace with function body.


func _on_teleport_timer_timeout() -> void:
	show()
	var enemy_path: EnemyPath = Stage.instance.enemies.get_child(randi_range(0,11))
	var random_position: Vector2 = Vector2(randf_range(0,1600),randf_range(0,1100))
	position = enemy_path.curve.get_closest_point(random_position) + Vector2(0,-100)
	position = Vector2(min(1600,position.x),min(1100,position.y))
	Stage.instance.stage_camera.position = position
	enemy_sprite.play("teleport_finish")
	teleport_effect()
	await get_tree().physics_frame
	await get_tree().physics_frame
	body_collision.disabled = false
	hurt_box.monitorable = true
	waiting_skill_timer.start()
	say_something()
	pass # Replace with function body.


func into_story_mode():
	waiting_skill_timer.stop()
	disappear_timer.stop()
	teleport_timer.stop()
	pass


func skill_1_release():
	var lightning_area: Area2D = preload("res://Scenes/Skills/HatingEmperorStory/hating_emp_skill_1_area.tscn").instantiate()
	if ally_area.has_overlapping_bodies():
		var body = ally_area.get_overlapping_bodies().pick_random()
		var ally: Ally = body.owner
		lightning_area.position = ally.position
	else:
		lightning_area.position = Vector2(randf_range(0,1300),randf_range(0,1300))
		lightning_area.position = Stage.instance.get_closest_enemy_path(lightning_area.position).curve.get_closest_point(lightning_area.position)
	Stage.instance.bullets.add_child(lightning_area)
	pass


func skill_2_release():
	var lightning_area: Area2D = preload("res://Scenes/Skills/HatingEmperorStory/hating_emp_skill_1_area.tscn").instantiate()
	if tower_area.has_overlapping_areas():
		var area = tower_area.get_overlapping_areas().pick_random()
		var tower: DefenceTower = area.owner
		lightning_area.position = tower.position
		tower.destroy_tower()
	else:
		lightning_area.position = Vector2(randf_range(0,1300),randf_range(0,1300))
		lightning_area.position = Stage.instance.get_closest_enemy_path(lightning_area.position).curve.get_closest_point(lightning_area.position)
	Stage.instance.bullets.add_child(lightning_area)
	pass


func skill_3_release():
	for i in 66:
		var lightning_area: Area2D = preload("res://Scenes/Skills/HatingEmperorStory/hating_emp_lightning_area.tscn").instantiate()
		var target_pos: Vector2 = Vector2(randf_range(0,2100),randf_range(0,1300))
		var enemy_path: EnemyPath = Stage.instance.enemies.get_children()[randf_range(0,17)]
		target_pos = enemy_path.curve.get_closest_point(target_pos)
		lightning_area.position = target_pos
		Stage.instance.bullets.add_child(lightning_area)
		await get_tree().create_timer(0.1,false).timeout
	pass


func super_release():
	lightning_particle.show()
	z_index += 1
	Stage.instance.can_control = false
	for area in tower_area.get_overlapping_areas():
		var tower: DefenceTower = area.owner
		tower.destroy_tower()
		var explosion_effect: AnimatedSprite2D = preload("res://Scenes/Effects/bullet_explosion_effect.tscn").instantiate()
		explosion_effect.position = tower.position
		Stage.instance.bullets.add_child(explosion_effect)
		var smoke_effect: AnimatedSprite2D = preload("res://Scenes/Effects/smoke_effect.tscn").instantiate()
		smoke_effect.position = tower.position
		Stage.instance.bullets.add_child(smoke_effect)
		await get_tree().process_frame
	for tower:DefenceTower in Stage.instance.towers.get_children():
		tower.process_mode = Node.PROCESS_MODE_DISABLED
	for body in ally_area.get_overlapping_bodies():
		var ally: Ally = body.owner
		ally.sec_kill(false)
	Stage.instance.stage_camera.position = position
	Stage.instance.stage_camera.zoom = Vector2.ONE
	Stage.instance.stage_camera.zoom_clamp()
	for skill_button: SkillButton in Stage.instance.skill_button_container.get_children():
		skill_button.process_mode = Node.PROCESS_MODE_DISABLED
	
	for i in 30:
		AudioManager.instance.play_explosion_audio()
		lightning_audio.play()
		Stage.instance.stage_camera.shake(10)
		await get_tree().create_timer(0.1,false).timeout
	
	create_tween().tween_property(lightning_particle,"modulate:a",0,0.4)
	enemy_sprite.play()
	
	await get_tree().create_timer(2,false).timeout
	var story_layer: StoryLayer = preload("res://Scenes/Stages/Stage15/stage_15_story_layer_2.tscn").instantiate()
	Stage.instance.add_child(story_layer)
	await get_tree().create_timer(41).timeout
	create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS).tween_property(boss_music_2,"volume_db",-70,2)
	pass


func teleport_effect():
	teleport_audio.play()
	var effect: AnimatedSprite2D = preload("res://Scenes/Effects/bullet_explosion_effect.tscn").instantiate()
	effect.position = hurt_box.global_position
	effect.modulate = Color.PURPLE
	Stage.instance.bullets.add_child(effect)
	pass


func say_something():
	if word_list.is_empty(): return
	await get_tree().create_timer(0.2,false).timeout
	var word: String = word_list.pick_random()
	word_list.erase(word)
	dialog_panel.dialog(word,5)
	pass
