extends DefenceTower


@onready var building_progress_bar: TextureProgressBar = $BuildingProgressBar
@onready var building_timer: Timer = $BuildingTimer
@onready var archer: Sprite2D = $Based/Slots/Archer
@onready var barrack: Sprite2D = $Based/Slots/Barrack
@onready var magic: Sprite2D = $Based/Slots/Magic
@onready var bombard: Sprite2D = $Based/Slots/Bombard


func _ready() -> void:
	archer.visible = tower_type == TowerType.Archer
	barrack.visible = tower_type == TowerType.Barrack
	magic.visible = tower_type == TowerType.Magic
	bombard.visible = tower_type == TowerType.Bombard
	pass


func _on_building_timer_timeout() -> void:
	var tower_scene: PackedScene
	match tower_type:
		TowerType.Archer:
			tower_scene = load("res://Scenes/DefenceTowers/ArcherTowers/archer_tower_lv_1.tscn")
		TowerType.Barrack:
			tower_scene = load("res://Scenes/DefenceTowers/BarrackTowers/barrack_tower_lv_1.tscn")
		TowerType.Magic:
			tower_scene = load("res://Scenes/DefenceTowers/MagicTower/magic_tower_lv_1.tscn")
		TowerType.Bombard:
			tower_scene = load("res://Scenes/DefenceTowers/BombardTowers/bombard_tower_lv_1.tscn")
	var new_tower: DefenceTower = tower_scene.instantiate()
	new_tower.based_skin = based_skin
	new_tower.position = position
	get_parent().add_child(new_tower)
	queue_free()
	pass # Replace with function body.


func _process(delta: float) -> void:
	building_progress_bar.value = building_timer.wait_time - building_timer.time_left
	pass
