extends Hero

@export var near_animation: SpriteFrames
@export var far_animation: SpriteFrames
@export var physics_arrow_scene: PackedScene
@export var magic_arrow_scene: PackedScene

@onready var teleport_audio: AudioStreamPlayer = $TeleportAudio
@onready var skill_1_timer: Timer = $Skill1Timer
@onready var skill_2_timer: Timer = $Skill2Timer
@onready var skill_3_timer: Timer = $Skill3Timer
@onready var skill_2_audio: AudioStreamPlayer = $Skill2Audio
@onready var dodge_particle: GPUParticles2D = $UnitBody/DodgeParticle

var current_skill1_damage_type: DataProcess.DamageType = DataProcess.DamageType.PhysicsDamage
var skill1_locked_enemy: Enemy
var skill1_locked_position: Vector2
var remaining_skill1_arrow_count: int = 10

var attacked_count: int = 0

var skill3_locked_pos: Vector2

var dodge_rate: float
var aoe_dodge_rate: float


func _ready() -> void:
	super()
	far_attack_bullet_scene = physics_arrow_scene
	skill_1_timer.wait_time = HeroSkillLibrary.hero_skill_data_library[ally_id][1].CD
	skill_2_timer.wait_time = HeroSkillLibrary.hero_skill_data_library[ally_id][2].CD
	skill_3_timer.wait_time = HeroSkillLibrary.hero_skill_data_library[ally_id][3].CD
	dodge_particle.visible = skill_levels[4] > 0
	dodge_rate = HeroSkillLibrary.hero_skill_data_library[ally_id][4].dodge_rate[skill_levels[4]-1]
	aoe_dodge_rate = HeroSkillLibrary.hero_skill_data_library[ally_id][4].aoe_dodge_rate[skill_levels[4]-1]
	pass


func anim_offset():
	if ally_sprite.sprite_frames == far_animation:
		far_anim_offset()
	elif ally_sprite.sprite_frames == near_animation:
		near_anim_offset()
	pass


func frame_changed():
	if ally_sprite.animation == "far_attack" and ally_sprite.frame == 8:
		far_attack_frame()
		AudioManager.instance.shoot_audio_2.play()
	if ally_sprite.animation == "teleport" and ally_sprite.frame == 14:
		teleport_finished()
		teleport_audio.play()
		teleport_effect_release(global_position + Vector2(0,-20))
	if ally_sprite.animation == "teleport" and ally_sprite.frame == 13:
		teleport_effect_release(global_position + Vector2(0,-20))
	if ally_sprite.animation == "attack" and ally_sprite.frame == 9:
		cause_damage()
		attacked_count += 1
	if ally_sprite.animation == "skill1" and ally_sprite.frame == 8:
		skill_1_release_oneshot(current_skill1_damage_type)
		AudioManager.instance.shoot_audio_2.play()
	if ally_sprite.animation == "skill1" and ally_sprite.frame == 13 and remaining_skill1_arrow_count > 0:
		ally_sprite.frame = 6
		ally_sprite.play()
	if ally_sprite.animation == "skill2" and ally_sprite.frame == 14:
		skill_2_audio.play()
		var damage: int = HeroSkillLibrary.hero_skill_data_library[ally_id][2].damage[skill_levels[2]-1]
		var enemy: Enemy = current_intercepting_enemy
		var show_pos: Vector2 = hurt_box.global_position
		show_pos.x += -20 if ally_sprite.flip_h else 20
		TextEffect.text_effect_show("重击！",TextEffect.TextEffectType.SecKill,show_pos)
		if enemy == null: return
		if enemy.take_damage(damage,DataProcess.DamageType.ExplodeDamage,0,false,self,true,false,) and enemy.enemy_type < Enemy.EnemyType.Boss:
			var broken_buff: PropertyBuff = preload("res://Scenes/Buffs/Rosa/rosa_broken_buff.tscn").instantiate()
			enemy.buffs.add_child(broken_buff)
	if ally_sprite.animation == "skill2" and ally_sprite.frame == 24:
		get_exp(skill2_exp_get[skill_levels[2]-1])
	if ally_sprite.animation == "skill3" and ally_sprite.frame == 8:
		if far_attack_area.has_overlapping_bodies():
			var enemy: Enemy = far_attack_area.get_overlapping_bodies()[0].owner
			skill3_locked_pos = enemy.hurt_box.global_position
		skill3_process()
		AudioManager.instance.shoot_audio_2.play()
	pass


