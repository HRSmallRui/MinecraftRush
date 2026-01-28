##敌人类
extends PathFollow2D
class_name Enemy

enum EnemyType{
	Small,
	Medium,
	Big,
	Super,
	MiniBoss,
	Boss
}

enum EnemyState{
	MOVE,
	BATTLE,
	SPECIAL,
	DIE
}

@export var enemy_name: String
@export var enemy_id: int
@export var enemy_texture: Texture
@export var enemy_type: EnemyType
@export var is_flying: bool
@export var is_final_boss: bool
@export var start_data: UnitData
@export var far_attack_bullet_scene: PackedScene
@export var interceptable: bool = true
@export var lives_taken: int = 1
@export var bounty: int
@export var show_tip: bool = true
@export var die_audio_stream_list: Array[AudioStream]

@onready var select_sprite: Sprite2D = $UnitBody/SelectSprite
@onready var enemy_button: Button = $UnitBody/EnemyButton
@onready var enemy_sprite: AnimatedSprite2D = $UnitBody/EnemySprite
@onready var unit_body: UnitBody = $UnitBody
@onready var direction_sprite: Sprite2D = $DirectionSprite
@onready var hurt_box: HurtBox = $UnitBody/HurtBox
@onready var health_bar: TextureProgressBar = $UnitBody/HealthBar
@onready var intercepting_marker: Marker2D = $UnitBody/InterceptingMarker
@onready var normal_attack_timer: Timer = $NormalAttackTimer
@onready var buffs: Node2D = $UnitBody/Buffs
@onready var die_audio: AudioStreamPlayer = $DieAudio
@onready var far_attack_area: Area2D = $UnitBody/FarAttackArea
@onready var far_attack_timer: Timer = $FarAttackTimer
@onready var far_attack_marker: Marker2D = $UnitBody/FarAttackMarker
@onready var far_attack_marker_flip: Marker2D = $UnitBody/FarAttackMarkerFlip
@onready var body_collision: CollisionShape2D = $UnitBody/BodyCollision

var current_data: UnitData
var enemy_state: EnemyState = EnemyState.MOVE
var direction:Vector2
var battle_length: float
var current_intercepting_units: Array[Ally]
var far_attack_position: Vector2
var enemy_buff_tags: Dictionary
var silence_layers: int = 0
var is_disappear_killing: bool = false


func _init() -> void:
	hide()
	pass


func _enter_tree() -> void:
	if Stage.instance.ui_update.is_connected(Callable(self,"ui_process")): return
	Stage.instance.ui_update.connect(ui_process)
	match Stage.instance.stage_sav.difficulty:
		0: 
			var new_data = start_data.duplicate() as UnitData
			new_data.health *= 0.8
			start_data = new_data
		2: 
			var new_data = start_data.duplicate() as UnitData
			new_data.health *= 1.2
			start_data = new_data
		1:
			var new_data = start_data.duplicate() as UnitData
			start_data = new_data
	current_data = start_data.duplicate()
	current_data.owner = self
	current_data.start_data = start_data
	pass


func _ready() -> void:
	#Stage.instance.enemy_count += 1
	
	update_health_bar()
	select_sprite.hide()
	unlock_condition()
	enemy_button.modulate.a = 0
	enemy_sprite.position = Vector2.ZERO
	enemy_sprite.animation_finished.connect(anim_finished)
	enemy_sprite.frame_changed.connect(frame_changed)
	enemy_sprite.animation_changed.connect(anim_changed)
	current_data.die.connect(die)
	unit_body.position = Vector2.ZERO
	unit_body.global_rotation = 0
	await get_tree().process_frame
	ui_process(Stage.instance.information_bar.current_check_member)
	show()
	battle_length = intercepting_marker.position.x
	normal_attack_timer.wait_time = current_data.near_attack_speed
	if current_data.far_attack_speed > 0:
		far_attack_timer.wait_time = current_data.far_attack_speed
	far_attack_area.scale = Vector2.ONE * float(current_data.far_damage_range)/100
	
	if enemy_type == EnemyType.Boss:
		boss_music_play()
	pass


