extends Control
class_name SeenBookUI

signal update(check_type: CheckType, check_id: int)

enum CheckType{
	Archers,
	Barracks,
	Magics,
	Bombards,
	Enemies
}

@onready var name_label: Label = $RightPanel/NameLabel
@onready var intro_label: Label = $RightPanel/IntroLabel
@onready var tower_slot: Control = $LeftPanel/TowerSlot
@onready var enemy_slot: Control = $LeftPanel/EnemySlot
@onready var intro_panel: Panel = $IntroPanel
@onready var seen_book_texture: TextureRect = $RightPanel/CenterContainer/SeenBookTexture

var sav: GameSaver
var can_control


func _ready() -> void:
	sav = Map.instance.current_sav
	intro_panel.hide()
	modulate.a = 0
	create_tween().tween_property(self,"modulate:a",1,0.4)
	$BookSprite.play("Open")
	await get_tree().process_frame
	change_check_id(CheckType.Archers,0)
	$TagTower.hide()
	$TagEnemy.hide()
	$LeftPanel.hide()
	$RightPanel.hide()
	$CloseButton.hide()
	await $BookSprite.animation_finished
	$AnimationPlayer.play("Show")
	await $AnimationPlayer.animation_finished
	can_control = true
	pass


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("escape") and can_control:
		quit_animation()
	pass


func _process(delta: float) -> void:
	intro_panel.position = get_global_mouse_position() + Vector2.ONE * 20
	pass


func _on_close_button_pressed() -> void:
	quit_animation()
	pass # Replace with function body.


func quit_animation():
	can_control = false
	intro_panel.hide()
	$AnimationPlayer.play("hide")
	await $AnimationPlayer.animation_finished
	$BookSprite.speed_scale = -1
	$BookSprite.play("Open")
	$BookAudio.play()
	create_tween().tween_property(self,"modulate:a",0,1)
	await get_tree().create_timer(1).timeout
	Map.instance.can_control = true
	queue_free()
	pass


func change_check_id(check_type: CheckType, check_id: int):
	tower_slot.visible = check_type < 4
	enemy_slot.visible = check_type == CheckType.Enemies
	
	slot_visible(check_type)
	change_texture(check_type,check_id)
	if check_type == CheckType.Archers:
		archer_check(check_id)
	elif check_type == CheckType.Barracks:
		barrack_check(check_id)
	elif check_type == CheckType.Magics:
		magic_check(check_id)
	elif check_type == CheckType.Bombards:
		bombard_check(check_id)
	elif check_type == CheckType.Enemies:
		enemy_check(check_id)
	
	update.emit(check_type,check_id)
	pass


func archer_check(check_id: int):
	var archer_block = DefenceTowerLibrary.archer_datas[check_id] as BasedTowerData
	name_label.text = archer_block.tower_name
	intro_label.text = archer_block.tower_intro
	var damage_label:Label = $RightPanel/ArcherSlot/Damage/PropertyLabel
	var cd_label:Label = $RightPanel/ArcherSlot/CD/PropertyLabel
	var range_label: Label = $RightPanel/ArcherSlot/Range/PropertyLabel
	damage_label.text = str(archer_block.damage_low) + " - " + str(archer_block.damage_high)
	cd_label.text = DataProcess.attack_speed_to_string(archer_block.attack_speed)
	var range: int = archer_block.tower_range
	if sav.upgrade_sav[0] >= 1: range = int(range * 1.15)
	range_label.text = DataProcess.range_to_string(range)
	pass


