extends Control
class_name InformationBar

@onready var animation_player: AnimationPlayer = $AnimationPlayer

@onready var archer_slot: HBoxContainer = $Panel/VBoxContainer/Slots/ArcherSlot
@onready var barrack_slot: HBoxContainer = $Panel/VBoxContainer/Slots/BarrackSlot
@onready var magic_slot: HBoxContainer = $Panel/VBoxContainer/Slots/MagicSlot
@onready var bombard_slot: HBoxContainer = $Panel/VBoxContainer/Slots/BombardSlot
@onready var ally_slot: HBoxContainer = $Panel/VBoxContainer/Slots/AllySlot
@onready var enemy_slot: HBoxContainer = $Panel/VBoxContainer/Slots/EnemySlot
@onready var intro_label: Label = $Panel/VBoxContainer/Slots/IntroLabel

@onready var head_texture: TextureRect = $Panel/PanelContainer/HeadTexture
@onready var name_label: Label = $Panel/VBoxContainer/NameLabel

var current_check_member: Node
var intro_list:Array[String] = [
	"在此建造防御塔"
]
var intro_name_list: Array[String] = [
	"战略点"
]


func _ready() -> void:
	Stage.instance.ui_update.connect(ui_process)
	set_process(false)
	pass


func ui_process(member: Node):
	if member == null and current_check_member != null: 
		animation_player.play("hide")
		set_process(false)
	elif current_check_member == null and member != null:
		animation_player.play("show")
		set_process(true)
	current_check_member = member
	if current_check_member != null: slot_visible()
	pass


func _process(delta: float) -> void:
	if current_check_member == null: return
	$Panel/PanelContainer.show()
	if current_check_member is ArcherTower: archer_process(current_check_member)
	elif current_check_member is BarrackTower: barrack_process(current_check_member)
	elif current_check_member is MagicTower: magic_process(current_check_member)
	elif current_check_member is BombardTower: bombard_process(current_check_member)
	elif current_check_member is BuyingSoldierTower: buying_soldier_tower_process(current_check_member)
	elif current_check_member is Ally: ally_process(current_check_member)
	elif current_check_member is Enemy: enemy_process(current_check_member)
	elif current_check_member is SkillButton: skill_button_process(current_check_member)
	else: intro_condition(current_check_member)
	pass


func archer_process(archer: ArcherTower):
	name_label.text = "  " + archer.tower_name
	head_texture.texture = archer.tower_texture
	var damage_label: Label = $Panel/VBoxContainer/Slots/ArcherSlot/Damage/Label
	var cd_label: Label = $Panel/VBoxContainer/Slots/ArcherSlot/CD/Label
	var range_label: Label = $Panel/VBoxContainer/Slots/ArcherSlot/Range/Label
	damage_label.text = str(archer.current_data.damage_low) + " - " + str(archer.current_data.damage_high)
	cd_label.text = DataProcess.attack_speed_to_string(archer.current_data.attack_speed)
	range_label.text = DataProcess.range_to_string(archer.current_tower_range)
	pass


func barrack_process(barrack:BarrackTower):
	name_label.text = "  " + barrack.tower_name
	head_texture.texture = barrack.tower_texture
	var health_label: Label = $Panel/VBoxContainer/Slots/BarrackSlot/Health/Label
	var damage_label: Label = $Panel/VBoxContainer/Slots/BarrackSlot/Damage/Label
	var armor_label: Label = $Panel/VBoxContainer/Slots/BarrackSlot/Armor/Label
	var rebirth_label: Label = $Panel/VBoxContainer/Slots/BarrackSlot/Rebirth/Label
	health_label.text = str(barrack.barrack_data.soldier_health)
	damage_label.text = str(barrack.barrack_data.damage_low) + " - " + str(barrack.barrack_data.damage_high)
	armor_label.text = DataProcess.defence_to_string(barrack.barrack_data.armor)
	rebirth_label.text = str(barrack.barrack_data.rebirth_time) + "s"
	pass


func magic_process(magic:MagicTower):
	name_label.text = "  " + magic.tower_name
	head_texture.texture = magic.tower_texture
	var damage_label: Label = $Panel/VBoxContainer/Slots/MagicSlot/Damage/Label
	var cd_label: Label = $Panel/VBoxContainer/Slots/MagicSlot/CD/Label
	var range_label:Label = $Panel/VBoxContainer/Slots/MagicSlot/Range/Label
	damage_label.text = str(magic.current_data.damage_low) + " - " + str(magic.current_data.damage_high)
	cd_label.text = DataProcess.attack_speed_to_string(magic.current_data.attack_speed)
	range_label.text = DataProcess.range_to_string(magic.current_tower_range)
	pass


func bombard_process(bombard: BombardTower):
	name_label.text = "  " + bombard.tower_name
	head_texture.texture = bombard.tower_texture
	var damage_label:Label = $Panel/VBoxContainer/Slots/BombardSlot/Damage/Label
	var cd_label: Label = $Panel/VBoxContainer/Slots/BombardSlot/CD/Label
	var range_label: Label = $Panel/VBoxContainer/Slots/BombardSlot/Range/Label
	damage_label.text = str(bombard.current_data.damage_low) + " - " + str(bombard.current_data.damage_high)
	cd_label.text = DataProcess.attack_speed_to_string(bombard.current_data.attack_speed)
	range_label.text = DataProcess.range_to_string(bombard.current_tower_range)
	pass


func buying_soldier_tower_process(buying_soldier_tower: BuyingSoldierTower):
	name_label.text = "  " + buying_soldier_tower.tower_name
	head_texture.texture = buying_soldier_tower.tower_texture
	intro_label.text = buying_soldier_tower.tower_intro
	intro_label.show()
	pass


