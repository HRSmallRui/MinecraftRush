extends Enemy

@onready var relay_timer: Timer = $RelayTimer

var origin_enemy: Enemy


func _ready() -> void:
	super()
	Achievement.achieve_int_add("MagicianGold",1,120)
	enemy_sprite.flip_h = direction.x < 0
	Stage.instance.tree_exiting.connect(on_stage_exist)
	start_data.health = float(origin_enemy.start_data.health) * 0.5
	current_data.health = float(origin_enemy.current_data.health) * 0.5
	pass


func move_process(delta: float):
	
	pass


func anim_offset():
	if enemy_sprite.animation == "idle":
		enemy_sprite.position = Vector2(0,-105)
	elif enemy_sprite.animation == "die":
		enemy_sprite.position = Vector2(-45,-85) if enemy_sprite.flip_h else Vector2(50,-85)
	pass


func _on_timer_timeout() -> void:
	for ally in current_intercepting_units:
		ally.current_intercepting_enemy = null
	current_intercepting_units.clear()
	#origin_enemy.current_intercepting_units = current_intercepting_units.duplicate()
	translate_to_new_state(EnemyState.DIE)
	get_parent().add_child(origin_enemy)
	origin_enemy.current_data.health = 2 * current_data.health
	hide()
	if Stage.instance.information_bar.current_check_member == self:
		Stage.instance.ui_process(origin_enemy)
	delay_free()
	pass # Replace with function body.


func die(explosion: bool = false):
	super(explosion)
	relay_timer.stop()
	on_stage_exist()
	pass


func disappear_kill():
	super()
	relay_timer.stop()
	on_stage_exist()
	pass


func battle():
	
	pass


func on_stage_exist():
	if origin_enemy == null: return
	origin_enemy.queue_free()
	pass


func die_blood(blood_packed_scene: PackedScene = preload("res://Scenes/Effects/blood.tscn")):
	
	pass