func far_anim_offset():
	match ally_sprite.animation:
		"die":
			ally_sprite.position = Vector2(55,-85) if ally_sprite.flip_h else Vector2(-55,-85)
		"far_attack":
			ally_sprite.position = Vector2(30,-85) if ally_sprite.flip_h else Vector2(-30,-85)
		"idle":
			ally_sprite.position = Vector2(35,-80) if ally_sprite.flip_h else Vector2(-35,-80)
		"idle_special":
			ally_sprite.position = Vector2(15,-80) if ally_sprite.flip_h else Vector2(-20,-80)
		"move":
			ally_sprite.position = Vector2(5,-85) if ally_sprite.flip_h else Vector2(-10,-85)
		"rebirth":
			ally_sprite.position = Vector2(20,-105) if ally_sprite.flip_h else Vector2(-25,-105)
		"skill1":
			ally_sprite.position = Vector2(30,-80) if ally_sprite.flip_h else Vector2(-30,-80)
		"skill3":
			ally_sprite.position = Vector2(25,-80) if ally_sprite.flip_h else Vector2(-25,-80)
		"teleport":
			ally_sprite.position = Vector2(20,-90) if ally_sprite.flip_h else Vector2(-20,-90)
	pass


func near_anim_offset():
	match ally_sprite.animation:
		"attack","idle":
			ally_sprite.position = Vector2(-25,-80) if ally_sprite.flip_h else Vector2(25,-80)
		"die":
			ally_sprite.position = Vector2(45,-75) if ally_sprite.flip_h else Vector2(-45,-75)
		"skill2":
			ally_sprite.position = Vector2(-5,-100) if ally_sprite.flip_h else Vector2(0,-100)
		"translate_to_near":
			ally_sprite.position = Vector2(0,-105) if ally_sprite.flip_h else Vector2(5,-105)
		"rebirth":
			ally_sprite.position = Vector2(20,-105) if ally_sprite.flip_h else Vector2(-25,-105)
	pass


func far_attack_frame(damage_type: DataProcess.DamageType = DataProcess.DamageType.PhysicsDamage):
	super(damage_type)
	if far_attack_area.has_overlapping_bodies():
		far_attack_target_enemy = far_attack_area.get_overlapping_bodies()[-1].owner
	if far_attack_target_enemy == null: return
	var summon_pos:Vector2 = far_attack_marker_flip.global_position if ally_sprite.flip_h else far_attack_marker.global_position
	var target_pos: Vector2 = far_attack_target_enemy.hurt_box.global_position
	target_pos += far_attack_target_enemy.direction * far_attack_target_enemy.current_data.unit_move_speed * 2
	var damage: int = randi_range(current_data.far_damage_low,current_data.far_damage_high)
	var bullet: Bullet = summon_bullet(magic_arrow_scene,summon_pos,target_pos,damage,damage_type)
	Stage.instance.bullets.add_child(bullet)
	pass


func translate_to_new_state(new_state: AllyState):
	super(new_state)
	if new_state == AllyState.BATTLE and ally_sprite.sprite_frames != near_animation:
		ally_sprite.sprite_frames = near_animation
		ally_sprite.play("translate_to_near")
		attacked_count = 0
	
	if new_state == AllyState.DIE:
		dodge_particle.hide()
	pass


func _on_idle_animation_timer_timeout() -> void:
	if ally_state == AllyState.IDLE:
		ally_sprite.play("idle_special")
	pass # Replace with function body.


func teleport_effect_release(effect_pos: Vector2):
	var teleport_effect: AnimatedSprite2D = preload("res://Scenes/Effects/bullet_explosion_effect.tscn").instantiate()
	teleport_effect.position = effect_pos
	teleport_effect.scale /= 2
	teleport_effect.modulate = Color.BLACK
	Stage.instance.bullets.add_child(teleport_effect)
	pass


func move_back():
	ally_sprite.sprite_frames = far_animation
	attacked_count = 0
	super()
	pass


func move_animation(target_pos:Vector2):
	ally_sprite.sprite_frames = far_animation if current_intercepting_enemy == null else near_animation
	super(target_pos)
	pass


func rebirth():
	ally_sprite.sprite_frames = far_animation
	dodge_particle.visible = skill_levels[4] > 0
	super()
	pass


func skill_1_release_oneshot(damage_type: DataProcess.DamageType):
	var locked_pos: Vector2
	var bullet: ShooterBullet
	if far_attack_area.has_overlapping_bodies():
		var enemy: Enemy = far_attack_area.get_overlapping_bodies()[0].owner
		locked_pos = enemy.hurt_box.global_position
		skill1_locked_position = locked_pos
	else:
		locked_pos = skill1_locked_position
	
	ally_sprite.flip_h = locked_pos.x < global_position.x
	var summon_pos: Vector2 = far_attack_marker_flip.global_position if ally_sprite.flip_h else far_attack_marker.global_position
	var bullet_scene: PackedScene = physics_arrow_scene if damage_type == DataProcess.DamageType.PhysicsDamage else magic_arrow_scene
	var damage_low: int = HeroSkillLibrary.hero_skill_data_library[ally_id][1].damage_low[skill_levels[1]-1]
	var damage_high: int = HeroSkillLibrary.hero_skill_data_library[ally_id][1].damage_high[skill_levels[1]-1]
	bullet = summon_bullet(bullet_scene,summon_pos,locked_pos,randi_range(damage_low,damage_high),damage_type)
	bullet.bullet_speed *= 1.4
	Stage.instance.bullets.add_child(bullet)
	
	remaining_skill1_arrow_count -= 1
	if damage_type == DataProcess.DamageType.PhysicsDamage:
		damage_type = DataProcess.DamageType.MagicDamage
	else:
		damage_type = DataProcess.DamageType.PhysicsDamage
	pass


