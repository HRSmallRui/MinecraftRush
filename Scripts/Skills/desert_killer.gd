extends Node2D
class_name DesertSentryKillingSkill


@onready var killing_anim: AnimatedSprite2D = $KillingAnim
@onready var killing_audio: AudioStreamPlayer = $KillingAudio

var skill_damage: int
var killing_enemy: Enemy
var killing_possibile: float
var desert_sentry_tower: DesertSentryTower


func _ready() -> void:
	killing_anim.frame_changed.connect(frame_changed)
	var dizness_buff: PropertyBuff = preload("res://Scenes/Buffs/dizness_buff.tscn").instantiate()
	dizness_buff.duration = 1.5
	#dizness_buff.immune_groups.erase("boss")
	dizness_buff.buff_tag = "killing_dizness"
	dizness_buff.unit = killing_enemy
	killing_enemy.buffs.add_child(dizness_buff)
	position = killing_enemy.position
	position.x += killing_enemy.battle_length / 5 if killing_enemy.enemy_sprite.flip_h else -killing_enemy.battle_length / 5
	scale.x *= -1 if position.x > killing_enemy.global_position.x else 1
	await get_tree().create_timer(0.1,false).timeout
	killing_anim.play()
	pass


func frame_changed():
	if killing_anim.frame == 10:
		killing_audio.play()
		if killing_enemy.enemy_state == Enemy.EnemyState.DIE: return
		#print(killing_possibile)
		if killing_enemy.enemy_type >= Enemy.EnemyType.Super or randf_range(0,1) >= killing_possibile:
			killing_enemy.take_damage(skill_damage,DataProcess.DamageType.TrueDamage,0,true)
			TextEffect.text_effect_show("重创",TextEffect.TextEffectType.SecKill,killing_enemy.hurt_box.global_position + Vector2(randf_range(-10,10),randf_range(-15,0)))
		else:
			killing_enemy.sec_kill(true)
			TextEffect.text_effect_show("秒杀",TextEffect.TextEffectType.SecKill,killing_enemy.hurt_box.global_position + Vector2(randf_range(-10,10),randf_range(-15,0)))
			Achievement.achieve_int_add("DeSentrySeckill",1,47)
	pass


func _on_killing_anim_animation_finished() -> void:
	var disappear_tween: Tween = create_tween()
	disappear_tween.tween_property(self,"modulate:a",0,0.4)
	await disappear_tween.finished
	queue_free()
	if desert_sentry_tower == null: return
	desert_sentry_tower.skill1_is_releasing = false
	desert_sentry_tower.desert_shooter.show()
	pass # Replace with function body.
