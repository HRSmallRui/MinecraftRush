extends SkillConditionArea2D

@export var move_speed: float = 20

@onready var during_timer: Timer = $DuringTimer
@onready var tornado_sprite: AnimatedSprite2D = $TornadoSprite
@onready var tornado_audio: AudioStreamPlayer = $TornadoAudio


var path_follower: PathFollow2D
var locked_path: EnemyPath
var move_curve: Curve2D

var enemy_list: Array[Enemy]


func _ready() -> void:
	during_timer.wait_time = HeroSkillLibrary.hero_skill_data_library[4][1].moving_time[skill_level-1]
	Stage.instance.on_wining.connect(on_win)
	
	path_follower = get_parent()
	locked_path = path_follower.get_parent()
	move_curve = locked_path.curve
	tornado_sprite.modulate.a = 0
	create_tween().tween_property(tornado_sprite,"modulate:a",1,0.3)
	await get_tree().create_timer(0.3,false).timeout
	monitoring = true
	during_timer.start()
	pass


func _process(delta: float) -> void:
	path_follower.progress = clampf(path_follower.progress - delta * move_speed, 0, move_curve.get_baked_length())
	if path_follower.progress < 0.1:
		end_move()
		during_timer.stop()
	pass


func _on_body_entered(body: Node2D) -> void:
	if enemy_list.size() > 5: return
	var enemy: Enemy = body.owner
	if enemy.enemy_type < Enemy.EnemyType.Super:
		enemy_list.append(enemy)
		for ally in enemy.current_intercepting_units:
			if ally != null:
				ally.current_intercepting_enemy = null
		enemy.current_intercepting_units.clear()
		for buff: BuffClass in enemy.buffs.get_children():
			buff.remove_buff()
		
		enemy.get_parent().remove_child(enemy)
	pass # Replace with function body.


func _on_during_timer_timeout() -> void:
	end_move()
	pass # Replace with function body.


func end_move():
	set_process(false)
	monitoring = false
	for enemy in enemy_list:
		var base_position: Vector2 = path_follower.global_position + Vector2(randf_range(-40,40),randf_range(-40,40))
		var target_enemy_path: EnemyPath = Stage.instance.get_closest_enemy_path(base_position)
		var enemy_progress: float = target_enemy_path.curve.get_closest_offset(base_position)
		enemy.progress = enemy_progress
		target_enemy_path.add_child(enemy)
		var dizness_buff: BuffClass = preload("res://Scenes/Buffs/dizness_buff.tscn").instantiate()
		dizness_buff.buff_tag = "RobortDiznessWind"
		dizness_buff.duration = 1
		enemy.buffs.add_child(dizness_buff)
		enemy.translate_to_new_state(Enemy.EnemyState.MOVE)
		for ally in enemy.current_intercepting_units:
			if ally != null: ally.current_intercepting_enemy = null
		enemy.current_intercepting_units.clear()
		if enemy.interceptable: delay_interceptable(enemy)
	
	var disappear_tween: Tween = create_tween()
	disappear_tween.tween_property(tornado_sprite,"modulate:a",0,0.5)
	await disappear_tween.finished
	queue_free()
	pass


func on_win():
	end_move()
	for enemy in enemy_list:
		enemy.sec_kill(false)
	pass


func delay_interceptable(enemy: Enemy):
	enemy.interceptable = false
	enemy.body_collision.disabled = true
	enemy.hurt_box.monitorable = false
	await get_tree().create_timer(0.1,false).timeout
	enemy.interceptable = true
	enemy.body_collision.disabled = false
	enemy.hurt_box.monitorable = true
	pass
