extends Enemy

@export var potion_animation_list: PackedStringArray
@export var potion_summon_frame_count: int = 14
@export var heal_potion_scene: PackedScene
@export var regon_potion_scene: PackedScene
@export var poison_potion_scene: PackedScene
@export var weakness_potion_scene: PackedScene

@onready var throw_audio: AudioStreamPlayer = $ThrowAudio
@onready var drink_audio: AudioStreamPlayer = $DrinkAudio
@onready var heal_self_timer: Timer = $HealSelfTimer
@onready var release_debuff_timer: Timer = $ReleaseDebuffTimer
@onready var heal_timer: Timer = $HealTimer
@onready var regon_timer: Timer = $RegonTimer
@onready var suppor_area: Area2D = $UnitBody/SupporArea


func anim_offset():
	match enemy_sprite.animation:
		"attack","idle":
			enemy_sprite.position = Vector2(-10,-120) if enemy_sprite.flip_h else Vector2(10,-120)
		"die":
			enemy_sprite.position = Vector2(115,-130) if enemy_sprite.flip_h else Vector2(-115,-130)
		"drink":
			enemy_sprite.position = Vector2(30,-120) if enemy_sprite.flip_h else Vector2(-30,-120)
		"far_attack","heal_potion","regon_potion","poison","weakness":
			enemy_sprite.position = Vector2(-20,-120) if enemy_sprite.flip_h else Vector2(25,-120)
		"move_back":
			enemy_sprite.position = Vector2(0,-115)
		"move_front":
			enemy_sprite.position = Vector2(0,-120)
		"move_normal":
			enemy_sprite.position = Vector2(5,-115) if enemy_sprite.flip_h else Vector2(0,-115)
	pass


func frame_changed():
	if enemy_sprite.animation == "attack" and enemy_sprite.frame == 14:
		cause_damage()
	
	if potion_animation_list.has(enemy_sprite.animation) and enemy_sprite.frame == potion_summon_frame_count:
		throw_audio.play()
		var summon_pos: Vector2 = far_attack_marker_flip.global_position if enemy_sprite.flip_h else far_attack_marker.global_position
		var bullet_scene: PackedScene
		var target_pos: Vector2 = far_attack_position
		match enemy_sprite.animation:
			"far_attack":
				bullet_scene = far_attack_bullet_scene
			"heal_potion":
				bullet_scene = heal_potion_scene
			"regon_potion":
				bullet_scene = regon_potion_scene
			"poison":
				bullet_scene = poison_potion_scene
			"weakness":
				bullet_scene = weakness_potion_scene
		if bullet_scene == null: return
		var bullet: Bullet = summon_bullet(bullet_scene,summon_pos,target_pos,0,DataProcess.DamageType.MagicDamage)
		if enemy_sprite.animation == "far_attack":
			bullet.damage = randi_range(current_data.far_damage_low,current_data.far_damage_high)
		Stage.instance.bullets.add_child(bullet)
	
	if potion_animation_list.has(enemy_sprite.animation) and enemy_sprite.frame == 23:
		update_state()
		if !current_intercepting_units.is_empty(): translate_to_new_state(EnemyState.BATTLE)
	
	if enemy_sprite.animation == "drink" and enemy_sprite.frame == 13:
		current_data.heal(120)
	if enemy_sprite.animation == "drink" and enemy_sprite.frame == 24:
		update_state()
		if !current_intercepting_units.is_empty(): translate_to_new_state(EnemyState.BATTLE)
	pass


func move_process(delta: float):
	if far_attack_area.has_overlapping_bodies() and far_attack_timer.is_stopped():
		translate_to_new_state(EnemyState.SPECIAL)
		var ally: Ally = far_attack_area.get_overlapping_bodies()[0].owner
		far_attack_position = ally.hurt_box.global_position
		enemy_sprite.play("far_attack")
		enemy_sprite.flip_h = far_attack_position.x < position.x
		far_attack_timer.start()
		return
	if heal_self_timer.is_stopped() and health_bar.value < 0.6 and silence_layers <= 0:
		release_heal_self()
		return
	if far_attack_area.has_overlapping_bodies() and release_debuff_timer.is_stopped() and silence_layers <= 0:
		translate_to_new_state(EnemyState.SPECIAL)
		release_debuff_timer.start()
		var ally: Ally = far_attack_area.get_overlapping_bodies()[0].owner
		far_attack_position = ally.hurt_box.global_position
		release_debuff_timer.start()
		match randi_range(0,1):
			0:
				enemy_sprite.play("poison")
			1:
				enemy_sprite.play("weakness")
		enemy_sprite.flip_h = far_attack_position.x < position.x
		return
	
	if suppor_area.get_overlapping_bodies().size() > 1 and silence_layers <= 0:
		if regon_timer.is_stopped():
			var enemy_list: Array[Enemy]
			for body in suppor_area.get_overlapping_bodies():
				enemy_list.append(body.owner)
			enemy_list.erase(self)
			var enemy: Enemy = enemy_list.pick_random()
			far_attack_position = enemy.hurt_box.global_position
			regon_timer.start()
			translate_to_new_state(EnemyState.SPECIAL)
			enemy_sprite.play("regon_potion")
			enemy_sprite.flip_h = far_attack_position.x < position.x
			return
		if heal_timer.is_stopped() and silence_layers <= 0:
			var heal_enemy: Enemy = get_heal_enemy()
			if heal_enemy != null:
				far_attack_position = heal_enemy.hurt_box.global_position
				heal_timer.start()
				translate_to_new_state(EnemyState.SPECIAL)
				enemy_sprite.play("heal_potion")
				enemy_sprite.flip_h = far_attack_position.x < position.x
				return
	super(delta)
	pass


func battle():
	if heal_self_timer.is_stopped() and health_bar.value < 0.6:
		release_heal_self()
		return
	super()
	pass


func release_heal_self():
	translate_to_new_state(EnemyState.SPECIAL)
	heal_self_timer.start()
	enemy_sprite.play("drink")
	drink_audio.play()
	pass


func get_heal_enemy() -> Enemy:
	for body in suppor_area.get_overlapping_bodies():
		var enemy:Enemy = body.owner
		if enemy == self: continue
		if enemy.health_bar.value < 0.5: return enemy
	
	return null
	pass


func special_process():
	super()
	if enemy_sprite.animation == "idle":
		if current_intercepting_units.is_empty():
			translate_to_new_state(EnemyState.MOVE)
		else:
			translate_to_new_state(EnemyState.BATTLE)
	pass
