extends ShooterBullet

@export var hit_effect_scene: PackedScene

@onready var plugin_area: Area2D = $PluginArea

var has_summon_hit_effect: bool = false


func enemy_take_damage(enemy:Enemy):
	super(enemy)
	var salem_plugin_debuff: DotBuff = preload("res://Scenes/Buffs/Salem/salem_plugin_buff.tscn").instantiate()
	salem_plugin_debuff.passive_level = special_skill_level
	salem_plugin_debuff.dead_explosion_level = bullet_special_tag_levels["explosion"]
	enemy.buffs.add_child(salem_plugin_debuff)
	if bullet_special_tag_levels["aoe"] > 0:
		var smoke_effect: AnimatedSprite2D = preload("res://Scenes/Effects/bullet_explosion_effect.tscn").instantiate()
		smoke_effect.modulate = Color.DARK_GREEN
		smoke_effect.position = position
		smoke_effect.scale *= 0.6
		Stage.instance.bullets.add_child(smoke_effect)
		for body in plugin_area.get_overlapping_areas():
			var now_enemy: Enemy = body.owner
			if now_enemy == enemy: continue
			var damage: int = HeroSkillLibrary.hero_skill_data_library[7][3].aoe_damage[bullet_special_tag_levels["aoe"]-1]
			now_enemy.take_damage(damage,DataProcess.DamageType.MagicDamage,0,false,null,false,true,)
			var plugin_debuff: DotBuff = preload("res://Scenes/Buffs/Salem/salem_plugin_buff.tscn").instantiate()
			plugin_debuff.passive_level = special_skill_level
			plugin_debuff.dead_explosion_level = bullet_special_tag_levels["explosion"]
			now_enemy.buffs.add_child(plugin_debuff)
	pass


func _ready() -> void:
	free_timer.wait_time = (target_position - self.global_position).length() / bullet_speed + 0.1
	super()
	pass


func hit_effect():
	if has_summon_hit_effect: return
	has_summon_hit_effect = true
	var hit_effect = hit_effect_scene.instantiate() as AnimatedSprite2D
	hit_effect.position = self.global_position + (target_position - global_position).normalized() * 15
	if move_type > MoveType.Trace:
		hit_effect.position = bullet_sprite.global_position + (target_position - global_position).normalized() * 15
	get_parent().add_child(hit_effect)
	pass


func after_attack_process(unit: Node2D):
	hit_effect()
	if unit == null: return
	if unit is Enemy:
		unit.hurt_audio_play(damage_source)
		var show_text: String
		match randi_range(0,1):
			0: show_text = "呜！"
			1: show_text = "咻！"
		if unit.enemy_state == Enemy.EnemyState.DIE:
			TextEffect.text_effect_show(show_text,TextEffect.TextEffectType.Magic,position + Vector2(0,-10))
		elif randf_range(0,1) < 0.1:
			TextEffect.text_effect_show(show_text,TextEffect.TextEffectType.Magic,position + Vector2(0,-10))
	pass


func _on_free_timer_timeout():
	hit_effect()
	super()
	pass
