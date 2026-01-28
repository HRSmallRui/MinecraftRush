extends Control
class_name TowerPanelUI

@onready var archer_slot: HBoxContainer = $PanelContainer/MarginContainer/VBoxContainer/Slots/ArcherSlot
@onready var barrack_slot: HBoxContainer = $PanelContainer/MarginContainer/VBoxContainer/Slots/BarrackSlot
@onready var magic_slot: HBoxContainer = $PanelContainer/MarginContainer/VBoxContainer/Slots/MagicSlot
@onready var bombard_slot: HBoxContainer = $PanelContainer/MarginContainer/VBoxContainer/Slots/BombardSlot
@onready var name_label: Label = $PanelContainer/MarginContainer/VBoxContainer/NameLabel
@onready var intro_label: Label = $PanelContainer/MarginContainer/VBoxContainer/IntroLabel
@onready var tower: DefenceTower = $"../.."
@onready var upgrade_range: Node2D = $"../UpgradeRange"
@onready var range_sprite: Sprite2D = $"../UpgradeRange/RangeSprite"
@onready var skill_words: Label = $PanelContainer/MarginContainer/VBoxContainer/Slots/SkillWords


func show_panel(show_type: int, show_id: int, key: String = ""):
	#0-3: tower 4: skill  5: intro, 6: buying_soldier
	position.x = -300 if Stage.instance.stage_camera.position.x < tower.position.x else 300
	$AnimationPlayer.play("show_panel")
	visible_slot(show_type)
	match show_type:
		0:
			archer_show(show_id)
		1:
			barrack_show(show_id)
		2:
			magic_show(show_id)
		3:
			bombard_show(show_id)
		5:
			intro_show(show_id)
		6:
			buying_soldier_show(key)
		
	if show_type < 4: upgrade_range_show(show_type,show_id)
	pass


func hide_panel():
	$AnimationPlayer.play("hide_panel")
	upgrade_range.hide()
	pass


func visible_slot(type: int):
	archer_slot.visible = type == 0
	barrack_slot.visible = type == 1 or type == 6
	magic_slot.visible = type == 2
	bombard_slot.visible = type == 3
	skill_words.visible = type == 4
	pass


func archer_show(id: int):
	var block: BasedTowerData = DefenceTowerLibrary.archer_datas[id-1]
	name_label.text = block.tower_name
	intro_label.text = block.tower_intro
	var damage_label: Label = $PanelContainer/MarginContainer/VBoxContainer/Slots/ArcherSlot/Damage/Label
	var cd_label: Label = $PanelContainer/MarginContainer/VBoxContainer/Slots/ArcherSlot/CD/Label
	var damage_low: int = block.damage_low
	var damage_high: int = block.damage_high
	damage_label.text = str(damage_low) + " - " + str(damage_high)
	cd_label.text = DataProcess.attack_speed_to_string(block.attack_speed)
	pass


func barrack_show(id: int):
	var block: BarrackTowerData = DefenceTowerLibrary.barrack_datas[id-1]
	name_label.text = block.tower_name
	intro_label.text = block.tower_intro
	var health_label: Label = $PanelContainer/MarginContainer/VBoxContainer/Slots/BarrackSlot/Health/Label
	var damage_label: Label = $PanelContainer/MarginContainer/VBoxContainer/Slots/BarrackSlot/Damage/Label
	var armor_label: Label = $PanelContainer/MarginContainer/VBoxContainer/Slots/BarrackSlot/Armor/Label
	var health: int = block.soldier_health
	if Stage.instance.stage_sav.upgrade_sav[1] >= 2: health *= 1.2
	health_label.text = str(health)
	damage_label.text = str(block.damage_low) + " - " + str(block.damage_high)
	var armor: float = block.soldier_armor
	if Stage.instance.stage_sav.upgrade_sav[1] >= 3: armor += 0.1
	armor_label.text = DataProcess.defence_to_string(armor)
	pass


