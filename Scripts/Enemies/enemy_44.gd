extends Enemy

const LAND_ANIMATION = preload("res://Assets/Animations/Enemies/44守卫者/SpriteFrames/land.res")
const WATER_ANIMATION = preload("res://Assets/Animations/Enemies/44守卫者/SpriteFrames/water.res")

@export var die_audio_water: AudioStream
@export var die_audio_land: AudioStream
@export var jump_audio_list: Array[AudioStream]
@export var end_point_sprite_gradient: GradientTexture2D
@export var end_point_particle_gradient: GradientTexture2D
@export var step_1_color: Color
@export var step_2_color: Color
@export_range(0,1,0.1) var mix_power: float

@onready var water_condition_area: Area2D = $UnitBody/WaterConditionArea
@onready var jump_audio: AudioStreamPlayer = $JumpAudio
@onready var attack_area: Area2D = $UnitBody/AttackArea
@onready var attack_audio: AudioStreamPlayer = $AttackAudio
@onready var far_attack_marker_flip_water: Marker2D = $UnitBody/FarAttackMarkerFlipWater
@onready var far_attack_marker_water: Marker2D = $UnitBody/FarAttackMarkerWater
@onready var water_marker: Marker2D = $WaterMarker
@onready var water_timer: Timer = $WaterTimer
@onready var ray: Line2D = $Ray
@onready var end_point_particle: GPUParticles2D = $EndPointParticle
@onready var start_point_particle: GPUParticles2D = $StartPointParticle
@onready var far_attack_hit_area: Area2D = $FarAttackHitArea
@onready var ray_animation_player: AnimationPlayer = $RayAnimationPlayer
@onready var ray_audio: AudioStreamPlayer = $RayAudio

var first_in_water: bool = true


func _ready() -> void:
	if Stage.instance.is_special_wave:
		bounty = 20
	ray.hide()
	end_point_particle.hide()
	start_point_particle.hide()
	super()
	water_timer.timeout.connect(_on_water_timer_timeout)
	water_timer.start()
	enemy_sprite.sprite_frames = LAND_ANIMATION
	die_audio_stream_list[0] = die_audio_land
	water_condition_area.area_entered.connect(in_water)
	water_condition_area.area_exited.connect(leave_water)
	await get_tree().create_timer(0.1,false).timeout
	first_in_water = false
	pass


func anim_offset():
	match enemy_sprite.sprite_frames:
		LAND_ANIMATION:
			match enemy_sprite.animation:
				"attack","idle":
					enemy_sprite.position = Vector2(-40,-120) if enemy_sprite.flip_h else Vector2(40,-120)
				"die":
					enemy_sprite.position = Vector2(-40,-155) if enemy_sprite.flip_h else Vector2(40,-155)
				"far_attack":
					enemy_sprite.position = Vector2(-30,-130) if enemy_sprite.flip_h else Vector2(30,-130)
				"move_back":
					enemy_sprite.position = Vector2(0,-100)
				"move_front":
					enemy_sprite.position = Vector2(0,-130)
				"move_normal":
					enemy_sprite.position = Vector2(-5,-130) if enemy_sprite.flip_h else Vector2(5,-130)
		WATER_ANIMATION:
			match enemy_sprite.animation:
				"die":
					enemy_sprite.position = Vector2(-10,-85) if enemy_sprite.flip_h else Vector2(0,-85)
				"far_attack":
					enemy_sprite.position = Vector2(-15,-125) if enemy_sprite.flip_h else Vector2(5,-125)
				"idle","move_normal":
					enemy_sprite.position = Vector2(15,-75) if enemy_sprite.flip_h else Vector2(-10,-75)
				"move_back","move_front":
					enemy_sprite.position = Vector2(5,-85) if enemy_sprite.flip_h else Vector2(-5,-85)
	pass


func frame_changed():
	if "move" in enemy_sprite.animation and enemy_sprite.frame == 14 and enemy_sprite.sprite_frames == LAND_ANIMATION:
		jump_audio.stream = jump_audio_list.pick_random()
		jump_audio.play()
	if enemy_sprite.animation == "attack" and enemy_sprite.frame == 12:
		attack_audio.play()
		for body in attack_area.get_overlapping_bodies():
			var ally: Ally = body.owner
			var damage: int = randi_range(current_data.near_damage_low,current_data.near_damage_high)
			ally.take_damage(damage,DataProcess.DamageType.PhysicsDamage,0.4,false,self,false,true,)
	if enemy_sprite.animation == "far_attack" and enemy_sprite.frame == 18:
		shoot_ray()
		ray_audio.play()
	pass


