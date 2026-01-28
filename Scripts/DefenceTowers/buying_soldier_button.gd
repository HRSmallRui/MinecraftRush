extends TextureButton
class_name BuyingSoldierButton

@export var linked_tower: BuyingSoldierTower
@export var button_key: String
@export var price: int
@export var soldier_scene: PackedScene

@onready var price_label: Label = $Panel/PriceLabel
@onready var mouse_over_audio: AudioStreamPlayer = $MouseOverAudio


func _ready() -> void:
	price_label.text = str(price)
	pass


func _process(delta: float) -> void:
	disabled = Stage.instance.current_money < price or linked_tower.buying_soldier_list.size() >= linked_tower.soldier_count_limit
	price_label.modulate = Color.GRAY if disabled else Color.YELLOW
	pass


func _on_pressed() -> void:
	Stage.instance.current_money -= price
	summon_soldier()
	pass # Replace with function body.


func _on_mouse_entered() -> void:
	mouse_over_audio.play()
	linked_tower.tower_panel_ui.show_panel(6,0,button_key)
	pass # Replace with function body.


func _on_mouse_exited() -> void:
	linked_tower.tower_panel_ui.hide_panel()
	pass # Replace with function body.


func summon_soldier():
	var soldier: BuyingSoldier = soldier_scene.instantiate()
	soldier.position = linked_tower.position
	soldier.linked_buying_tower = linked_tower
	Stage.instance.allys.add_child(soldier)
	linked_tower.buying_soldier_list.append(soldier)
	linked_tower.update_soldiers_position()
	linked_tower.update_buying_soldier_brothers()
	pass
