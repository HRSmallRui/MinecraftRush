extends Node2D
class_name DefenceTower

signal tower_unlock

enum TowerType{
	Archer,
	Barrack,
	Magic,
	Bombard,
	Based
}

enum BasedSkin{
	Royal,
	Jungle,
	Desert,
	Rising,
	Mountain,
	Swamp
}

@export var tower_type: TowerType
@export var tower_name: String
@export var tower_texture: Texture
@export var tower_id: int = 1
@export var tower_level: int
@export var tower_value: int
@export var based_skin: BasedSkin
@export var start_tower_range: int
var current_tower_range: int
@export var tower_skill_levels: Array[int]
@export var linked_areas: Array[Area2D]

@onready var tower_button: Button = $TowerButton
@onready var ui_animation_player: AnimationPlayer = $TowerUI/UIAnimationPlayer
@onready var click_audio: AudioStreamPlayer = $ClickAudio
@onready var tower_panel_ui: TowerPanelUI = $TowerUI/TowerPanelUI
@onready var mouse_over_audio: AudioStreamPlayer = $MouseOverAudio
@onready var tower_range: Node2D = $TowerUI/TowerRange
@onready var tower_area: Area2D = $TowerArea
@onready var sell_button: TextureButton = $TowerUI/Circle/SellButton
@onready var circle: Sprite2D = $TowerUI/Circle
@onready var tower_self_area: Area2D = $TowerSelfArea
@onready var tower_buffs: Node2D = $TowerBuffs

var is_locked: bool = false:
	set(v):
		var before = is_locked
		is_locked = v
		if before and !v and is_inside_tree():
			await get_tree().process_frame
			if !is_locked: tower_unlock.emit()

var tower_damage_buffs: Array[TowerPropertyBuffBlock]
var tower_range_buffs: Array[TowerPropertyBuffBlock]
var tower_attack_speed_buffs: Array[TowerPropertyBuffBlock]


func _enter_tree() -> void:
	current_tower_range = start_tower_range
	pass


func _ready() -> void:
	Stage.instance.ui_update.connect(ui_process)
	
	if OS.get_name() == "Android":
		circle.scale = Vector2.ONE
	
	if tower_level > 0:
		Stage.instance.tower_check()
	pass


func _on_tower_button_mouse_entered() -> void:
	$Based.select()
	pass # Replace with function body.


func _on_tower_button_mouse_exited() -> void:
	$Based.select_cancel()
	pass # Replace with function body.


func _on_tower_button_pressed() -> void:
	Stage.instance.ui_process(self,Stage.StageUI.Check)
	click_audio.play(0.2)
	var parent = get_parent()
	parent.remove_child(self)
	parent.add_child(self)
	MobileMiddleProcess.instance.current_touch_object = self
	pass # Replace with function body.


func ui_process(member: Node):
	if member == self:
		ui_animation_player.stop()
		$TowerUI.scale = Vector2.ZERO
		ui_animation_player.play("show_ui")
	elif $TowerUI.scale.length() > 0.02:
		ui_animation_player.play("hide_ui")
	if Stage.instance.stage_ui == Stage.StageUI.None or Stage.instance.stage_ui == Stage.StageUI.Check:
		tower_button.mouse_filter = Control.MOUSE_FILTER_STOP
	else:
		tower_button.mouse_filter = Control.MOUSE_FILTER_IGNORE
	pass


func _on_sell_button_mouse_entered() -> void:
	tower_panel_ui.show_panel(5,0)
	mouse_over_audio.play()
	pass # Replace with function body.


func _on_sell_button_mouse_exited() -> void:
	tower_panel_ui.hide_panel()
	pass # Replace with function body.


