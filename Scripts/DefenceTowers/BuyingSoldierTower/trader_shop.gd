extends BuyingSoldierTower

@export var max_wait_time: float
@export var min_wait_time: float
@export_multiline var trader_words_list: Array[String]
@export_multiline var trader_words_finished_list: Array[String]
@export var oil_scene: PackedScene

@onready var wandering_trader: AnimatedSprite2D = $WanderingTrader
@onready var hello_timer: Timer = $HelloTimer
@onready var dialog_panel: DialogPanel = $WanderingTrader/DialogPanel
@onready var skill_2_timer: Timer = $Skill2Timer
@onready var skill_2_area: Area2D = $Skill2Area

var last_word: String


func _on_hello_timer_timeout() -> void:
	hello_timer.wait_time = randf_range(min_wait_time,max_wait_time)
	wandering_trader.play("hello")
	pass # Replace with function body.


func _on_tower_button_pressed() -> void:
	super()
	if dialog_panel.visible: return
	
	var list: Array[String]
	if tower_skill_levels == [3,3,2]:
		list = trader_words_finished_list.duplicate()
	else:
		list = trader_words_list.duplicate()
	
	list.erase(last_word)
	last_word = list.pick_random() as String
	dialog_panel.dialog(last_word,4)
	pass


func _on_tower_area_body_exited(body: Node2D) -> void:
	if tower_skill_levels[0] > 0:
		var enemy: Enemy = body.owner
		if enemy.enemy_state == Enemy.EnemyState.DIE:
			var extra_rate: float
			match tower_skill_levels[0]:
				1: extra_rate = 0.1
				2: extra_rate = 0.2
				3: extra_rate = 0.3
			var extra_money: int = int(float(enemy.bounty) * extra_rate)
			if extra_money == 0: return
			Stage.instance.current_money += extra_money
			var money_effect: MoneyGetEffect = preload("res://Scenes/Effects/money_get_effect.tscn").instantiate()
			money_effect.position = enemy.hurt_box.global_position
			money_effect.money_count = extra_money
			money_effect.z_index += 1
			#print(extra_money)
			Stage.instance.bullets.add_child(money_effect)
			money_effect.gold.stop()
	pass # Replace with function body.


func _physics_process(delta: float) -> void:
	if tower_skill_levels[2] > 0 and skill_2_timer.is_stopped() and skill_2_area.has_overlapping_bodies():
		skill_2_timer.start()
		var enemy: Enemy = skill_2_area.get_overlapping_bodies().pick_random().owner
		var shell: Shell = oil_scene.instantiate()
		shell.position = global_position
		shell.target_position = enemy.global_position
		match tower_skill_levels[2]:
			1:
				shell.damage = 40
				shell.low_damage = 20
			2:
				shell.damage = 60
				shell.low_damage = 30
		shell.special_skill_level = tower_skill_levels[2]
		Stage.instance.bullets.add_child(shell)
	pass
