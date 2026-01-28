extends Control

@export var can_control: bool = true
@export var code_list: Array[String]

@onready var close_button: TextureButton = $CloseButton
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var line_edit: LineEdit = $LineEdit
@onready var click_audio: AudioStreamPlayer = $NormalButton/ClickAudio

var sav: GameSaver


func _ready() -> void:
	sav = Map.instance.current_sav
	pass


func _on_normal_button_pressed() -> void:
	_on_line_edit_text_submitted(line_edit.text)
	pass # Replace with function body.


func _process(delta: float) -> void:
	close_button.modulate = Color.WHITE * 2 if close_button.get_draw_mode() == Button.DrawMode.DRAW_HOVER else Color.WHITE
	pass


func _on_close_button_pressed() -> void:
	can_control = false
	close_button.disabled = true
	animation_player.play_backwards()
	await animation_player.animation_finished
	queue_free()
	pass # Replace with function body.


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("escape") and can_control:
		_on_close_button_pressed()
	pass


func _on_line_edit_text_submitted(new_text: String) -> void:
	click_audio.play()
	if new_text == "": return
	var unlock_tip: PanelContainer = preload("res://Scenes/UI-Components/Map/unlock_tip.tscn").instantiate()
	add_child(unlock_tip)
	var label: Label = unlock_tip.get_child(0)
	if new_text in code_list:
		code_process(new_text,label)
	else:
		label.text = "代码不存在"
	line_edit.text = ""
	pass # Replace with function body.


func code_process(words: String, label: Label):
	call_deferred(words,label)
	pass


func GODFUTURE(label: Label):
	label.text = "已成功解锁迈克 史密斯"
	if sav.hero_sav[9].unlocked:
		label.text = "该英雄已解锁"
	else:
		sav.hero_sav[9].unlocked = true
	pass


func FUCHEN(label: Label):
	label.text = "已成功解锁法辰"
	if sav.hero_sav[1].unlocked:
		label.text = "该英雄已解锁"
	else:
		sav.hero_sav[1].unlocked = true
	pass


func ALEX(label: Label):
	label.text = "已成功解锁艾利克斯"
	if sav.hero_sav[2].unlocked:
		label.text = "该英雄已解锁"
	else:
		sav.hero_sav[2].unlocked = true
	pass


func TALZIN(label: Label):
	label.text = "已成功解锁塔尔辛"
	if sav.hero_sav[3].unlocked:
		label.text = "该英雄已解锁"
	else:
		sav.hero_sav[3].unlocked = true
	pass


func ROBORT(label: Label):
	label.text = "已成功解锁鲁伯特"
	if sav.hero_sav[4].unlocked:
		label.text = "该英雄已解锁"
	else:
		sav.hero_sav[4].unlocked = true
	pass


func SALEM(label: Label):
	label.text = "已成功解锁塞勒姆"
	if sav.hero_sav[7].unlocked:
		label.text = "该英雄已解锁"
	else:
		sav.hero_sav[7].unlocked = true
	pass


func JOHNNY(label: Label):
	label.text = "已成功解锁乔尼"
	if sav.hero_sav[8].unlocked:
		label.text = "该英雄已解锁"
	else:
		sav.hero_sav[8].unlocked = true
	pass
