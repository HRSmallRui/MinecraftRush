extends Ally
class_name Hero

@export var hero_level: int = 1
@export var hero_exp: int
var exp_rate: float
@export var skill_levels: Array[int] = [0,0,0,0,0] ##0:被动,1-4：非主动技能等级
@export var heal_speeds: Array[int] = [
	0,0,0,0,0,0,0,0,0,0
]
@export var teleport_limit_length: float
@export var hero_property_block: HeroPropertyBlock
@export var skill1_exp_get: Array[int] = [0,0,0]
@export var skill2_exp_get: Array[int] = [0,0,0]
@export var skill3_exp_get: Array[int] = [0,0,0]
@export var skill4_exp_get: Array[int] = [0,0,0]

@onready var navigation_timer: Timer = $NavigationComponent/NavigationTimer
@onready var navigation_agent: NavigationAgent2D = $NavigationComponent/NavigationAgent2D

static var hero_level_xps = [1300,2500,5800,13100,19600,29400,44100,66100,90000]

var teleport_target_position: Vector2
var when_moving_mouse_in_path: bool


func _enter_tree() -> void:
	if Stage.instance.ui_update.is_connected(Callable(self,"ui_process")): return
	start_data_process()
	super()
	heal_speed = heal_speeds[hero_level-1]
	exp_rate = hero_property_block.xp_speed_rate
	pass


func _ready() -> void:
	Stage.instance.tree_exiting.connect(save_hero_sav)
	super()
	ally_sprite.play("rebirth")
	AudioManager.instance.level_up_audio.play(0.2)
	pass


func _on_ally_button_pressed():
	await get_tree().process_frame
	Stage.instance.ui_process(self,Stage.StageUI.Move)
	pass


func try_to_move(target_pos: Vector2):
	if is_fly:
		move(target_pos)
		Stage.instance.move_point_effect(target_pos)
		Stage.instance.ui_process(null)
	elif when_moving_mouse_in_path:
		navigation_agent.target_position = target_pos
		if navigation_agent.is_target_reachable():
			var path_array: PackedVector2Array = navigation_agent.get_current_navigation_path()
			var length: float = 0.0
			for i in path_array.size()-1:
				length += (path_array[i+1] - path_array[i]).length()
			print(length)
			if teleport_limit_length > 0:
				if length > teleport_limit_length:
					teleport_move(target_pos)
			else:
				navigation_move()
				Stage.instance.ui_process(null)
		else:
			if teleport_limit_length > 0:
				teleport_move(target_pos)
			else:
				Stage.instance.stop_effect()
	pass


func teleport_move(target_pos: Vector2):
	if ally_state == AllyState.SPECIAL:
		waiting_to_move = true
		next_move_position = navigation_agent.target_position
		return
	if current_intercepting_enemy != null:
		current_intercepting_enemy.current_intercepting_units.erase(self)
		current_intercepting_enemy = null
	ally_sprite.flip_h = target_pos.x < position.x
	ally_sprite.play("teleport")
	translate_to_new_state(AllyState.SPECIAL)
	change_collision_layer(true)
	teleport_target_position = target_pos
	navigation_agent.target_position = position
	navigation_timer.stop()
	if move_tween != null: move_tween.kill()
	Stage.instance.move_point_effect(target_pos)
	pass


func teleport_finished():
	if move_tween != null: move_tween.kill()
	position = teleport_target_position
	station_position = teleport_target_position
	intercepting_area.position = station_position
	pass


func move(target_pos:Vector2):
	if is_fly:
		super(target_pos)
		Stage.instance.move_point_effect(target_pos)
		Stage.instance.ui_process(null)
	elif when_moving_mouse_in_path:
		navigation_agent.target_position = target_pos
		if navigation_agent.is_target_reachable():
			var path_array: PackedVector2Array = navigation_agent.get_current_navigation_path()
			var length: float = 0.0
			for i in path_array.size()-1:
				length += (path_array[i+1] - path_array[i]).length()
			if teleport_limit_length > 0:
				if length > teleport_limit_length:
					teleport_move(target_pos)
					Stage.instance.ui_process(null)
				else:
					navigation_move()
					Stage.instance.ui_process(null)
			else:
				navigation_move()
				Stage.instance.ui_process(null)
		else:
			if teleport_limit_length > 0:
				teleport_move(target_pos)
				Stage.instance.ui_process(null)
			else:
				Stage.instance.stop_effect()
	pass


func navigation_move():
	if ally_state == AllyState.SPECIAL:
		waiting_to_move = true
		next_move_position = navigation_agent.target_position
		return
	station_position = navigation_agent.target_position
	navigation_timer.start()
	enemy_list.clear()
	if current_intercepting_enemy != null: current_intercepting_enemy.current_intercepting_units.erase(self)
	current_intercepting_enemy = null
	translate_to_new_state(AllyState.MOVE)
	Stage.instance.move_point_effect(navigation_agent.target_position)
	#station_position = navigation_agent.target_position
	pass


func rebirth():
	current_data.health = start_data.health
	ally_sprite.play("rebirth")
	AudioManager.instance.level_up_audio.play(0.2)
	await ally_sprite.animation_finished
	super()
	pass


