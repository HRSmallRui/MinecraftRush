extends TextureButton
class_name TowerButton

const LOCKED = preload("res://Assets/Images/DefenceTowers/UI/locked.tres")

@export var tower: DefenceTower
@export var tower_type: DefenceTower.TowerType
@export var id: int = 1
@export var price: int
@export var unlocked_level: int

@onready var price_label: Label = $Panel/PriceLabel
@onready var price_panel: Panel = $Panel
@onready var mouse_over_audio: AudioStreamPlayer = $MouseOverAudio

var locked: bool = false


func _enter_tree() -> void:
	
	pass


func _ready() -> void:
	if tower_type == DefenceTower.TowerType.Archer and clampi(Stage.instance.stage_sav.upgrade_sav[0],0,Stage.instance.limit_tech_level) >= 2:
		price -= 10
	price_label.text = str(price)
	lock_condition()
	pass


func lock():
	locked = true
	set_process(false)
	texture_disabled = LOCKED
	disabled = true
	price_panel.hide()
	pass


func _process(delta: float) -> void:
	disabled = Stage.instance.current_money < price
	price_label.modulate = Color.GRAY if disabled else Color.YELLOW
	pass


func lock_condition():
	if !Stage.instance.unlocked_tower_list[tower_type] and id == 1: lock()
	elif Stage.instance.stage_count < unlocked_level: lock()
	pass


func _on_mouse_entered() -> void:
	if !locked: 
		mouse_over_audio.play()
		tower.tower_panel_ui.show_panel(tower_type_to_int(tower_type),id)
	pass # Replace with function body.


func _on_mouse_exited() -> void:
	if locked: return
	tower.tower_panel_ui.hide_panel()
	if MobileMiddleProcess.instance.current_touch_object == self:
		MobileMiddleProcess.instance.current_touch_object = null
	pass # Replace with function body.


func _on_pressed() -> void:
	if Stage.instance.current_money < price: return
	
	if OS.get_name() == "Android":
		if MobileMiddleProcess.instance.current_touch_object != self:
			MobileMiddleProcess.instance.current_touch_object = self
			return
	
	tower.tower_level_up(tower_type,id)
	Stage.instance.current_money -= price
	pass # Replace with function body.


func tower_type_to_int(type: DefenceTower.TowerType) -> int:
	if type == DefenceTower.TowerType.Archer: return 0
	elif type == DefenceTower.TowerType.Barrack: return 1
	elif type == DefenceTower.TowerType.Magic: return 2
	elif type == DefenceTower.TowerType.Bombard: return 3
	else: return -1
	pass