func unlock_condition():
	if enemy_id < 0: return
	var unlocked_list = Stage.instance.stage_sav.enemy_unlock_sav as Dictionary
	if unlocked_list.has(enemy_id):
		if !unlocked_list[enemy_id]: tip_show()
	else: tip_show()
	pass


func tip_show():
	Stage.instance.stage_sav.enemy_unlock_sav[enemy_id] = true
	Global.sav_game_sav(Stage.instance.stage_sav)
	if show_tip:
		await get_tree().process_frame
		var tip_button = preload("res://Scenes/UI-Components/enemy_tip_button.tscn").instantiate() as TipButton
		tip_button.id = enemy_id
		Stage.instance.tips_container.add_child(tip_button)
	pass


func _on_enemy_button_pressed() -> void:
	Stage.instance.ui_process(self,Stage.StageUI.Check)
	MobileMiddleProcess.instance.current_touch_object = self
	pass # Replace with function body.


func ui_process(member: Node):
	select_sprite.visible = member == self
	if Stage.instance.stage_ui == Stage.StageUI.None or Stage.instance.stage_ui == Stage.StageUI.Check:
		enemy_button.mouse_filter = Control.MOUSE_FILTER_STOP
	else:
		enemy_button.mouse_filter = Control.MOUSE_FILTER_IGNORE
	pass


func _process(delta: float) -> void:
	anim_offset()
	unit_body.global_rotation = 0
	update_health_bar()
	direction = direction_sprite.global_position - self.global_position
	match enemy_state:
		EnemyState.MOVE:
			move_process(delta)
		EnemyState.BATTLE:
			battle_process()
		EnemyState.SPECIAL:
			special_process()
	intercepting_marker.position.x = -battle_length if enemy_sprite.flip_h else battle_length
	anim_offset()
	pass


func update_health_bar():
	health_bar.value = float(current_data.health) / float(start_data.health)
	health_bar.visible = current_data.health < start_data.health and enemy_state != EnemyState.DIE
	pass


func anim_offset():
	
	pass


func move_process(delta:float):
	progress += delta * current_data.unit_move_speed * UnitData.speed_unit
	if progress_ratio >= 0.999:
		if Stage.instance.information_bar.current_check_member == self: Stage.instance.ui_process(null)
		Stage.instance.lives_taken(lives_taken)
		Stage.instance.current_money += bounty
		queue_free()
		Stage.instance.enemy_die()
	enemy_sprite.flip_h = direction.x < 0
	if direction.y < -7:
		enemy_sprite.play("move_back")
	elif direction.y > 7:
		enemy_sprite.play("move_front")
	else:
		enemy_sprite.play("move_normal")
	pass


func move_speed_update():
	
	pass


func battle_process():
	var ally_list: Array[Ally] = current_intercepting_units.duplicate()
	for ally in current_intercepting_units:
		if ally.ally_state == Ally.AllyState.DIE: ally_list.erase(ally)
	current_intercepting_units = ally_list
	
	if current_intercepting_units.size() > 0:
		if current_intercepting_units[0].ally_state != Ally.AllyState.BATTLE and current_intercepting_units[0].ally_state != Ally.AllyState.SPECIAL: 
			return
	elif enemy_sprite.animation == "idle":
		update_state()
		return
	if current_intercepting_units.size() > 0:
		battle()
	pass


func battle():
	if normal_attack_timer.is_stopped() and enemy_sprite.animation == "idle":
		enemy_sprite.play("attack")
		normal_attack_timer.start()
	pass


func special_process():
	current_data.unit_move_speed = 0
	#if enemy_sprite.animation == "idle" and current_intercepting_units.is_empty():
		#translate_to_new_state(EnemyState.MOVE)
	pass