func start_data_process():
	var sav_block: HeroSavBlock = Stage.instance.stage_sav.hero_sav[ally_id]
	hero_level = sav_block.hero_level
	hero_exp = sav_block.hero_exp
	for i in sav_block.skill_levels.size()-1:
		skill_levels[i+1] = sav_block.skill_levels[i]
	ally_group = hero_property_block.hero_type
	start_data = UnitData.new()
	start_data.health = hero_property_block.max_healths[hero_level-1]
	start_data.unit_move_speed = hero_property_block.move_speed
	start_data.near_attack_speed = hero_property_block.damage_near_speed
	start_data.near_damage_low = hero_property_block.damage_nears[hero_level-1].damage_low
	start_data.near_damage_high = hero_property_block.damage_nears[hero_level-1].damage_high
	start_data.far_attack_speed = hero_property_block.damage_far_speed
	start_data.far_damage_low = hero_property_block.damage_fars[hero_level-1].damage_low
	start_data.far_damage_high = hero_property_block.damage_fars[hero_level-1].damage_high
	start_data.far_damage_range = hero_property_block.damage_far_range
	start_data.armor = hero_property_block.armors[hero_level-1]
	start_data.magic_defence = hero_property_block.magic_defences[hero_level-1]
	pass


func die(explosion: bool):
	if ally_state == AllyState.MOVE:
		navigation_agent.target_position = position
		navigation_timer.stop()
		station_position = position
		move_tween.kill()
	super(explosion)
	pass


func _on_navigation_timer_timeout() -> void:
	if ally_state == AllyState.SPECIAL or ally_state == AllyState.DIE: return
	
	move_animation(navigation_agent.get_next_path_position())
	if navigation_agent.is_target_reached(): 
		navigation_timer.stop()
		translate_to_new_state(AllyState.IDLE)
	pass # Replace with function body.


func get_exp(xp_point: int):
	if hero_level == 10: return
	hero_exp += xp_point
	if hero_exp >= Hero.hero_level_xps[hero_level-1]:
		level_up()
	pass


func level_up():
	translate_to_new_state(AllyState.SPECIAL)
	ally_sprite.play("rebirth")
	AudioManager.instance.level_up_audio.play(0.2)
	hero_level += 1
	hero_exp = 0
	var sav_block: HeroSavBlock = Stage.instance.stage_sav.hero_sav[ally_id]
	sav_block.hero_level = hero_level
	sav_block.hero_exp = hero_exp
	sav_block.current_skill_point += 4
	Global.sav_game_sav(Stage.instance.stage_sav)
	start_data_process()
	current_data.ready_data(start_data)
	pass


func cause_damage(damage_type: int = 0):
	if current_intercepting_enemy == null: return
	match damage_type:
		0:
			var target_enemy: Enemy = current_intercepting_enemy
			var damage: int = randi_range(current_data.near_damage_low,current_data.near_damage_high)
			if current_intercepting_enemy.take_damage(damage,DataProcess.DamageType.PhysicsDamage,0,false,self):
				get_exp(int(float(damage) * exp_rate))
				if target_enemy.enemy_state != Enemy.EnemyState.DIE:
					on_normal_attack_hit(target_enemy)
				if randf_range(0,1) < 0.1:
					var text:String
					match randi_range(1,6):
						1: text = "铮！"
						2: text = "锵！"
						3: text = "唰！"
						4: text = "剁！"
						5: text = "铛！"
						6: text = "哐！"
					var show_pos: Vector2 = hurt_box.global_position - Vector2(0,10)
					show_pos += Vector2(-20,0) if ally_sprite.flip_h else Vector2(20,0)
					TextEffect.text_effect_show(text,TextEffect.TextEffectType.Barrack,show_pos)
				AudioManager.instance.battle_audio_play()
	pass


func save_hero_sav():
	var sav_block: HeroSavBlock = Stage.instance.stage_sav.hero_sav[ally_id]
	sav_block.hero_level = hero_level
	sav_block.hero_exp = hero_exp
	Global.sav_game_sav(Stage.instance.stage_sav)
	pass


func move_back():
	super()
	pass


func ui_process(member: Node):
	super(member)
	pass


func far_attack_frame(damage_type: DataProcess.DamageType = DataProcess.DamageType.PhysicsDamage):
	if far_attack_target_enemy == null: return
	var summon_pos:Vector2 = far_attack_marker_flip.global_position if ally_sprite.flip_h else far_attack_marker.global_position
	var target_pos: Vector2 = far_attack_target_enemy.hurt_box.global_position
	target_pos += far_attack_target_enemy.direction * far_attack_target_enemy.current_data.unit_move_speed * 2
	var damage: int = randi_range(current_data.far_damage_low,current_data.far_damage_high)
	var bullet: Bullet = summon_bullet(far_attack_bullet_scene,summon_pos,target_pos,damage,damage_type)
	Stage.instance.bullets.add_child(bullet)
	get_exp(int(float(damage) * exp_rate))
	pass