func idle_process():
	super()
	if ally_state != AllyState.IDLE: return
	#print(intercepting_area.get_overlapping_bodies())
	if ally_sprite.animation == "idle":
		if far_attack_area.get_overlapping_bodies().size() >= 3 and skill_levels[3] > 0 and skill_3_timer.is_stopped():
			skill_3_timer.start()
			translate_to_new_state(AllyState.SPECIAL)
			ally_sprite.play("skill3")
			var enemy: Enemy = far_attack_area.get_overlapping_bodies()[0].owner
			ally_sprite.flip_h = enemy.position.x < position.x
			skill3_locked_pos = enemy.hurt_box.global_position
			return
		
		if skill_1_timer.is_stopped() and far_attack_area.has_overlapping_bodies() and skill_levels[1] > 0:
			skill_1_timer.start()
			current_skill1_damage_type = DataProcess.DamageType.PhysicsDamage
			remaining_skill1_arrow_count = 10
			translate_to_new_state(AllyState.SPECIAL)
			skill1_locked_enemy = far_attack_area.get_overlapping_bodies()[0].owner
			ally_sprite.flip_h = skill1_locked_enemy.position.x < position.x
			skill1_locked_position = skill1_locked_enemy.hurt_box.global_position
			ally_sprite.play("skill1")
			return
	pass


func battle():
	if ally_sprite.animation == "idle" and skill_2_timer.is_stopped() and attacked_count >= 1:
		translate_to_new_state(AllyState.SPECIAL)
		ally_sprite.play("skill2")
		skill_2_timer.start()
		return
	super()
	pass


func skill3_process():
	var enemy_path: EnemyPath = Stage.instance.get_closest_main_enemy_path(skill3_locked_pos)
	var is_adding: bool
	var enemy_progress: float = enemy_path.curve.get_closest_offset(skill3_locked_pos)
	var self_progress: float = enemy_path.curve.get_closest_offset(global_position)
	is_adding = self_progress < enemy_progress
	var unit_offset: float = 120
	unit_offset *= 1 if is_adding else -1
	
	for i in 5:
		var arrow: ShooterBullet = preload("res://Scenes/Bullets/rosa_explosion_arrow.tscn").instantiate()
		arrow.damage = randi_range(current_data.far_damage_low,current_data.far_damage_high)
		var target_position: Vector2 = skill3_locked_pos
		if i > 0:
			var y_direction: Vector2
			var target_progress: float
			match i: #通过progress获取基础坐标
				1,2:
					target_progress = enemy_progress + unit_offset
					target_position = enemy_path.curve.sample_baked(target_progress)
					y_direction = enemy_path.curve.sample_baked_with_rotation(target_progress).y
					target_position += y_direction * 40 if i == 1 else y_direction * (-40)
				3,4:
					target_progress = enemy_progress + unit_offset * 2
					target_position = enemy_path.curve.sample_baked(target_progress)
					y_direction = enemy_path.curve.sample_baked_with_rotation(target_progress).y
					target_position += y_direction * 40 if i == 3 else y_direction * (-40)
		
		arrow.target_position = target_position
		arrow.position = far_attack_marker_flip.global_position if ally_sprite.flip_h else far_attack_marker.global_position
		Stage.instance.bullets.add_child(arrow)
		if i > 5:
			arrow.hit_box.set_collision_layer_value(6,false)
			arrow.hit_box.set_collision_layer_value(7,false)
	pass


func take_damage(damage: int, damage_type: DataProcess.DamageType, broken_rate: float, far_attack: bool = false, source: Node2D = null,explosion: bool = false,aoe_attack: bool = false, deadly: bool = true) -> bool:
	if source != null:
		if source is Enemy:
			if source.enemy_type < Enemy.EnemyType.Boss:
				var dodge_possible: float = randf()
				#print("rosa_dodge:",dodge_possible)
				if far_attack and dodge_possible < dodge_rate: 
					dodge()
					return false
				if aoe_attack and dodge_possible < aoe_dodge_rate: 
					dodge()
					return false
	
	return super(damage,damage_type,broken_rate,far_attack,source,explosion,aoe_attack,deadly)


func start_data_process():
	super()
	start_data.dodge_rate = dodge_rate
	
	await get_tree().process_frame
	current_data.dodge_rate = dodge_rate
	pass


func teleport_move(target_pos: Vector2):
	if ally_state == AllyState.SPECIAL:
		waiting_to_move = true
		next_move_position = navigation_agent.target_position
		return
	ally_sprite.sprite_frames = far_animation
	attacked_count = 0
	super(target_pos)
	pass


func move(target_pos:Vector2):
	if ally_sprite.animation == "skill1" and ally_state == AllyState.SPECIAL:
		translate_to_new_state(AllyState.IDLE)
	super(target_pos)
	pass
