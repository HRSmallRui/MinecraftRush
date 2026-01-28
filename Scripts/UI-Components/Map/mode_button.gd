@tool
extends Button

enum GameMode{
	Campaign,
	Diamond,
	Bedrock
}

@export var game_mode: GameMode:
	set(v): 
		mode_select(v)
		game_mode = v
@export var ready_ui: ReadyToFightUI

@onready var mode_label: Label = $ModeLabel
@onready var texture_rect: TextureRect = $TextureRect
@onready var intro_panel: Panel = $IntroPPanel
@onready var pane_mode_label: Label = $IntroPPanel/PaneModeLabel
@onready var mode_intro_panel: Label = $IntroPPanel/ModeIntroPanel


func _ready() -> void:
	intro_panel.hide()
	game_mode_select()
	if game_mode == GameMode.Diamond:
		pane_mode_label.text = "钻石挑战"
		pane_mode_label.modulate = Color.SKY_BLUE
		mode_intro_panel.text = "钻石挑战该挑战为想要进一步挑战自我的领导者准备，在只有一点生命的情况下面对敌人的五波精锐部队的侵袭，测验一下你的战术技巧吧！（战役模式三星评价通关解锁）"
	elif game_mode == GameMode.Bedrock:
		pane_mode_label.text = "基岩挑战"
		pane_mode_label.modulate = Color.RED
		mode_intro_panel.text = "基岩挑战是为终极防御者提供的考验，在限制防御塔种类，只有一点生命的前提下应对一波敌人超精英部队的总攻，是对领导者战术技巧的终极考验，它将会把你的战术技巧提升至极限。（战役模式三星评价通关解锁）"
	
	if game_mode == GameMode.Campaign: grab_focus() 
	pass


func _process(delta: float) -> void:
	if Engine.is_editor_hint(): return
	intro_panel.global_position = get_global_mouse_position() + Vector2(20,20)
	pass


func mode_select(mode: GameMode):
	if !Engine.is_editor_hint(): return
	match mode:
		0:
			mode_label.text = "战役模式"
			texture_rect.texture = load("res://Assets/Images/UI/battle_mode.png")
		1:
			mode_label.text = "钻石挑战"
			texture_rect.texture = load("res://Assets/Images/UI/diamond.png")
		2:
			mode_label.text = "基岩挑战"
			texture_rect.texture = load("res://Assets/Images/UI/bedrock.png")
	pass


func game_mode_select():
	match game_mode:
		0:
			mode_label.text = "战役模式"
			texture_rect.texture = load("res://Assets/Images/UI/battle_mode.png")
		1:
			mode_label.text = "钻石挑战"
			texture_rect.texture = load("res://Assets/Images/UI/diamond.png")
			if disabled: 
				texture_rect.texture = load("res://Assets/Images/UI/diamond-null.png")
				mode_label.modulate = Color.GRAY
		2:
			mode_label.text = "基岩挑战"
			texture_rect.texture = load("res://Assets/Images/UI/bedrock.png")
			if disabled: 
				texture_rect.texture = load("res://Assets/Images/UI/bedrock-null.png")
				mode_label.modulate = Color.GRAY
	
	if disabled: focus_mode = FocusMode.FOCUS_NONE
	pass


func _on_mouse_entered() -> void:
	if disabled: intro_panel.show()
	pass # Replace with function body.


func _on_mouse_exited() -> void:
	intro_panel.hide()
	pass # Replace with function body.


func _pressed() -> void:
	ready_ui.change_mode(game_mode as int)
	pass
