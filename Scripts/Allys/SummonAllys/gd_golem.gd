extends SummonAlly

enum PokeType{
	Spade,
	Heart,
	Club,
	Diamond
}

@export var poke_type: PokeType
@export var dizness_buff_scene: PackedScene
@export var explosion_effect_scene: PackedScene
@export var smoke_effect_scene: PackedScene
@export var die_explosion_damage: DamageBlock

@onready var existing_timer: Timer = $ExistingTimer
@onready var heal_area: Area2D = $UnitBody/HealArea
@onready var explosion_attack_area: Area2D = $UnitBody/ExplosionAttackArea
@onready var heal_shot_timer: Timer = $HealShotTimer


func _ready() -> void:
	super()
	if poke_type != PokeType.Heart:
		heal_area.queue_free()
		heal_shot_timer.queue_free()
	else:
		heal_shot_timer.start()
	
	modulate.a = 0
	var target_pos: Vector2 = position
	position += Vector2(-40,0) if randi_range(0,1) == 0 else Vector2(40,0)
	move(target_pos)
	create_tween().tween_property(self,"modulate:a",1,0.5)
	await get_tree().create_timer(1,false).timeout
	existing_timer.start()
	pass


func anim_offset():
	match ally_sprite.animation:
		"idle","attack":
			ally_sprite.position = Vector2(-10,-80) if ally_sprite.flip_h else Vector2(10,-80)
		"move":
			ally_sprite.position = Vector2(0,-85)
	pass


func frame_changed():
	if ally_sprite.animation == "attack" and ally_sprite.frame == 11:
		cause_damage()
	pass


func _on_existing_timer_timeout() -> void:
	die(false)
	pass # Replace with function body.


func leave():
	var target_pos: Vector2 = position
	target_pos += Vector2(50,0) if ally_sprite.flip_h else Vector2(-50,0)
	move_animation(target_pos)
	create_tween().tween_property(self,"modulate:a",0,0.4)
	await move_tween.finished
	queue_free()
	pass


func die(explosion: bool):
	super(explosion)
	rebirth_timer.stop()
	if poke_type == PokeType.Diamond:
		die_explosion()
	else:
		leave()
	pass


func die_explosion():
	hide()
	AudioManager.instance.play_explosion_audio()
	var explosion_effect: AnimatedSprite2D = explosion_effect_scene.instantiate()
	explosion_effect.position = position
	Stage.instance.bullets.add_child(explosion_effect)
	var smoke_effect: AnimatedSprite2D = smoke_effect_scene.instantiate()
	smoke_effect.position= position
	Stage.instance.bullets.add_child(smoke_effect)
	for body in explosion_attack_area.get_overlapping_bodies():
		var enemy: Enemy = body.owner
		var damage: int = randi_range(die_explosion_damage.damage_low,die_explosion_damage.damage_high)
		enemy.take_damage(damage,DataProcess.DamageType.ExplodeDamage,0,false,null,true,true,)
	if current_intercepting_enemy != null:
		current_intercepting_enemy.current_intercepting_units.erase(self)
	queue_free()
	pass


func _on_heal_shot_timer_timeout() -> void:
	for body in heal_area.get_overlapping_bodies():
		var ally: Ally = body.owner
		if ally == self: continue
		ally.current_data.heal(6)
	pass # Replace with function body.


func on_normal_attack_hit(target_enemy: Enemy):
	if poke_type == PokeType.Spade and randf() < 0.4:
		var dizness_buff: DiznessBuff = dizness_buff_scene.instantiate()
		dizness_buff.duration = 1
		dizness_buff.buff_tag = "spade_dizness"
		target_enemy.buffs.add_child(dizness_buff)
	pass


func take_damage(damage: int, damage_type: DataProcess.DamageType, broken_rate: float, far_attack: bool = false, source: Node2D = null,explosion: bool = false,aoe_attack: bool = false, deadly: bool = true) -> bool:
	if source != null and poke_type == PokeType.Club and randf() < 0.5:
		if source is Enemy:
			damage = float(damage) * 0.1
			TextEffect.text_effect_show("免伤",TextEffect.TextEffectType.Magic,hurt_box.global_position + Vector2(0,-20))
	var result: bool = super(damage,damage_type,broken_rate,far_attack,source,explosion,aoe_attack,deadly)
	return result