func intro_process(id: int):
	
	pass


func ally_process(ally: Ally):
	name_label.text = "  " + ally.ally_name
	head_texture.texture = ally.ally_texture
	var health_bar: TextureProgressBar = $Panel/VBoxContainer/Slots/AllySlot/Health/HealthBar
	var health_label: Label = $Panel/VBoxContainer/Slots/AllySlot/Health/Label
	var damage_texture: TextureRect = $Panel/VBoxContainer/Slots/AllySlot/Damage
	var damage_label: Label = $Panel/VBoxContainer/Slots/AllySlot/Damage/Label
	var armor_label: Label = $Panel/VBoxContainer/Slots/AllySlot/Defence/Armor/Label
	var magic_defence_label: Label = $Panel/VBoxContainer/Slots/AllySlot/Defence/MagicDefence/Label
	var rebirth_label: Label = $Panel/VBoxContainer/Slots/AllySlot/Rebirth/Label
	health_bar.value = float(ally.current_data.health) / float(ally.start_data.health)
	health_label.text = str(ally.current_data.health) + " / " + str(ally.start_data.health)
	if ally.ally_group == Ally.AllyGroup.Warrior: damage_label.text = str(ally.current_data.near_damage_low) + " - " + str(ally.current_data.near_damage_high)
	else: damage_label.text = str(ally.current_data.far_damage_low) + " - " + str(ally.current_data.far_damage_high)
	if ally.ally_group == Ally.AllyGroup.Warrior: damage_texture.texture = load("res://Assets/Images/UI/DataUIs/damage_physics_hero.res")
	elif ally.ally_group == Ally.AllyGroup.Shooters: damage_texture.texture = load("res://Assets/Images/UI/DataUIs/damage_bow.res")
	elif ally.ally_group == Ally.AllyGroup.Magicians: damage_texture.texture = load("res://Assets/Images/UI/DataUIs/damage_magic.res")
	armor_label.text = defence_property_to_string(ally.current_data.armor,ally.current_data.physic_immune)
	magic_defence_label.text = defence_property_to_string(ally.current_data.magic_defence,ally.current_data.magic_immune)
	if ally.rebirth_time == 0: rebirth_label.text = " - "
	else: rebirth_label.text = str(ally.rebirth_time) + "s"
	pass


func enemy_process(enemy: Enemy):
	name_label.text = "  " + enemy.enemy_name
	head_texture.texture = enemy.enemy_texture
	var health_bar: TextureProgressBar = $Panel/VBoxContainer/Slots/EnemySlot/Health/HealthBar
	var health_label: Label = $Panel/VBoxContainer/Slots/EnemySlot/Health/Label
	var damage_label: Label = $Panel/VBoxContainer/Slots/EnemySlot/Damage/Label
	var armor_label: Label = $Panel/VBoxContainer/Slots/EnemySlot/Defence/Armor/Label
	var magic_defence_label: Label = $Panel/VBoxContainer/Slots/EnemySlot/Defence/MagicDefence/Label
	var lives_taken_label: Label = $Panel/VBoxContainer/Slots/EnemySlot/LivesTaken/Label
	health_bar.value = float(enemy.current_data.health) / float(enemy.start_data.health)
	health_label.text = str(enemy.current_data.health) + " / " + str(enemy.start_data.health)
	if enemy.start_data.health == -1:
		health_label.text = "?? / ??"
	elif enemy.start_data.health == -2:
		health_label.text = "错误"
	damage_label.text = str(enemy.current_data.near_damage_low) + " - " + str(enemy.current_data.near_damage_high)
	if enemy.current_data.near_damage_high == 0: 
		damage_label.text = "无"
		damage_label.add_theme_constant_override("outline_size",4)
	elif enemy.current_data.near_damage_high == -1:
		damage_label.add_theme_constant_override("outline_size",0)
		damage_label.text = "?? - ??"
	elif enemy.current_data.near_damage_high == -2:
		damage_label.add_theme_constant_override("outline_size",4)
		damage_label.text = "错误"
	else:
		damage_label.add_theme_constant_override("outline_size",0)
	armor_label.text = defence_property_to_string(enemy.current_data.armor,enemy.current_data.physic_immune)
	magic_defence_label.text = defence_property_to_string(enemy.current_data.magic_defence,enemy.current_data.magic_immune)
	lives_taken_label.text = str(enemy.lives_taken)
	pass


func slot_visible():
	intro_label.hide()
	archer_slot.visible = current_check_member is ArcherTower
	barrack_slot.visible = current_check_member is BarrackTower
	magic_slot.visible = current_check_member is MagicTower
	bombard_slot.visible = current_check_member is BombardTower
	ally_slot.visible = current_check_member is Ally
	enemy_slot.visible = current_check_member is Enemy
	
	pass


func intro_condition(check_node: Node):
	intro_label.show()
	if check_node is DefenceTower:
		if check_node.tower_type == DefenceTower.TowerType.Based:
			name_label.text = "  " +check_node.tower_name
			head_texture.texture = check_node.tower_texture
			intro_label.text = "在此建造防御塔"
	pass


func skill_button_process(skill_button: SkillButton):
	intro_label.show()
	name_label.text = "  " + skill_button.skill_name
	intro_label.text = skill_button.skill_intro
	$Panel/PanelContainer.hide()
	pass


func defence_property_to_string(defence: float, is_immune:bool) -> String:
	if is_immune: return "免疫"
	else: return DataProcess.defence_to_string(defence)
	pass
