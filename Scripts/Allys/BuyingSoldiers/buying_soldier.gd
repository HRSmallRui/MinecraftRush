extends Ally
class_name BuyingSoldier

@export var linked_buying_tower: BuyingSoldierTower
@export var name_list: PackedStringArray

var buying_soldier_brothers: Array[BuyingSoldier]


func _ready() -> void:
	super()
	ally_name = name_list[randi_range(0,name_list.size()-1)]
	pass


func die(explosion: bool = false):
	super(explosion)
	linked_buying_tower.buying_soldier_list.erase(self)
	linked_buying_tower.update_soldiers_position()
	linked_buying_tower.update_buying_soldier_brothers()
	await get_tree().create_timer(8,false).timeout
	queue_free()
	pass


func rebirth():
	
	pass


func idle_process():
	super()
	if current_intercepting_enemy == null and ally_state == AllyState.IDLE:
		for soldier in buying_soldier_brothers:
			if soldier.ally_state == AllyState.BATTLE and soldier.current_intercepting_enemy != null:
				var enemy = soldier.current_intercepting_enemy as Enemy
				current_intercepting_enemy = enemy
				enemy.current_intercepting_units.append(self)
				move_to_intercept(enemy.intercepting_marker.global_position)
				return
	pass