func barrack_check(check_id: int):
	var barrack_block = DefenceTowerLibrary.barrack_datas[check_id] as BarrackTowerData
	name_label.text = barrack_block.tower_name
	intro_label.text = barrack_block.tower_intro
	var health_label:Label = $RightPanel/BarrackSlot/Health/PropertyLabel
	var damage_label:Label = $RightPanel/BarrackSlot/Attack/PropertyLabel
	var armor_label: Label = $RightPanel/BarrackSlot/Armor/PropertyLabel
	var rebirth_label: Label = $RightPanel/BarrackSlot/Rebirth/PropertyLabel
	var health = barrack_block.soldier_health
	if sav.upgrade_sav[1] >= 2: health = int(health * 1.2)
	health_label.text = str(health)
	damage_label.text = str(barrack_block.damage_low) + " - " + str(barrack_block.damage_high)
	var armor: float = barrack_block.soldier_armor
	if sav.upgrade_sav[1] >= 3: armor += 0.1
	armor_label.text = DataProcess.defence_to_string(armor)
	var rebirth_time: int = barrack_block.rebirth_time
	if sav.upgrade_sav[1] >= 4: rebirth_time = int(rebirth_time * 0.8)
	rebirth_label.text = str(rebirth_time) + "s"
	pass


func magic_check(check_id: int):
	var magic_block = DefenceTowerLibrary.magic_datas[check_id] as BasedTowerData
	name_label.text = magic_block.tower_name
	intro_label.text = magic_block.tower_intro
	var damage_label:Label = $RightPanel/MagicSlot/Damage/PropertyLabel
	var cd_label:Label = $RightPanel/MagicSlot/CD/PropertyLabel
	var range_label:Label = $RightPanel/MagicSlot/Range/PropertyLabel
	var damage_low: float = magic_block.damage_low
	var damage_high: float = magic_block.damage_high
	if sav.upgrade_sav[2] >= 5:
		damage_low = DataProcess.upgrade_damage(damage_low,0.15)
		damage_high = DataProcess.upgrade_damage(damage_high,0.15)
	damage_label.text = str(damage_low) + " - " + str(damage_high)
	cd_label.text = DataProcess.attack_speed_to_string(magic_block.attack_speed)
	var attack_range: int = magic_block.tower_range
	if sav.upgrade_sav[2] >= 1: attack_range *= 1.1
	range_label.text = DataProcess.range_to_string(attack_range)
	pass


func bombard_check(check_id: int):
	var bombard_block = DefenceTowerLibrary.bombard_datas[check_id] as BasedTowerData
	name_label.text = bombard_block.tower_name
	intro_label.text = bombard_block.tower_intro
	var damage_label: Label = $RightPanel/BombardSlot/Damage/PropertyLabel
	var cd_label:Label = $RightPanel/BombardSlot/CD/PropertyLabel
	var range_label:Label = $RightPanel/BombardSlot/Range/PropertyLabel
	var damage_low:float = bombard_block.damage_low
	var damage_high:float = bombard_block.damage_high
	if sav.upgrade_sav[3] >= 2:
		damage_low = DataProcess.upgrade_damage(damage_low,0.1)
		damage_high = DataProcess.upgrade_damage(damage_high,0.1)
	damage_label.text = str(damage_low) + " - " + str(damage_high)
	cd_label.text = DataProcess.attack_speed_to_string(bombard_block.attack_speed)
	var range: int = bombard_block.tower_range
	if sav.upgrade_sav[3] >= 1:
		range *= 1.1
	range_label.text = DataProcess.range_to_string(range)
	pass


