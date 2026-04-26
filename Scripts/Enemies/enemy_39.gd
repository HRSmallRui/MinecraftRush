extends Enemy

const MIDDLE_SLIME_SCENE:PackedScene = preload("res://Scenes/Enemies/SlimeChild/middle_slime.tscn")

@export var attack_audio_list: Array[AudioStream]
@export var summon_area_list: Array[Area2D]

@onready var attack_audio: AudioStreamPlayer = $AttackAudio


func anim_offset():
	match enemy_sprite.animation:
		"attack","die","idle":
			enemy_sprite.position = Vector2(0,-105)
		"move_back","move_front","move_normal":
			enemy_sprite.position = Vector2(0,-335)
	pass


func frame_changed():
	if "move" in enemy_sprite.animation and enemy_sprite.frame == 27:
		die_audio_play()
	if enemy_sprite.animation == "attack" and enemy_sprite.frame == 1:
		cause_damage()
		attack_audio.stream = attack_audio_list.pick_random()
		attack_audio.play()
	if enemy_sprite.animation == "die" and enemy_sprite.frame == 6:
		var smoke_effect:AnimatedSprite2D = preload("res://Scenes/Effects/bullet_explosion_effect.tscn").instantiate()
		smoke_effect.position = position
		Stage.instance.bullets.add_child(smoke_effect)
		
		if Stage.instance.is_win: return
		
		summon_area_list = summon_area_list.duplicate()
		summon_area_list.shuffle()
		var loop_count: int = randi_range(2,4)
		for i in loop_count:
			var current_area: Area2D = summon_area_list[i]
			if !current_area.has_overlapping_areas(): continue
			var target_path: EnemyPath = Stage.instance.get_closest_enemy_path(current_area.global_position)
			var target_position: Vector2 = target_path.curve.get_closest_point(current_area.global_position)
			summon_middle_slime(target_position,target_path)
	pass


func summon_middle_slime(target_position: Vector2, target_enemy_path: EnemyPath):
	var middle_slime: Enemy = MIDDLE_SLIME_SCENE.instantiate()
	middle_slime.progress = target_enemy_path.curve.get_closest_offset(target_position)
	middle_slime.interceptable = false
	middle_slime.bounty = 0
	
	target_enemy_path.add_child(middle_slime)
	middle_slime.translate_to_new_state(EnemyState.SPECIAL)
	middle_slime.position = position
	middle_slime.unit_body.set_collision_layer_value(6,false)
	middle_slime.hurt_box.set_collision_layer_value(6,false)
	middle_slime.enemy_sprite.flip_h = target_position.x < middle_slime.position.x
	middle_slime.enemy_sprite.play("move_normal")
	var move_tween: Tween = create_tween()
	move_tween.tween_property(middle_slime,"position",target_position,0.4)
	await move_tween.finished
	middle_slime.unit_body.set_collision_layer_value(6,true)
	middle_slime.hurt_box.set_collision_layer_value(6,true)
	middle_slime.translate_to_new_state(EnemyState.MOVE)
	middle_slime.interceptable = true
	pass


func die_blood(blood_packed_scene: PackedScene = null):
	
	pass
