extends Enemy

@onready var teleport_timer: Timer = $TeleportTimer
@onready var teleport_audio: AudioStreamPlayer = $TeleportAudio
@onready var teleport_audio_2: AudioStreamPlayer = $TeleportAudio2


func anim_offset():
	match enemy_sprite.animation:
		"attack","idle":
			enemy_sprite.position = Vector2(20,-110) if enemy_sprite.flip_h else Vector2(-20,-110)
		"die":
			enemy_sprite.position = Vector2(-65,-140) if enemy_sprite.flip_h else Vector2(60,-140)
		"move_back":
			enemy_sprite.position = Vector2(-5,-155) if enemy_sprite.flip_h else Vector2(5,-155)
		"move_front":
			enemy_sprite.position = Vector2(5,-155) if enemy_sprite.flip_h else Vector2(-10,-155)
		"move_normal":
			enemy_sprite.position = Vector2(-5,-160) if enemy_sprite.flip_h else Vector2(5,-160)
	pass


func frame_changed():
	if enemy_sprite.animation == "attack" and enemy_sprite.frame == 14:
		cause_damage()
	pass


func teleport():
	var teleport_effect: AnimatedSprite2D = preload("res://Scenes/Effects/bullet_explosion_effect.tscn").instantiate()
	teleport_effect.modulate = Color.PURPLE
	teleport_effect.scale *= 0.5
	teleport_effect.position = hurt_box.global_position
	Stage.instance.bullets.add_child(teleport_effect)
	match randi_range(1,2):
		1: teleport_audio.play()
		2: teleport_audio_2.play()
	progress += 200
	if enemy_state != EnemyState.DIE:
		translate_to_new_state(EnemyState.MOVE)
	for ally: Ally in current_intercepting_units:
		if ally == null: continue
		if ally.current_intercepting_enemy == self:
			ally.current_intercepting_enemy = null
	current_intercepting_units.clear()
	pass


func take_damage(damage: int, damage_type: DataProcess.DamageType, broken_rate: float, far_attack: bool = false, source: Node2D = null,explosion: bool = false,aoe_attack: bool = false, deadly: bool = true) -> bool:
	if far_attack and teleport_timer.is_stopped() and silence_layers <= 0:
		var enemy_path: EnemyPath = get_parent()
		var remaining_length: float = enemy_path.curve.get_baked_length() - progress
		if remaining_length > 400:
			teleport_timer.start()
			teleport()
			return false
	
	return super(damage,damage_type,broken_rate,far_attack,source,explosion,aoe_attack, deadly)
	pass
