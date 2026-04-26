extends Enemy

@onready var attack_area: Area2D = $UnitBody/AttackArea
@onready var bite_audio: AudioStreamPlayer = $BiteAudio
@onready var explosion_area: Area2D = $UnitBody/ExplosionArea

var explosion_damage: int = 120

func anim_offset():
	match enemy_sprite.animation:
		"idle","attack":
			enemy_sprite.position = Vector2(-20,-75) if enemy_sprite.flip_h else Vector2(20,-75)
		"move_back":
			enemy_sprite.position = Vector2(0,-70)
		"move_front":
			enemy_sprite.position = Vector2(0,-75)
		"move_normal":
			enemy_sprite.position = Vector2(0,-75)
	pass


func frame_changed():
	if enemy_sprite.animation == "attack" and enemy_sprite.frame == 13:
		bite_audio.play()
		var has_sec_kill: bool
		var attack_count: int
		for body in attack_area.get_overlapping_bodies():
			if attack_count >= 3: break
			var ally: Ally = body.owner
			if ally.ally_type == Ally.AllyType.Soldiers and randf() < 0.1 and !has_sec_kill and ally.ally_level < 4:
				ally.sec_kill(true)
				has_sec_kill = true
			else:
				var damage: int = randi_range(current_data.near_damage_low,current_data.near_damage_high)
				ally.take_damage(damage,DataProcess.DamageType.PhysicsDamage,0,false,self,false,true)
			attack_count += 1
		
		if has_sec_kill:
			var summon_pos: Vector2 = intercepting_marker.global_position + Vector2(0,-20)
			TextEffect.text_effect_show("秒杀！",TextEffect.TextEffectType.SecKill,summon_pos)
	pass


func _process(delta: float) -> void:
	super(delta)
	attack_area.position.x = -60 if enemy_sprite.flip_h else 60
	pass


func add_new_buff_tag(tag_name: String, tag_level: int = 1):
	if tag_name == "lightning":
		explosion_area.scale = Vector2.ONE * 1.2
		explosion_damage  = 150
		remove_from_group("creeper")
	pass


func die_blood(blood_packed_scene: PackedScene = null):
	
	pass


func explosion():
	AudioManager.instance.play_explosion_audio()
	var explosion_effect: AnimatedSprite2D = preload("res://Scenes/Effects/bullet_explosion_effect.tscn").instantiate()
	
	explosion_effect.global_position = self.hurt_box.global_position
	Stage.instance.bullets.add_child(explosion_effect)
	
	for ally_body: UnitBody in explosion_area.get_overlapping_bodies():
		var ally: Ally = ally_body.owner
		ally.take_damage(explosion_damage,DataProcess.DamageType.ExplodeDamage,0,false,self,false,true)
	pass


func die(explosion: bool = false):
	explosion()
	super(false)
	hide()
	pass
