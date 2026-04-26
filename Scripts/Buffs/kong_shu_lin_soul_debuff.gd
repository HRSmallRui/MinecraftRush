extends PropertyBuff

@export var soul_scene: PackedScene

@onready var plugin_effect: Sprite2D = $PluginEffect

var enemy: Enemy


func buff_start():
	super()
	enemy = unit
	pass


func _buff_process(delta: float):
	super(delta)
	plugin_effect.global_position = enemy.hurt_box.global_position
	pass


func remove_buff():
	super()
	if enemy.enemy_state == Enemy.EnemyState.DIE:
		var kongshulin: Hero = Stage.instance.hero_list[0]
		kongshulin.call_deferred("get_live_layer")
		var soul: Bullet = soul_scene.instantiate()
		soul.position = enemy.hurt_box.global_position
		soul.target_position = kongshulin.hurt_box.global_position
		Stage.instance.bullets.add_child(soul)
	pass
