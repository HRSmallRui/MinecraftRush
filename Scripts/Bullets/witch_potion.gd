extends ShooterBullet

enum PotionType{
	DAMAGE,
	POISON,
	WEAKNESS,
	HEAL_IMMEDI,
	REGON
}

@export var potion_type: PotionType
@export var potion_color: Color
@export var check_area: Area2D


func ally_take_damage(ally: Ally):
	super(ally)
	summon_potion_area()
	pass


func summon_potion_area():
	var potion_slash_effect: AnimatedSprite2D = preload("res://Scenes/Effects/potion_slash_effect_with_audio.tscn").instantiate()
	potion_slash_effect.position = position
	potion_slash_effect.modulate = potion_color
	Stage.instance.bullets.add_child(potion_slash_effect)
	
	match potion_type:
		PotionType.POISON:
			poison_release()
		PotionType.WEAKNESS:
			weakness_release()
		PotionType.HEAL_IMMEDI:
			heal_imedi()
		PotionType.REGON:
			regon_release()
	pass


func _on_free_timer_timeout() -> void:
	super()
	summon_potion_area()
	pass


func poison_release():
	if check_area == null: return
	for area in check_area.get_overlapping_areas():
		var ally: Ally = area.owner
		var poison_buff: DotBuff = preload("res://Scenes/Buffs/Enemies/witch_poison_debuff.tscn").instantiate()
		ally.buffs.add_child(poison_buff)
	pass


func weakness_release():
	if check_area == null: return
	for area in check_area.get_overlapping_areas():
		var ally: Ally = area.owner
		var weakness_buff: PropertyBuff = preload("res://Scenes/Buffs/Enemies/witch_lower_damage_debuff.tscn").instantiate()
		ally.buffs.add_child(weakness_buff)
	pass


func heal_imedi():
	if check_area == null: return
	for body in check_area.get_overlapping_bodies():
		var enemy: Enemy = body.owner
		enemy.current_data.heal(80)
	pass


func regon_release():
	if check_area == null: return
	for body in check_area.get_overlapping_bodies():
		var enemy: Enemy = body.owner
		var witch_heal_buff: HealBuff = preload("res://Scenes/Buffs/Enemies/witch_heal_buff.tscn").instantiate()
		enemy.buffs.add_child(witch_heal_buff)
	pass
