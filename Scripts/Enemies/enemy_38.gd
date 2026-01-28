extends Enemy

const RUN_STATE_ANIMATION = preload("res://Assets/Animations/Enemies/38劫掠兽/SpriteFrames/run_state_animation.res")
const WALK_STATE_ANIMATION = preload("res://Assets/Animations/Enemies/38劫掠兽/SpriteFrames/walk_state_animation.res")

@export var roar_audio_list: Array[AudioStream]
@export var attack_audio_list: Array[AudioStream]
@export var move_audio_list: Array[AudioStreamPlayer]

@onready var attack_area: Area2D = $UnitBody/AttackArea
@onready var attack_audio: AudioStreamPlayer = $AttackAudio
@onready var run_timer: Timer = $RunTimer
@onready var roar_audio: AudioStreamPlayer = $RoarAudio
@onready var skill_condition_area: Area2D = $UnitBody/SkillConditionArea
@onready var run_hit_area: Area2D = $UnitBody/RunHitArea
@onready var run_duration_timer: Timer = $RunDurationTimer
@onready var running_prepare_timer: Timer = $RunningPrepareTimer

var attack_area_position_no_flip: Vector2
var hit_list: Array[Ally]


func _ready() -> void:
	super()
	enemy_sprite.sprite_frames = WALK_STATE_ANIMATION
	attack_area_position_no_flip = attack_area.position
	pass


func _process(delta: float) -> void:
	super(delta)
	attack_area.position = Vector2(-attack_area_position_no_flip.x,attack_area_position_no_flip.y) if enemy_sprite.flip_h else attack_area_position_no_flip
	pass


func anim_offset():
	match enemy_sprite.animation:
		"attack","idle":
			enemy_sprite.position = Vector2(-60,-110) if enemy_sprite.flip_h else Vector2(60,-110)
		"die":
			enemy_sprite.position = Vector2(25,-130) if enemy_sprite.flip_h else Vector2(-25,-130)
		"move_back":
			if enemy_sprite.sprite_frames == WALK_STATE_ANIMATION:
				enemy_sprite.position = Vector2(0,-110)
			elif enemy_sprite.sprite_frames == RUN_STATE_ANIMATION:
				enemy_sprite.position = Vector2(0,-125)
		"move_front":
			if enemy_sprite.sprite_frames == WALK_STATE_ANIMATION:
				enemy_sprite.position = Vector2(0,-125)
			elif enemy_sprite.sprite_frames == RUN_STATE_ANIMATION:
				enemy_sprite.position = Vector2(0,-115)
		"move_normal":
			if enemy_sprite.sprite_frames == WALK_STATE_ANIMATION:
				enemy_sprite.position = Vector2(-5,-100) if enemy_sprite.flip_h else Vector2(5,-100)
			elif enemy_sprite.sprite_frames == RUN_STATE_ANIMATION:
				enemy_sprite.position = Vector2(15,-125) if enemy_sprite.flip_h else Vector2(-15,-125)
	pass


func frame_changed():
	if "move" in enemy_sprite.animation:
		walk_audio_process()
	if enemy_sprite.animation == "attack" and enemy_sprite.frame == 10:
		var damage: int = randi_range(current_data.near_damage_low,current_data.near_damage_high)
		for body in attack_area.get_overlapping_bodies():
			var ally: Ally = body.owner
			ally.take_damage(damage,DataProcess.DamageType.PhysicsDamage,0,false,self,false,true,)
		attack_audio.stream = attack_audio_list.pick_random()
		attack_audio.play()
	pass

func walk_audio_process():
	if enemy_sprite.sprite_frames == WALK_STATE_ANIMATION:
		if enemy_sprite.frame == 38 or enemy_sprite.frame == 18:
			play_walk_audio()
	elif enemy_sprite.sprite_frames == RUN_STATE_ANIMATION:
		if enemy_sprite.frame == 10:
			play_walk_audio()
	pass


func play_walk_audio():
	var audio_player: AudioStreamPlayer = move_audio_list.pick_random() as AudioStreamPlayer
	audio_player.play()
	pass


func move_process(delta: float):
	super(delta)
	if run_timer.is_stopped() and running_prepare_timer.is_stopped() and skill_condition_area.has_overlapping_bodies() and silence_layers <= 0 and can_run():
		run_timer.start()
		run_duration_timer.start()
		enemy_sprite.sprite_frames = RUN_STATE_ANIMATION
		interceptable = false
		current_data.unit_move_speed = 2
		roar_audio.stream = roar_audio_list.pick_random()
		roar_audio.play()
	pass


func _on_run_duration_timer_timeout() -> void:
	enemy_sprite.sprite_frames = WALK_STATE_ANIMATION
	start_data.unit_move_speed = 0.4
	interceptable = true
	current_data.update_move_speed()
	hit_list.clear()
	pass # Replace with function body.


func die(explosion: bool = false):
	super(explosion)
	run_duration_timer.stop()
	pass


func _on_run_hit_area_area_entered(area: Area2D) -> void:
	if enemy_sprite.sprite_frames == WALK_STATE_ANIMATION: return
	if !"move" in  enemy_sprite.animation: return
	var ally: Ally = area.owner
	if ally in hit_list: return
	var damage: int = randi_range(120,150)
	ally.take_damage(damage,DataProcess.DamageType.PhysicsDamage,0,false,self,false,true,)
	hit_list.append(ally)
	pass # Replace with function body.


func die_blood(blood_packed_scene: PackedScene = preload("res://Scenes/Effects/blood.tscn")):
	var blood = blood_packed_scene.instantiate() as Sprite2D
	blood.position = position
	blood.scale *= 2
	Stage.instance.bullets.add_child(blood)
	pass


func can_run() -> bool:
	var enemy_path: EnemyPath = get_parent()
	var curve: Curve2D = enemy_path.curve
	var last_length: float = curve.get_baked_length() - progress
	return last_length > 800
