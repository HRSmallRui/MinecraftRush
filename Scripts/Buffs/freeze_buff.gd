extends PropertyBuff

var current_animation: StringName
var current_frame: int
var freeze_sprite: AnimatedSprite2D


func buff_start():
	super()
	if unit is Ally:
		freeze_sprite = unit.ally_sprite
		freeze_sprite.frame_changed.disconnect(unit.frame_changed)
	elif unit is Enemy:
		freeze_sprite = unit.enemy_sprite
		freeze_sprite.frame_changed.disconnect(unit.frame_changed)
		unit.silence_layers += 1
	current_animation = freeze_sprite.animation
	current_frame = freeze_sprite.frame
	unit.set_process(false)
	freeze_sprite.pause()
	pass


func _buff_process(delta: float):
	super(delta)
	#freeze_sprite.animation = current_animation
	#freeze_sprite.frame = current_frame
	pass


func remove_buff():
	unit.set_process(true)
	if unit is Ally:
		if unit.ally_state != Ally.AllyState.DIE:
			freeze_sprite.frame_changed.connect(unit.frame_changed)
	elif unit is Enemy:
		if unit.enemy_state != Enemy.EnemyState.DIE:
			freeze_sprite.frame_changed.connect(unit.frame_changed)
			unit.silence_layers -= 1
		#await get_tree().process_frame
		#if unit.enemy_state != Enemy.EnemyState.DIE:
			#unit.enemy_sprite.play("idle")
	freeze_sprite.play()
	super()
	pass
