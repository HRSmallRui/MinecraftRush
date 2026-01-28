extends SkillButton

@onready var condition_area: Area2D = $ConditionArea
@onready var sec_kill_effect: Sprite2D = $SecKillEffect
@onready var preparation_audio: AudioStreamPlayer = $PreparationAudio
@onready var kill_animation_player: AnimationPlayer = $KillAnimationPlayer
@onready var sec_kill_audio: AudioStreamPlayer = $SecKillAudio

var effect_enable: bool = false

var locked_enemy: Enemy
var skill_level: int
var damage: int
var enemy_list: Array[Enemy]


func _ready() -> void:
	super()
	remove_child(condition_area)
	remove_child(sec_kill_effect)
	Stage.instance.bullets.add_child(condition_area)
	Stage.instance.bullets.add_child(sec_kill_effect)
	skill_level = Stage.instance.stage_sav.hero_sav[3].skill_levels[4]
	cooling_time = HeroSkillLibrary.hero_skill_data_library[3][5].CD[skill_level]
	damage = HeroSkillLibrary.hero_skill_data_library[3][5].damage[skill_level]
	pass


func skill_unlease_condition():
	#print(condition_area.get_overlapping_areas())
	if condition_area.has_overlapping_areas():
		var enemy: Enemy = condition_area.get_overlapping_areas()[0].owner
		if enemy != null:
			locked_enemy = enemy
			skill_unlease()
	elif !enemy_list.is_empty():
		var enemy: Enemy = enemy_list[0]
		if enemy != null:
			locked_enemy = enemy
			skill_unlease()
	pass


func _process(delta: float) -> void:
	super(delta)
	condition_area.position = Stage.instance.get_local_mouse_position()
	sec_kill_effect.visible = effect_enable
	if locked_enemy != null:
		sec_kill_effect.position = locked_enemy.hurt_box.global_position
	pass


func _physics_process(delta: float) -> void:
	condition_area.position = Stage.instance.get_local_mouse_position()
	pass


func skill_unlease():
	super()
	effect_enable = true
	preparation_audio.play()
	await get_tree().create_timer(1,false).timeout
	kill_animation_player.play("kill")
	pass


func sec_kill():
	if locked_enemy == null:
		AudioManager.instance.shoot_audio_2.play()
		effect_enable = false
	elif !locked_enemy.hurt_box.monitorable or locked_enemy.hurt_box.get_child(0).disabled:
		AudioManager.instance.shoot_audio_2.play()
		effect_enable = false
	else:
		sec_kill_audio.play()
		var show_text: String
		if locked_enemy.enemy_type < Enemy.EnemyType.MiniBoss:
			locked_enemy.sec_kill(true)
			show_text = "抹除"
		else:
			locked_enemy.take_damage(damage,DataProcess.DamageType.TrueDamage,0,true)
			show_text = "重创"
		
		TextEffect.text_effect_show(show_text,TextEffect.TextEffectType.SecKill,locked_enemy.hurt_box.global_position)
		await get_tree().create_timer(0.1,false).timeout
		effect_enable = false
	pass


func _on_condition_area_area_entered(area: Area2D) -> void:
	#print("enter,",area)
	enemy_list.append(area.owner)
	pass # Replace with function body.


func _on_condition_area_area_exited(area: Area2D) -> void:
	#print("exit,",area)
	enemy_list.erase(area.owner)
	pass # Replace with function body.
