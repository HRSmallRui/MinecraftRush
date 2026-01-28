extends SkillConditionArea2D

@onready var shot_timer: Timer = $ShotTimer
@onready var fog_audio: AudioStreamPlayer = $FogAudio

var damage: int
var buff_scene: PackedScene


func _ready() -> void:
	fog_audio.play(0.4)
	match skill_level:
		1: 
			damage = 4
			buff_scene = preload("res://Scenes/Buffs/TowerBuffs/WitchTower/witch_fog_buff.tscn")
		2: 
			damage = 6
			buff_scene = preload("res://Scenes/Buffs/TowerBuffs/WitchTower/witch_fog_buff_lv2.tscn")
		3: 
			damage = 8
			buff_scene = preload("res://Scenes/Buffs/TowerBuffs/WitchTower/witch_fog_buff_lv3.tscn")
	pass


func _on_timer_timeout() -> void:
	monitoring = false
	shot_timer.stop()
	var disappear_tween: Tween = create_tween()
	disappear_tween.tween_property(self,"modulate:a",0,0.4)
	await disappear_tween.finished
	queue_free()
	pass # Replace with function body.


func _on_shot_timer_timeout() -> void:
	for body in get_overlapping_bodies():
		var unit = body.owner
		if unit is Enemy:
			var enemy: Enemy = body.owner
			var enemy_group = enemy.get_groups()
			if!(enemy_group.has("undead") or enemy_group.has("no_live")):
				enemy.take_damage(damage,DataProcess.DamageType.TrueDamage,0,)
			var buff: PropertyBuff = buff_scene.instantiate()
			enemy.buffs.add_child(buff)
	pass # Replace with function body.
