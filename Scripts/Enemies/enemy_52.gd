extends Enemy

@onready var hating_soldier: AnimatedSprite2D = $UnitBody/HatingSoldier
@onready var shadow: Sprite2D = $UnitBody/Shadow


func _ready() -> void:
	hating_soldier.frame_changed.connect(on_haitng_frame_changed)
	super()
	pass


func anim_offset():
	match enemy_sprite.animation:
		"idle","die":
			enemy_sprite.position = Vector2(5,-300) if enemy_sprite.flip_h else Vector2(-5,-300)
			hating_soldier.position = Vector2(0,-425)
		"move_back","move_front":
			enemy_sprite.position = Vector2(0,-355)
			hating_soldier.position.x = 5 if enemy_sprite.animation == "move_back" else -5
			set_hating_height(hating_soldier.animation)
		"move_normal":
			enemy_sprite.position = Vector2(5,-355) if enemy_sprite.flip_h else Vector2(-5,-355)
			hating_soldier.position.x = 0
			set_hating_height(hating_soldier.animation)
	pass


func on_haitng_frame_changed():
	if hating_soldier.animation == "far_attack" and hating_soldier.frame == 14:
		var summon_pos: Vector2 = far_attack_marker_flip.global_position if enemy_sprite.flip_h else far_attack_marker.global_position
		var bullet: Shell = summon_bullet(far_attack_bullet_scene,summon_pos,far_attack_position,current_data.near_damage_high,DataProcess.DamageType.ExplodeDamage)
		bullet.low_damage = current_data.near_damage_low
		Stage.instance.bullets.add_child(bullet)
	pass


func set_hating_height(anim_name: String):
	var max_height: float
	var min_height: float
	match anim_name:
		"idle":
			max_height = -425
			min_height = -400
		"front":
			max_height = -455
			min_height = -425
		"back":
			max_height = -440
			min_height = -405
	var weight: float = float(enemy_sprite.frame) / 12 if enemy_sprite.frame <= 12 else 1 - float(enemy_sprite.frame - 12) / 12
	hating_soldier.position.y = lerpf(max_height,min_height,weight)
	#print(weight)
	#print(hating_soldier.position.y)
	pass


func move_process(delta_time: float):
	var anim_name: String
	match enemy_sprite.animation:
		"move_normal": anim_name = "idle"
		"move_back": anim_name = "back"
		"move_front": anim_name = "front"
	hating_soldier.play(anim_name)
	if far_attack_area.get_overlapping_bodies().size() > 0 and far_attack_timer.is_stopped():
		translate_to_new_state(EnemyState.SPECIAL)
		enemy_sprite.play("idle")
		return
	super(delta_time)
	pass


func die_blood(blood_packed_scene: PackedScene = null):
	shadow.hide()
	pass


func die(explosion: bool = false):
	super(explosion)
	hide()
	var explosion_effect: AnimatedSprite2D = preload("res://Scenes/Effects/bullet_explosion_effect.tscn").instantiate()
	explosion_effect.global_position = hurt_box.global_position
	Stage.instance.bullets.add_child(explosion_effect)
	AudioManager.instance.play_explosion_audio()
	var damage: int = 100
	if enemy_buff_tags.has("lightning"):
		damage = 150
	var phatom: Enemy = preload("res://Scenes/Enemies/enemy_40.tscn").instantiate()
	phatom.progress = progress
	get_parent().add_child(phatom)
	phatom.take_damage(damage,DataProcess.DamageType.ExplodeDamage,0,false,null,false,true)
	pass


func _process(delta: float) -> void:
	super(delta)
	hating_soldier.flip_h = enemy_sprite.flip_h
	pass


func special_process():
	if !hating_soldier.is_playing() and far_attack_area.get_overlapping_bodies().size() == 0:
		translate_to_new_state(EnemyState.MOVE)
		return
	if current_intercepting_units.size() > 0:
		translate_to_new_state(EnemyState.BATTLE)
	elif far_attack_area.get_overlapping_bodies().size() > 0 and far_attack_timer.is_stopped():
		var ally: Ally = far_attack_area.get_overlapping_bodies()[0].owner
		far_attack_position = ally.hurt_box.global_position
		far_attack_timer.start()
		hating_soldier.play("far_attack")
		enemy_sprite.flip_h = far_attack_position.x < position.x
	pass
