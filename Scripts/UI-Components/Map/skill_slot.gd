extends Control

@onready var royal_guard: HBoxContainer = $RoyalGuard
@onready var protector_church: HBoxContainer = $ProtectorChurch
@onready var stone_tower: HBoxContainer = $StoneTower
@onready var operator_turret: HBoxContainer = $OperatorTurret
@onready var desert_sentry_tower: HBoxContainer = $DesertSentryTower
@onready var epee_church: HBoxContainer = $EpeeChurch
@onready var nuclear_turret: HBoxContainer = $NuclearTurret
@onready var witch_tower: HBoxContainer = $WitchTower
@onready var medical_camp: HBoxContainer = $MedicalCamp
@onready var sentry_tower: HBoxContainer = $SentryTower
@onready var alchemist_tower: HBoxContainer = $AlchemistTower


func _on_seen_book_ui_update(check_type: SeenBookUI.CheckType, check_id: int) -> void:
	visible = check_type < 4 and check_id > 2
	
	royal_guard.visible = check_type == 1 and check_id == 3
	protector_church.visible = check_type == 2 and check_id == 3
	stone_tower.visible = check_type == 0 and check_id == 3
	
	operator_turret.visible = check_type == 3 and check_id == 3
	desert_sentry_tower.visible = check_type == 0 and check_id == 4
	epee_church.visible = check_type == 1 and check_id == 4
	nuclear_turret.visible = check_type == 3 and check_id == 4
	
	witch_tower.visible = check_type == 2 and check_id == 4
	medical_camp.visible = check_type == 1 and check_id == 5
	sentry_tower.visible = check_type == 0 and check_id == 5
	alchemist_tower.visible = check_type == 2 and check_id == 5
	pass # Replace with function body.