func enemy_check(check_id: int):
	var enemy_block = EnemyLibrary.enemy_datas[check_id] as EnemyData
	name_label.text = enemy_block.enemy_name
	intro_label.text = enemy_block.enemy_intro
	var health_label: Label = $RightPanel/EnemySlot/Health/PropertyLabel
	var damage_label: Label = $RightPanel/EnemySlot/Attack/PropertyLabel
	var armor_label: Label = $RightPanel/EnemySlot/Armor/PropertyLabel
	var magic_defence_label:Label = $RightPanel/EnemySlot/MagicDefence/PropertyLabel
	var speed_label:Label = $RightPanel/EnemySlot/Speed/PropertyLabel
	var lives_taken_label:Label = $RightPanel/EnemySlot/LivesTaken/PropertyLabel
	var special_tag_label: Label = $RightPanel/EnemySlot/SpecialTagLabel
	
	var rate: float = 1
	if sav.difficulty == 0: rate = 0.8
	elif sav.difficulty == 1: rate = 1
	elif sav.difficulty == 2: rate  = 1.2
	health_label.text = str(rate * enemy_block.enemy_health)
	if enemy_block.damage_low == 0 and enemy_block.damage_high == 0: damage_label.text = "无"
	else: damage_label.text = str(enemy_block.damage_low) + " - " + str(enemy_block.damage_high)
	armor_label.text = DataProcess.defence_to_string(enemy_block.enemy_armor)
	magic_defence_label.text = DataProcess.defence_to_string(enemy_block.enemy_magic_defence)
	speed_label.text = DataProcess.move_speed_to_string(enemy_block.enemy_move_speed)
	lives_taken_label.text = str(enemy_block.lives_taken)
	special_tag_label.text = enemy_block.seen_book_tag
	pass


func slot_visible(check_type: CheckType):
	$RightPanel/ArcherSlot.visible = check_type == CheckType.Archers
	$RightPanel/BarrackSlot.visible = check_type == CheckType.Barracks
	$RightPanel/MagicSlot.visible = check_type == CheckType.Magics
	$RightPanel/BombardSlot.visible = check_type == CheckType.Bombards
	$RightPanel/EnemySlot.visible = check_type == CheckType.Enemies
	pass


func show_panel(type: int, id: int):
	intro_panel.show()
	var intro_name_label: Label = $IntroPanel/IntroNameLabel
	var intro_intro_label: Label = $IntroPanel/IntroIntroLabel
	if type == 0:
		match id:
			0:
				intro_name_label.text = "生命值"
				intro_intro_label.text = "单位所能承受的伤害上限"
			1:
				intro_name_label.text = "攻击伤害"
				intro_intro_label.text = "攻击可以对敌人造成的伤害"
			2:
				intro_name_label.text = "护甲"
				intro_intro_label.text = "护甲可以减少所受到的物理伤害"
			3:
				intro_name_label.text = "魔法抗性"
				intro_intro_label.text = "魔法抗性可以减少所受到的魔法伤害"
			4:
				intro_name_label.text = "速度"
				intro_intro_label.text = "单位的移动速度"
			5:
				intro_name_label.text = "代价"
				intro_intro_label.text = "敌人通过防守线后我方失去的生命"
			6:
				intro_name_label.text = "攻击伤害"
				intro_intro_label.text = "攻击时所造成的伤害"
			7:
				intro_name_label.text = "攻击间隔"
				intro_intro_label.text = "两次攻击间隔的时间"
			8:
				intro_name_label.text = "攻击范围"
				intro_intro_label.text = "防御塔可以攻击到的最远距离"
			9:
				intro_name_label.text = "训练时间"
				intro_intro_label.text = "训练新士兵所需要的时间"
	pass


func hide_panel():
	intro_panel.hide()
	pass


func change_texture(check_type: CheckType, check_id: int):
	var load_path: String
	match check_type:
		CheckType.Archers:
			load_path = "res://Assets/Images/UI/SeenBook/DefenceTowers/Textures/Archer"
		CheckType.Barracks:
			load_path = "res://Assets/Images/UI/SeenBook/DefenceTowers/Textures/Barrack"
		CheckType.Magics:
			load_path = "res://Assets/Images/UI/SeenBook/DefenceTowers/Textures/Magic"
		CheckType.Bombards:
			load_path = "res://Assets/Images/UI/SeenBook/DefenceTowers/Textures/Bombard"
		CheckType.Enemies:
			load_path = "res://Assets/Images/UI/SeenBook/Enemies/Textures/enemy"
	load_path += str(check_id) + ".png"
	seen_book_texture.texture = load(load_path)
	pass


func _on_delete_no_button_pressed() -> void:
	quit_animation()
	pass # Replace with function body.
