extends Button
class_name HeroSkillButton

const BALL_ABLED = preload("res://Assets/Images/UI/HeroHall/经验球.png")
const BALL_DISABLED = preload("res://Assets/Images/UI/HeroHall/经验球disabled.png")


@export var skill_id: int = 1

@export var hero_skill_textures: Array[Texture]

@export var hero_skill_textures_disabled: Array[Texture]

@onready var skill_texture: Sprite2D = $SkillTexture
@onready var price_bar: Button = $PriceBar
@onready var price_ball: TextureRect = $PriceBar/PriceBall
@onready var price_label: Label = $PriceBar/PriceLabel
@onready var level_1: Sprite2D = $Level1
@onready var level_2: Sprite2D = $Level2
@onready var level_3: Sprite2D = $Level3
@onready var click_audio: AudioStreamPlayer = $ClickAudio

var skill_level: int
var skill_show_texture: Texture
var skill_disabled_texture: Texture
var skill_price: int


func _ready() -> void:
	HeroHall.instance.update_hero.connect(update_hero)
	HeroHall.instance.update_hero_skills.connect(update_hero_skill)
	mouse_entered.connect(mouse_enter)
	mouse_exited.connect(mouse_out)
	pass


func update_hero(hero_id: int):
	skill_show_texture = hero_skill_textures[hero_id]
	skill_disabled_texture = hero_skill_textures_disabled[hero_id]
	update_hero_skill()
	pass


func mouse_enter():
	if OS.get_name() == "Android":
		await get_tree().process_frame
		await get_tree().process_frame
		HeroHall.instance.skill_intro_panel.set_process(false)
	var show_level: int
	match skill_level:
		0: show_level = 1
		1: show_level = 2
		2,3: show_level = 3
	HeroHall.instance.show_panel(skill_id,show_level)
	HeroSkillMobileIntroPanel.instance.show_skill_information(self)
	pass


func mouse_out():
	HeroHall.instance.hide_panel()
	if MobileMiddleProcess.instance.current_touch_object == self:
		MobileMiddleProcess.instance.current_touch_object = null
	if OS.get_name() == "Android":
		await get_tree().process_frame
		HeroHall.instance.skill_intro_panel.set_process(true)
	HeroSkillMobileIntroPanel.instance.hide()
	pass


func _process(delta: float) -> void:
	skill_texture.modulate = Color.WHITE * 1.5 if get_draw_mode() == DrawMode.DRAW_HOVER else Color.WHITE
	pass


func update_hero_skill():
	skill_level = HeroHall.instance.skill_levels[skill_id-1]
	level_1.visible = skill_level >= 1
	level_2.visible = skill_level >= 2
	level_3.visible = skill_level >= 3
	price_bar.visible = skill_level < 3
	skill_texture.texture = skill_show_texture
	if skill_level < 3:
		skill_price = HeroSkillLibrary.hero_skill_price_library[HeroHall.instance.current_check][skill_id-1][skill_level]
		price_label.text = str(skill_price)
		
		disabled = HeroHall.instance.current_skill_points < skill_price
		skill_texture.texture = skill_disabled_texture if disabled else skill_show_texture
		price_ball.texture = BALL_DISABLED if disabled else BALL_ABLED
		price_label.modulate = Color.WHITE if disabled else Color.YELLOW
	pass


func _pressed() -> void:
	if OS.get_name() == "Android":
		if MobileMiddleProcess.instance.current_touch_object != self:
			MobileMiddleProcess.instance.current_touch_object = self
			return
	
	if skill_level < 3:
		var sav_block: HeroSavBlock = Map.instance.current_sav.hero_sav[HeroHall.instance.current_check]
		sav_block.skill_levels[skill_id-1] += 1
		sav_block.current_skill_point -= skill_price
		HeroHall.instance.current_skill_points = sav_block.current_skill_point
		Global.sav_game_sav(Map.instance.current_sav)
		HeroHall.instance.update_hero_skills.emit()
		click_audio.play()
		mouse_enter()
	pass
