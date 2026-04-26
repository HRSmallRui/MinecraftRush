extends SkillConditionArea2D

@onready var flag: Node2D = $Flag
@onready var shadow: Sprite2D = $Shadow
@onready var buff_effect: Sprite2D = $BuffEffect
@onready var duration_timer: Timer = $DurationTimer
@onready var shot_timer: Timer = $ShotTimer


func _ready() -> void:
	duration_timer.wait_time = HeroSkillLibrary.hero_skill_data_library[8][5].duration[skill_level]
	flag.modulate.a = 0
	flag.position.y -= 40
	create_tween().tween_property(flag,"position:y",flag.position.y + 40, 0.3)
	create_tween().tween_property(flag,"modulate:a",1,0.3)
	create_tween().tween_property(shadow,"modulate:a",1,0.3)
	create_tween().tween_property(buff_effect,"modulate:a",0.6,0.5)
	await get_tree().create_timer(0.5,false).timeout
	duration_timer.start()
	shot_timer.start()
	pass


func _on_timer_timeout() -> void:
	shot_timer.stop()
	var disappear_tween: Tween = create_tween()
	disappear_tween.tween_property(self,"modulate:a",0,0.5)
	await disappear_tween.finished
	queue_free()
	pass # Replace with function body.


func _on_shot_timer_timeout() -> void:
	for body in get_overlapping_bodies():
		var ally: Ally = body.owner
		var upgrade_buff: PropertyBuff = preload("res://Scenes/Buffs/Johnny/johnny_upgrade_buff.tscn").instantiate()
		ally.buffs.add_child(upgrade_buff)
	
	for area in get_overlapping_areas():
		if !area.owner is DefenceTower: continue
		var tower: DefenceTower = area.owner
		var upgrade_buff: TowerBuff = preload("res://Scenes/TowerBuffs/johnny_tower_buff.tscn").instantiate()
		tower.tower_buffs.add_child(upgrade_buff)
	pass # Replace with function body.
