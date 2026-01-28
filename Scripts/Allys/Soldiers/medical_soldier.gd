extends Soldier

const BLOOD_SOLDIERRES = preload("res://Assets/Animations/Soldiers/LV4-3/SpriteFrames/blood_soldierres.res")
const NORMAL_SOLDIER = preload("res://Assets/Animations/Soldiers/LV4-3/SpriteFrames/normal_soldier.res")

@onready var heal_animation_player: AnimationPlayer = $UnitBody/HealAnimationPlayer
@onready var heal_area: Area2D = $UnitBody/HealArea
@onready var skill_heal_timer: Timer = $SkillHealTimer
@onready var heal_audio: AudioStreamPlayer = $HealAudio
@onready var passive_heal_timer: Timer = $PassiveHealTimer


func _ready() -> void:
	super()
	ally_sprite.sprite_frames = NORMAL_SOLDIER
	await get_tree().create_timer(randf_range(1,2),false).timeout
	passive_heal_timer.start()
	pass


func anim_offset():
	match ally_sprite.animation:
		"attack","idle":
			ally_sprite.position = Vector2(-20,-90) if ally_sprite.flip_h else Vector2(20,-90)
		"die":
			ally_sprite.position = Vector2(75,-100) if ally_sprite.flip_h else Vector2(-80,-100)
		"far_attack":
			ally_sprite.position = Vector2(25,-105) if ally_sprite.flip_h else Vector2(-25,-105)
		"move":
			ally_sprite.position = Vector2(0,-100)
		"heal":
			ally_sprite.position = Vector2(0,-90) if ally_sprite.flip_h else Vector2(-5,-90)
	pass


func frame_changed():
	if ally_sprite.animation == "attack" and ally_sprite.frame == 15:
		cause_damage()
	if ally_sprite.animation == "far_attack" and ally_sprite.frame == 15:
		far_attack_frame()
		AudioManager.instance.shoot_audio_1.play()
	if ally_sprite.animation == "heal":
		if ally_sprite.frame == 11:
			heal_animation_player.play("Appear")
		if ally_sprite.frame == 19:
			var heal_data: int
			match soldier_skill_levels[2]:
				1: heal_data = 60
				2: heal_data = 120
				3: heal_data = 180
			for body in heal_area.get_overlapping_bodies():
				var ally: Ally = body.owner
				ally.current_data.heal(heal_data)
	pass


func on_normal_attack_hit(target_enemy):
	if soldier_skill_levels[0] > 0:
		var duration: float
		match soldier_skill_levels[0]:
			1: duration = 4
			2: duration = 6
			3: duration = 8
		var plugin_buff: DotBuff = preload("res://Scenes/Buffs/Allys/medical_plugin_dot_debuff.tscn").instantiate()
		plugin_buff.buff_level = soldier_skill_levels[0]
		plugin_buff.duration = duration
		target_enemy.buffs.add_child(plugin_buff)
	pass


func _on_passive_heal_timer_timeout() -> void:
	if ally_state != AllyState.DIE:
		for body in heal_area.get_overlapping_bodies():
			var ally: Ally = body.owner
			if ally == self: continue
			if ally is Soldier and ally in soldier_brothers: continue
			ally.current_data.heal(4)
			var heal_effect: HealBuff = preload("res://Scenes/Buffs/Allys/medical_heal_buff.tscn").instantiate()
			ally.buffs.add_child(heal_effect)
	pass # Replace with function body.


func soldier_skill_level_up(skill_id: int, skill_level: int):
	super(skill_id,skill_level)
	if skill_id == 0 and skill_level == 1:
		var current_animation: String = ally_sprite.animation
		var current_frame: int = ally_sprite.frame
		ally_sprite.sprite_frames = BLOOD_SOLDIERRES
		ally_sprite.play(current_animation)
		ally_sprite.frame == current_frame
	if skill_id == 1:
		if skill_level == 1:
			start_data.far_damage_range = 300
			current_data.update_far_attack_range()
			#far_attack_area.scale = Vector2.ONE * float(current_data.far_damage_range) / 100
			start_data.far_attack_speed = 1.5
			current_data.update_far_damage_speed()
			#far_attack_timer.wait_time = current_data.far_attack_speed
			#var shape: CollisionShape2D = far_attack_area.get_child(0)
			#shape.disabled = false
		var damage_low: int
		var damage_high: int
		match skill_level:
			1:
				damage_low = 8
				damage_high = 12
			2:
				damage_low = 10
				damage_high = 16
			3:
				damage_low = 15
				damage_high = 20
		start_data.far_damage_low = damage_low
		start_data.far_damage_high = damage_high
		current_data.update_far_damage()
	pass


func summon_bullet(bullet_scene: PackedScene,summon_pos: Vector2, target_pos: Vector2, damage: int, damage_type: DataProcess.DamageType) -> Bullet:
	var bullet: Bullet = super(bullet_scene,summon_pos,target_pos,damage,damage_type)
	bullet.bullet_special_tag_levels["plugin"] = soldier_skill_levels[1]
	
	return bullet
	pass


func idle_process():
	if soldier_skill_levels[2] > 0 and skill_heal_timer.is_stopped() and current_data.health <= 100:
		translate_to_new_state(AllyState.SPECIAL)
		ally_sprite.play("heal")
		skill_heal_timer.start()
		heal_audio.play()
		return
	super()
	pass


func battle():
	if ally_sprite.animation == "idle":
		if soldier_skill_levels[2] > 0 and skill_heal_timer.is_stopped() and current_data.health <= 100:
			translate_to_new_state(AllyState.SPECIAL)
			ally_sprite.play("heal")
			skill_heal_timer.start()
			heal_audio.play()
			return
	super()
	pass
