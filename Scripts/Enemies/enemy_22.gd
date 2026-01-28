extends Enemy

@onready var summon_area_1: Area2D = $SummonArea1
@onready var summon_area_2: Area2D = $SummonArea2
@onready var summon_area_3: Area2D = $SummonArea3
@onready var call_audio: AudioStreamPlayer = $CallAudio
@onready var call_timer: Timer = $CallTimer
@onready var battle_timer: Timer = $BattleTimer
@onready var dirt_timer: Timer = $DirtTimer


func anim_offset():
	
	match enemy_sprite.animation:
		"idle","attack","call":
			enemy_sprite.position = Vector2(0,-35)
		"die","move_normal":
			enemy_sprite.position = Vector2(0,-25)
		"move_back":
			enemy_sprite.position = Vector2(0,-10)
		"move_front":
			enemy_sprite.position = Vector2(0,-20)
		"appear":
			enemy_sprite.position = Vector2(0,-30)
	pass


func frame_changed():
	if enemy_sprite.animation == "attack" and enemy_sprite.frame == 11:
		cause_damage()
	elif enemy_sprite.animation == "call" and enemy_sprite.frame == 18:
		call_partner()
	elif enemy_sprite.animation == "appear" and enemy_sprite.frame == 15:
		if enemy_state != EnemyState.DIE:
			translate_to_new_state(EnemyState.MOVE)
			unit_body.set_collision_layer_value(6,true)
			hurt_box.set_collision_layer_value(6,true)
	#elif enemy_sprite.animation == "appear" and enemy_sprite.frame == 1:
		#call_timer.start()
	pass


func die_blood(blood_packed_scene: PackedScene = null):
	
	pass


func _on_dirt_timer_timeout() -> void:
	if enemy_sprite.animation == "appear":
		var dir_effect: AnimatedSprite2D = preload("res://Scenes/Effects/block_particle.tscn").instantiate()
		dir_effect.modulate = Color(0.3,0.1,0.07)
		dir_effect.scale *= 0.5
		dir_effect.position = position
		dir_effect.z_index += 1
		Stage.instance.bullets.add_child(dir_effect)
	pass # Replace with function body.


func translate_to_new_state(new_state: EnemyState):
	super(new_state)
	if new_state == EnemyState.BATTLE:
		battle_timer.start()
	pass


func battle():
	if enemy_sprite.animation == "idle" and call_timer.is_stopped() and battle_timer.is_stopped() and silence_layers <= 0:
		enemy_sprite.play("call")
		call_timer.start()
		call_audio.play()
		return
	super()
	pass


func call_partner():
	if summon_area_1.has_overlapping_areas():
		var target_enemy_path: EnemyPath = Stage.instance.get_closest_enemy_path(summon_area_1.global_position)
		var target_progress: float = target_enemy_path.curve.get_closest_offset(summon_area_1.global_position)
		try_to_call_partner(target_enemy_path,target_progress)
	
	if summon_area_2.has_overlapping_areas() and randf_range(0,1) < 0.5:
		var target_enemy_path: EnemyPath = Stage.instance.get_closest_enemy_path(summon_area_2.global_position)
		var target_progress: float = target_enemy_path.curve.get_closest_offset(summon_area_2.global_position)
		try_to_call_partner(target_enemy_path,target_progress)
	
	if summon_area_3.has_overlapping_areas() and randf_range(0,1) < 0.5:
		var target_enemy_path: EnemyPath = Stage.instance.get_closest_enemy_path(summon_area_3.global_position)
		var target_progress: float = target_enemy_path.curve.get_closest_offset(summon_area_3.global_position)
		try_to_call_partner(target_enemy_path,target_progress)
	pass


func try_to_call_partner(enemy_path: EnemyPath, partner_progress: float):
	var partner: Enemy = preload("res://Scenes/Enemies/enemy_22.tscn").instantiate()
	partner.bounty = 0
	partner.progress = partner_progress
	enemy_path.add_child(partner)
	partner.translate_to_new_state(EnemyState.SPECIAL)
	partner.enemy_sprite.play("appear")
	partner.enemy_sprite.flip_h = enemy_sprite.flip_h
	partner.unit_body.set_collision_layer_value(6,false)
	partner.hurt_box.set_collision_layer_value(6,false)
	pass