func magic_show(id: int):
	var block:BasedTowerData = DefenceTowerLibrary.magic_datas[id-1]
	name_label.text = block.tower_name
	intro_label.text = block.tower_intro
	var damage_label: Label = $PanelContainer/MarginContainer/VBoxContainer/Slots/MagicSlot/Damage/Label
	var cd_label: Label = $PanelContainer/MarginContainer/VBoxContainer/Slots/MagicSlot/CD/Label
	if Stage.instance.stage_sav.upgrade_sav[2] >= 5:
		damage_label.text = str(DataProcess.upgrade_damage(block.damage_low,0.15)) + " - " + str(DataProcess.upgrade_damage(block.damage_high,0.15))
	else:
		damage_label.text = str(block.damage_low) + " - " + str(block.damage_high)
	cd_label.text = DataProcess.attack_speed_to_string(block.attack_speed)
	pass


func bombard_show(id: int):
	var block:BasedTowerData = DefenceTowerLibrary.bombard_datas[id-1]
	name_label.text = block.tower_name
	intro_label.text = block.tower_intro
	var damage_label: Label = $PanelContainer/MarginContainer/VBoxContainer/Slots/BombardSlot/Damage/Label
	var cd_label: Label = $PanelContainer/MarginContainer/VBoxContainer/Slots/BombardSlot/CD/Label
	if Stage.instance.stage_sav.upgrade_sav[3] >= 4:
		damage_label.text = str(DataProcess.upgrade_damage(block.damage_low,0.1)) + " - " + str(DataProcess.upgrade_damage(block.damage_high,0.1))
	else:
		damage_label.text = str(block.damage_low) + " - " + str(block.damage_high)
	cd_label.text = DataProcess.attack_speed_to_string(block.attack_speed)
	pass


func intro_show(id: int):
	match id:
		0:
			name_label.text = "出售防御塔"
			var value = tower.tower_value
			if Stage.instance.current_wave != 0: value = int(value * 0.6)
			intro_label.text = "出售该防御塔并获得" + str(value) + "绿宝石。"
	pass


func buying_soldier_show(key: String):
	var block: BarrackTowerData = DefenceTowerLibrary.buying_soldier_datas[key]
	name_label.text = block.tower_name
	intro_label.text = block.tower_intro
	var health_label: Label = $PanelContainer/MarginContainer/VBoxContainer/Slots/BarrackSlot/Health/Label
	var damage_label: Label = $PanelContainer/MarginContainer/VBoxContainer/Slots/BarrackSlot/Damage/Label
	var armor_label: Label = $PanelContainer/MarginContainer/VBoxContainer/Slots/BarrackSlot/Armor/Label
	var health: int = block.soldier_health
	health_label.text = str(health)
	damage_label.text = str(block.damage_low) + " - " + str(block.damage_high)
	var armor: float = block.soldier_armor
	armor_label.text = DataProcess.defence_to_string(armor)
	pass


func upgrade_range_show(type: int, id: int):
	upgrade_range.show()
	var range_length:float
	var show_range: int
	if type != 1:
		range_sprite.texture = load("res://Assets/Images/DefenceTowers/UI/射程范围.png")
		var block: BasedTowerData
		match type:
			0: 
				block = DefenceTowerLibrary.archer_datas[id-1]
				show_range = block.tower_range
				if clampi(Stage.instance.stage_sav.upgrade_sav[0] >= 1,0,Stage.instance.limit_tech_level) >= 1 :
					show_range = int(show_range * 1.15)
			2: 
				block = DefenceTowerLibrary.magic_datas[id-1]
				show_range = block.tower_range
				if clampi(Stage.instance.stage_sav.upgrade_sav[2] >= 1,0,Stage.instance.limit_tech_level) >= 1:
					show_range = int(show_range * 1.1)
			3: 
				block = DefenceTowerLibrary.bombard_datas[id-1]
				show_range = block.tower_range
				if clampi(Stage.instance.stage_sav.upgrade_sav[3] >= 1,0,Stage.instance.limit_tech_level) >= 1:
					show_range = int(show_range * 1.1)
		
		range_length = float(show_range)/100
	else:
		range_sprite.texture = load("res://Assets/Images/DefenceTowers/UI/集结范围.png")
		var block: BarrackTowerData = DefenceTowerLibrary.barrack_datas[id-1]
		show_range = block.tower_range
		if clampi(Stage.instance.stage_sav.upgrade_sav[2] >= 1,0,Stage.instance.limit_tech_level) >= 1:
			show_range *= 1.2
		
		range_length = float(show_range)/100
	
	upgrade_range.scale = Vector2.ONE * range_length
	pass
