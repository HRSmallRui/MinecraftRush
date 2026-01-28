extends TextureButton

@export var slot_number: int = 1

@onready var click_audio: AudioStreamPlayer = $ClickAudio
@onready var new_label: Label = $NewSlot/NewLabel
@onready var old_label: Label = $OldSlot/OldLabel
@onready var star_label: Label = $OldSlot/HBoxContainer/Star/StarLabel
@onready var diamond_label: Label = $OldSlot/HBoxContainer/Diamond/DiamondLabel
@onready var bedrock_label: Label = $OldSlot/HBoxContainer/Bedrock/BedrockLabel
@onready var new_slot: Control = $NewSlot
@onready var old_slot: Control = $OldSlot
@onready var trash_button: TextureButton = $OldSlot/TrashButton
@onready var animation_player: AnimationPlayer = $OldSlot/AnimationPlayer

var linked_sav_slot: GameSaver


func _ready() -> void:
	old_label.text = "档位" + str(slot_number)
	linked_sav_slot = Global.get_game_sav(slot_number)
	new_slot.visible = linked_sav_slot == null
	old_slot.visible = !new_slot.visible
	if linked_sav_slot != null:
		star_label.text = str(linked_sav_slot.total_stars) + " / " + str(Global.total_stars)
		diamond_label.text = str(linked_sav_slot.total_diamonds) + " / " + str(Global.total_level_count - ReadyToFightUI.no_challenge_levels.size())
		bedrock_label.text = str(linked_sav_slot.total_bedrocks) + " / " + str(Global.total_level_count - ReadyToFightUI.no_challenge_levels.size())
	pass


func _on_pressed() -> void:
	click_audio.play(0.2)
	Global.current_sav_slot = slot_number
	Global.change_scene("res://Scenes/GameBased/main_map.tscn")
	pass # Replace with function body.


func _process(delta: float) -> void:
	if get_draw_mode() == Button.DrawMode.DRAW_PRESSED:
		self_modulate = Color.GREEN
		new_label.modulate = Color.WHITE
		old_label.modulate = Color.WHITE
		star_label.modulate = Color.WHITE
		diamond_label.modulate = Color.WHITE
		bedrock_label.modulate = Color.WHITE
	else:
		self_modulate = Color.WHITE
		new_label.modulate = Color.BLACK
		old_label.modulate = Color.BLACK
		star_label.modulate = Color.BLACK
		diamond_label.modulate = Color.BLACK
		bedrock_label.modulate = Color.BLACK
	pass


func _on_trash_button_focus_exited() -> void:
	animation_player.play_backwards("answer")
	pass # Replace with function body.


func _on_trash_button_focus_entered() -> void:
	animation_player.play("answer")
	pass # Replace with function body.


func _on_trash_button_pressed() -> void:
	if animation_player.current_animation_position >= animation_player.current_animation_length:
		animation_player.play_backwards("answer")
		trash_button.release_focus()
	pass # Replace with function body.


func _on_delete_yes_button_pressed() -> void:
	new_slot.show()
	old_slot.hide()
	DirAccess.remove_absolute(Global.get_game_sav_path(slot_number))
	pass # Replace with function body.