func tower_level_up(type: TowerType, id: int):
	Stage.instance.ui_process(null)
	var tower_scene: PackedScene
	if id == 1:
		tower_scene = load("res://Scenes/DefenceTowers/defence_tower_lv_0.tscn")
	else:
		match type:
			TowerType.Archer:
				match id:
					2:
						tower_scene = load("res://Scenes/DefenceTowers/ArcherTowers/archer_tower_lv_2.tscn")
					3:
						tower_scene = load("res://Scenes/DefenceTowers/ArcherTowers/archer_tower_lv_3.tscn")
					4:
						tower_scene = load("res://Scenes/DefenceTowers/ArcherTowers/stone_tower.tscn")
					5:
						tower_scene = load("res://Scenes/DefenceTowers/ArcherTowers/desert_sentry_tower.tscn")
					6:
						tower_scene = load("res://Scenes/DefenceTowers/ArcherTowers/sentry_tower.tscn")
			TowerType.Barrack:
				match id:
					2:
						tower_scene = load("res://Scenes/DefenceTowers/BarrackTowers/barrack_tower_lv_2.tscn")
					3:
						tower_scene = load("res://Scenes/DefenceTowers/BarrackTowers/barrack_tower_lv_3.tscn")
					4:
						tower_scene = load("res://Scenes/DefenceTowers/BarrackTowers/royal_guard_palace.tscn")
					5:
						tower_scene = load("res://Scenes/DefenceTowers/BarrackTowers/epee_church.tscn")
					6:
						tower_scene = load("res://Scenes/DefenceTowers/BarrackTowers/medical_guard_camp.tscn")
			TowerType.Magic:
				match id:
					2:
						tower_scene = load("res://Scenes/DefenceTowers/MagicTower/magic_tower_lv_2.tscn")
					3:
						tower_scene = load("res://Scenes/DefenceTowers/MagicTower/magic_tower_lv_3.tscn")
					4:
						tower_scene = load("res://Scenes/DefenceTowers/MagicTower/protector_church.tscn")
					5:
						tower_scene = load("res://Scenes/DefenceTowers/MagicTower/witch_tower.tscn")
					6:
						tower_scene = load("res://Scenes/DefenceTowers/MagicTower/alchemist_tower.tscn")
			TowerType.Bombard:
				match id:
					2:
						tower_scene = load("res://Scenes/DefenceTowers/BombardTowers/bombard_tower_lv_2.tscn")
					3:
						tower_scene = load("res://Scenes/DefenceTowers/BombardTowers/bombard_tower_lv_3.tscn")
					4:
						tower_scene = load("res://Scenes/DefenceTowers/BombardTowers/operator_turret.tscn")
					5:
						tower_scene = load("res://Scenes/DefenceTowers/BombardTowers/nuclear_turret.tscn")
					6:
						tower_scene = load("res://Scenes/DefenceTowers/BombardTowers/stone_machine.tscn")
	
	var new_tower:DefenceTower = tower_scene.instantiate()
	if id == 1: new_tower.tower_type = type
	new_tower.based_skin = based_skin
	new_tower.position = position
	get_parent().add_child(new_tower)
	queue_free()
	pass


func _process(delta: float) -> void:
	
	tower_range.scale = Vector2.ONE * float(current_tower_range)/100
	tower_area.scale = Vector2.ONE * float(current_tower_range)/100
	pass


func _on_sell_button_pressed() -> void:
	if OS.get_name() == "Android":
		if MobileMiddleProcess.instance.current_touch_object != sell_button:
			MobileMiddleProcess.instance.current_touch_object = sell_button
			return
	get_money()
	destroy_tower()
	
	pass # Replace with function body.


func get_money():
	var value = tower_value
	if Stage.instance.current_wave > 0: value = int(value * 0.6)
	Stage.instance.current_money += value
	AudioManager.instance.tower_sell_audio.play()
	pass


func tower_skill_level_up(skill_id: int, skill_level: int):
	tower_skill_levels[skill_id] = skill_level
	pass


func destroy_tower():
	Stage.instance.ui_process(null)
	var based_tower: DefenceTower = load("res://Scenes/DefenceTowers/defence_tower_based.tscn").instantiate()
	based_tower.based_skin = based_skin
	based_tower.position = position
	get_parent().add_child(based_tower)
	queue_free()
	pass


func update_tower_data():
	update_tower_range()
	pass


func update_tower_range():
	current_tower_range = start_tower_range
	for property_block in tower_range_buffs:
		if property_block.operation_type == TowerBuff.OperationType.Add:
			current_tower_range += property_block.operation_data
		elif property_block.operation_type == TowerBuff.OperationType.Multiply:
			current_tower_range = float(current_tower_range) * property_block.operation_data
	
	current_tower_range = max(0,current_tower_range)
	pass
