extends Node2D
class_name NuclearTNTPlane

@export var fly_height: float = -90
@export var move_speed: float
@export var level: int = 1

@onready var shadow: Sprite2D = $Shadow
@onready var sprite_player: Node2D = $SpritePlayer
@onready var normal: AnimatedSprite2D = $SpritePlayer/Normal
@onready var front: AnimatedSprite2D = $SpritePlayer/Front
@onready var back: AnimatedSprite2D = $SpritePlayer/Back
@onready var normal_shoot_marker: Marker2D = $SpritePlayer/Normal/NormalShootMarker
@onready var front_shoot_marker: Marker2D = $SpritePlayer/Front/FrontShootMarker
@onready var back_shoot_marker: Marker2D = $SpritePlayer/Back/BackShootMarker
@onready var push_audio: AudioStreamPlayer = $PushAudio
@onready var pull_audio: AudioStreamPlayer = $PullAudio
@onready var move_timer: Timer = $MoveTimer

var move_path: Curve2D
var progress: float
var last_frame_position: Vector2


func _ready() -> void:
	shadow.modulate.a = 0
	normal.frame_changed.connect(on_normal_sprite_frame_changed)
	set_process(false)
	sprite_player.scale = Vector2(0.2,0.2)
	
	var current_position: Vector2 = position
	var start_position: Vector2 = move_path.sample_baked(progress)
	var move_time: float = (start_position - position).length() / move_speed
	var move_tween: Tween = create_tween()
	move_tween.tween_property(self,"position",start_position,move_time)
	create_tween().tween_property(sprite_player,"position:y",fly_height,move_time)
	create_tween().tween_property(shadow,"modulate:a",1,move_time)
	
	set_direction(current_position,start_position)
	await move_tween.finished
	move_timer.start()
	set_process(true)
	last_frame_position = current_position
	pass


func on_normal_sprite_frame_changed():
	if normal.frame == 0:
		push_audio.play()
		summon_tnt()
	if normal.frame == 6:
		pull_audio.play()
	pass


func summon_tnt():
	if move_timer.is_stopped(): return
	
	var tnt: Shell = preload("res://Scenes/Bullets/nuclear_shell.tscn").instantiate()
	var max_damage: int
	var min_damage: int
	match level:
		1:
			max_damage = 40
			min_damage = 20
		2:
			max_damage = 60
			min_damage = 30
	if Stage.instance.get_current_techno_level(3) >= 4:
		min_damage = max_damage
	tnt.damage = max_damage
	tnt.low_damage = min_damage
	tnt.move_type = Bullet.MoveType.Straight
	tnt.target_position = position
	tnt.position = sprite_player.global_position
	Stage.instance.bullets.add_child(tnt)
	tnt.hit_box.set_collision_mask_value(7,true)
	pass


func _on_move_timer_timeout() -> void:
	set_process(false)
	var disappear_tween: Tween = create_tween()
	disappear_tween.tween_property(self,"modulate:a",0,0.5)
	await disappear_tween.finished
	queue_free()
	pass # Replace with function body.


func _process(delta: float) -> void:
	sprite_player.scale = Vector2.ONE * 0.2
	#set_direction(last_frame_position,position)
	set_progress_direction()
	position = move_path.sample_baked(progress)
	progress -= move_speed * delta
	sprite_player.scale = Vector2.ONE * 0.2
	if progress < 10:
		move_timer.stop()
		_on_move_timer_timeout()
		set_process(false)
	pass


func set_direction(from_position: Vector2, to_position: Vector2):
	var direction: Vector2 = to_position - from_position
	direction = direction.normalized()
	scale.x = -1 if direction.x > 0 else 1
	var condition_length: float = 0.75
	normal.visible = absf(direction.y) < condition_length
	front.visible = direction.y >= condition_length
	back.visible = direction.y <= -condition_length
	pass


func set_progress_direction():
	var face_position: Vector2 = move_path.sample_baked(progress - 1)
	var direction = (face_position - position).normalized()
	scale.x = -1 if direction.x > 0 else 1
	var condition_length: float = 0.75
	normal.visible = absf(direction.y) < condition_length
	front.visible = direction.y >= condition_length
	back.visible = direction.y <= -condition_length
	pass