func translate_to_new_state(new_state: EnemyState):
	match new_state:
		EnemyState.MOVE:
			current_data.update_move_speed()
			pass
		EnemyState.BATTLE:
			current_data.unit_move_speed = 0
			#enemy_sprite.play("idle")
		EnemyState.SPECIAL:
			current_data.unit_move_speed = 0
			pass
		EnemyState.DIE:
			achievement_enemy_die()
			unit_body.set_collision_layer_value(6,false)
			unit_body.set_collision_layer_value(7,false)
			unit_body.set_collision_layer_value(9,true)
			hurt_box.set_collision_layer_value(6,false)
			hurt_box.set_collision_layer_value(7,false)
			hurt_box.set_collision_layer_value(9,true)
			enemy_button.mouse_filter = Control.MOUSE_FILTER_IGNORE
			if Stage.instance.information_bar.current_check_member == self: Stage.instance.ui_process(null)
			for ally in current_intercepting_units:
				ally.current_intercepting_enemy = null
			current_intercepting_units.clear()
	enemy_state = new_state
	pass


func update_state():
	if enemy_state == EnemyState.DIE: return
	
	if enemy_state == EnemyState.MOVE and current_intercepting_units.size() > 0:
		translate_to_new_state(EnemyState.BATTLE)
		enemy_sprite.play("idle")
	elif current_intercepting_units.size() == 0:
		translate_to_new_state(EnemyState.MOVE)
	pass


func anim_finished():
	if enemy_state != EnemyState.DIE:
		enemy_sprite.play("idle")
	pass


func anim_changed():
	anim_offset()
	pass


func frame_changed():
	
	pass


func die(explosion: bool = false):
	enemy_button.hide()
	Achievement.achieve_int_add("FirstBlood",1,1)
	translate_to_new_state(EnemyState.DIE)
	clear_buff()
	delay_free()
	Stage.instance.current_money += bounty
	Stage.instance.enemy_die()
	current_data.unit_move_speed = 0
	die_blood()
	if enemy_type == EnemyType.Boss:
		boss_die_time()
	if is_final_boss:
		Stage.instance.final_boss_die()
	
	if explosion:
		enemy_sprite.pause()
		hide()
		die_explosion_process()
	else:
		enemy_sprite.play("die")
		die_audio_play()
		if enemy_type < EnemyType.Boss:
			await get_tree().create_timer(4,false).timeout
			hide()
	pass


func achievement_enemy_die():
	Achievement.achieve_int_add("Bloody",1,800)
	Achievement.achieve_int_add("Killer",1,2000)
	Achievement.achieve_int_add("DeathKill",1,20000)
	var stage_count: int = Stage.instance.stage_count
	if stage_count < 5 or (stage_count > 17 and stage_count < 21):
		Achievement.achieve_int_add("RoyalDefender",1,2500)
	if stage_count >= 5 and stage_count <= 11:
		Achievement.achieve_int_add("WildRegionCleaner",1,2000)
	pass


func die_explosion_process():
	var dead_explosion = preload("res://Scenes/Effects/dead_body_explosion.tscn").instantiate() as AnimatedSprite2D
	dead_explosion.position = position
	AudioManager.instance.explosion_dead_body_audio_play()
	get_parent().add_child(dead_explosion)
	pass


func delay_free():
	if enemy_type == EnemyType.Boss: return
	await get_tree().create_timer(8,false).timeout
	queue_free()
	pass


func die_audio_play():
	if die_audio_stream_list.size() > 0:
		die_audio.stream = die_audio_stream_list[randf_range(0,die_audio_stream_list.size()-1)]
		if die_audio.stream in AudioManager.instance.registor_oneshot_audio_list:
			return
		else:
			AudioManager.instance.oneshot_audio_registor(die_audio.stream)
		die_audio.play()
	pass


func cause_damage(damage_type: int = 0):
	match damage_type:
		0:
			if current_intercepting_units.size() > 0:
				var target_ally: Ally = current_intercepting_units[0]
				var damage = randi_range(current_data.near_damage_low,current_data.near_damage_high)
				if target_ally.take_damage(damage,DataProcess.DamageType.PhysicsDamage,0,false,self,false,false):
					if target_ally.ally_state != Ally.AllyState.DIE:
						on_normal_attack_hit(target_ally)
	pass


