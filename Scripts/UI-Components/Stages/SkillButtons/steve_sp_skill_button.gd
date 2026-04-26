extends SkillButton

enum SteveSkillType{
	Front,
	Back
}

@export_group("FrontSkill","front_skill")
@export var front_skill_name: String
@export_multiline var front_skill_intro: String
@export var front_skill_normal_texture: Texture
@export var front_skill_select_texture: Texture
@export var front_skill_area_scene: PackedScene

@export_group("BackSkill","back_skill")
@export var back_skill_name: String
@export_multiline var back_skill_intro: String
@export var back_skill_normal_texture: Texture
@export var back_skill_select_texture: Texture
@export var back_skill_area_scene: PackedScene

var skill_level: int
var steve_skill_type: SteveSkillType = SteveSkillType.Front


func _ready() -> void:
	super()
	skill_level = Stage.instance.stage_sav.hero_sav[11].skill_levels[4]
	
	pass


func skill_unlease():
	super()
	if steve_skill_type == SteveSkillType.Front:
		front_skill_release()
	else:
		back_skill_release()
	animation_player.play_backwards("unlock")
	await animation_player.animation_finished
	steve_skill_type = SteveSkillType.Back if steve_skill_type == SteveSkillType.Front else SteveSkillType.Front
	change_steve_skill_type(steve_skill_type)
	animation_player.play("unlock")
	pass


func front_skill_release():
	var summon_pos: Vector2 = Stage.instance.get_local_mouse_position()
	var front_skill_area: SkillConditionArea2D = front_skill_area_scene.instantiate()
	front_skill_area.skill_level = skill_level
	front_skill_area.position = summon_pos
	Stage.instance.bullets.add_child(front_skill_area)
	pass


func back_skill_release():
	var summon_pos: Vector2 = Stage.instance.get_local_mouse_position()
	var back_skill_area: SkillConditionArea2D = back_skill_area_scene.instantiate()
	back_skill_area.position = summon_pos
	back_skill_area.skill_level = skill_level
	Stage.instance.bullets.add_child(back_skill_area)
	pass


func change_steve_skill_type(new_type: SteveSkillType):
	if new_type == SteveSkillType.Front:
		skill_name = front_skill_name
		skill_intro = front_skill_intro
		texture_normal = front_skill_normal_texture
		texture_select = front_skill_select_texture
	else:
		skill_name = back_skill_name
		skill_intro = back_skill_intro
		texture_normal = back_skill_normal_texture
		texture_select = back_skill_select_texture
	normal_texture.texture = texture_normal
	hover_texture.texture = texture_select
	pass


func skill_unlease_condition():
	if Stage.instance.mouse_in_path:
		if steve_skill_type == SteveSkillType.Front:
			if !Stage.instance.mouse_in_fire_stop_area: skill_unlease()
		else:
			skill_unlease()
	pass
