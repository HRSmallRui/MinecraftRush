extends TowerPanelUI

@onready var show_slot: Node2D = $"../../ShowSlot"
@onready var tower_archer_slot: Sprite2D = $"../../ShowSlot/ArcherSlot"
@onready var tower_barrack_slot: Sprite2D = $"../../ShowSlot/BarrackSlot"
@onready var tower_magic_slot: Sprite2D = $"../../ShowSlot/MagicSlot"
@onready var tower_bombard_slot: Sprite2D = $"../../ShowSlot/BombardSlot"


func show_panel(show_type: int, show_id: int, key: String = ""):
	super(show_type,show_id)
	show_slot.show()
	tower_archer_slot.visible = show_type == 0
	tower_barrack_slot.visible = show_type == 1
	tower_magic_slot.visible = show_type == 2
	tower_bombard_slot.visible = show_type == 3
	pass


func hide_panel():
	super()
	show_slot.hide()
	pass
