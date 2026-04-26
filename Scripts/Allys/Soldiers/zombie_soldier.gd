extends Soldier

@onready var jade_die_audio: AudioStreamPlayer = $JadeDieAudio
@onready var jade_die_area: Area2D = $UnitBody/JadeDieArea


func anim_offset():
	match ally_sprite.animation:
		"idle","attack":
			ally_sprite.position = Vector2(-10,-120) if ally_sprite.flip_h else Vector2(5,-120)
		"die":
			ally_sprite.position = Vector2(55,-100) if ally_sprite.flip_h else Vector2(-55,-100)
		"move":
			ally_sprite.position = Vector2(-20,-95) if ally_sprite.flip_h else Vector2(15,-95)
		"jade_die":
			ally_sprite.position = Vector2(-35,-90) if ally_sprite.flip_h else Vector2(30,-90)
	pass


func cause_damage(damage_type: int = 0):
	super(damage_type)
	if soldier_skill_levels[0] > 0:
		var heal_data: int
		match soldier_skill_levels[0]:
			1: heal_data = 5
			2: heal_data = 10
			3: heal_data = 15
		current_data.heal(heal_data)
	pass


func frame_changed():
	if ally_sprite.animation == "attack" and ally_sprite.frame == 14:
		cause_damage()
	if ally_sprite.animation == "jade_die" and ally_sprite.frame == 23:
		jade_die_audio.play()
		var duration: float
		match soldier_skill_levels[2]:
			1: duration = 4
			2: duration = 6
			3: duration = 8
		for ally_body in jade_die_area.get_overlapping_bodies():
			var ally: Ally = ally_body.owner
			if ally == self: continue
			var jade_die_damage_buff: PropertyBuff = preload("res://Scenes/Buffs/TowerBuffs/jade_die_damage_buff.tscn").instantiate()
			jade_die_damage_buff.duration = duration
			jade_die_damage_buff.unit = ally
			ally.buffs.add_child(jade_die_damage_buff)
			var jade_die_heal_buff: HealBuff = preload("res://Scenes/Buffs/jade_die_heal_buff.tscn").instantiate()
			jade_die_heal_buff.duration = duration
			jade_die_heal_buff.unit = ally
			ally.buffs.add_child(jade_die_heal_buff)
	pass


func die(explosion: bool):
	super(explosion)
	if !explosion and soldier_skill_levels[2] > 0:
		ally_sprite.play("jade_die")	
	pass
