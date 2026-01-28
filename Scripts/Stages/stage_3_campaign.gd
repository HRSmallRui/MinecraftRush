extends Stage


@onready var explosion_marker: Marker2D = $ExplosionMarker


func _ready() -> void:
	super()
	for block: Array in stage_sav.tower_unlock_sav:
		block[2] = true
	pass


func wave_tip(wave_count: int):
	match wave_count:
		7:
			tips_container.add_child(preload("res://Scenes/UI-Components/TipButtons/magic_defence_tip_button.tscn").instantiate())
		9:
			await get_tree().create_timer(15,false).timeout
			var explosion_effect: AnimatedSprite2D = preload("res://Scenes/Effects/bullet_explosion_effect.tscn").instantiate()
			explosion_effect.position = explosion_marker.global_position
			explosion_effect.scale *= 3
			bullets.add_child(explosion_effect)
			AudioManager.instance.play_explosion_audio()
			stage_camera.position = explosion_marker.position
	pass


func tower_check():
	var tower_lv3_finished: Array[bool] = [false,false,false,false]
	for tower: DefenceTower in towers.get_children():
		if tower.tower_level >= 3:
			tower_lv3_finished[tower.tower_type] = true
			
	for value in tower_lv3_finished:
		if !value: return
	
	Achievement.achieve_complete("TowerLV3")
	
	pass
