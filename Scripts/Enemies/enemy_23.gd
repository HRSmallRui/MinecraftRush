extends Enemy

@onready var shadow: Sprite2D = $UnitBody/Shadow


func anim_offset():
	match enemy_sprite.animation:
		"idle","die":
			enemy_sprite.position = Vector2(5,-300) if enemy_sprite.flip_h else Vector2(-5,-300)
		"move_back","move_front":
			enemy_sprite.position = Vector2(0,-355)
		"move_normal":
			enemy_sprite.position = Vector2(5,-355) if enemy_sprite.flip_h else Vector2(-5,-355)
	pass


func die_audio_play():
	super()
	AudioManager.instance.explosion_dead_body_audio_play()
	shadow.hide()
	pass


func die_blood(blood_packed_scene: PackedScene = null):
	await get_tree().create_timer(1.2,false).timeout
	hide()
	pass