@warning_ignore("unused_parameter")
func in_water(area: Area2D):
	#print("in_water")
	if enemy_state == EnemyState.DIE: return
	if !interceptable: return
	interceptable = false
	add_to_group("special")
	enemy_sprite.sprite_frames = WATER_ANIMATION
	die_audio_stream_list[0] = die_audio_water
	start_data.unit_move_speed = 1.5
	current_data.update_move_speed()
	water_animation()
	pass



@warning_ignore("unused_parameter")
func leave_water(area: Area2D):
	if enemy_state == EnemyState.DIE: return
	if interceptable: return
	interceptable = true
	remove_from_group("special")
	enemy_sprite.sprite_frames = LAND_ANIMATION
	die_audio_stream_list[0] = die_audio_land
	start_data.unit_move_speed = 0.7
	current_data.update_move_speed()
	water_animation()
	pass


func water_animation():
	if first_in_water: return
	AudioManager.instance.play_water_audio()
	var water_particle: AnimatedSprite2D = preload("res://Scenes/Effects/block_particle.tscn").instantiate()
	water_particle.position = position
	water_particle.modulate = Color(0,0.8,1,0.6)
	Stage.instance.bullets.add_child(water_particle)
	AudioManager.instance.play_water_audio()
	pass


func die_blood(blood_packed_scene: PackedScene = preload("res://Scenes/Effects/blood.tscn")):
	if enemy_sprite.sprite_frames == WATER_ANIMATION: return
	var blood = blood_packed_scene.instantiate() as Sprite2D
	blood.position = position
	blood.scale *= 2
	Stage.instance.bullets.add_child(blood)
	pass


func _on_water_timer_timeout() -> void:
	if enemy_sprite.sprite_frames == LAND_ANIMATION: return
	if enemy_state != EnemyState.MOVE: return
	var water_effect: Sprite2D = preload("res://Scenes/Effects/water_move_effect.tscn").instantiate()
	water_effect.position = water_marker.global_position
	Stage.instance.bullets.add_child(water_effect)
	pass # Replace with function body.


func _process(delta: float) -> void:
	super(delta)
	ray.set_point_position(1,far_attack_position)
	var shader: ShaderMaterial = ray.material
	shader.set_shader_parameter("mix_power",mix_power)
	pass


func shoot_ray():
	var start_position: Vector2
	if enemy_sprite.sprite_frames == LAND_ANIMATION:
		start_position = far_attack_marker_flip.global_position if enemy_sprite.flip_h else far_attack_marker.global_position
	elif enemy_sprite.sprite_frames == WATER_ANIMATION:
		start_position = far_attack_marker_flip_water.global_position if enemy_sprite.flip_h else far_attack_marker_water.global_position
	ray.set_point_position(0,start_position)
	#end_point_particle_gradient.gradient.colors[1] = step_1_color
	#end_point_sprite_gradient.gradient.colors[1] = step_1_color
	start_point_particle.global_position = start_position
	end_point_particle.global_position = far_attack_position
	ray.show()
	start_point_particle.show()
	end_point_particle.show()
	far_attack_hit_area.global_position = far_attack_position
	ray.width = 0
	ray_animation_player.play("anim")
	await ray_animation_player.animation_finished
	for area in far_attack_hit_area.get_overlapping_areas():
		var ally: Ally = area.owner
		ally.take_damage(randi_range(current_data.far_damage_low,current_data.far_damage_high),DataProcess.DamageType.MagicDamage,0,false,self,false,true,)
		break
	ray_animation_player.play_backwards("anim")
	await ray_animation_player.animation_finished
	ray.hide()
	end_point_particle.hide()
	start_point_particle.hide()
	pass


func move_process(delta_time: float):
	super(delta_time)
	#print(normal_attack_timer.time_left)
	if far_attack_timer.is_stopped() and silence_layers <= 0 and far_attack_area.has_overlapping_bodies():
		var ally: Ally = far_attack_area.get_overlapping_bodies()[0].owner
		far_attack_position = ally.hurt_box.global_position
		translate_to_new_state(EnemyState.SPECIAL)
		enemy_sprite.play("far_attack")
		enemy_sprite.flip_h = far_attack_position.x < position.x
		far_attack_timer.start()
		return
	pass


func special_process():
	if enemy_sprite.animation == "idle" and current_intercepting_units.is_empty():
		translate_to_new_state(EnemyState.MOVE)
	elif enemy_sprite.animation == "idle" and current_intercepting_units.size() > 0:
		translate_to_new_state(EnemyState.BATTLE)
	pass


func purple_to_orange():
	create_tween().tween_property(ray,"material:shader_parameter/mix_power",step_2_color,0.3)
	pass
