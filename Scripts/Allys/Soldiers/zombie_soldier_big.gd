extends Soldier

@export var dizness_possible_list: Array[float]
@export var aoe_damage_list: Array[DamageBlock]
@export var super_attack_damage_list: Array[int]
@export var super_attack_heal_list: Array[int]
@export var immune_rate_list: Array[float]
@export var return_damage_rate_list: Array[float]
@export var defence_possible_list: Array[float]

@onready var aoe_hit_audio: AudioStreamPlayer = $AoeHitAudio
@onready var aoe_attack_area: Area2D = $UnitBody/AoeAttackArea
@onready var defence_audio: AudioStreamPlayer = $DefenceAudio
@onready var super_attack_audio: AudioStreamPlayer = $SuperAttackAudio
@onready var skill_2_timer: Timer = $Skill2Timer


func anim_offset():
	match ally_sprite.animation:
		"idle","attack":
			ally_sprite.position = Vector2(-10,-155) if ally_sprite.flip_h else Vector2(10,-155)
		"die":
			ally_sprite.position = Vector2(-60,-135) if ally_sprite.flip_h else Vector2(60,-135)
		"move":
			ally_sprite.position = Vector2(25,-135) if ally_sprite.flip_h else Vector2(-25,-135)
		"defence":
			ally_sprite.position = Vector2(60,-205) if ally_sprite.flip_h else Vector2(-55,-205)
		"super_attack":
			ally_sprite.position = Vector2(-55,-185) if ally_sprite.flip_h else Vector2(60,-185)
	pass


func frame_changed():
	if ally_sprite.animation == "attack" and ally_sprite.frame == 25:
		cause_damage()
		aoe_hit_audio.play()
		if soldier_skill_levels[0] > 0:
			for body in aoe_attack_area.get_overlapping_bodies():
				var enemy: Enemy = body.owner
				if randf() < dizness_possible_list[soldier_skill_levels[0]-1]:
					var dizness_buff: DiznessBuff = preload("res://Scenes/Buffs/dizness_buff.tscn").instantiate()
					dizness_buff.duration = 1.5
					dizness_buff.buff_tag = "zombie_big_dizness"
					enemy.buffs.add_child(dizness_buff)
				if enemy == current_intercepting_enemy: continue
				var damage_block: DamageBlock = aoe_damage_list[soldier_skill_levels[0]-1]
				var damage: int = randi_range(damage_block.damage_low,damage_block.damage_high)
				enemy.take_damage(damage,DataProcess.DamageType.PhysicsDamage,0,false,self,false,true,)
	
	if ally_sprite.animation == "super_attack" and ally_sprite.frame == 21:
		super_attack_audio.play()
		var heal_data: int = super_attack_heal_list[soldier_skill_levels[1]-1]
		current_data.heal(heal_data)
		var damage: int = super_attack_damage_list[soldier_skill_levels[1]-1]
		for body in aoe_attack_area.get_overlapping_bodies():
			var enemy: Enemy = body.owner
			enemy.take_damage(damage,DataProcess.DamageType.TrueDamage,0,false,self,true,true)
	pass


func battle():
	if soldier_skill_levels[1] > 0 and skill_2_timer.is_stopped():
		translate_to_new_state(AllyState.SPECIAL)
		ally_sprite.play("super_attack")
		skill_2_timer.start()
		return
	super()
	pass


func take_damage(damage: int, damage_type: DataProcess.DamageType, broken_rate: float, far_attack: bool = false, source: Node2D = null,explosion: bool = false,aoe_attack: bool = false, deadly: bool = true) -> bool:
	#var origin_health: int = current_data.health
	#var is_defence: bool
	if soldier_skill_levels[2] > 0 and source != null:
		var defence_possible: float = defence_possible_list[soldier_skill_levels[2]-1]
		#print(defence_possible)
		if source is Enemy and !far_attack and randf() < defence_possible:
			#is_defence = true
			translate_to_new_state(AllyState.SPECIAL)
			ally_sprite.play("defence")
			defence_audio.play()
			var immue_rate: float = immune_rate_list[soldier_skill_levels[2]-1]
			var return_damage_rate: float = return_damage_rate_list[soldier_skill_levels[2]-1]
			var return_damage: int = float(damage) * return_damage_rate
			damage = float(damage) * (1-immue_rate)
			var enemy: Enemy = source as Enemy
			enemy.take_damage(return_damage,DataProcess.DamageType.TrueDamage,0,)
			#print(return_damage)
	var result: bool = super(damage,damage_type,broken_rate,far_attack,source,explosion,aoe_attack,deadly)
	return result
	pass
