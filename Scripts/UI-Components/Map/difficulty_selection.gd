extends Control


@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var intro_label: Label = $IntroLabel
@onready var easy_card: TextureButton = $EasyCard
@onready var normal_card: TextureButton = $NormalCard
@onready var hard_car: TextureButton = $HardCar


func _on_easy_card_mouse_entered() -> void:
	intro_label.text = "敌人较为脆弱，适合新手"
	intro_label.modulate = Color.GREEN
	easy_card.position.y = 290
	pass # Replace with function body.


func _on_normal_card_mouse_entered() -> void:
	intro_label.text = "中规中矩，不错的挑战"
	intro_label.modulate = Color.ORANGE
	normal_card.position.y = 290
	pass # Replace with function body.


func _on_hard_car_mouse_entered() -> void:
	intro_label.text = "敌人更加顽强，风险更高，谨慎选择"
	intro_label.modulate = Color.RED
	hard_car.position.y = 290
	pass # Replace with function body.


func back_normal_label():
	intro_label.text = "难度可在后续随时更改"
	intro_label.modulate = Color.WHITE
	pass


func _on_hard_car_mouse_exited() -> void:
	back_normal_label()
	hard_car.position.y = 312
	pass # Replace with function body.


func _on_normal_card_mouse_exited() -> void:
	back_normal_label()
	normal_card.position.y = 321
	pass # Replace with function body.


func _on_easy_card_mouse_exited() -> void:
	back_normal_label()
	easy_card.position.y = 312
	pass # Replace with function body.


func _on_easy_card_pressed() -> void:
	input_ignore()
	
	Map.instance.current_sav.difficulty = GameSaver.Difficulty.EASY
	Global.sav_game_sav(Map.instance.current_sav)
	
	create_tween().tween_property(normal_card,"position:x",2020,0.6)
	create_tween().tween_property(hard_car,"position:x",2020,0.4)
	await get_tree().create_timer(0.2).timeout
	create_tween().tween_property(easy_card,"position:x",780,0.4)
	await get_tree().create_timer(0.4).timeout
	animation_player.play("Exit")
	await animation_player.animation_finished
	queue_free()
	Map.instance.can_control = true
	pass # Replace with function body.


func _on_normal_card_pressed() -> void:
	input_ignore()
	
	Map.instance.current_sav.difficulty = GameSaver.Difficulty.NORMAL
	Global.sav_game_sav(Map.instance.current_sav)
	
	create_tween().tween_property(easy_card,"position:x",-340,0.5)
	create_tween().tween_property(hard_car,"position:x",2020,0.5)
	await get_tree().create_timer(0.6).timeout
	animation_player.play("Exit")
	await animation_player.animation_finished
	queue_free()
	Map.instance.can_control = true
	pass # Replace with function body.


func _on_hard_car_pressed() -> void:
	input_ignore()
	
	Map.instance.current_sav.difficulty = GameSaver.Difficulty.HARD
	Global.sav_game_sav(Map.instance.current_sav)
	
	create_tween().tween_property(easy_card,"position:x",-340,0.4)
	create_tween().tween_property(normal_card,"position:x",-340,0.6)
	await get_tree().create_timer(0.2).timeout
	create_tween().tween_property(hard_car,"position:x",780,0.4)
	await get_tree().create_timer(0.4).timeout
	animation_player.play("Exit")
	await animation_player.animation_finished
	queue_free()
	Map.instance.can_control = true
	pass # Replace with function body.


func input_ignore():
	$ClickAudio.play(0.2)
	easy_card.mouse_filter = Control.MOUSE_FILTER_IGNORE
	normal_card.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hard_car.mouse_filter = Control.MOUSE_FILTER_IGNORE
	Map.instance.current_sav.has_selected_difficulty = true
	pass


func _on_tree_exited() -> void:
	Map.instance.difficulty_select_finished.emit()
	pass # Replace with function body.
