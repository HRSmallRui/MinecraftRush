extends Soldier

@export var return_damage_list: Array[float]
@export var heal_duration_list: Array[float]
@export var sec_kill_rate_list: Array[float]

@onready var heal_buff_timer: Timer = $HealBuffTimer
@onready var sec_kill_area: Area2D = $UnitBody/SecKillArea
@onready var skill_2_timer: Timer = $Skill2Timer
@onready var sec_kill_sprite: Sprite2D = $SecKillSprite

var current_return_damage_rate: float = 0.2
var locked_enemy: Enemy


func _ready() -> void:
	super()
	sec_kill_sprite.hide()
	pass


func anim_offset():
	match ally_sprite.animation:
		"attack","idle":
			ally_sprite.position = Vector2(5,-120) if ally_sprite.flip_h else Vector2(-5,-120)
		"die":
			ally_sprite.position = Vector2(95,-100) if ally_sprite.flip_h else Vector2(-100,-100)
		"far_attack":
			ally_sprite.position = Vector2(-15,-100) if ally_sprite.flip_h else Vector2(10,-100)
		"move":
			ally_sprite.position = Vector2(20,-105) if ally_sprite.flip_h else Vector2(-20,-105)
		"sec_kill":
			ally_sprite.position = Vector2(0,-140) if ally_sprite.flip_h else Vector2(-5,-140)
	pass


func idle_process():
	if !intercepting_area.has_overlapping_bodies() and skill_2_timer.is_stopped() and soldier_skill_levels[1] > 0 and sec_kill_area.has_overlapping_bodies():
		locked_enemy = get_sec_kill_enemy()
		if locked_enemy != null:
			sec_kill_sprite.show()
			translate_to_new_state(AllyState.SPECIAL)
			ally_sprite.play("sec_kill")
			ally_sprite.flip_h = locked_enemy.global_position.x < global_position.x
			skill_2_timer.start()
			return
	super()
	pass


func frame_changed():
	if ally_sprite.animation == "attack" and ally_sprite.frame == 14:
		cause_damage()
	if ally_sprite.animation == "far_attack" and ally_sprite.frame == 16:
		far_attack_frame()
		AudioManager.instance.shoot_audio_1.play()
	if ally_sprite.animation == "sec_kill" and ally_sprite.frame == 20:
		sec_kill_sprite.hide()
		AudioManager.instance.shoot_audio_2.play()
		if locked_enemy == null: return
		if locked_enemy.enemy_state == Enemy.EnemyState.DIE: return
		if randf() < 0.4:
			locked_enemy.sec_kill(true)
			TextEffect.text_effect_show("秒杀！",TextEffect.TextEffectType.SecKill,locked_enemy.hurt_box.global_position)
		else:
			var total_damage: int = 2 * randi_range(current_data.far_damage_low,current_data.far_damage_high)
			var rate: float = sec_kill_rate_list[soldier_skill_levels[1]-1]
			total_damage += float(locked_enemy.start_data.health) * rate
			TextEffect.text_effect_show("重创！",TextEffect.TextEffectType.SecKill,locked_enemy.hurt_box.global_position)
			locked_enemy.take_damage(total_damage,DataProcess.DamageType.TrueDamage,0,true,self,true,false,)
		
	pass


func take_damage(damage: int, damage_type: DataProcess.DamageType, broken_rate: float, far_attack: bool = false, source: Node2D = null,explosion: bool = false,aoe_attack: bool = false, deadly: bool = true) -> bool:
	var origin_health: int = current_data.health
	var result: bool = super(damage,damage_type,broken_rate,far_attack,source,explosion,aoe_attack,deadly)
	var delta_damage: int = maxi(origin_health - current_data.health,0)
	if source != null:
		if source is Enemy:
			var return_damage: int = float(delta_damage) * current_return_damage_rate
			var enemy: Enemy = source
			enemy.take_damage(return_damage,DataProcess.DamageType.TrueDamage,0,false,)
			#print(return_damage)
	return result


func soldier_skill_level_up(skill_id: int, skill_level: int):
	super(skill_id,skill_level)
	if skill_id == 0:
		current_return_damage_rate = return_damage_list[soldier_skill_levels[0]-1]
	pass


func _process(delta: float) -> void:
	super(delta)
	if ally_state != AllyState.DIE and heal_buff_timer.is_stopped() and soldier_skill_levels[2 ]> 0 and health_bar.value < 0.4:
		heal_buff_timer.start()
		var heal_buff: HealBuff = preload("res://Scenes/Buffs/Allys/skeleton_heal_buff.tscn").instantiate()
		var heal_duration: float = heal_duration_list[soldier_skill_levels[2]-1]
		heal_buff.duration = heal_duration
		buffs.add_child(heal_buff)
	
	if locked_enemy != null:
		sec_kill_sprite.global_position = locked_enemy.hurt_box.global_position
	pass


func die(explosion: bool = false):
	super(explosion)
	sec_kill_sprite.hide()
	pass


func disappear_kill():
	super()
	sec_kill_sprite.hide()
	pass


func get_sec_kill_enemy() -> Enemy:
	var back_enemy_list: Array[Enemy]
	var back_enemy: Enemy
	for body in sec_kill_area.get_overlapping_bodies():
		var enemy: Enemy = body.owner
		if enemy.enemy_type >= Enemy.EnemyType.Super: continue
		back_enemy_list.append(enemy)
	if back_enemy_list.is_empty(): return null
	back_enemy = back_enemy_list[0]
	for enemy in back_enemy_list:
		if enemy.current_data.health > back_enemy.current_data.health: back_enemy = enemy
	
	return back_enemy
	pass
