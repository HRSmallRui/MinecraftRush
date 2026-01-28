extends SummonAlly

@onready var existing_timer: Timer = $ExistingTimer
@onready var dizness_area: Area2D = $UnitBody/DiznessArea


func _ready() -> void:
	super()
	await get_tree().physics_frame
	await get_tree().physics_frame
	modulate.a = 0
	for body in dizness_area.get_overlapping_bodies():
		var enemy: Enemy = body.owner
		var dizness_buff: PropertyBuff = preload("res://Scenes/Buffs/dizness_buff.tscn").instantiate()
		dizness_buff.buff_tag = "knight_dizness"
		dizness_buff.duration = 1
		enemy.buffs.add_child(dizness_buff)
	existing_timer.wait_time = HeroSkillLibrary.hero_skill_data_library[7][5].existing_time[level-1]
	var target_pos: Vector2 = position
	position += Vector2(-40,0) if randi_range(0,1) == 0 else Vector2(40,0)
	move(target_pos)
	create_tween().tween_property(self,"modulate:a",1,0.5)
	await get_tree().create_timer(1,false).timeout
	existing_timer.start()
	pass


func anim_offset():
	match ally_sprite.animation:
		"attack","idle":
			ally_sprite.position = Vector2(10,-105) if ally_sprite.flip_h else Vector2(-15,-105)
		"move":
			ally_sprite.position = Vector2(-5,-95) if ally_sprite.flip_h else Vector2(0,-95)
	pass


func frame_changed():
	if ally_sprite.animation == "attack" and ally_sprite.frame == 20:
		if current_intercepting_enemy != null:
			var damage: int = randi_range(current_data.near_damage_low,current_data.near_damage_high)
			current_intercepting_enemy.take_damage(damage,DataProcess.DamageType.TrueDamage,0,false,self,false,false,)
			AudioManager.instance.battle_audio_play()
	pass


func _on_existing_timer_timeout() -> void:
	die(false)
	pass # Replace with function body.


func die(explosion: bool = false):
	super(explosion)
	rebirth_timer.stop()
	existing_timer.stop()
	var target_pos: Vector2 = position
	target_pos += Vector2(50,0) if ally_sprite.flip_h else Vector2(-50,0)
	move_animation(target_pos)
	create_tween().tween_property(self,"modulate:a",0,0.4)
	await move_tween.finished
	queue_free()
	pass


func rebirth():
	
	pass