func on_normal_attack_hit(target_ally: Ally):
	
	pass


func take_damage(damage: int, damage_type: DataProcess.DamageType, broken_rate: float, far_attack: bool = false, source: Node2D = null,explosion: bool = false,aoe_attack: bool = false, deadly: bool = true) -> bool:
	if source is Ally and !far_attack and !aoe_attack:
		var data: UnitData = source.current_data
		var hit_possible: float = data.near_hit_rate - current_data.dodge_rate
		if randf_range(0,1) > hit_possible:
			dodge()
			return false
	current_data.take_damage(damage,damage_type,broken_rate,far_attack,source,explosion, deadly)
	return true
	pass


func hurt_audio_play(damage_source: String):
	match damage_source:
		"Arrow","MagicBall":
			match randi_range(1,2):
				1: AudioManager.instance.arrow_hit_1.play()
				2: AudioManager.instance.arrow_hit_2.play()
	pass


func die_blood(blood_packed_scene: PackedScene = preload("res://Scenes/Effects/blood.tscn")):
	var blood = blood_packed_scene.instantiate() as Sprite2D
	blood.position = position
	Stage.instance.bullets.add_child(blood)
	pass


func sec_kill(explosion: bool):
	if enemy_type == EnemyType.Boss: return
	#print("sec_kill")
	if enemy_type > EnemyType.Super: return
	if enemy_type > EnemyType.Medium: die(false)
	else: die(explosion)
	pass


func clear_buff():
	for buff: BuffClass in buffs.get_children():
		buff.remove_buff()
	pass


func enemy_hide():
	unit_body.set_collision_layer_value(6,false)
	unit_body.set_collision_layer_value(7,false)
	unit_body.set_collision_layer_value(9,true)
	pass


func enemy_show():
	unit_body.set_collision_layer_value(9,false)
	if is_flying:
		unit_body.set_collision_layer_value(7,true)
	else:
		unit_body.set_collision_layer_value(6,true)
	pass


func dodge():
	TextEffect.text_effect_show("闪避",TextEffect.TextEffectType.Magic,hurt_box.global_position)
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


func boss_music_play():
	await get_tree().create_timer(1,false).timeout
	Stage.instance.preparation_music.stop()
	Stage.instance.battle_music.stop()
	Stage.instance.boss_music.play()
	pass


func boss_die_time():
	Stage.instance.stage_camera.position = self.position
	Stage.instance.stage_camera.shake(10)
	#create_tween().tween_property(Stage.instance.stage_camera,"zoom",Vector2.ONE * 2,0.3)
	Engine.time_scale = 0.1
	await get_tree().create_timer(3,false,false,true).timeout
	create_tween().tween_property(Engine,"time_scale",1,0.6)
	pass


func disappear_kill():
	for buff: BuffClass in buffs.get_children():
		buff.process_mode = Node.PROCESS_MODE_DISABLED
	if enemy_type == EnemyType.Boss: return
	translate_to_new_state(EnemyState.DIE)
	hide()
	is_disappear_killing = true
	Stage.instance.current_money += bounty
	Stage.instance.enemy_die()
	clear_buff()
	enemy_sprite.pause()
	delay_free()
	pass


func add_new_buff_tag(tag_name: String, tag_level: int = 1):
	
	pass


func normal_far_attack_frame():
	var summon_pos: Vector2 = far_attack_marker_flip.global_position if enemy_sprite.flip_h else far_attack_marker.global_position
	var damage: int = randi_range(current_data.far_damage_low,current_data.far_damage_high)
	var bullet: Bullet = summon_bullet(far_attack_bullet_scene,summon_pos,far_attack_position,damage,DataProcess.DamageType.PhysicsDamage)
	Stage.instance.bullets.add_child(bullet)
	AudioManager.instance.shoot_audio_1.play()
	pass
