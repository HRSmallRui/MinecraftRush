extends Enemy

@onready var explosion_area: Area2D = $UnitBody/ExplosionArea

var explosion_damage: int = 200


func anim_offset():
	match enemy_sprite.animation:
		"idle","attack":
			enemy_sprite.position = Vector2(0,-120)
		"move_back":
			enemy_sprite.position = Vector2(0,-85)
		"move_front":
			enemy_sprite.position = Vector2(0,-95)
		"move_normal":
			enemy_sprite.position = Vector2(-15,-95) if enemy_sprite.flip_h else Vector2(15,-95)
	pass


func frame_changed():
	if enemy_sprite.animation == "attack" and enemy_sprite.frame == 14:
		cause_damage()
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


func die_blood(blood_packed_scene: PackedScene = null):
	
	pass


func add_new_buff_tag(tag_name: String, tag_level: int = 1):
	if tag_name == "lightning":
		explosion_area.scale *= 1.5
		explosion_damage  = 250
	pass
