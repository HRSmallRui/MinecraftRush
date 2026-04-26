extends TextureButton

enum CheckType{
	Archers,
	Barracks,
	Magics,
	Bombards,
	Enemies
}

@export var button_check_type: CheckType
@export var button_check_id: int
@export var seen_book_ui: SeenBookUI

@onready var texture_rect: TextureRect = $TextureRect

const BUTTON_NORMAL = preload("res://Assets/Images/UI/SeenBook/button_normal.tres")
const BUTTON_SELECTED = preload("res://Assets/Images/UI/SeenBook/button_selected.tres")
const LOCKED = preload("res://Assets/Images/UI/SeenBook/Locked.png")

func _ready() -> void:
	if button_check_type == CheckType.Enemies:
		for i in get_parent().get_child_count():
			if get_parent().get_child(i) == self:
				button_check_id = i
				break
	
	await get_tree().process_frame
	seen_book_ui.update.connect(update)
	if button_check_id > 0:
		if button_check_type < 4:
			if !seen_book_ui.sav.tower_unlock_sav[button_check_type][button_check_id]:
				lock()
				return
		else:
			if !seen_book_ui.sav.enemy_unlock_sav.has(button_check_id):
				lock()
				return
	
	var path: String
	if button_check_type < 4:
		path = "res://Assets/Images/UI/SeenBook/DefenceTowers/HeadTex/"
		if button_check_type == CheckType.Archers: path += "Archer"
		elif button_check_type == CheckType.Barracks: path += "Barrack"
		elif button_check_type == CheckType.Magics: path += "Magic"
		elif button_check_type == CheckType.Bombards: path += "Bombard"
	else: path = "res://Assets/Images/UI/SeenBook/Enemies/HeadTex/enemy"
	texture_rect.texture = load(path + str(button_check_id) + ".png")
	
	pass


func update(check_type: CheckType, check_id: int):
	texture_normal = BUTTON_SELECTED if check_type == button_check_type and check_id == button_check_id else BUTTON_NORMAL
	if OS.get_name() == "Android" : texture_hover = texture_normal
	pass


func _pressed() -> void:
	$ChangeAudio.play()
	var check_type = button_check_type as SeenBookUI.CheckType
	seen_book_ui.change_check_id(check_type,button_check_id)
	pass


func lock():
	disabled = true
	pass
