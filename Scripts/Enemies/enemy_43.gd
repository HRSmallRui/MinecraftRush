extends Enemy

const FLYING_ANIMATION = preload("res://Assets/Animations/Enemies/43泰坦威克斯/SpriteFrames/flying_animation.res")
const LANDING_ANIMATION = preload("res://Assets/Animations/Enemies/43泰坦威克斯/SpriteFrames/landing_animation.res")

@onready var fly_cd_timer: Timer = $FlyCDTimer
@onready var fly_during_timer: Timer = $FlyDuringTimer
@onready var enemy_button_2: Button = $UnitBody/EnemyButton2

var hurt_box_position: Vector2
var flying_hurt_box_position: Vector2


func _ready() -> void:
	super()
	enemy_sprite.sprite_frames = LANDING_ANIMATION
	enemy_button_2.hide()
	hurt_box_position = hurt_box.position
	flying_hurt_box_position = hurt_box_position
	flying_hurt_box_position.y -= 130
	enemy_button_2.modulate.a = 0
	pass


func anim_offset():
	match enemy_sprite.sprite_frames:
		LANDING_ANIMATION:
			match enemy_sprite.animation:
				"attack","idle":
					enemy_sprite.position = Vector2(15,-180) if enemy_sprite.flip_h else Vector2(-15,-180)
				"die":
					enemy_sprite.position = Vector2(-20,-105) if enemy_sprite.flip_h else Vector2(20,-105)
				"land":
					enemy_sprite.position = Vector2(20,-175) if enemy_sprite.flip_h else Vector2(-20,-175)
				"move_back":
					enemy_sprite.position = Vector2(0,-100)
				"move_front":
					enemy_sprite.position = Vector2(0,-105)
				"move_normal":
					enemy_sprite.position = Vector2(10,-105) if enemy_sprite.flip_h else Vector2(-10,-105)
		FLYING_ANIMATION:
			match enemy_sprite.animation:
				"idle","die":
					enemy_sprite.position = Vector2(60,-200) if enemy_sprite.flip_h else Vector2(-65,-200)
				"fly":
					enemy_sprite.position = Vector2(20,-175) if enemy_sprite.flip_h else Vector2(-20,-175)
				"move_back","move_front":
					enemy_sprite.position = Vector2(0,-180)
				"move_normal":
					enemy_sprite.position = Vector2(10,-195) if enemy_sprite.flip_h else Vector2(-15,-195)
	pass


func frame_changed():
	if enemy_sprite.animation == "attack" and enemy_sprite.frame == 20:
		cause_damage()
	pass


func _on_fly_during_timer_timeout() -> void:
	landing()
	pass # Replace with function body.


func battle():
	if enemy_sprite.animation == "idle" and fly_cd_timer.is_stopped() and fly_can_release():
		fly()
		fly_cd_timer.start()
	super()
	pass


func fly():
	for ally in current_intercepting_units:
		ally.current_intercepting_enemy = null
	current_intercepting_units.clear()
	unit_body.set_collision_layer_value(6,false)
	unit_body.set_collision_layer_value(7,true)
	hurt_box.set_collision_layer_value(6,false)
	hurt_box.set_collision_layer_value(7,true)
	interceptable = false
	enemy_sprite.sprite_frames = FLYING_ANIMATION
	enemy_sprite.play("fly")
	enemy_button.hide()
	enemy_button_2.show()
	hurt_box.position = flying_hurt_box_position
	buffs.position.y -= 130
	health_bar.position.y = -385
	
	start_data.unit_move_speed = 1.2
	current_data.update_move_speed()
	fly_during_timer.start()
	anim_offset()
	pass


func translate_to_new_state(new_state: EnemyState):
	super(new_state)
	if new_state == EnemyState.DIE:
		fly_during_timer.stop()
	pass


func landing():
	translate_to_new_state(EnemyState.SPECIAL)
	unit_body.set_collision_layer_value(6,true)
	unit_body.set_collision_layer_value(7,false)
	hurt_box.set_collision_layer_value(6,true)
	hurt_box.set_collision_layer_value(7,false)
	interceptable = true
	buffs.position.y += 130
	
	enemy_sprite.sprite_frames = LANDING_ANIMATION
	enemy_sprite.play_backwards("land")
	enemy_button.show()
	enemy_button_2.hide()
	hurt_box.position = hurt_box_position
	health_bar.position.y = -250
	
	start_data.unit_move_speed = 0.6
	current_data.update_move_speed()
	anim_offset()
	
	await enemy_sprite.animation_finished
	update_state()
	if current_intercepting_units.size() > 0:
		translate_to_new_state(EnemyState.BATTLE)
	pass


func fly_can_release() -> bool:
	var enemy_path: EnemyPath = get_parent()
	var remaining_length: float = enemy_path.curve.get_baked_length() - progress
	return remaining_length > 350
	pass
