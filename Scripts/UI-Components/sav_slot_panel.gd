extends Panel
class_name SavSlotPanel

@onready var new_slot: Control = $NewSlot
@onready var old_slot: Control = $OldSlot
@onready var slot_number_label: Label = $SlotNumberLabel

@onready var difficulty_label: Label = $OldSlot/DifficultyLabel
@onready var time_label: Label = $OldSlot/TimeLabel
@onready var star_label: Label = $OldSlot/VBoxContainer2/StarLabel
@onready var diamond_label: Label = $OldSlot/VBoxContainer2/DiamondLabel
@onready var bedrock_label: Label = $OldSlot/VBoxContainer2/BedrockLabel


func _ready() -> void:
	hide()
	pass


func _process(delta: float) -> void:
	if OS.get_name() == "Android": 
		set_process(false)
		position = Vector2(2500,1400)
	position = get_global_mouse_position() + Vector2(20,20)
	pass
