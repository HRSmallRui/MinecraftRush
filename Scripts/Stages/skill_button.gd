extends Control
class_name SkillButton

enum SkillType{
	Firerain,
	Reinforce,
	HeroSkill
}

enum ButtonState{
	Disabled,
	Cooling,
	Enable
}

@export var skill_type: SkillType
@export var texture_normal: Texture
@export var texture_select: Texture
@export var skill_name: String
@export_multiline var skill_intro: String
@export var cooling_time: float = 10
@export var skill_information_texture: Texture

@onready var button: Button = $TotalComponent/Button
@onready var normal_texture: TextureRect = $TotalComponent/NormalTexture
@onready var hover_texture: TextureRect = $TotalComponent/HoverTexture
@onready var cooling_progress_bar: TextureProgressBar = $TotalComponent/CoolingProgressBar
@onready var fast_button: Button = $TotalComponent/FastButton
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var cooling_finished_audio: AudioStreamPlayer = $CoolingFinishedAudio

var cooling_timer: float = 0
var button_state: ButtonState
var fast_key: String


func _ready() -> void:
	normal_texture.texture = texture_normal
	hover_texture.texture = texture_select
	fast_button.visible = OS.get_name() == "Windows"
	Stage.instance.ui_update.connect(ui_process)
	fast_button.text = str(skill_type+1)
	button.disabled = true
	
	match skill_type:
		SkillType.Reinforce:
			fast_key = "reinforce"
		SkillType.Firerain:
			fast_key = "firerain"
		SkillType.HeroSkill:
			fast_key = "hero_skill"
	pass


func _process(delta: float) -> void:
	hover_texture.visible = button.get_draw_mode() == Button.DrawMode.DRAW_HOVER
	if OS.get_name() == "Android":
		hover_texture.hide()
	var font_color: Color = Color.WHITE
	match button.get_draw_mode():
		Button.DrawMode.DRAW_NORMAL:
			font_color = Color.WHITE
		Button.DrawMode.DRAW_HOVER:
			font_color = Color.YELLOW
		Button.DrawMode.DRAW_DISABLED:
			font_color = Color.GRAY
	if Stage.instance.information_bar.current_check_member == self: font_color = Color.YELLOW
	fast_button.add_theme_color_override("font_color",font_color)
	normal_texture.modulate = Color.WHITE if button_state == ButtonState.Enable else Color.GRAY * 0.8
	normal_texture.modulate.a = 1
	
	cooling_progress_bar.visible = button_state == ButtonState.Cooling
	cooling_progress_bar.value = cooling_timer / cooling_time
	if button_state == ButtonState.Cooling:
		cooling_timer -= delta
		if cooling_timer <= 0: translate_to_state(ButtonState.Enable)
	pass


func _on_button_pressed() -> void:
	if Stage.instance.information_bar.current_check_member == self:
		Stage.instance.ui_process(null)
		MobileMiddleProcess.instance.current_touch_object = null
	else:
		Stage.instance.ui_process(self,Stage.StageUI.SkillPreparation)
		MobileMiddleProcess.instance.current_touch_object = self
	pass # Replace with function body.


func ui_process(member: Node):
	normal_texture.texture = texture_select if member == self else texture_normal
	
	pass


func skill_unlease_condition():
	if Stage.instance.mouse_in_path:
		skill_unlease()
	pass


func skill_unlease():
	unlease_effect()
	translate_to_state(ButtonState.Cooling)
	Stage.instance.ui_process(null)
	pass


func unlock():
	animation_player.play("unlock")
	translate_to_state(ButtonState.Enable)
	pass


func translate_to_state(new_state: ButtonState):
	match new_state:
		ButtonState.Disabled:
			button.disabled = true
		ButtonState.Cooling:
			button.disabled = true
			cooling_timer = cooling_time
		ButtonState.Enable:
			if button_state == ButtonState.Cooling:
				cooling_finished_audio.play()
			button.disabled = false
	
	button_state = new_state
	pass


func _input(event: InputEvent) -> void:
	if event.is_action_pressed(fast_key) and button_state == ButtonState.Enable:
		_on_button_pressed()
	pass


func unlease_effect():
	var unlease = preload("res://Scenes/Effects/skill_unlease_effect.tscn").instantiate() as Sprite2D
	unlease.position = Stage.instance.get_local_mouse_position() + Vector2(0,-20)
	unlease.texture = texture_normal
	Stage.instance.bullets.add_child(unlease)
	pass


func cooling_fast(time: float):
	if button_state == ButtonState.Cooling:
		cooling_timer -= time
		var cooling_fast_effect = preload("res://Scenes/Effects/cooling_fast_effect.tscn").instantiate() as CoolingFastEffect
		cooling_fast_effect.cooling_data = time
		cooling_fast_effect.position = Vector2(0,-50)
		add_child(cooling_fast_effect)
	pass
