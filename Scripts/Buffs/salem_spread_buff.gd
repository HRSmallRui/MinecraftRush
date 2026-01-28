extends BuffClass

@onready var spread_area: Area2D = $SpreadArea
@onready var spread_timer: Timer = $SpreadTimer
@onready var skill_particle_shooter: GPUParticles2D = $SkillParticleShooter

var passive_level: int
var dead_explosion_level: int


func buff_start():
	super()
	skill_particle_shooter.amount_ratio = 0
	create_tween().tween_property(skill_particle_shooter,"amount_ratio",1,0.4)
	pass


func _process(delta: float) -> void:
	super(delta)
	var owner_enemy: Enemy = unit
	if !owner_enemy.visible:
		end()
		set_process(false)
	pass


func _on_spread_timer_timeout() -> void:
	for body in spread_area.get_overlapping_bodies():
		var enemy: Enemy = body.owner
		var plugin_buff: BuffClass = load("res://Scenes/Buffs/Salem/salem_plugin_buff.tscn").instantiate()
		plugin_buff.passive_level = passive_level
		plugin_buff.dead_explosion_level = dead_explosion_level
		enemy.buffs.add_child(plugin_buff)
	pass # Replace with function body.


func end():
	create_tween().tween_property(self,"modulate:a",0,0.4)
	spread_timer.stop()
	pass


func buff_condition() -> bool:
	return false
	pass


func remove_buff():
	end()
	await get_tree().create_timer(0.5,false).timeout
	super()
	pass
