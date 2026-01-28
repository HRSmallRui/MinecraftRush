extends TextureRect

enum IconType{
	Health,
	UnitDamage,
	Armor,
	MagicDefence,
	UnitSpeed,
	LivesTaken,
	TowerDamage,
	TowerAttackSpeed,
	TowerRange,
	RebirthTime
}

@export var icon_type: IconType
@export var seen_book_ui: SeenBookUI


func _ready() -> void:
	if OS.get_name() == "Android":
		return
	mouse_entered.connect(mouse_enter)
	mouse_exited.connect(mouse_exit)
	pass


func mouse_enter():
	seen_book_ui.show_panel(0,icon_type)
	pass


func mouse_exit():
	seen_book_ui.hide_panel()
	pass
