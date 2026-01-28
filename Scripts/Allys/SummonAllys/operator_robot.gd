extends SummonAlly

@onready var walk_audio: AudioStreamPlayer = $WalkAudio
@onready var attack_audio: AudioStreamPlayer = $AttackAudio
@onready var rebirth_audio: AudioStreamPlayer = $RebirthAudio
@onready var die_audio: AudioStreamPlayer = $DieAudio
@onready var sec_kill_audio: AudioStreamPlayer = $SecKillAudio

var sec_kill_possible: float = 0.04


func anim_offset():
	match ally_sprite.animation:
		"attack","idle":
			ally_sprite.position = Vector2(25,-150) if ally_sprite.flip_h else Vector2(-25,-150)
		"die":
			ally_sprite.position = Vector2(10,-75) if ally_sprite.flip_h else Vector2(-10,-75)
		"move":
			ally_sprite.position = Vector2(-25,-150) if ally_sprite.flip_h else Vector2(20,-150)
		"rebirth":
			ally_sprite.position = Vector2(-10,-90) if ally_sprite.flip_h else Vector2(5,-90)
		"sec_kill":
			ally_sprite.position = Vector2(15,-265) if ally_sprite.flip_h else Vector2(-20,-265)
	pass


func frame_changed():
	if ally_sprite.animation == "move":
		if ally_sprite.frame == 2 or ally_sprite.frame == 18:
			walk_audio.play()
	if ally_sprite.animation == "attack":
		if ally_sprite.frame == 6: attack_audio.play()
		elif ally_sprite.frame == 11: cause_damage()
	if ally_sprite.animation == "sec_kill":
		if ally_sprite.frame == 6: sec_kill_audio.play()
		if ally_sprite.frame == 30: sec_kill_audio.stop()
		if ally_sprite.frame == 17 and current_intercepting_enemy != null:
			if current_intercepting_enemy.enemy_type < Enemy.EnemyType.Super:
				TextEffect.text_effect_show("秒杀",TextEffect.TextEffectType.SecKill,current_intercepting_enemy.hurt_box.global_position + Vector2(0,-30))
				current_intercepting_enemy.sec_kill(true)
				Achievement.achieve_int_add("OperatorSeckill",1,666)
	pass


func _ready() -> void:
	ally_sprite.play("rebirth")
	translate_to_new_state(AllyState.SPECIAL)
	rebirth_audio.play()
	super()
	pass


func die(explosion: bool = false):
	super(explosion)
	die_audio.play()
	pass


func rebirth():
	rebirth_audio.play()
	ally_sprite.play("rebirth")
	await ally_sprite.animation_finished
	super()
	pass


func battle():
	if ally_sprite.animation == "idle" and normal_attack_timer.is_stopped() and current_intercepting_enemy != null:
		if current_intercepting_enemy.enemy_type < Enemy.EnemyType.Super:
			if randf_range(0,1) < sec_kill_possible:
				ally_sprite.play("sec_kill")
				normal_attack_timer.start()
				return
	super()
	pass
