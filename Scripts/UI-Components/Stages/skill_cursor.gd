extends AnimatedSprite2D

@onready var skill_texture: Sprite2D = $SkillTexture


func _ready() -> void:
	if OS.get_name() == "Android":
		set_process(false)
		return
	Stage.instance.ui_update.connect(ui_process)
	pass


func _process(delta: float) -> void:
	position = get_global_mouse_position()
	pass


func ui_process(member: Node):
	visible = Stage.instance.stage_ui == Stage.StageUI.SkillPreparation
	if member is SkillButton:
		skill_texture.texture = member.texture_normal
	pass
